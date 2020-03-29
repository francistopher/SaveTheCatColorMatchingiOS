//
//  UINoAds.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/13/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIAds: UIButton {
    
    var originalFrame:CGRect?
    var reducedFrame:CGRect?
    var adsText:UICLabel?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        self.originalFrame = CGRect(x: x, y: y, width: width, height: height);
        self.backgroundColor = .clear;
        self.layer.cornerRadius = height / 2.0;
        setupAdsText();
        setIconImage(imageName: "noSymbol.png");
        self.bringSubviewToFront(imageView!);
        self.addTarget(self, action: #selector(noAdsSelector), for: .touchUpInside);
        parentView.addSubview(self);
        setStyle();
    }
    
    func setupAdsText() {
        adsText = UICLabel(parentView: self, x: frame.height * 0.01, y: frame.height * 0.04, width: frame.width, height: frame.height);
        adsText!.text = "ADS";
        adsText!.backgroundColor = UIColor.clear;
        adsText!.font = UIFont.boldSystemFont(ofSize: adsText!.frame.height * 0.4);
        ViewController.updateFont(label: adsText!);
        self.addSubview(adsText!);
    }

    @objc func noAdsSelector() {
        print("Testing: No Ads!");
    }


    var iconImage:UIImage?
    func setIconImage(imageName:String) {
        iconImage = nil;
        iconImage = UIImage(named:imageName);
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func setStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            adsText!.textColor = UIColor.black;
        } else {
            adsText!.textColor = UIColor.white;
        }
    }
    
}
