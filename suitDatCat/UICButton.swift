//
//  UICButton.swift
//  suitDatCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI
import UIKit

class UICButton:UIButton {
    
    var originalX:CGFloat = 0.0;
    var originalY:CGFloat = 0.0;
    var originalWidth:CGFloat = 0.0;
    var originalHeight:CGFloat = 0.0;
    
    var shrunkX:CGFloat = 0.0;
    var shrunkY:CGFloat = 0.0;
    var shrunkWidth:CGFloat = 0.0;
    var shrunkHeight:CGFloat = 0.0;
    
    var originalFrame:CGRect? = nil;
    var shrunkFrame:CGRect? = nil;
    var originalBackgroundColor:UIColor? = nil;
    
    var selectColor:UIColor? = nil;
    var animationStage:Int = 0;
    var previousNamed:String = "";
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    init(parentView: UIView, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat, backgroundColor:UIColor) {
        super.init(frame:CGRect(x: x, y: y, width: width, height: height));
        originalX = x;
        originalY = y;
        originalWidth = width;
        originalHeight = height;
        originalFrame = CGRect(x: x, y: y, width: width, height: height);
        originalBackgroundColor = backgroundColor;
        self.backgroundColor = backgroundColor;
        self.layer.cornerRadius = height / 5.0;
        parentView.addSubview(self);
        self.isSelected = false;
    }
    
    func grow(){
        UIView.animate(withDuration: 1.0, delay: 0.25, options: .curveEaseInOut, animations: {
            self.frame = CGRect(x: self.originalX, y:self.originalY, width: self.originalWidth, height: self.originalHeight);
        });
    }
    
    func shrink(){
        self.layer.removeAllAnimations();
        UIView.animate(withDuration: 1.0, delay: 0.25, options: .curveEaseIn, animations: {
            self.frame = CGRect(x: self.shrunkX, y: self.shrunkY, width: 0.0, height: 0.0);
        });
    }
    
    func hide(color:UIColor){
        UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseIn, animations: {
            self.backgroundColor = color;
        });
    }
    
    func show(){
        UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseIn, animations: {
        self.backgroundColor = self.originalBackgroundColor!;
        });
    }
    
    func grownAndShrunk(){
        originalX = self.frame.minX;
        originalY = self.frame.minY;
        shrunkX = self.frame.minX + (originalWidth / 2.0);
        shrunkY = self.frame.minY + (originalHeight / 2.0);
    }
    
    func shrinked(){
        self.frame = CGRect(x: self.shrunkX, y: self.shrunkY, width: 0.0, height: 0.0);
    }
    
    func select(){
        if (!self.isSelected) {
            self.superview!.bringSubviewToFront(self);
            UIView.animate(withDuration: 1.0, delay: 0.125, options:[.curveEaseInOut], animations: {
                self.transform = self.transform.scaledBy(x: 1.375, y: 1.375);
            });
            self.isSelected = true;
        }
    }
    
    func unSelect(){
        if (self.isSelected) {
            UIView.animate(withDuration: 1.0, delay: 0.125, options:[.curveEaseInOut], animations: {
                self.transform = self.transform.scaledBy(x: 0.75, y: 0.75);
            });
            self.isSelected = false;
        }
    }
    
    func setCat(named:String, stage:Int){
        // Save the new color
        if (named != "") {
            previousNamed = named;
        }
        // Build cat color string
        var namedCatImage:String = "";
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            namedCatImage += "dark" + previousNamed;
        } else{
            namedCatImage += "light" + previousNamed;
        }
        // Clear button background if cat dies
        if (stage == 2) {
            self.backgroundColor = UIColor.clear;
        }
        if (stage != 4 || stage != 5) {
            animationStage = stage;
        }
        let iconImage:UIImage? = UIImage(named: namedCatImage);
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
        if (animationStage == 0){
            self.imageView!.alpha = 0.0;
        }
        var dispatchTime:DispatchTime? = nil ;
        if (stage == 4){
            self.imageView!.layer.removeAllAnimations();
            dispatchTime = .now();
            self.animationStage = 0;
        } else if (stage == 1 || stage == 0){
            dispatchTime = .now() + 1.0;
        } else {
            dispatchTime = .now();
        }
        DispatchQueue.main.asyncAfter(deadline: dispatchTime!) {
            UIView.animate(withDuration: 1.0, delay:0.0, options:[.curveEaseInOut], animations: {
                self.imageView!.alpha = 1.0;
            });
            if (self.animationStage == 0){
                self.setRandomCatAnimation();
            }
        }
    }
    
    func setVirus() {
        let iconImage:UIImage? = UIImage(named: "virus.png");
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
        setCurrentVirusAnimation();
    }
    
    func setCurrentVirusAnimation(){
        UIView.animate(withDuration: 1.75, delay: 0.125, options:[.curveEaseInOut, .repeat, .autoreverse], animations: {
            var xTranslation:CGFloat = self.frame.width / 8.0;
            var yTranslation:CGFloat = self.frame.height / 8.0;
            if (Int.random(in: 0...1) == 1) {
                xTranslation *= -1;
            }
            if (Int.random(in: 0...1) == 1) {
                yTranslation *= -1;
            }
            self.imageView!.transform = self.imageView!.transform.translatedBy(x: xTranslation, y: yTranslation);
        });
    }
    
    func setRandomCatAnimation() {
        let randomAnimationSelection:Int = Int.random(in: 0...3);
        if (randomAnimationSelection > 2){
            self.imageView!.transform = self.imageView!.transform.rotated(by:-CGFloat.pi / 2.0);
            UIView.animate(withDuration: 1.75, delay: 0.125, options:[.curveEaseInOut, .repeat, .autoreverse], animations: {
                self.imageView!.transform = self.imageView!.transform.rotated(by:-CGFloat.pi);
            });
        } else if (randomAnimationSelection > 1) {
            self.imageView!.transform = self.imageView!.transform.rotated(by:CGFloat.pi / 2.0);
            UIView.animate(withDuration: 1.75, delay: 0.125, options:[.curveEaseInOut, .repeat, .autoreverse], animations: {
                self.imageView!.transform = self.imageView!.transform.rotated(by:-CGFloat.pi);
            });
        } else if (randomAnimationSelection > 0) {
            UIView.animate(withDuration: 1.75, delay: 0.125, options:[.curveEaseInOut, .repeat, .autoreverse], animations: {
                self.imageView!.transform = self.imageView!.transform.rotated(by:-CGFloat.pi);
            });
        } else {
            self.imageView!.transform = self.imageView!.transform.rotated(by:-CGFloat.pi / 2.0);
            UIView.animate(withDuration: 1.75, delay: 0.125, options:[.curveEaseInOut, .repeat, .autoreverse], animations: {
                self.imageView!.transform = self.imageView!.transform.rotated(by:CGFloat.pi);
            });
        }
    }
    
    
}

