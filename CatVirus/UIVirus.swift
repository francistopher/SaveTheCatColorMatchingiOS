//
//  virus.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/11/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI


enum Virus{
    case standard
}

class UIVirus:UIButton {
    
     var originalFrame:CGRect? = nil;
        var selectedVirus:Virus = .standard;
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView, frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = .clear;
        self.originalFrame = frame;
        self.setVirusImage();
//        self.addTarget(self, action: #selector(virusAudio), for: .touchUpInside);
        parentView.addSubview(self);
    }
    
    
    func hide() {
        alpha = 0.0;
    }
    
    func setVirusImage() {
        let iconImage:UIImage? = UIImage(named: getVirusFileName());
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func getVirusFileName() -> String {
        switch (selectedVirus) {
        case Virus.standard:
            if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
                 return "lightVirus.png";
            } else {
                 return "darkVirus.png";
            }
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
    
    func translateToAndBackAt(xTarget:CGFloat, yTarget:CGFloat) {
        UIView.animate(withDuration: 0.25, delay:0.0, options: [.curveEaseInOut], animations: {
            let xDistance:CGFloat = xTarget - self.frame.midX;
            let yDistance:CGFloat = yTarget - self.frame.midY;
            self.transform = self.transform.translatedBy(x: xDistance, y: yDistance);
        }, completion: { _ in
            UIView.animate(withDuration: 1.0, delay:0.125, options: [.curveEaseInOut], animations: {
                self.frame = self.originalFrame!;
            })
            self.sway();
        })
    }
}
