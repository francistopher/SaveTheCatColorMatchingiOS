//
//  UINoAds.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/13/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIAds: UIButton {
    
    var keyValueStore:NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore();
    
    var originalFrame:CGRect?
    var reducedFrame:CGRect?
    var adsText:UICLabel?
    var noAdsAlert:UIAlertController?
    
    static var canHideAds:Bool = false;
    static var isAdHidden:Bool = false;
    static var stylePreference:Int = -1;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        self.originalFrame = CGRect(x: x, y: y, width: width, height: height);
        self.backgroundColor = .clear;
        self.layer.cornerRadius = height / 2.0;
        setIconImage(imageName: "noRedSymbol.png");
        setupAdsText();
        setupNoAdsAlert();
        // Set static parameters
        updateStaticParameters();
        // Finish
        self.bringSubviewToFront(imageView!);
        self.addTarget(self, action: #selector(noAdsSelector), for: .touchUpInside);
        parentView.addSubview(self);
                setStyle();
    }
    
    var compiledStaticParameters:String?
    func updateStaticParameters() {
        compiledStaticParameters = keyValueStore.string(forKey: "aboutAdsStyle");
        if (compiledStaticParameters != nil) {
            if (Array(compiledStaticParameters!)[0] == "1") {
                UIAds.canHideAds = true;
            }
            if (Array(compiledStaticParameters!)[1] == "1") {
                UIAds.isAdHidden = true;
            }
            if (Array(compiledStaticParameters!)[2] == "1") {
                UIAds.stylePreference = 1;
                setIconImage(imageName: "lightStyle");
            } else if (Array(compiledStaticParameters!)[2] == "0") {
                UIAds.stylePreference = 0;
                setIconImage(imageName: "darkStyle");
            } else {
                UIAds.stylePreference = -1;
                setIconImage(imageName: "autoStyle");
            }
        }
    }
    
    func saveStaticParameters() {
        compiledStaticParameters = ""
        if (UIAds.canHideAds) {
            compiledStaticParameters! += "1"
        } else {
            compiledStaticParameters! += "0"
        }
        
        if (UIAds.isAdHidden) {
            compiledStaticParameters! += "1"
        } else {
            compiledStaticParameters! += "0"
        }
        
        if (UIAds.stylePreference == 1) {
            compiledStaticParameters! += "1"
        } else if (UIAds.stylePreference == 0) {
            compiledStaticParameters! += "0"
        } else {
            compiledStaticParameters! += "-"
        }
        keyValueStore.set(compiledStaticParameters!, forKey: "aboutAdsStyle");
    }
    
    
    func setupNoAdsAlert() {
        noAdsAlert = UIAlertController(title: "No Ads", message: "", preferredStyle: .alert);
        noAdsAlert!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));
        checkIfCanHideAds();
    }
    
    func checkIfCanHideAds() {
        if (UIAds.canHideAds) {
            setIconImage(imageName: "noGreenSymbol");
            noAdsAlert!.message = "You've saved over 9000 cats!\nYou can now hide ads visible\nduring gameplay!"
            noAdsAlert!.addAction(UIAlertAction(title: "Hide", style: .default, handler: { _ in
                ViewController.staticSelf!.bannerView!.alpha = 0.0;
                ViewController.staticSelf!.noInternetBannerView!.alpha = 0.0;
                self.setIconImage(imageName: "autoStyle")
                self.adsText!.alpha = 0.0;
                UIAds.isAdHidden = true;
                self.saveStaticParameters();
            }));
            self.saveStaticParameters();
        } else {
            noAdsAlert!.message = "To hide ads during gameplay,\nyou must save over 9000 cats!"
        }
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
        if (UIAds.isAdHidden) {
            if (UIAds.stylePreference == -1) {
                UIAds.stylePreference = 0;
                setIconImage(imageName: "darkStyle");
            } else if (UIAds.stylePreference == 0) {
                UIAds.stylePreference = 1
                setIconImage(imageName: "lightStyle")
            } else if (UIAds.stylePreference == 1) {
                UIAds.stylePreference = -1
                setIconImage(imageName: "autoStyle")
            }
            ViewController.staticSelf!.traitCollectionChange();
            self.saveStaticParameters();
        } else {
           ViewController.staticSelf!.present(noAdsAlert!, animated: true, completion: nil);
        }
    }


    var iconImage:UIImage?
    func setIconImage(imageName:String) {
        iconImage = nil;
        iconImage = UIImage(named:imageName);
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func setStyle() {
        if (ViewController.uiStyleRawValue == 1){
            adsText!.textColor = UIColor.black;
        } else {
            adsText!.textColor = UIColor.white;
        }
    }
    
}
