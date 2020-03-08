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
    
    static var settingsButton:UISettingsButton?;
    
    var settingsMenu:UISettingsMenu?
    
    var originalFrame:CGRect? = nil;
    var shrunkFrame:CGRect? = nil;
    var originalBackgroundColor:UIColor? = nil;
    var isPressed:Bool = false;
    var isPressable:Bool = true;
    
    var colorOptionsView:UIColorOptions? = nil;
    var boardGame:UIBoardGame? = nil;
    
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
        setStyle();
        self.addTarget(self, action: #selector(settingsMenuSelector), for: .touchUpInside);
    }
    
    func setIconImage(imageName:String) {
        let iconImage:UIImage? = UIImage(named:imageName);
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func setupSettingsMenu(parentView:UIView) {
        let width:CGFloat = ViewController.staticMainView!.frame.width - (self.frame.minX * 2.0);
        settingsMenu = UISettingsMenu(parentView: parentView, frame: CGRect(x: self.frame.minX, y: self.frame.minY, width: width, height: self.frame.height));
        parentView.bringSubviewToFront(self);
        settingsMenu!.reduceSettingsMenuAndContents();
    }
    
    @objc func settingsMenuSelector(){
        if (isPressable) {
            isPressable = false;
            // Settings button pressed
            if(!isPressed){
                ViewController.staticMainView!.bringSubviewToFront(settingsMenu!);
                ViewController.staticMainView!.bringSubviewToFront(self);
                ViewController.staticMainView!.bringSubviewToFront(settingsMenu!.mouseCoin!.mouseCoinView!);
                if (ViewController.aspectRatio! != .ar19point5by9) {
                    settingsMenu!.mouseCoin!.mouseCoinView!.transform(frame: settingsMenu!.mouseCoin!.mouseCoinView!.originalFrame!);
                }
                settingsMenu!.mouseCoin!.setStyle();
                boardGame!.cats.clearCatButtons();
                boardGame!.attackMeter!.pauseVirusMovement();
                settingsMenuShow();
            } else {
                // Settings button unpressed
                if (ViewController.aspectRatio! != .ar19point5by9) {
                    settingsMenu!.mouseCoin!.mouseCoinView!.transform(frame: settingsMenu!.mouseCoin!.mouseCoinView!.reducedFrame!);
                }
                settingsMenu!.mouseCoin!.mouseCoinView!.backgroundColor = UIColor.clear;
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
            self.settingsMenu!.enlargeSettingsMenuAndContents();
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
            self.settingsMenu!.reduceSettingsMenuAndContents();
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
            self.layer.borderColor = UIColor.black.cgColor;
            self.backgroundColor = UIColor.white;
            setIconImage(imageName: "darkGear.png");
            settingsMenu!.setStyleAndElementsStyle();
        } else {
            self.layer.borderColor = UIColor.white.cgColor;
            self.backgroundColor = UIColor.black;
            setIconImage(imageName: "lightGear.png");
            settingsMenu!.setStyleAndElementsStyle();
        }
    }
    
    func setBoardGameAndColorOptionsView(boardGameView:UIBoardGame, colorOptionsView:UIColorOptions) {
        self.boardGame = boardGameView;
        self.colorOptionsView = colorOptionsView;
        self.settingsMenu!.mouseCoin!.mouseCoinView!.frame = boardGame!.attackMeter!.frame;
        CenterController.center(childView: self.settingsMenu!.mouseCoin!.amountLabel!, parentRect: self.settingsMenu!.mouseCoin!.mouseCoinView!.frame, childRect: self.settingsMenu!.mouseCoin!.amountLabel!.frame);
        self.settingsMenu!.mouseCoin!.mouseCoinView!.reducedFrame = boardGame!.attackMeter!.frame;
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
