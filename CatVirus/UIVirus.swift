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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView, spawnFrame: CGRect, targetFrame:CGRect, virus:Virus, targetCat:UICatButton) {
        super.init(frame: spawnFrame);
        backgroundColor = .clear;
        self.frame = spawnFrame;
        setVirusImage(virus:virus);
        parentView.addSubview(self);
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
    
    
//     func expandAndContract() {
//    UIView.animate(withDuration: 1.0, delay: 0.125, options: [.curveEaseInOut, .autoreverse, .repeat], animations: {
//        self.imageView!.transform = self.imageView!.transform.scaledBy(x: 1.25, y: 1.25);
//    })
//}
    
    func setVirusImage(virus:Virus) {
        let iconImage:UIImage? = UIImage(named: "corona.png");
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
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
    
//   func fadeOut() {
//       UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseIn, animations: {
//           self.alpha = 0.0;
//        });
//    }
    
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
