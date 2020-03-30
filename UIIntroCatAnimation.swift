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
    
    let darkCatImage:UIImage = UIImage(named: "darkCat.png")!;
    let lightCatImage:UIImage = UIImage(named: "lightCat.png")!;
    
    let darkIntroText:UIImage = UIImage(named: "darkIntroText.png")!;
    let lightIntroText:UIImage = UIImage(named: "lightIntroText.png")!;
    var introTextView:UIImageView?
    
    var fadeInAnimation:UIViewPropertyAnimator?
    var fadeOutAnimation:UIViewPropertyAnimator?
    var waitForFadeInTimer:Timer?
    var introTextRotationTimer:Timer?
    
    init(parentView:UIView, frame:CGRect) {
        super.init(parentView: parentView, frame: frame, backgroundColor: UIColor.clear);
        self.alpha = 0.0;
        setIntroTextImage();
        setCompiledStyle();
        setupIntroTextRotationTimer();
    }
    
    func setupIntroTextRotationTimer() {
        introTextRotationTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
            self.introTextView!.transform = self.introTextView!.transform.rotated(by: CGFloat.pi * 0.005);
        })
    }
    
    func setIntroTextImage() {
        introTextView = UIImageView(frame: frame);
        introTextView!.transform = introTextView!.transform.translatedBy(x: 0.0, y: introTextView!.frame.height * 0.015);
        introTextView!.backgroundColor = UIColor.clear;
        introTextView!.contentMode = UIView.ContentMode.scaleAspectFit;
        addSubview(introTextView!);
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
        fadeOutAnimation!.addCompletion({ _ in
            self.introTextRotationTimer!.invalidate();
        })
    }

    func setCompiledStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            self.setImage(darkCatImage, for: .normal);
            introTextView!.image = darkIntroText;
        } else {
            self.setImage(lightCatImage, for: .normal);
            introTextView!.image = lightIntroText;
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

