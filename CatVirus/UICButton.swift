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
    
    var originalFrame:CGRect? = nil;
    var shrunkFrame:CGRect? = nil;
    var originalBackgroundColor:UIColor? = nil;
    var shrinkType:shrink = .mid;
    var parentView:UIView? = nil;
    var willBeShrunk:Bool = false;
    
    var inverted:Bool = false;
    enum shrink {
        case left
        case mid
        case right
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    init(parentView: UIView, frame:CGRect, backgroundColor:UIColor) {
        super.init(frame:frame);
        self.parentView = parentView;
        originalFrame = frame;
        originalBackgroundColor = backgroundColor;
        self.backgroundColor = backgroundColor;
        configureShrunkFrame();
        parentView.addSubview(self);
        self.layer.cornerRadius = self.frame.height / 5.0;
        self.layer.borderWidth = (sqrt(self.frame.width * 0.01) * 10.0) * 0.35;
        self.isSelected = false;
        self.setStyle();
    }
    
    func translate(newOriginalFrame:CGRect) {
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseInOut, animations: {
            self.frame = newOriginalFrame;
            self.originalFrame! = newOriginalFrame;
            self.configureShrunkFrame();
        });
    }
    
    func configureShrunkFrame() {
        shrunkFrame = CGRect(x: originalFrame!.midX, y: originalFrame!.minY, width: 0.0, height: originalFrame!.height);
    }
    
    func grow(){
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseInOut, animations: {
            self.frame = CGRect(x: self.originalFrame!.minX, y:self.originalFrame!.minY, width: self.originalFrame!.width, height: self.originalFrame!.height);
        });
    }
    
    func fadeBackgroundIn(color:UIColor){
        UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseIn, animations: {
            self.backgroundColor = color;
        });
    }
    
    func shrink() {
        willBeShrunk = true;
        var x:CGFloat = 0.0;
        var duration:Double = 0;
        switch(self.shrinkType) {
        case .left:
            x = 0.0;
            duration = 0.75;
        case .mid:
            x = self.originalFrame!.midX;
            duration = 0.50;
        case .right:
            duration = 0.75;
            x = self.parentView!.frame.width;
        }
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn, animations: {
            self.frame = CGRect(x: x, y: self.frame.minY, width: 0.0, height: self.frame.height);
        }, completion: { _ in
            self.removeFromSuperview();
        });
    }
    
    func hide(){
        self.alpha = 0.0;
    }
    
    func show() {
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseIn, animations: {
            self.alpha = 1.0;
       });
    }
    
    func fadeBackgroundIn(){
        UIView.animate(withDuration: 0.5, delay: 125, options: .curveEaseIn, animations: {
            self.backgroundColor = self.originalBackgroundColor!;
        });
    }
    
    func shrinked(){
        self.frame = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0);
    }
    
    func select(){
        if (!self.isSelected) {
            self.superview!.bringSubviewToFront(self);
            UIView.animate(withDuration: 0.5, delay: 0.125, options:[.curveEaseInOut], animations: {
                self.transform = self.transform.scaledBy(x: 1.0, y: 1.375);
            });
            self.isSelected = true;
        }
    }
    
    func unSelect(){
        if (self.isSelected) {
            UIView.animate(withDuration: 0.5, delay: 0.125, options:[.curveEaseInOut], animations: {
                self.transform = self.transform.scaledBy(x: 1.0, y: 0.75);
            });
            self.isSelected = false;
        }
    }
    
    func setStyle() {
        if (inverted) {
            if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
                self.layer.borderColor = UIColor.white.cgColor;
            } else {
                self.layer.borderColor = UIColor.black.cgColor;
            }
        } else {
            if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
                self.layer.borderColor = UIColor.black.cgColor;
            } else {
                self.layer.borderColor = UIColor.white.cgColor;
            }
        }
        
    }
}

