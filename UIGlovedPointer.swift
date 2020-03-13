//
//  UIGlovePointer.swift
//  SaveTheCat
//
//  Created by Christopher Francisco on 3/11/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI
import Foundation

class UIGlovedPointer:UICButton {
    
    var darkImage = UIImage(named: "darkGlovePointer.png");
    var lightImage = UIImage(named: "lightGlovePointer.png");
    var darkTapImage = UIImage(named: "darkGloveTap.png");
    var lightTapImage = UIImage(named: "lightGloveTap.png");

    var xTranslation:CGFloat = 0.0;
    var yTranslation:CGFloat = 0.0;
    
    var isTapping:Bool = true;
    var doShrink:Bool = true;
    var translateToTapAnimation:UIViewPropertyAnimator?
    var translateFromTapAnimation:UIViewPropertyAnimator?
    
    var transitionedToCatButton:Bool = false;
    
    var adButton:UICButton?
    
    var colorButton:UICButton?
    var catButton:UICatButton?
    
    var colorButtons:[UICButton]?
    var catButtons:UICatButtons?
    
    var hiddenForever:Bool = false;
    
    init(parentView:UIView, frame:CGRect) {
        super.init(parentView: parentView, frame: frame, backgroundColor: UIColor.clear);
        xTranslation = self.originalFrame!.width / 3.5;
        yTranslation = self.originalFrame!.height / 3.5;
        self.layer.borderWidth = 0.0;
        addTarget(self, action: #selector(selfSelector), for: .touchUpInside);
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColorAndCatButtons(colorButtons:[UICButton], catButtons:UICatButtons, first:Bool) {
        if (first) {
            self.colorButton = colorButtons[0];
        } else {
            self.colorButton = colorButtons[1];
        }
        self.catButton = catButtons.getCatButtonWith(backgroundColor: colorButton!.originalBackgroundColor!);
        self.colorButton!.addTarget(self, action: #selector(translateGloveToCatButtonCenter), for: .touchUpInside);
        resetPositionToFrontOfColorButton();
    }
    
    func resetPositionToFrontOfColorButton() {
        self.transitionedToCatButton = false;
        let x:CGFloat = self.colorButton!.superview!.frame.minX - (self.frame.width * 0.1);
        let y:CGFloat = self.colorButton!.superview!.frame.minY + self.colorButton!.frame.height * 0.2;
        let newframe:CGRect = CGRect(x: x, y: y, width: self.originalFrame!.width, height: self.originalFrame!.height);
        translate(newOriginalFrame: newframe);
        self.originalFrame! = newframe;
        if (doShrink) {
            self.shrinked();
        }
    }
    
    @objc func translateGloveToCatButtonCenter() {
        self.transitionedToCatButton = true;
        let newFrame:CGRect = CGRect(x: self.catButton!.superview!.frame.minX + self.catButton!.frame.midX - (self.frame.width * 0.75), y: self.catButton!.superview!.frame.minY + self.catButton!.frame.midY - (self.frame.height * 0.25), width: self.frame.width, height: self.frame.height)
        self.stopAnimations();
        self.translate(newOriginalFrame: newFrame);
        self.alpha = 1.0;
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            self.sway();
        })
        
    }
    
    @objc func selfSelector() {
        if (adButton != nil) {
            adButton?.sendActions(for: .touchUpInside);
            return;
        }
        if (transitionedToCatButton) {
            catButton?.sendActions(for: .touchUpInside);
        } else {
            colorButton?.sendActions(for: .touchUpInside);
        }
    }
    
    func setCompiledStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            if (isTapping) {
                self.setImage(lightTapImage!, for: .normal);
            } else {
                self.setImage(lightImage!, for: .normal);
            }
            self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
        } else {
            if (isTapping) {
                self.setImage(darkTapImage!, for: .normal);
            } else {
                self.setImage(darkImage!, for: .normal);
            }
            self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
        }
    }
    
    func reset() {
        stopAnimations();
        self.frame = self.originalFrame!;
        self.transitionedToCatButton = false;
        self.alpha = 0.0;
    }
    
    func stopAnimations() {
        translateToTapAnimation?.stopAnimation(true);
        translateFromTapAnimation?.stopAnimation(true);
        self.layer.removeAllAnimations();
        self.transform = .identity;
    }
    
    func shrink() {
        self.superview!.bringSubviewToFront(self);
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseInOut, animations: {
            self.frame = self.shrunkFrame!;
        });
    }
    
    override func grow() {
        self.alpha = 1.0;
        self.superview!.bringSubviewToFront(self);
        self.isTapping = false;
        self.setCompiledStyle();
        UIView.animate(withDuration: 0.25, delay: 0.75, options: .curveEaseInOut, animations: {
            self.frame = self.originalFrame!;
        }, completion: { _ in
            self.sway();
        });
    }
    
    func setupTranslateFromTapAnimation() {
        translateFromTapAnimation = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: {
            self.frame = CGRect(x: self.frame.minX - self.xTranslation, y: self.frame.minY - self.yTranslation, width: self.frame.width, height: self.frame.height);
        })
        translateFromTapAnimation!.addCompletion({ _ in
            self.setupTranslateToTapAnimation();
            self.translateToTapAnimation!.startAnimation();
        })
    }
    
    func setupTranslateToTapAnimation() {
        translateToTapAnimation = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: {
            self.frame = CGRect(x: self.frame.minX + self.xTranslation, y: self.frame.minY + self.yTranslation, width: self.frame.width, height: self.frame.height);
        })
        translateToTapAnimation!.addCompletion({ _ in
            self.isTapping = true;
            self.setCompiledStyle();
            self.sway();
        })
    }
    
    func sway() {
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: { _ in
            self.isTapping = false;
            self.setCompiledStyle();
        })
        setupTranslateFromTapAnimation();
        translateFromTapAnimation!.startAnimation(afterDelay: 0.125);
    }
    
    override func translate(newOriginalFrame:CGRect) {
        setCompiledStyle();
        transitionedToCatButton = true;
        stopAnimations();
        UIView.animate(withDuration: 0.5, delay: 0.125, options: .curveEaseInOut, animations: {
            self.isTapping = true;
            self.frame = newOriginalFrame;
            self.configureShrunkFrame();
        });
    }
    
}
