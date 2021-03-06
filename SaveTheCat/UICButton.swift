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
    
    // Sizes and positions
    var originalFrame:CGRect?
    var secondaryFrame:CGRect?
    var shrunkFrame:CGRect?
    
    var originalBackgroundColor:UIColor?
    
    var shrinkType:shrink = .mid;
    
    // Nature properties
    var willBeShrunk:Bool = false;
    var styleBackground:Bool = false;
    
    var notSelectable:Bool = false;
    
    var isStyleInverted:Bool = false;
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
    
    func shrunked() {
        self.frame = self.shrunkFrame!;
    }
    
    /*
        Translates the button to the desired position
     */
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
    
    /*
        Increases both the width and the height
        to its original size
     */
    func grow(){
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseInOut, animations: {
            self.frame = self.originalFrame!;
        });
    }
    
    /*
        Makes the background color of
        the button opaque
     */
    func fadeBackgroundIn(color:UIColor, duration:Double){
        UIView.animate(withDuration: duration, delay: 0.25, options: .curveEaseIn, animations: {
            self.backgroundColor = color;
        });
    }
    
    /*
        Shrinks both the length and the
        width of the button at one side
     */
    func shrink(colorOptionButton:Bool) {
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
            x = self.superview!.frame.width;
        }
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseIn, animations: {
            if (!colorOptionButton) {
                self.frame = CGRect(x: self.originalFrame!.midX, y: self.originalFrame!.midY, width: 0.0, height: 0.0);
            } else {
                self.frame = CGRect(x: x, y: self.frame.minY, width: 0.0, height: self.frame.height);
            }
        }, completion: { _ in
            if (!colorOptionButton) {
                self.removeFromSuperview();
            }
        });
    }
    
    /*
        Makes the button transparent over time
     */
    func hide(){
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseIn, animations: {
            self.alpha = 0.0;
        });
    }
    
    /*
        Makes the button opaque over time
     */
    func show() {
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseIn, animations: {
            self.alpha = 1.0;
        });
    }
    
    /*
        Increase the opacity of the background color
        over time
     */
    func fadeBackgroundIn(){
        UIView.animate(withDuration: 0.25, delay: 125, options: .curveEaseIn, animations: {
            self.backgroundColor = self.originalBackgroundColor!;
        });
    }
    
    /*
        Make the button transparent and
        then opque over time
     */
    func fadeOutAndIn() {
        UIView.animate(withDuration: 0.125, delay: 0.0, options: .curveEaseInOut, animations: {
            super.alpha = 0.0;
        }, completion: { _ in
            UIView.animate(withDuration: 0.125, delay: 0.0, options: .curveEaseInOut, animations: {
                super.alpha = 1.0;
            })
        })
    }
    
    func shrinked(){
        self.frame = CGRect(x: self.frame.midX, y: self.frame.midY, width: 1.0, height: 1.0);
    }
    
    /*
        Update the shape of the button
        to be selected
     */
    func select(){
        if (!self.isSelected) {
            self.superview!.bringSubviewToFront(self);
            UIView.animate(withDuration: 0.5, delay: 0.125, options:[.curveEaseInOut], animations: {
                self.transform = self.transform.scaledBy(x: 1.0, y: 1.275);
            });
            self.isSelected = true;
        }
    }
    
    /*
        Reset the shape of the button
        to be unselected
     */
    func unSelect(){
        if (self.isSelected) {
            UIView.animate(withDuration: 0.5, delay: 0.125, options:[.curveEaseInOut], animations: {
                self.transform = self.transform.scaledBy(x: 1.0, y: (1/1.275));
            });
            self.isSelected = false;
        }
    }
    
    /*
        Update the appearance of the button
        based on the theme of the operating system
     */
    func setStyle() {
        if (isStyleInverted) {
            if (ViewController.uiStyleRawValue == 1){
                self.layer.borderColor = UIColor.white.cgColor;
                self.setTitleColor(UIColor.white, for: .normal);
                if (styleBackground) {
                    self.backgroundColor = UIColor.black;
                }
            } else {
                self.layer.borderColor = UIColor.black.cgColor;
                self.setTitleColor(UIColor.black, for: .normal);
                if (styleBackground) {
                    self.backgroundColor = UIColor.white;
                }
            }
        } else {
            if (ViewController.uiStyleRawValue == 1){
                self.layer.borderColor = UIColor.black.cgColor;
                self.setTitleColor(UIColor.black, for: .normal);
                if (styleBackground) {
                    self.backgroundColor = UIColor.white;
                }
            } else {
                self.layer.borderColor = UIColor.white.cgColor;
                self.setTitleColor(UIColor.white, for: .normal);
                if (styleBackground) {
                   self.backgroundColor = UIColor.black;
                }
            }
        }
    }
}

