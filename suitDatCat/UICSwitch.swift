//
//  UICSwitch.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/10/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI
import Foundation
import UIKit

class UICSwitch:UISwitch {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat, tintColor:UIColor, onTintColor:UIColor) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        setStyle();
        self.tintColor = tintColor;
        self.onTintColor = onTintColor;
        self.layer.cornerRadius = self.frame.height / 2.0;
        self.backgroundColor = tintColor;
        self.addTarget(self, action: #selector(generalSelector), for: .valueChanged);
        parentView.addSubview(self);
    }
    
    func setStyle(){
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            self.thumbTintColor = UIColor.white;
        }
        else {
            self.thumbTintColor = UIColor.black;
        }
    }
    
    @objc func generalSelector(){
        if (self.isOn) {
            self.backgroundColor = self.onTintColor;
        } else {
            self.backgroundColor = self.tintColor;
        }
    }
    
    
}

