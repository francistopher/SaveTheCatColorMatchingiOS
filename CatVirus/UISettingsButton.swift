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
    var settingsMenu:UICView? = nil;
    
    var colorOptionsView:UIColorOptions? = nil;
    var boardGame:UIBoardGame? = nil;
    var cellFrame:CGRect? = nil;
    
    var mouseCoin:UIMouseCoin? = nil;
    var moreCats:UIMoreCats? = nil;
    var multiplayer:UIMultiplayer? = nil;
    var restart1:UIRestart1? = nil;
    var stats:UIStats? = nil;
    var noAds:UINoAds? = nil;
    
    var gearSpinningPath:String? = nil;
    var gearSpinningURL:URL? = nil;
    var gearSpinningSoundEffect:AVAudioPlayer?
    
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
        configureMouseCoinButton(parentView:settingsMenu!);
        configureMoreCatsButton(parentView:settingsMenu!);
        configureMultiplayerButton(parentView:settingsMenu!);
        configureRestart1Button(parentView:settingsMenu!);
        configureStatsButton(parentView:settingsMenu!);
        configureNoAdsButton(parentView:settingsMenu!);
        settingsMenu!.frame = CGRect(x: self.frame.midX * 0.7, y: self.frame.minY, width: cellFrame!.width * 1.75, height: settingsMenu!.frame.height);
        settingsMenu!.reducedFrame = settingsMenu!.frame;
        setStyle();
        configureGearSpinning();
        self.addTarget(self, action: #selector(settingsMenuSelector), for: .touchUpInside);
    }
    
    func configureGearSpinning() {
           gearSpinningPath = Bundle.main.path(forResource: "gearSpinning.mp3", ofType: nil);
           gearSpinningURL = URL(fileURLWithPath: gearSpinningPath!);
           do {
                gearSpinningSoundEffect = try AVAudioPlayer(contentsOf: gearSpinningURL!);
            gearSpinningSoundEffect!.volume = 0.5;
           } catch {
               print("Unable to play gearSpinning sound effect.");
           }
       }
    
    func gearSpinning() {
        gearSpinningSoundEffect!.stop();
        gearSpinningSoundEffect!.play();
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
        cellFrame = CGRect(x: cellFrame!.width / 7.0, y: 0.0, width: settingsMenu!.frame.width / 8.0, height: settingsMenu!.frame.height);
    }
    
    func configureNoAdsButton(parentView:UICView!) {
        noAds = UINoAds(parentView: parentView, x: cellFrame!.width * 1.05, y: 0.0, width: cellFrame!.width, height: cellFrame!.height);
        noAds!.frame = CGRect(x: -cellFrame!.width * 0.25, y: noAds!.frame.minY, width: noAds!.frame.width, height: noAds!.frame.height);
        noAds!.reducedFrame = noAds!.frame;
    }
    
    func configureRestart1Button(parentView:UICView) {
        restart1 = UIRestart1(parentView: parentView, x: cellFrame!.width * 2.25, y: 0.0, width: cellFrame!.width, height: cellFrame!.height);
        restart1!.frame = CGRect(x: -cellFrame!.width * 0.25, y: restart1!.frame.minY, width: restart1!.frame.width, height: restart1!.frame.height);
        restart1!.reducedFrame = restart1!.frame;
    }
    
    func configureStatsButton(parentView:UICView!) {
        stats = UIStats(parentView: parentView, x: cellFrame!.width * 3.40, y: 0.0, width: cellFrame!.width, height: cellFrame!.height);
        stats!.frame = CGRect(x: -cellFrame!.width * 0.25, y: stats!.frame.minY, width: stats!.frame.width, height: stats!.frame.height);
        stats!.reducedFrame = stats!.frame;
    }
    
    func configureMultiplayerButton(parentView:UICView) {
        multiplayer = UIMultiplayer(parentView: parentView, x: cellFrame!.width * 4.60, y: 0.0, width: cellFrame!.width, height: cellFrame!.height);
        multiplayer!.frame = CGRect(x: -cellFrame!.width * 0.25, y: multiplayer!.frame.minY, width: multiplayer!.frame.width, height: multiplayer!.frame.height);
        multiplayer!.reducedFrame = multiplayer!.frame;
    }
    
    func configureMoreCatsButton(parentView:UICView) {
        moreCats = UIMoreCats(parentView: parentView, x: cellFrame!.width * 5.80, y: 0.0, width: cellFrame!.width, height: cellFrame!.height);
        moreCats!.frame = CGRect(x: -cellFrame!.width * 0.25, y: moreCats!.frame.minY, width: moreCats!.frame.width, height: moreCats!.frame.height);
        moreCats!.reducedFrame = moreCats!.frame;
    }
    
    func configureMouseCoinButton(parentView:UICView){
        mouseCoin = UIMouseCoin(parentView: parentView, x: cellFrame!.width * 6.965, y: 0.0, width: cellFrame!.width, height: cellFrame!.height * 1.025);
        mouseCoin!.frame = CGRect(x: cellFrame!.width * 0.725, y: mouseCoin!.frame.minY, width: mouseCoin!.frame.width, height:  mouseCoin!.frame.height);
        mouseCoin!.reducedFrame = mouseCoin!.frame;
    }
    
    func configureSettingsMenu(parentView:UIView) {
        settingsMenu = UICView(parentView: parentView, x: self.frame.midX * 0.75, y: self.frame.minY, width: parentView.frame.width * 0.8575, height: self.frame.height, backgroundColor: .clear);
        settingsMenu!.layer.cornerRadius = settingsMenu!.frame.height / 2.0;
        settingsMenu!.layer.borderWidth = self.frame.height / 12.0;
        parentView.bringSubviewToFront(self);
    }
    
    @objc func settingsMenuSelector(){
        gearSpinning();
        if(!isPressed){
            boardGame!.attackMeter!.stopVirusMovement();
            settingsMenuShow();
        }else{
            settingsMenuHide();
            boardGame!.attackMeter!.restartVirusMovement();
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
            self.mouseCoin!.frame = self.mouseCoin!.originalFrame!;
            self.moreCats!.frame = self.moreCats!.originalFrame!;
            self.multiplayer!.frame = self.multiplayer!.originalFrame!;
            self.stats!.frame = self.stats!.originalFrame!;
            self.restart1!.frame = self.restart1!.originalFrame!;
            self.noAds!.frame = self.noAds!.originalFrame!;
        })
        colorOptionsView!.isUserInteractionEnabled = false;
        boardGame!.isUserInteractionEnabled = false;
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
            self.mouseCoin!.frame = self.mouseCoin!.reducedFrame!;
            self.moreCats!.frame = self.moreCats!.reducedFrame!;
            self.multiplayer!.frame = self.multiplayer!.reducedFrame!;
            self.stats!.frame = self.stats!.reducedFrame!;
            self.restart1!.frame = self.restart1!.reducedFrame!;
            self.noAds!.frame = self.noAds!.reducedFrame!;
        })
        colorOptionsView!.isUserInteractionEnabled = true;
        boardGame!.isUserInteractionEnabled = true;
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
        moreCats!.setStyle();
        multiplayer!.setStyle();
        stats!.setStyle();
        restart1!.setStyle();
        noAds!.setStyle();
    }
    
    func setBoardGameAndColorOptionsView(boardGameView:UIBoardGame, colorOptionsView:UIColorOptions) {
        self.boardGame = boardGameView;
        self.colorOptionsView = colorOptionsView;
        self.restart1!.setTargetResources(boardGameView: boardGameView, settingsButton: self);
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
