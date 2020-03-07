//
//  CUILabel.swift
//  bagDatCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import UIKit

class UICLabel:UILabel {
    
    var isInverted:Bool = false;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat){
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        self.textAlignment = NSTextAlignment.center;
        self.setStyle()
        parentView.addSubview(self);
    }
    
    func shrink() {
        UIView.animate(withDuration: 0.25, delay: 0.125, options: .curveEaseInOut, animations: {
            self.frame = CGRect(x: self.frame.midX, y: self.frame.midY, width: 0.0, height: 0.0);
        }, completion: { _ in
            self.removeFromSuperview();
        })
    }
    
    func fadeInAndOut(){
        UIView.animate(withDuration: 2, delay: 0.5, options: .curveEaseIn, animations: {
            super.alpha = 1.0;
        }) { (_) in
            SoundController.kittenMeow();
            UIView.animate(withDuration: 2, delay: 0.5, options: .curveEaseOut, animations: {
                super.alpha = 0.0;
            })
        }
    }
    
    func setStyle() {
        if (isInverted) {
            if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
                self.textColor = UIColor.white;
                self.backgroundColor = UIColor.black;
            } else {
                self.textColor = UIColor.black;
                self.backgroundColor = UIColor.white;
            }
        } else {
            if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
                self.textColor = UIColor.black;
                self.backgroundColor = UIColor.white;
            } else {
                self.textColor = UIColor.white;
                self.backgroundColor = UIColor.black;
            }
        }
    }
    
}