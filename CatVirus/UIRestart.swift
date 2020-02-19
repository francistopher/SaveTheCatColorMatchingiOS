//
//  UIRestart.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/13/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIRestart: UIButton {
    
    var originalFrame:CGRect? = nil;
    var reducedFrame:CGRect? = nil;
    var boardGameView:UIBoardGame? = nil;
    var settingsButton:UISettingsButton? = nil;

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        self.originalFrame = CGRect(x: x, y: y, width: width, height: height);
        self.backgroundColor = .clear;
        self.layer.cornerRadius = height / 2.0;
        self.setStyle();
        self.addTarget(self, action: #selector(testingSelector), for: .touchUpInside);
        parentView.addSubview(self);
    }

    @objc func testingSelector() {
        print("Testing: Restart!");
    }
    
    func setIconImage(imageName:String) {
         let iconImage:UIImage? = UIImage(named:imageName);
         self.setImage(iconImage, for: .normal);
         self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
     }
     
    func setStyle() {
         if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
             setIconImage(imageName: "lightRestart.png");
         } else {
             setIconImage(imageName: "darkRestart.png");
         }
     }
    
    func setTargetResources(boardGameView:UIBoardGame, settingsButton:UISettingsButton) {
        self.boardGameView = boardGameView;
        self.settingsButton = settingsButton;
        self.addTarget(self, action: #selector(restartSelector), for: .touchUpInside);
    }
    
    @objc func restartSelector() {
        self.settingsButton!.sendActions(for: .touchUpInside);
        boardGameView!.maintain();
    }
}
