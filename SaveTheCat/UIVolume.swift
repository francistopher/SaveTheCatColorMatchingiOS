//
//  UIMultiplayer.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/13/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI
import MultipeerConnectivity

class UIVolume: UIButton {

    var originalFrame:CGRect?
    var reducedFrame:CGRect?
    static var musicOn:Bool = true;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        originalFrame = CGRect(x: x, y: y, width: width, height: height);
        backgroundColor = .clear;
        layer.cornerRadius = height / 2.0;
        parentView.addSubview(self);
        self.addTarget(self, action: #selector(volumeTarget), for: .touchUpInside);
        setStyle();
    }
    
    var iconImage:UIImage?
    func setIconImage(imageName: String) {
        iconImage = nil;
        iconImage = UIImage(named: imageName);
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    @objc func volumeTarget() {
        if (UIVolume.musicOn) {
            SoundController.setMusicVolumeTo0();
            UIVolume.musicOn = false;
        } else {
            SoundController.setMusicVolumeTo100();
            UIVolume.musicOn = true;
        }
        setStyle();
    }
    
    func setStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            if (UIVolume.musicOn) {
                setIconImage(imageName: "darkMusicOn.png");
            } else {
                setIconImage(imageName: "darkMusicOff.png");
            }
        } else {
            if (UIVolume.musicOn) {
                setIconImage(imageName: "lightMusicOn.png");
            } else {
                setIconImage(imageName: "lightMusicOff.png");
            }
        }
    }
}
