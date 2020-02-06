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
    
    init(parentView:UIView, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat, backgroundColor:UIColor, textColor:UIColor, font:UIFont, text:String){
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        super.backgroundColor = backgroundColor;
        super.textColor = textColor;
        super.font = font;
        super.text = text;
        super.textAlignment = NSTextAlignment.center;
        parentView.addSubview(self);
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fadeInAndOut(){
        UIView.animate(withDuration: 2, delay: 0.5, options: .curveEaseIn, animations: {
            super.alpha = 1.0;
        }) { (_) in
            UIView.animate(withDuration: 2, delay: 0.5, options: .curveEaseOut, animations: {
                super.alpha = 0.0;
            })
        }
    }
    
    func fadeOnDark() {
        UIView.animate(withDuration: 0.125, delay:0.0, options: .curveEaseIn, animations: {
            super.backgroundColor = UIColor.white;
            super.textColor = UIColor.black;
        })
    }
    
    func fadeOnLight(){
        UIView.animate(withDuration: 0.125, delay: 0.0, options: .curveEaseIn, animations: {
            super.backgroundColor = UIColor.black;
            super.textColor = UIColor.white;
        })
    }
    
}
