//
//  Heaven.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/8/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import UIKit

class CACGradientLayer:CAGradientLayer {
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(layer: Any) {
        super.init(layer: layer);
    }
    
    var darkColors:[Any]? = nil;
    var lightColors:[Any]? = nil;
    
    var darkEndingPoint:CGPoint? = nil;
    var lightEndingPoint:CGPoint? = nil;
    
    init(parentView:UIView, type:CAGradientLayerType, startPoint:CGPoint){
        super.init();
        
        self.frame = parentView.frame;
        parentView.layer.addSublayer(self);
        self.type = type;
        self.startPoint = startPoint;
    }
    
    func setColors(lightColors:[Any], darkColors:[Any]){
        self.lightColors = lightColors;
        self.darkColors = darkColors;
    }
    
    func setEndingPoints(lightEndingPoint:CGPoint, darkEndingPoint:CGPoint){
        self.lightEndingPoint = lightEndingPoint;
        self.darkEndingPoint = darkEndingPoint;
    }
    
    func configureForUserInterfaceStyle(){
        let userInterfaceStyle:Int = UIScreen.main.traitCollection.userInterfaceStyle.rawValue;
        if (userInterfaceStyle == 1){
            self.colors = lightColors!;
            self.endPoint = lightEndingPoint!;
        } else {
            self.colors = darkColors!;
            self.endPoint = darkEndingPoint!;
        }
    }
    
    
}

