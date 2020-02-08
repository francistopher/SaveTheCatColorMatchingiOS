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
        self.backgroundColor = backgroundColor;
        self.layer.cornerRadius = height / 5.0;
        self.originalBackgroundColor = backgroundColor;
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
    
    func empty(color:UIColor){
        UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseIn, animations: {
            self.backgroundColor = color;
        });
    }
    
    func fill(){
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
}

