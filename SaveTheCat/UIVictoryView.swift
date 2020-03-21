//
//  UIVictoryView.swift
//  SaveTheCat
//
//  Created by Christopher Francisco on 3/20/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import UIKit


class UIVictoryView:UICView {
    
    var label:UICLabel?
    var unitHeight:CGFloat = 0.0;
    var imageView:UIImageView?
    var image:UIImage?
    var awardAmount:Int = 0;
    var watchAdButton:UICButton?
    
    // Save number of coins
    var keyValueStore:NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore();
    
    init(parentView:UIView, frame:CGRect) {
        super.init(parentView: parentView, x: frame.minX, y: frame.minY, width: frame.width * 0.95, height: frame.height * 0.95, backgroundColor: UIColor.clear);
        self.layer.cornerRadius = frame.width / 5.0;
        self.layer.borderWidth = frame.width * 0.02;
        unitHeight = frame.height * 0.1;
        self.clipsToBounds = true;
        setupLabel();
        setupWatchAdForMouseCoinButton();
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabel() {
        label = UICLabel(parentView: self, x: 0.0, y: unitHeight * 0.25, width: frame.width, height: unitHeight * 2.0);
        label!.font = UIFont.boldSystemFont(ofSize: label!.frame.height * 0.3);
        label!.lineBreakMode = NSLineBreakMode.byWordWrapping;
        label!.numberOfLines = 2;
    }
    
    func setupWatchAdForMouseCoinButton() {
        watchAdButton = UICButton(parentView: self, frame: CGRect(x: 0.0, y: unitHeight * 7.6, width: unitHeight * 6.5, height: unitHeight * 1.25), backgroundColor: UIColor.clear);
        watchAdButton!.layer.cornerRadius = watchAdButton!.frame.width * 0.08
        CenterController.centerHorizontally(childView: watchAdButton!, parentRect: self.frame, childRect: watchAdButton!.frame);
        
    }
    
    func showVictoryMessageAndGifWith(text:String) {
        label!.text = text;
        setupImageView();
    }
    
    func setupImageView() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
            SoundController.cuteLaugh();
            self.giveMouseCoins();
        })
        imageView?.removeFromSuperview();
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            imageView = UIImageView(image: UIImage.gifImageWithName("blackBorderGal")!);
        } else {
            imageView = UIImageView(image: UIImage.gifImageWithName("whiteBorderGal")!);
        }
        imageView!.frame =  CGRect(x: 0.0, y: unitHeight * 2.25, width: unitHeight * 5, height: unitHeight * 5);
        CenterController.centerHorizontally(childView: imageView!, parentRect: self.frame, childRect: imageView!.frame);
        self.addSubview(imageView!);
    }
    
    func giveMouseCoins() {
        let mainView:UIView = ViewController.staticMainView!;
        // Set angles
        let angleIncrements:CGFloat = 360.0 / CGFloat(awardAmount);
        var currentAngle:CGFloat = -90.0;
        // Settings views
        let settingsButton:UISettingsButton = ViewController.settingsButton!;
        let settingsMenuFrame:CGRect = settingsButton.settingsMenu!.frame;
        let settingsMouseCoinFrame:CGRect = settingsButton.settingsMenu!.mouseCoin!.frame;
        // Mouse coin X and Y
        var mouseCoinX:CGFloat
        var mouseCoinY:CGFloat
        // Radially position mouse coins
        for index in 0..<awardAmount {
            // Set X and Y
            mouseCoinX = mainView.center.x - (settingsMouseCoinFrame.height * 0.5);
            mouseCoinY = mainView.center.y - (settingsMouseCoinFrame.width * 0.5);
            mouseCoinX += (mainView.frame.width * 0.25) * (cos(currentAngle * CGFloat.pi / 180.0));
            mouseCoinY += (mainView.frame.height * 0.25) * (sin(currentAngle * CGFloat.pi / 180.0));
            // Generate mouse coin
            let mouseCoin:UIMouseCoin = UIMouseCoin(parentView: mainView, x: mouseCoinX, y: mouseCoinY, width: settingsMouseCoinFrame.width, height: settingsMouseCoinFrame.height);
            // Calculate time for translation
            let boardGameFrame:CGRect = self.superview!.frame;
            let time:Double = Double(mouseCoin.frame.minX / (boardGameFrame.minX + boardGameFrame.width));
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                ViewController.staticMainView!.bringSubviewToFront(mouseCoin);
                UIView.animate(withDuration: 1.0, delay: 0.125, options: [.curveEaseInOut], animations: {
                    let newMouseCoinFrame:CGRect = CGRect(x: settingsMenuFrame.minX + settingsMouseCoinFrame.minX, y: settingsMenuFrame.minY + settingsMouseCoinFrame.minY, width: settingsMouseCoinFrame.width, height: settingsMouseCoinFrame.height);
                    mouseCoin.frame = newMouseCoinFrame;
                }, completion: { _ in
                    SoundController.coinEarned();
                    mouseCoin.removeFromSuperview();
                    if (index == UIResults.rewardAmount - 1) {
                        ViewController.staticSelf!.settingsButton!.settingsMenu!.mouseCoin!.setMouseCoinValue(newValue: UIResults.mouseCoins + Int64(UIResults.rewardAmount));
                        self.keyValueStore.set(UIResults.mouseCoins + Int64(UIResults.rewardAmount), forKey: "mouseCoins");
                        self.keyValueStore.synchronize();
                        settingsButton.settingsMenu!.mouseCoin!.sendActions(for: .touchUpInside);
                    }
                })
            }
            // Increment angle
            currentAngle += angleIncrements;
        }
    }
    
    
    func setCompiledStyle() {
        if (self.alpha > 0.0) {
            setupImageView();
        }
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            self.backgroundColor = UIColor.white;
            self.layer.borderColor = UIColor.black.cgColor;
        } else {
            self.backgroundColor = UIColor.black;
            self.layer.borderColor = UIColor.white.cgColor;
        }
    }
    
}
