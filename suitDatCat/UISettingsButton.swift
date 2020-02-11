//
//  UISettingsButton.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/9/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
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
    var bak2sqr1Label:UICLabel? = nil;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        self.backgroundColor = backgroundColor;
        self.layer.cornerRadius = height / 2.0625;
        self.layer.borderWidth = self.frame.height / 12.0;
        self.setTitle("···", for: .normal);
        self.titleLabel!.font = UIFont.boldSystemFont(ofSize: height / 2.0);
        parentView.addSubview(self);
        configureSettingsMenu(parentView:parentView);
        self.cellFrame = CGRect(x:0, y:0, width:settingsMenu!.frame.width, height: settingsMenu!.frame.height / 6.0);
        configureTitleLabel();
        configureRestartButton();
        configureBak2Sqr1Button();
        setStyle();
        self.addTarget(self, action: #selector(settingsMenuSelector), for: .touchUpInside);
    }
    
    func configureTitleLabel(){
        settingsTitle = UICLabel(parentView: settingsMenu!, x: 0.0, y: 0.0, width: cellFrame!.width, height: cellFrame!.height);
        settingsTitle!.text = "Settings";
        settingsTitle!.font = UIFont.boldSystemFont(ofSize: settingsTitle!.frame.height * 0.375);
        settingsTitle!.layer.cornerRadius = settingsMenu!.layer.cornerRadius;
        settingsTitle!.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner];
        settingsTitle!.layer.borderWidth = settingsMenu!.layer.borderWidth;
    }
    
    func configureRestartButton(){
        restartButton = UICButton(parentView: settingsMenu!, x: 0.0, y: cellFrame!.height, width: cellFrame!.width, height: cellFrame!.height, backgroundColor: .clear);
        restartButton!.setTitle("Restart", for: .normal);
        restartButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: restartButton!.frame.height * 0.375);
        settingsMenu!.addSubview(restartButton!);
        restartButton!.addTarget(self, action: #selector(restartButtonSelector), for: .touchUpInside);
        restartButton!.layer.cornerRadius = 0.0;
    }
    
    @objc func restartButtonSelector() {
           boardGameView!.restart(promote: false);
           self.sendActions(for: .touchUpInside);
       }
    
    func configureBak2Sqr1Button(){
        bak2sqr1Label = UICLabel(parentView: settingsMenu!, x: 0, y: cellFrame!.height * 2, width: cellFrame!.width, height: cellFrame!.height);
        let spacesCount:Int = Int(cellFrame!.width / 100.0) * 2;
        var text:String = "";
        for _ in 0..<spacesCount {
            text += " ";
        }
        bak2sqr1Label!.text = text + "bak2sqr1";
        bak2sqr1Label!.font = UIFont.boldSystemFont(ofSize: bak2sqr1Label!.frame.height * 0.375);
        bak2sqr1Label!.layer.cornerRadius = 0.0;
        bak2sqr1Label!.layer.borderWidth = settingsMenu!.layer.borderWidth;
        bak2sqr1Label!.textAlignment = NSTextAlignment.left;
        
        let bak2sqr1Switch:UICSwitch = UICSwitch(parentView: bak2sqr1Label!, x: 0, y: 0, width: bak2sqr1Label!.frame.width * 0.75, height: bak2sqr1Label!.frame.height * 0.75, backgroundColor: .clear);
        UICenterKit.centerWithHorizontalDisplacement(childView: bak2sqr1Switch, parentRect: bak2sqr1Label!.frame, childRect: bak2sqr1Switch.frame, horizontalDisplacement: bak2sqr1Label!.frame.width * 0.25);
        bak2sqr1Switch.setOn(true, animated: true);
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
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseInOut, animations: {
            self.settingsMenu!.alpha = 1.0;
        });
        colorOptionsView!.isUserInteractionEnabled = false;
        boardGameView!.isUserInteractionEnabled = false;
    }
    
    @objc func settingsMenuHide(){
        print("Unselected");
        isPressed = false;
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseInOut, animations: {
            self.settingsMenu!.alpha = 0.0;
        });
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
            self.backgroundColor = UIColor.white;
            self.setTitleColor(UIColor.black, for: .normal);
            self.layer.borderColor = UIColor.black.cgColor;
            // Settings menu colors
            self.settingsMenu!.layer.borderColor = UIColor.black.cgColor;
            self.settingsMenu!.backgroundColor = UIColor.white;
            // Settings menu title
            self.settingsTitle!.layer.borderColor = UIColor.black.cgColor;
            // Restart button in white
            self.restartButton!.setTitleColor(UIColor.white, for: .normal);
            self.restartButton!.backgroundColor = UIColor.black;
            // bak2sqr1 button in white
            self.bak2sqr1Label!.textColor = UIColor.black;
            self.bak2sqr1Label!.layer.borderColor = UIColor.black.cgColor;
        } else {
            // Setting button colors
            self.backgroundColor = UIColor.black;
            self.setTitleColor(UIColor.white, for: .normal);
            self.layer.borderColor = UIColor.white.cgColor;
            // Setting menu colors
            self.settingsMenu!.layer.borderColor = UIColor.white.cgColor;
            self.settingsMenu!.backgroundColor = UIColor.black;
            // Settings menu title
            self.settingsTitle!.layer.borderColor = UIColor.white.cgColor;
            // Restart button in black
            self.restartButton!.setTitleColor(UIColor.black, for: .normal);
            self.restartButton!.backgroundColor = UIColor.white;
            // bak2sqr1 button in black
            self.bak2sqr1Label!.textColor = UIColor.white;
            self.bak2sqr1Label!.layer.borderColor = UIColor.white.cgColor;
        }
        
    }
}
