//
//  CenterKit.swift
//  bagDatCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import UIKit

class CenterController {
    
    static func center(childView:UIView, parentRect:CGRect, childRect:CGRect){
        let centeredX:CGFloat = CenterController.getCenteredX(parentRect: parentRect, childRect: childRect);
        let centeredY:CGFloat = CenterController.getCenteredY(parentRect: parentRect, childRect: childRect);
        childView.frame = CGRect(x: centeredX, y:centeredY, width: childRect.width, height: childRect.height);
    }
    
//    static func centerWithHorizontalDisplacement(childView:UIView, parentRect:CGRect, childRect:CGRect, horizontalDisplacement:CGFloat){
//        let centeredX:CGFloat = UICenterKit.getCenteredX(parentRect: parentRect, childRect: childRect) + horizontalDisplacement;
//        let centeredY:CGFloat = UICenterKit.getCenteredY(parentRect: parentRect, childRect: childRect);
//        childView.frame = CGRect(x: centeredX, y: centeredY, width: childRect.width, height: childRect.height);
//    }
    
    static func centerWithVerticalDisplacement(childView:UIView, parentRect:CGRect, childRect:CGRect, verticalDisplacement:CGFloat){
        let centeredX:CGFloat = CenterController.getCenteredX(parentRect: parentRect, childRect: childRect);
        let centeredY:CGFloat = CenterController.getCenteredY(parentRect: parentRect, childRect: childRect) + verticalDisplacement;
        childView.frame = CGRect(x: centeredX, y: centeredY, width: childRect.width, height: childRect.height);
    }
    
    static func centerHorizontally(childView:UIView, parentRect:CGRect, childRect:CGRect){
        let centeredX:CGFloat = CenterController.getCenteredX(parentRect: parentRect, childRect: childRect);
        childView.frame = CGRect(x: centeredX, y: childRect.minY, width: childRect.width, height: childRect.height);
    }
    
    static func centerVertically(childView:UIView, parentRect:CGRect, childRect:CGRect){
        let centeredY:CGFloat = CenterController.getCenteredY(parentRect: parentRect, childRect: childRect);
        childView.frame = CGRect(x: childRect.minX, y: centeredY, width: childRect.width, height: childRect.height);
    }
    
    static func getCenteredX(parentRect:CGRect, childRect:CGRect) -> CGFloat {
        return (parentRect.width - childRect.width) / 2.0;
    }
    
    static func getCenteredY(parentRect:CGRect, childRect:CGRect) -> CGFloat {
        return (parentRect.height - childRect.height) / 2.0;
    }
    
}
