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
import AVFoundation

class UISettingsButton:UIButton {
    
    static var settingsButton:UISettingsButton? = nil;
    
    var originalFrame:CGRect? = nil;
    var shrunkFrame:CGRect? = nil;
    var originalBackgroundColor:UIColor? = nil;
    var isPressed:Bool = false;
    var isPressable:Bool = true;
    var settingsMenu:UICView? = nil;
    
    var colorOptionsView:UIColorOptions? = nil;
    var boardGame:UIBoardGame? = nil;
    var cellFrame:CGRect? = nil;
    
    
    var showContentAnimation:UIViewPropertyAnimator?
    var hideContentAnimation:UIViewPropertyAnimator?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        self.backgroundColor = backgroundColor;
        self.layer.cornerRadius = height / 2.0625;
        self.layer.borderWidth = self.frame.height / 12.0;
        parentView.addSubview(self);
        setupSettingsMenu(parentView:parentView);
        setupCellFrame();
        settingsMenu!.frame = CGRect(x: self.frame.midX * 0.7, y: self.frame.minY, width: cellFrame!.width * 1.75, height: settingsMenu!.frame.height);
        settingsMenu!.reducedFrame = settingsMenu!.frame;
        setStyle();
        self.addTarget(self, action: #selector(settingsMenuSelector), for: .touchUpInside);
    }
    
    func setIconImage(imageName:String) {
        let iconImage:UIImage? = UIImage(named:imageName);
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func setupSettingsMenu(parentView:UIView) {
        settingsMenu = UICView(parentView: parentView, x: self.frame.minX, y: self.frame.minY, width: parentView.frame.width * 0.8575, height: self.frame.height, backgroundColor: .clear);
        settingsMenu!.layer.cornerRadius = settingsMenu!.frame.height / 2.0;
        settingsMenu!.layer.borderWidth = self.frame.height / 12.0;
        parentView.bringSubviewToFront(self);
    }
    
    func setupCellFrame(){
        cellFrame = CGRect(x: 0.0, y: 0.0, width: (settingsMenu!.frame.width / 7.0), height: settingsMenu!.frame.height);
        cellFrame = CGRect(x: cellFrame!.width / 7.0, y: 0.0, width: settingsMenu!.frame.width / 8.0, height: settingsMenu!.frame.height);
    }
    
    @objc func settingsMenuSelector(){
        if (isPressable) {
            isPressable = false;
            // Settings button pressed
            if(!isPressed){
                boardGame!.cats.clearCatButtons();
                boardGame!.attackMeter!.pauseVirusMovement();
                settingsMenuShow();
            }else{
                // Settings button unpressed
                boardGame!.cats.unClearCatButtons();
                boardGame!.attackMeter!.unPauseVirusMovement();
                settingsMenuHide();
            }
            SoundController.gearSpinning();
        }
    }
    
    func setupShowContentAnimation() {
        showContentAnimation = UIViewPropertyAnimator.init(duration: 1.0, curve: .easeInOut, animations: {
            self.imageView!.transform = self.imageView!.transform.rotated(by: CGFloat.pi);
            self.settingsMenu!.frame = self.settingsMenu!.originalFrame!;
        })
        showContentAnimation!.addCompletion({ _ in
            self.isPressable = true;
        })
    }
    
    @objc func settingsMenuShow(){
        isPressed = true;
        print("Selected");
        colorOptionsView!.isUserInteractionEnabled = false;
        boardGame!.isUserInteractionEnabled = false;
        setupShowContentAnimation();
        showContentAnimation!.startAnimation();
    }
    
    func setupHideContentAnimation() {
        hideContentAnimation = UIViewPropertyAnimator.init(duration: 1.0, curve: .easeInOut, animations: {
            self.imageView!.transform = self.imageView!.transform.rotated(by: CGFloat.pi);
            self.settingsMenu!.frame = self.settingsMenu!.reducedFrame!;
        })
        hideContentAnimation!.addCompletion({ _ in
            self.isPressable = true;
            self.colorOptionsView!.isUserInteractionEnabled = true;
            self.boardGame!.isUserInteractionEnabled = true;
        })
    }
    
    @objc func settingsMenuHide(){
        print("Unselected");
        isPressed = false;
        setupHideContentAnimation();
        hideContentAnimation!.startAnimation();
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
//        moreCats!.setStyle();
//        multiplayer!.setStyle();
//        stats!.setStyle();
//        noAds!.setStyle();
    }
    
    func setBoardGameAndColorOptionsView(boardGameView:UIBoardGame, colorOptionsView:UIColorOptions) {
        self.boardGame = boardGameView;
        self.colorOptionsView = colorOptionsView;
    }
    
    func fadeIn(){
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseIn, animations: {
            self.alpha = 1.0;
            self.settingsMenu!.alpha = 1.0;
        });
    }
    
    func hide() {
        self.alpha = 0.0;
        self.settingsMenu!.alpha = 1.0;
    }
}
