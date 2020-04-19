//
//  enemy.swift
//  SaveTheCat
//
//  Created by Christopher Francisco on 2/11/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI


enum Enemy{
    case hairball
}

class UIEnemy:UIButton {
    
    var originalFrame:CGRect?
    var selectedEnemy:Enemy = .hairball;
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView, frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = .clear;
        self.originalFrame = frame;
        self.setupEnemyImage();
        parentView.addSubview(self);
    }
    
    
    func hide() {
        alpha = 0.0;
    }
    
    var iconImage:UIImage?
    func setupEnemyImage() {
        iconImage = nil;
        iconImage = UIImage(named: getEnemyFileName());
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func getEnemyFileName() -> String {
        switch (selectedEnemy) {
        case .hairball:
            if (ViewController.uiStyleRawValue == 1) {
                 return "lightHairBall.png";
            } else {
                 return "darkHairBall.png";
            }
        }
    
    }
    
    func sway(immediately:Bool){
        var xTranslation:CGFloat = self.originalFrame!.width / 7.5;
        var yTranslation:CGFloat = self.originalFrame!.height / 7.5;
        if (Int.random(in: 0...1) == 1) {
            xTranslation *= -1;
        }
        if (Int.random(in: 0...1) == 1) {
            yTranslation *= -1;
        }
        var delay:Double = 0.125;
        if (immediately) {
            delay = 0.0;
        }
        UIView.animate(withDuration: 1.75, delay: delay, options:[.curveEaseInOut, .repeat, .autoreverse], animations: {
            self.imageView!.transform = self.imageView!.transform.translatedBy(x: xTranslation, y: yTranslation);
        });
        if (immediately) {
            fadeIn();
        }
    }

    func fadeIn() {
        UIView.animate(withDuration: 0.5, delay: 0.125, options: .curveEaseIn, animations: {
            self.alpha = 1.0;
        });
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 0.5, delay: 0.125, options: .curveEaseIn, animations: {
            self.alpha = 0.0;
        });
    }
    
    func translateToAndBackAt(xTarget:CGFloat, yTarget:CGFloat) {
        UIView.animate(withDuration: 0.25, delay:0.0, options: [.curveEaseInOut], animations: {
            self.transform = self.transform.translatedBy(x: xTarget - self.frame.midX, y: yTarget - self.frame.midY);
        }, completion: { _ in
            UIView.animate(withDuration: 1.0, delay:0.125, options: [.curveEaseInOut], animations: {
                self.frame = self.originalFrame!;
            })
            self.sway(immediately: false);
        })
    }
}
