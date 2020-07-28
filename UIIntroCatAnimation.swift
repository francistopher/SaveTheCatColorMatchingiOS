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
    
    /*
        Create timer to rotate
        the text continouslly
     */
    func setupIntroTextRotationTimer() {
        introTextRotationTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
            self.introTextView!.transform = self.introTextView!.transform.rotated(by: CGFloat.pi * 0.005);
        })
    }
    
    /*
        Creates the radial text
     */
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

    /*
        Makes the intro cat animation
        opaque over time
     */
    func setupFadeInAnimation() {
        fadeInAnimation = UIViewPropertyAnimator(duration: 2.0, curve: .easeIn, animations: {
            self.alpha = 1.0;
        })
    }

    /*
        Timer that fades and plays
        the meow sound
     */
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

    /*
        Animation that makes the intro cat
        animation transparent
     */
    func setupFadeOutAnimation() {
        fadeOutAnimation = UIViewPropertyAnimator(duration: 2.0, curve: .easeOut, animations: {
            self.alpha = 0.0;
        })
        fadeOutAnimation!.addCompletion({ _ in
            self.introTextRotationTimer!.invalidate();
        })
    }

    /*
        Updates the appearance of the intro cat
        animation based on the theme of the OS
     */
    func setCompiledStyle() {
        if (ViewController.uiStyleRawValue == 1) {
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

