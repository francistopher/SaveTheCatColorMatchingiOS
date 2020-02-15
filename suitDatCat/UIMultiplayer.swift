//
//  UIMultiPlayer.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/13/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIMultiplayer: UIButton {

    var originalFrame:CGRect? = nil;
    var reducedFrame:CGRect? = nil;

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        self.originalFrame = CGRect(x: x, y: y, width: width, height: height);
        self.backgroundColor = .clear;
        self.layer.cornerRadius = height / 2.0;
        setIconImage(imageName: "multiplayer.png");
        self.addTarget(self, action: #selector(testingSelector), for: .touchUpInside);
        parentView.addSubview(self);
    }

    @objc func testingSelector() {
        print("Testing: Multiplayer!");
    }
    
    func setIconImage(imageName:String) {
        let iconImage:UIImage? = UIImage(named:imageName);
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func setStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            setIconImage(imageName: "lightMultiplayer.png");
        } else {
            setIconImage(imageName: "darkMultiplayer.png");
        }
    }
    
    
}