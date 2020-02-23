//
//  UIRestart1.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/13/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIRestart1: UIButton {
    
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
        setStyle();
        self.addTarget(self, action: #selector(restart1Selector), for: .touchUpInside);
        parentView.addSubview(self);
    }

    func setIconImage(imageName:String) {
        let iconImage:UIImage? = UIImage(named:imageName);
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func setStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            setIconImage(imageName: "lightRestart1.png");
        } else {
            setIconImage(imageName: "darkRestart1.png");
        }
    }
    
    func setTargetResources(boardGameView:UIBoardGame, settingsButton:UISettingsButton) {
        self.boardGameView = boardGameView;
        self.settingsButton = settingsButton;
        self.addTarget(self, action: #selector(restart1Selector), for: .touchUpInside);
    }
    
    @objc func restart1Selector() {
        self.settingsButton!.sendActions(for: .touchUpInside);
        self.boardGameView!.revertSelections();
    }
}
