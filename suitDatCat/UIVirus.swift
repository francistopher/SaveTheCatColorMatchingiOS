//
//  virus.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/11/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

enum Virus{
    case corona
    case ebolaSquare
    case bacteriophage
    case ebolaRectangle
}

class UIVirus:UIButton {
    
    var originalFrame:CGRect? = nil;
    var targetCat:UICatButton? = nil;
    var selectedVirus:Virus = .ebolaSquare;
    var playerHits:Int = 0;
    var hasBeenDispersed:Bool = false;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView, spawnFrame: CGRect, targetFrame:CGRect, virus:Virus, targetCat:UICatButton) {
        super.init(frame: spawnFrame);
        backgroundColor = .clear;
        self.frame = spawnFrame;
        setVirusImage(virus:virus);
        self.targetCat = targetCat;
        transitionToTargetFrame(targetFrame: targetFrame);
        self.addTarget(self, action: #selector(playerTap), for: .touchUpInside);
        parentView.addSubview(self);
    }
    
    @objc func playerTap() {
        playerHits += 1;
        switch(self.selectedVirus, playerHits) {
        case (.corona, 5):
            disperseRadially();
        case (.ebolaSquare, 4):
            disperseRadially();
        case (.ebolaRectangle, 4):
            disperseRadially();
        case (.bacteriophage, 3):
            disperseRadially();
        case (_, _):
            print("Do Something");
        }
    }
    
    func transitionToTargetFrame(targetFrame:CGRect) {
        UIView.animate(withDuration: 1.0, delay: 0.125, options: [.curveEaseInOut], animations: {
            self.frame = targetFrame;
        }, completion: { _ in
            self.startAction();
        });
    }
    
    func startAction() {
        expandAndContract();
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            if (!self.hasBeenDispersed) {
                switch (self.selectedVirus) {
                    case .bacteriophage:
                        self.absorbColor();
                    case .ebolaSquare:
                        self.removeBorder();
                    case .ebolaRectangle:
                        self.removeBorder();
                    case.corona:
                        if (!self.targetCat!.isPodded) {
                            self.targetCat!.isAlive = false;
                            self.targetCat!.kittenDie();
                            if (self.targetCat != nil) {
                                self.targetCat!.disperseRadially();
                            }
                        }
                }
            }
        });
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
            self.targetCat!.isTargeted = false;
            self.disperseRadially();
        });
    }
    
    func absorbColor() {
        self.targetCat!.imageContainerButton!.fadeBackgroundIn(color: UIColor.lightGray);
        self.targetCat!.fadeBackgroundIn(color: UIColor.lightGray);
    }
    
    func removeBorder() {
        self.targetCat!.layer.borderWidth = 0.0;
        self.targetCat!.imageContainerButton!.layer.borderWidth = 0.0;
    }
    
    func disperseRadially() {
        if (hasBeenDispersed) {
            return;
        }
        let angle:CGFloat = CGFloat(Int.random(in: 0...360));
        let targetPointX:CGFloat = getRadialXTargetPoint(parentFrame: self.superview!.frame, childFrame: self.frame, angle: angle);
        let targetPointY:CGFloat = getRadialYTargetPoint(parentFrame: self.superview!.frame, childFrame: self.frame, angle: angle);
        UIView.animate(withDuration: 1.5, delay: 0.125, options: .curveEaseIn, animations: {
            self.transform = self.transform.rotated(by: CGFloat.pi);
            let newFrame:CGRect = CGRect(x: targetPointX, y:targetPointY, width: self.frame.width, height: self.frame.height);
            self.frame = newFrame;
        }, completion: { _ in
            self.removeFromSuperview();
        });
        hasBeenDispersed = true;
    }
    
    func getRadialXTargetPoint(parentFrame:CGRect, childFrame:CGRect, angle:CGFloat) -> CGFloat {
        var targetX:CGFloat = childFrame.minX;
        targetX += parentFrame.width + childFrame.width;
        targetX *= cos((CGFloat.pi * angle) / 180.0);
        return targetX;
    }
    
    
    func getRadialYTargetPoint(parentFrame:CGRect, childFrame:CGRect, angle:CGFloat) -> CGFloat {
        var targetY:CGFloat = childFrame.minY;
        targetY += parentFrame.height + childFrame.height;
        targetY *= sin((CGFloat.pi * angle) / 180.0);
        return targetY;
    }
    
    func expandAndContract() {
        UIView.animate(withDuration: 1.0, delay: 0.125, options: [.curveEaseInOut, .autoreverse, .repeat], animations: {
            self.imageView!.transform = self.imageView!.transform.scaledBy(x: 1.25, y: 1.25);
        })
    }
    
    func setVirusImage(virus:Virus) {
        selectedVirus = virus;
        let virusFileName:String = getVirusFileName(virus:virus);
        let iconImage:UIImage? = UIImage(named: virusFileName);
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func getVirusFileName(virus:Virus) -> String {
        switch (virus) {
        case .corona:
            return "corona.png";
        case .ebolaSquare:
            if (self.frame.width > self.frame.height) {
                return "ebolaRectangle.png";
            } else {
                return "ebolaSquare.png";
            }
        case .bacteriophage:
            return "bacteriophage.png";
        case .ebolaRectangle:
            return "ebolaRectangle.png";
        }
    }
    
    func sway(){
        var xTranslation:CGFloat = self.originalFrame!.width / 7.5;
        var yTranslation:CGFloat = self.originalFrame!.height / 7.5;
        if (Int.random(in: 0...1) == 1) {
            xTranslation *= -1;
        }
        if (Int.random(in: 0...1) == 1) {
            yTranslation *= -1;
        }
        UIView.animate(withDuration: 1.75, delay: 0.125, options:[.curveEaseInOut, .repeat, .autoreverse], animations: {
            self.imageView!.transform = self.imageView!.transform.translatedBy(x: xTranslation, y: yTranslation);
        });
    }
    
    func fadeIn() {
        UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseIn, animations: {
            self.alpha = 1.0;
        });
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseIn, animations: {
            self.alpha = 0.0;
        });
    }
    
    func translateToCatsAndBack() {
        UIView.animate(withDuration: 0.25, delay:0.0, options: [.curveEaseInOut], animations: {
            let xDistance:CGFloat = self.superview!.center.x - self.frame.midX;
            let yDistance:CGFloat = self.superview!.center.y - self.frame.midY;
            self.transform = self.transform.translatedBy(x: xDistance, y: yDistance);
        }, completion: { _ in
            UIView.animate(withDuration: 1.5, delay:0.125, options: [.curveEaseInOut], animations: {
                self.frame = self.originalFrame!;
            })
            self.sway();
        })
    }
}
