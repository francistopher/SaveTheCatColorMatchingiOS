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
    static var musicOff:Bool = false;
    let defaults = UserDefaults.standard;
    
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
        setMusicOn();
        setStyle();
    }
    
    func setMusicOn() {
        if (defaults.bool(forKey: "musicOff")) {
            volumeTarget();
        }
    }
    
    var iconImage:UIImage?
    func setIconImage(imageName: String) {
        iconImage = nil;
        iconImage = UIImage(named: imageName);
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    @objc func volumeTarget() {
        if (UIVolume.musicOff) {
            SoundController.setMusicVolumeTo100();
            UIVolume.musicOff = false;
        } else {
            SoundController.setMusicVolumeTo0();
            UIVolume.musicOff = true;
        }
        setStyle();
        saveVolumeState();
    }
    
    func saveVolumeState() {
        defaults.set(UIVolume.musicOff, forKey: "musicOff");
    }
    
    func setStyle() {
        if (ViewController.uiStyleRawValue == 1){
            if (UIVolume.musicOff) {
                setIconImage(imageName: "darkMusicOff.png");
            } else {
                setIconImage(imageName: "darkMusicOn.png");
            }
        } else {
            if (UIVolume.musicOff) {
                setIconImage(imageName: "lightMusicOff.png");
            } else {
                setIconImage(imageName: "lightMusicOn.png");
            }
        }
    }
}
