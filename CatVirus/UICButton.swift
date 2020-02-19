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
        self.layer.borderWidth = parentView.frame.width * 0.01;
        self.isSelected = false;
        self.setStyle();
    }
    
    func configureShrunkFrame() {
        shrunkFrame = CGRect(x: originalFrame!.minX + originalFrame!.width / 2.0, y: originalFrame!.minY + originalFrame!.height / 2.0, width: 0.0, height: 0.0);
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
    
    func shrink(){
        self.layer.removeAllAnimations();
        UIView.animate(withDuration: 1.0, delay: 0.25, options: .curveEaseIn, animations: {
            self.frame = self.shrunkFrame!;
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
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            self.layer.borderColor = UIColor.black.cgColor;
        } else {
            self.layer.borderColor = UIColor.white.cgColor;
        }
    }
}

