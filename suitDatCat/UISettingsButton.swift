//
//  UISettingsButton.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/9/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class UISettingsButton:UIButton {
    
    var originalX:CGFloat = 0.0;
    var originalY:CGFloat = 0.0;
    var originalWidth:CGFloat = 0.0;
    var originalHeight:CGFloat = 0.0;
    
    var shrunkX:CGFloat = 0.0;
    var shrunkY:CGFloat = 0.0;
    var shrunkWidth:CGFloat = 0.0;
    var shrunkHeight:CGFloat = 0.0;
    
    var originalFrame:CGRect? = nil;
    var shrunkFrame:CGRect? = nil;
    var originalBackgroundColor:UIColor? = nil;
    var isPressed:Bool = false;
    var settingsMenu:UICView? = nil;
    
    var colorOptionsView:UIColorOptionsView? = nil;
    var boardGameView:UIBoardGameView? = nil;
    var cellFrame:CGRect? = nil;
    
    var fishCoin:UIFishCoin? = nil;
    var moreCats:UIMoreCats? = nil;
    var multiplayer:UIMultiplayer? = nil;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        self.backgroundColor = backgroundColor;
        self.layer.cornerRadius = height / 2.0625;
        self.layer.borderWidth = self.frame.height / 12.0;
        parentView.addSubview(self);
        configureSettingsMenu(parentView:parentView);
        configureCellFrame();
        configureFishCoinButton(parentView:settingsMenu!);
        configureMoreCatsButton(parentView:settingsMenu!);
        configureMultiplayerButton(parentView:settingsMenu!);
        settingsMenu!.frame = CGRect(x: self.frame.midX * 0.75, y: self.frame.minY, width: cellFrame!.width * 1.635, height: settingsMenu!.frame.height);
        settingsMenu!.reducedFrame = settingsMenu!.frame;
        
        // Control
//        settingsMenu!.frame = settingsMenu!.originalFrame!;
//        fishCoin!.frame = fishCoin!.originalFrame!;
        
        setStyle();
        self.addTarget(self, action: #selector(settingsMenuSelector), for: .touchUpInside);
    }
    
    func setIconImage(imageName:String) {
        let iconImage:UIImage? = UIImage(named:imageName);
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func enable() {
        self.isEnabled = true;
        self.setTitle("· · ·", for: .normal);
    }
    
    func disable() {
        self.isEnabled = false;
        self.setTitle("", for: .normal);
    }
    
    func configureCellFrame(){
        cellFrame = CGRect(x: 0.0, y: 0.0, width: settingsMenu!.frame.width / 7.0, height: settingsMenu!.frame.height);
        cellFrame = CGRect(x: cellFrame!.width / 6.0, y: 0.0, width: settingsMenu!.frame.width / 7.0, height: settingsMenu!.frame.height);
    }
    
    func configureMultiplayerButton(parentView:UICView) {
        multiplayer = UIMultiplayer(parentView: parentView, x: cellFrame!.width * 4.0 + cellFrame!.minX, y: 0.0, width: cellFrame!.width, height: cellFrame!.height);
        multiplayer!.frame = CGRect(x: -cellFrame!.minX, y: moreCats!.frame.minY, width: moreCats!.frame.width, height: moreCats!.frame.height);
        multiplayer!.reducedFrame = multiplayer!.frame;
    }
    
    func configureMoreCatsButton(parentView:UICView) {
        moreCats = UIMoreCats(parentView: parentView, x: cellFrame!.width * 5.0 + cellFrame!.minX, y: 0.0, width: cellFrame!.width, height: cellFrame!.height);
        moreCats!.frame = CGRect(x: -cellFrame!.minX, y: moreCats!.frame.minY, width: moreCats!.frame.width, height: moreCats!.frame.height);
        moreCats!.reducedFrame = moreCats!.frame;
    }
    
    func configureFishCoinButton(parentView:UICView){
        fishCoin = UIFishCoin(parentView: parentView, x: cellFrame!.width * 6.0 + cellFrame!.minX * 0.1, y: 0.0, width: cellFrame!.width, height: cellFrame!.height);
        fishCoin!.frame = CGRect(x: fishCoin!.frame.minX / 6.0 - cellFrame!.width * 0.365, y: fishCoin!.frame.minY, width: fishCoin!.frame.width, height:  fishCoin!.frame.height);
        fishCoin!.reducedFrame = fishCoin!.frame;
    }
    
    func configureSettingsMenu(parentView:UIView) {
        settingsMenu = UICView(parentView: parentView, x: self.frame.midX * 0.75, y: self.frame.minY, width: self.frame.width * 7.25, height: self.frame.height, backgroundColor: .clear);
        settingsMenu!.layer.cornerRadius = settingsMenu!.frame.height / 2.0;
        settingsMenu!.layer.borderWidth = self.frame.height / 12.0;
        parentView.bringSubviewToFront(self);
    }
    
    @objc func settingsMenuSelector(){
        if(!isPressed){
            settingsMenuShow();
        }else{
            settingsMenuHide();
        }
    }
    
    @objc func settingsMenuShow(){
        print("Selected");
        isPressed = true;
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            self.imageView!.transform = self.imageView!.transform.rotated(by: CGFloat.pi / 2.0);
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                 self.imageView!.transform = self.imageView!.transform.rotated(by: CGFloat.pi / 2.0);
            })
        }
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseOut, animations: {
            self.settingsMenu!.frame = self.settingsMenu!.originalFrame!;
            self.fishCoin!.frame = self.fishCoin!.originalFrame!;
            self.moreCats!.frame = self.moreCats!.originalFrame!;
            self.multiplayer!.frame = self.multiplayer!.originalFrame!;
        })
        colorOptionsView!.isUserInteractionEnabled = false;
        boardGameView!.isUserInteractionEnabled = false;
    }
    
    @objc func settingsMenuHide(){
        print("Unselected");
        isPressed = false;
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
             self.imageView!.transform = self.imageView!.transform.rotated(by: -CGFloat.pi / 2.0);
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                 self.imageView!.transform = self.imageView!.transform.rotated(by: -CGFloat.pi / 2.0);
            })
        }
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseOut, animations: {
            self.settingsMenu!.frame = self.settingsMenu!.reducedFrame!;
            self.fishCoin!.frame = self.fishCoin!.reducedFrame!;
            self.moreCats!.frame = self.moreCats!.reducedFrame!;
            self.multiplayer!.frame = self.multiplayer!.reducedFrame!;
        })
        colorOptionsView!.isUserInteractionEnabled = true;
        boardGameView!.isUserInteractionEnabled = true;
    }
    
    func setStyle(){
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            // Settings button colors
            self.setTitleColor(UIColor.black, for: .normal);
            self.layer.borderColor = UIColor.black.cgColor;
            self.backgroundColor = UIColor.white;
            setIconImage(imageName: "darkGear.png");
            // Settings menu colors
            self.settingsMenu!.layer.borderColor = UIColor.black.cgColor;
            self.settingsMenu!.backgroundColor = UIColor.white;
        } else {
            // Setting button colors
            self.setTitleColor(UIColor.white, for: .normal);
            self.layer.borderColor = UIColor.white.cgColor;
            self.backgroundColor = UIColor.black;
            setIconImage(imageName: "lightGear.png");
            // Setting menu colors
            self.settingsMenu!.layer.borderColor = UIColor.white.cgColor;
            self.settingsMenu!.backgroundColor = UIColor.black;
        }
    }
    
    func show(){
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseIn, animations: {
            self.alpha = 1.0;
        });
    }
}
