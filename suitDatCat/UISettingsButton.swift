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

    var settingsTitle:UICLabel? = nil;
    var restartButton:UICButton? = nil;
    
    var bak2sqr1ButtonAsALabel:UICButton? = nil;
    var bak2sqr1Switch:UICSwitch? = nil;
    var invokedByPressureSwitch:Bool = false;
    
    var pressureButtonAsALabel:UICButton? = nil;
    var pressureSwitch:UICSwitch? = nil;
    
    var statsButton:UICButton? = nil;
    var multiplayerButton:UICButton? = nil;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        self.backgroundColor = backgroundColor;
        self.layer.cornerRadius = height / 2.0625;
        self.layer.borderWidth = self.frame.height / 12.0;
        parentView.addSubview(self);
//        configureSettingsMenu(parentView:parentView);
//        self.cellFrame = CGRect(x:0.0, y:0.0, width:settingsMenu!.frame.width,
//                                height: settingsMenu!.frame.height / 6.0);
//        configureTitleLabel();
//        configureRestartButton();
//        configureBak2Sqr1Label();
//        configureUnderPressureLabel();
//        configureStatsButton();
//        configureMultiplayerButton();
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
    
    func configureTitleLabel(){
        settingsTitle = UICLabel(parentView: settingsMenu!, x: 0.0, y: cellFrame!.minY, width: cellFrame!.width, height: cellFrame!.height);
        settingsTitle!.text = "Settings";
        settingsTitle!.font = UIFont.boldSystemFont(ofSize: settingsTitle!.frame.height * 0.375);
        settingsTitle!.layer.cornerRadius = settingsMenu!.layer.cornerRadius;
        settingsTitle!.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner];
        settingsTitle!.layer.backgroundColor = UIColor.magenta.cgColor;
    }
    
    func configureRestartButton(){
        restartButton = UICButton(parentView: settingsMenu!, frame:CGRect( x: 0.0, y: cellFrame!.height, width: cellFrame!.width, height: cellFrame!.height), backgroundColor: .clear);
        restartButton!.setTitle("Restart", for: .normal);
        restartButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: restartButton!.frame.height * 0.375);
        settingsMenu!.addSubview(restartButton!);
        restartButton!.layer.cornerRadius = 0.0;
        restartButton!.addTarget(self, action: #selector(restartButtonSelector), for: .touchUpInside);
    }
    
    @objc func restartButtonSelector() {
           boardGameView!.restart();
           self.sendActions(for: .touchUpInside);
       }
    
    func configureBak2Sqr1Label(){
        bak2sqr1ButtonAsALabel = UICButton(parentView: settingsMenu!, frame:CGRect(x: 0.0, y: cellFrame!.height * 2, width: cellFrame!.width, height: cellFrame!.height), backgroundColor: .clear);
        let spacesCount:Int = Int(bak2sqr1ButtonAsALabel!.frame.width / 100.0) * 2;
        var text:String = "";
        for _ in 0..<spacesCount {
            text += " ";
        }
        bak2sqr1ButtonAsALabel!.setTitle(text + "Bak2sqr1", for: .normal);
        bak2sqr1ButtonAsALabel!.titleLabel!.font = UIFont.boldSystemFont(ofSize: bak2sqr1ButtonAsALabel!.frame.height * 0.375);
        bak2sqr1ButtonAsALabel!.layer.cornerRadius = 0.0;
        bak2sqr1ButtonAsALabel!.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left;
        configureBak2sqr1Switch();
    }
    
    func configureBak2sqr1Switch(){
        bak2sqr1Switch = UICSwitch(parentView: bak2sqr1ButtonAsALabel!,x: 0, y: 0, width: bak2sqr1ButtonAsALabel!.frame.height / 2.0, height: bak2sqr1ButtonAsALabel!.frame.height / 2.0, tintColor: UIColor.systemRed, onTintColor: UIColor.systemGreen);
        UICenterKit.centerWithHorizontalDisplacement(childView: bak2sqr1Switch!, parentRect: bak2sqr1ButtonAsALabel!.frame, childRect: bak2sqr1Switch!.frame, horizontalDisplacement: bak2sqr1ButtonAsALabel!.frame.width * 0.25);
        bak2sqr1Switch!.addTarget(self, action: #selector(bak2sqr1Selector), for: .valueChanged);
    }
    
    @objc func bak2sqr1Selector(){
        if (bak2sqr1Switch!.isOn){
            self.boardGameView!.bak2sqr1 = true;
            invokedByPressureSwitch = false;
        } else {
            self.boardGameView!.bak2sqr1 = false;
        }
    }
    
    func configureUnderPressureLabel(){
        pressureButtonAsALabel = UICButton(parentView: settingsMenu!, frame:CGRect(x: 0.0, y: cellFrame!.height * 3, width: cellFrame!.width, height: cellFrame!.height), backgroundColor: .clear);
        let spacesCount:Int = Int(cellFrame!.width / 100.0) * 2;
        var text:String = " ";
        for _ in 0..<spacesCount {
            text += " ";
        }
        pressureButtonAsALabel!.setTitle(text + "Pressure", for: .normal);
        pressureButtonAsALabel!.titleLabel!.font = UIFont.boldSystemFont(ofSize: bak2sqr1ButtonAsALabel!.frame.height * 0.375);
        pressureButtonAsALabel!.layer.cornerRadius = 0.0;
        pressureButtonAsALabel!.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left;
        configurePressureSwitch();
    }
    
    func configurePressureSwitch(){
        pressureSwitch = UICSwitch(parentView: pressureButtonAsALabel!, x: 0.0, y: 0.0, width: pressureButtonAsALabel!.frame.height / 2.0, height: pressureButtonAsALabel!.frame.height / 2.0, tintColor: UIColor.systemRed, onTintColor: UIColor.systemGreen);
        UICenterKit.centerWithHorizontalDisplacement(childView: pressureSwitch!, parentRect: pressureButtonAsALabel!.frame, childRect: pressureSwitch!.frame, horizontalDisplacement: pressureButtonAsALabel!.frame.width * 0.25);
        pressureSwitch!.addTarget(self, action: #selector(pressureSelector), for: .valueChanged);
    }
    
    @objc func pressureSelector() {
        if (pressureSwitch!.isOn) {
            if (!bak2sqr1Switch!.isOn) {
                print("Set bak2sqr1switch on");
                bak2sqr1Switch!.setOn(true, animated: true);
                invokedByPressureSwitch = true;
            }
        } else {
            if (invokedByPressureSwitch) {
                bak2sqr1Switch!.setOn(false, animated: true);
            }
        }
    }
    
    func configureStatsButton(){
        statsButton = UICButton(parentView: settingsMenu!, frame: CGRect( x: 0.0, y: cellFrame!.height * 4, width: cellFrame!.width, height: cellFrame!.height), backgroundColor: .clear);
        statsButton!.setTitle("Stats", for: .normal);
        statsButton!.layer.cornerRadius = 0.0;
        statsButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: statsButton!.frame.height * 0.375);
        settingsMenu!.addSubview(statsButton!);
    }
    
    func configureMultiplayerButton(){
        multiplayerButton = UICButton(parentView: settingsMenu!, frame: CGRect( x: 0.0, y: cellFrame!.height * 5, width: cellFrame!.width, height: cellFrame!.height), backgroundColor: .clear);
        multiplayerButton!.setTitle("Multiplayer", for: .normal);
        multiplayerButton!.layer.cornerRadius = settingsMenu!.layer.cornerRadius;
        multiplayerButton!.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner];
        multiplayerButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: multiplayerButton!.frame.height * 0.375);
        settingsMenu!.addSubview(multiplayerButton!);
    }
    
    func configureSettingsMenu(parentView:UIView) {
        settingsMenu = UICView(parentView: parentView, x: 0, y: 0, width: parentView.frame.width / 1.75, height: parentView.frame.height / 1.75, backgroundColor:.clear);
        settingsMenu!.layer.cornerRadius = settingsMenu!.frame.width / 8.0;
        settingsMenu!.layer.borderWidth = self.frame.height / 12.0;
        UICenterKit.center(childView: settingsMenu!, parentRect: parentView.frame, childRect: settingsMenu!.frame);
        settingsMenu!.alpha = 0.0;
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
            self.imageView!.transform = self.imageView!.transform.rotated(by: -CGFloat.pi / 2.0);
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                 self.imageView!.transform = self.imageView!.transform.rotated(by: -CGFloat.pi / 2.0);
            })
        }
        colorOptionsView!.isUserInteractionEnabled = false;
        boardGameView!.isUserInteractionEnabled = false;
    }
    
    @objc func settingsMenuHide(){
        print("Unselected");
        isPressed = false;
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
             self.imageView!.transform = self.imageView!.transform.rotated(by: CGFloat.pi / 2.0);
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                 self.imageView!.transform = self.imageView!.transform.rotated(by: CGFloat.pi / 2.0);
            })
        }
        colorOptionsView!.isUserInteractionEnabled = true;
        boardGameView!.isUserInteractionEnabled = true;
    }
    
    func hide(color:UIColor){
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseIn, animations: {
            self.alpha = 0.0;
        });
    }
    
    func show(){
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseIn, animations: {
            self.alpha = 1.0;
        });
    }
    
    func setStyle(){
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            // Settings button colors
            self.setTitleColor(UIColor.black, for: .normal);
            self.layer.borderColor = UIColor.black.cgColor;
            self.backgroundColor = UIColor.white;
            setIconImage(imageName: "darkGear.png");
//            // Settings menu colors
//            self.settingsMenu!.layer.borderColor = UIColor.black.cgColor;
//            self.settingsMenu!.backgroundColor = UIColor.white;
//            // Settings menu title
//            self.settingsTitle!.layer.borderColor = UIColor.black.cgColor;
//            self.settingsTitle!.textColor! = UIColor.white;
//            // Restart button in white
//            self.restartButton!.setTitleColor(UIColor.black, for: .normal);
//            self.restartButton!.backgroundColor = UIColor.white;
//            // bak2sqr1 button in white
//            self.bak2sqr1ButtonAsALabel!.setTitleColor(UIColor.white, for: .normal);
//            self.bak2sqr1ButtonAsALabel!.backgroundColor = UIColor.black;
//            // Pressure button in white
//            self.pressureButtonAsALabel!.setTitleColor(UIColor.black, for: .normal);
//            self.pressureButtonAsALabel!.backgroundColor = UIColor.white;
//            // Stats button in white
//            self.statsButton!.setTitleColor(UIColor.white, for: .normal);
//            self.statsButton!.backgroundColor = UIColor.black;
//            // Multiplayer button in white
//            self.multiplayerButton!.setTitleColor(UIColor.black, for: .normal);
//            self.multiplayerButton!.backgroundColor = UIColor.white;
        } else {
            // Setting button colors
            self.setTitleColor(UIColor.white, for: .normal);
            self.layer.borderColor = UIColor.white.cgColor;
            self.backgroundColor = UIColor.black;
            setIconImage(imageName: "lightGear.png");
//            // Setting menu colors
//            self.settingsMenu!.layer.borderColor = UIColor.white.cgColor;
//            self.settingsMenu!.backgroundColor = UIColor.black;
//            // Settings menu title
//            self.settingsTitle!.layer.borderColor = UIColor.white.cgColor;
//            self.settingsTitle!.textColor! = UIColor.black;
//            // Restart button in black
//            self.restartButton!.setTitleColor(UIColor.white, for: .normal);
//            self.restartButton!.backgroundColor = UIColor.black;
//            // bak2sqr1 button in black
//            self.bak2sqr1ButtonAsALabel!.setTitleColor(UIColor.black, for: .normal);
//            self.bak2sqr1ButtonAsALabel!.backgroundColor = UIColor.white;
//            // Pressure button in black
//            self.pressureButtonAsALabel!.setTitleColor(UIColor.white, for: .normal);
//            self.pressureButtonAsALabel!.backgroundColor = UIColor.black;
//            // Stats butting in black
//            self.statsButton!.setTitleColor(UIColor.black, for: .normal);
//            self.statsButton!.backgroundColor = UIColor.white;
//            // Multiplayer button in black
//            self.multiplayerButton!.setTitleColor(UIColor.white, for: .normal);
//            self.multiplayerButton!.backgroundColor = UIColor.black;
        }
    }
}
