//
//  CUIView.swift
//  bagDatCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import UIKit

 class UICView:UIView {
    
    var originalFrame:CGRect? = nil;
    var reducedFrame:CGRect? = nil;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    init(parentView: UIView, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat, backgroundColor:UIColor) {
        super.init(frame:CGRect(x: x, y: y, width: width, height: height));
        self.originalFrame = CGRect(x: x, y: y, width: width, height: height);
        self.backgroundColor = backgroundColor;
        self.layer.cornerRadius = height / 5.0;
        self.setStyle();
        parentView.addSubview(self);
    }
    
    func fadeIn() {
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseInOut, animations: {
            self.alpha = 1.0;
        })
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseInOut, animations: {
            self.alpha = 0.0;
        })
    }
    
    func setStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            self.layer.borderColor = UIColor.black.cgColor;
            self.backgroundColor = UIColor.white;
        } else {
            self.layer.borderColor = UIColor.white.cgColor;
            self.backgroundColor = UIColor.black;
        }
    }
}

