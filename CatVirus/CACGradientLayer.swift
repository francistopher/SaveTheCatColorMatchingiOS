//
//  CACGradientLayer.swift
//  CatVirus
//
//  Created by Christopher Francisco on 2/19/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class CACGradientLayer:CAGradientLayer {
    
    let mellowYellow:UIColor = UIColor(red: 252.0/255.0, green: 212.0/255.0, blue: 64.0/255.0, alpha: 1.0);
    
    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView, type:CAGradientLayerType){
        super.init();
        self.frame = parentView.frame;
        parentView.layer.addSublayer(self);
        self.type = type;
        self.startPoint = CGPoint(x:0.5, y:0.0);
        self.endPoint = CGPoint(x:-0.5, y:0.15);
    }
    
    func setStyle() {
        super.isHidden = false;
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
             super.colors = [self.mellowYellow.cgColor, UIColor.white.cgColor];
         } else {
             super.colors =  [self.mellowYellow.cgColor, UIColor.black.cgColor];
        }
    }
    
}
