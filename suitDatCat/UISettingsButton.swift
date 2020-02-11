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
    
    var restartButton:UICButton? = nil;
    var colorOptionsView:UIColorOptionsView? = nil;
    
    
    var boardGameView:UIBoardGameView? = nil;
    var cellFrame:CGRect? = nil;
    
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
        self.cellFrame = CGRect(x:0, y:0, width:settingsMenu!.frame.width, height: settingsMenu!.frame.height / 5.0);
        configureRestartButton();
        setStyle();
        self.addTarget(self, action: #selector(selector), for: .touchUpInside);
    }
    
    
    func configureSettingsMenu(parentView:UIView) {
        settingsMenu = UICView(parentView: parentView, x: 0, y: 0, width: parentView.frame.width / 1.75, height: parentView.frame.height / 1.75, backgroundColor: UIColor.white);
        settingsMenu!.layer.cornerRadius = settingsMenu!.frame.width / 8.0;
        settingsMenu!.layer.borderWidth = self.frame.height / 12.0;
        UICenterKit.center(childView: settingsMenu!, parentRect: parentView.frame, childRect: settingsMenu!.frame);
        settingsMenu!.alpha = 0.0;
    }
    
    func configureRestartButton(){
        restartButton = UICButton(parentView: settingsMenu!, x: 0, y: 0, width: cellFrame!.width, height: cellFrame!.height, backgroundColor: .lightGray);
        restartButton!.setTitle("Restart", for: .normal);
        restartButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: restartButton!.frame.height / 2.0);
        restartButton!.layer.cornerRadius = settingsMenu!.layer.cornerRadius;
        restartButton!.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner];
        settingsMenu!.addSubview(restartButton!);
        restartButton!.addTarget(self, action: #selector(restartButtonSelector), for: .touchUpInside);
    }
    
    @objc func restartButtonSelector() {
        boardGameView!.restart(promote: false);
    }
    
    func setStyle(){
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            self.backgroundColor = UIColor.white;
            self.setTitleColor(UIColor.black, for: .normal);
            self.layer.borderColor = UIColor.black.cgColor;
            self.settingsMenu!.layer.borderColor = UIColor.black.cgColor;
            self.settingsMenu!.backgroundColor = UIColor.white;
            // Restart button in white
            self.restartButton!.setTitleColor(UIColor.black, for: .normal);
            self.restartButton!.layer.borderColor = UIColor.black.cgColor;
        } else {
            self.backgroundColor = UIColor.black;
            self.setTitleColor(UIColor.white, for: .normal);
            self.layer.borderColor = UIColor.white.cgColor;
            self.settingsMenu!.layer.borderColor = UIColor.white.cgColor;
            self.settingsMenu!.backgroundColor = UIColor.black;
            // Restart button in black
            self.restartButton!.setTitleColor(UIColor.white, for: .normal);
            self.restartButton!.titleLabel!.textColor = UIColor.white;
        }
        
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
    
    @objc func selector(){
        if(!isPressed){
            print("Selected");
            isPressed = true;
            UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseIn, animations: {
                self.settingsMenu!.alpha = 1.0;
            });
            colorOptionsView!.isUserInteractionEnabled = false;
            boardGameView!.isUserInteractionEnabled = false;
        }else{
            print("Unselected");
            isPressed = false;
            UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseIn, animations: {
                self.settingsMenu!.alpha = 0.0;
            });
            colorOptionsView!.isUserInteractionEnabled = true;
            boardGameView!.isUserInteractionEnabled = true;
        }
    }
    
}
