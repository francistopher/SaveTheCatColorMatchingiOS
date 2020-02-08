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
        UIView.animate(withDuration: 1.0, delay: 0.125, options:[.curveEaseInOut], animations: {
           if (userInterfaceStyle == 1){
            self.colors = self.lightColors!;
            self.endPoint = self.lightEndingPoint!;
           } else {
            self.colors = self.darkColors!;
            self.endPoint = self.darkEndingPoint!;
           }
        });
    }
    
    func configureForHidden(isHidden:Bool){
        UIView.animate(withDuration: 1.0, delay: 0.125, options:[.curveEaseInOut], animations: {
            self.isHidden = isHidden;
        });
    }
    
}

