//
//  UIMultiplayer.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/13/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI
import MultipeerConnectivity

class UIMultiplayer: UIButton {

    var originalFrame:CGRect? = nil;
    var reducedFrame:CGRect? = nil;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        originalFrame = CGRect(x: x, y: y, width: width, height: height);
        backgroundColor = .clear;
        layer.cornerRadius = height / 2.0;
        parentView.addSubview(self);
        setStyle();
    }
    
    
    func setIconImage(imageName: String) {
        let iconImage:UIImage? = UIImage(named: imageName);
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func setStyle() {
        setIconImage(imageName: "multiPlayer.png");
    }
}
