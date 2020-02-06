//
//  UIColorOptionsView.swift
//  suitDatCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIColorOptionsView: UIView {
    
    var boardGameView:UIBoardGameView? = nil;
    
    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented");
   }
   
   init(parentView: UIView, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat, backgroundColor:UIColor) {
       super.init(frame:CGRect(x: x, y: y, width: width, height: height));
       self.backgroundColor = backgroundColor;
       self.layer.cornerRadius = height / 5.0;
       parentView.addSubview(self);
   }
   
   func fadeIn(){
      UIView.animate(withDuration: 2, delay: 0.5, options: .curveEaseIn, animations: {
          super.alpha = 1.0;
      })
   }
   
   func fadeOnDark() {
       UIView.animate(withDuration: 0.0625, delay: 0.0, options: .curveEaseIn, animations: {
           super.backgroundColor = UIColor.white;
       })
   }
   
   func fadeOnLight(){
       UIView.animate(withDuration: 0.0625, delay: 0.0, options: .curveEaseIn, animations: {
           super.backgroundColor = UIColor.black;
       })
   }
    
}
