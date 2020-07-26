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
    
    static var centeredX:CGFloat?
    static var centeredY:CGFloat?
    
    /*
        Centers a view onto its parent view
     */
    static func center(childView:UIView, parentRect:CGRect, childRect:CGRect){
        centeredX = CenterController.getCenteredX(parentRect: parentRect, childRect: childRect);
        centeredY = CenterController.getCenteredY(parentRect: parentRect, childRect: childRect);
        childView.frame = CGRect(x: centeredX!, y:centeredY!, width: childRect.width, height: childRect.height);
    }
    
    /*
        Vertically centers a view onto its parent
        view with the additional offset
     */
    static func centerWithVerticalDisplacement(childView:UIView, parentRect:CGRect, childRect:CGRect, verticalDisplacement:CGFloat){
        centeredX = CenterController.getCenteredX(parentRect: parentRect, childRect: childRect);
        centeredY = CenterController.getCenteredY(parentRect: parentRect, childRect: childRect) + verticalDisplacement;
        childView.frame = CGRect(x: centeredX!, y: centeredY!, width: childRect.width, height: childRect.height);
    }
    
    /*
        Centers a view horizontally
        onto its parent
     */
    static func centerHorizontally(childView:UIView, parentRect:CGRect, childRect:CGRect){
        centeredX = CenterController.getCenteredX(parentRect: parentRect, childRect: childRect);
        childView.frame = CGRect(x: centeredX!, y: childRect.minY, width: childRect.width, height: childRect.height);
    }
    
    /*
        Centers a view vertically
        onto its parent
     */
    static func centerVertically(childView:UIView, parentRect:CGRect, childRect:CGRect){
        centeredY = CenterController.getCenteredY(parentRect: parentRect, childRect: childRect);
        childView.frame = CGRect(x: childRect.minX, y: centeredY!, width: childRect.width, height: childRect.height);
    }
    
    static func getCenteredX(parentRect:CGRect, childRect:CGRect) -> CGFloat {
        return (parentRect.width - childRect.width) / 2.0;
    }
    
    static func getCenteredY(parentRect:CGRect, childRect:CGRect) -> CGFloat {
        return (parentRect.height - childRect.height) / 2.0;
    }
    
}
