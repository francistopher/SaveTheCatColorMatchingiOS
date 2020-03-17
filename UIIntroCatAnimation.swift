//
//  UIIntroCatAnimation.swift
//  SaveTheCat
//
//  Created by Christopher Francisco on 3/17/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import UIKit


class UIIntroCatAnimation:UICButton {
    
    let darkCatImage:UIImage = UIImage(named: "darkCatIntro")!;
    let lightCatImage:UIImage = UIImage(named: "lightCatIntro")!;
    var fadeInAnimation:UIViewPropertyAnimator?
    var fadeOutAnimation:UIViewPropertyAnimator?
    var waitForFadeInTimer:Timer?
    
   init(parentView:UIView, frame:CGRect) {
        super.init(parentView: parentView, frame: frame, backgroundColor: UIColor.clear);
        self.alpha = 0.0;
        setCompiledStyle();
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupFadeInAnimation() {
        fadeInAnimation = UIViewPropertyAnimator(duration: 2.0, curve: .easeIn, animations: {
            self.alpha = 1.0;
        })
    }
    
    func setupWaitForFadeInTimer() {
        waitForFadeInTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
            if (self.alpha == 1.0) {
                SoundController.kittenMeow();
                self.setupFadeOutAnimation();
                self.fadeOutAnimation!.startAnimation();
                self.waitForFadeInTimer!.invalidate();
            }
        })
    }
    
    func setupFadeOutAnimation() {
        fadeOutAnimation = UIViewPropertyAnimator(duration: 2.0, curve: .easeOut, animations: {
            self.alpha = 0.0;
        })
    }
    
    func setCompiledStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            self.setImage(darkCatImage, for: .normal);
        } else {
            self.setImage(lightCatImage, for: .normal);
        }
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func fadeIn() {
        setupFadeInAnimation();
        fadeInAnimation!.startAnimation();
    }
    
    func fadeOut() {
        setupWaitForFadeInTimer();
    }
    
}

