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
    

    let mainView:UIView = ViewController.staticMainView!;

    // Settings views
    var settingsButton:UISettingsButton?
    var settingsMenuFrame:CGRect?
    var settingsMouseCoinFrame:CGRect?
    
    var label:UICLabel?
    var unitHeight:CGFloat = 0.0;
    var awardAmount:Int = 0;
    var watchAdButton:UICButton?
    var mouseCoin:UIMouseCoin?
    
    var deadCat:UIImageView?
    var cheeringCat:UIImageView?
    var catsSavedCountLabel:UICLabel?
    var catsDeadCountLabel:UICLabel?
    var catImage:UIImage?
    
    // Save number of coins
    var keyValueStore:NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore();
    
    init(parentView:UIView, frame:CGRect) {
        super.init(parentView: parentView, x: frame.minX, y: frame.minY, width: frame.width * 0.95, height: frame.height * 0.95, backgroundColor: UIColor.clear);
        self.layer.cornerRadius = frame.width / 7.0;
        self.layer.borderWidth = frame.width * 0.02;
        unitHeight = frame.height * 0.1;
        self.clipsToBounds = true;
        setupLabel();
        setupCheeringCat();
        setupDeadCat();
        setupWatchAdForMouseCoinButton();
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabel() {
        label = UICLabel(parentView: self, x: 0.0, y: unitHeight * 0.25, width: frame.width, height: unitHeight * 2.0);
        label!.font = UIFont.boldSystemFont(ofSize: label!.frame.height * 0.375);
        label!.text = "You Won!";
        ViewController.updateFont(label: label!)
    }
    
    func setupCheeringCat() {
        cheeringCat = UIImageView(frame: CGRect(x: frame.width * 0.04, y: unitHeight * 1.75, width: frame.width * 0.5, height: unitHeight * 4.5));
        cheeringCat!.image = UIImage(named: UICatButton.getCatFileName(named: "SmilingCat", selectedCat: .standard));
        cheeringCat!.contentMode = UIView.ContentMode.scaleAspectFit;
        cheeringCat!.transform = cheeringCat!.transform.scaledBy(x: 1.25, y: 1.25);
        self.addSubview(cheeringCat!);
        setupCatsLivedLabel();
    }
    
    func setupCatsLivedLabel() {
        catsSavedCountLabel = UICLabel(parentView: self, x: cheeringCat!.frame.minX, y: cheeringCat!.frame.maxY - unitHeight * 0.6, width: cheeringCat!.frame.width, height: unitHeight);
        catsSavedCountLabel!.font = UIFont.boldSystemFont(ofSize: catsSavedCountLabel!.frame.height * 0.6);
        catsSavedCountLabel!.text = "0";
    }
    
    func setupDeadCat() {
        deadCat = UIImageView(frame: CGRect(x: frame.width * 0.46, y: unitHeight * 1.75, width: frame.width * 0.5, height: unitHeight * 4.5));
        deadCat!.image =  UIImage(named: UICatButton.getCatFileName(named: "DeadCat", selectedCat: .standard));
        deadCat!.contentMode = UIView.ContentMode.scaleAspectFit;
        deadCat!.transform = deadCat!.transform.scaledBy(x: 1.25, y: 1.25);
        self.addSubview(deadCat!);
        setupCatsDeadLabel();
    }
    
    func setupCatsDeadLabel() {
        catsDeadCountLabel = UICLabel(parentView: self, x: deadCat!.frame.minX, y: deadCat!.frame.maxY - unitHeight * 0.6, width: deadCat!.frame.width, height: unitHeight);
        catsDeadCountLabel!.font = UIFont.boldSystemFont(ofSize: catsDeadCountLabel!.frame.height * 0.6);
        catsDeadCountLabel!.text = "0";
    }
    
    func setupWatchAdForMouseCoinButton() {
        watchAdButton = UICButton(parentView: self, frame: CGRect(x: 0.0, y: unitHeight * 7.6, width: unitHeight * 7.25, height: unitHeight * 1.25), backgroundColor: UIColor.clear);
        watchAdButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: watchAdButton!.frame.height * 0.37);
        watchAdButton!.setTitle("Watch Short Ad to Win + ····· s!", for: .normal);
        watchAdButton!.layer.borderWidth = watchAdButton!.frame.height * 0.08;
        watchAdButton!.layer.cornerRadius = watchAdButton!.frame.width * 0.05;
        CenterController.centerHorizontally(childView: watchAdButton!, parentRect: self.frame, childRect: watchAdButton!.frame);
        watchAdButton!.addTarget(self, action: #selector(watchAdButtonSelector), for: .touchUpInside);
        watchAdButton!.layer.borderColor = UIColor.systemYellow.cgColor;
        watchAdButton!.alpha = 0.0;
        ViewController.updateFont(button: watchAdButton!);
        setupMouseCoin();
    }
    
    func setupMouseCoin() {
        var x:CGFloat?
        var y:CGFloat?
        var sideLength:CGFloat?
        if (ViewController.aspectRatio! == .ar4by3) {
            sideLength = watchAdButton!.frame.height * 0.65;
            x = watchAdButton!.frame.width * 0.77;
            y = watchAdButton!.frame.height * 0.175;
        } else if (ViewController.aspectRatio! == .ar16by9) {
            sideLength = watchAdButton!.frame.height * 0.75;
            x = watchAdButton!.frame.width * 0.775;
            y = watchAdButton!.frame.height * 0.125;
        } else {
            sideLength = watchAdButton!.frame.height * 0.75;
            x = watchAdButton!.frame.width * 0.775;
            y = watchAdButton!.frame.height * 0.125;
        }
        mouseCoin = UIMouseCoin(parentView: watchAdButton!, x: x!, y: y!, width: sideLength!, height: sideLength!);
        mouseCoin!.addTarget(self, action: #selector(watchAdButtonSelector), for: .touchUpInside);
        mouseCoin!.alpha = 0.0;
    }
    
    @objc func watchAdButtonSelector() {
        UIResults.adIsShowing = true;
        ViewController.presentInterstitial();
        var timer:Timer?
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
            if (ViewController.interstitialWillPresentScreen) {
                ViewController.interstitialWillPresentScreen = false;
                SoundController.mozartSonata(play: false, startOver: false);
                timer!.invalidate();
                // Wait for the ad to be dismissed
                timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
                    if (ViewController.interstitialWillDismissScreen) {
                        ViewController.interstitialWillDismissScreen = false;
                        SoundController.mozartSonata(play: true, startOver: false);
                        timer!.invalidate();
                        // Give mouse coins and hide mouse coin and label
                        self.awardAmount = UIResults.rewardAmount;
                        self.giveMouseCoins();
                        if (UIResults.rewardAmount < 20) {
                            UIResults.rewardAmount += 1;
                        }
                        self.watchAdButton!.titleLabel!.alpha = 0.0;
                        self.mouseCoin!.alpha = 0.0;
                        self.watchAdButton!.isUserInteractionEnabled = false;
                    }
                })
            }
        })
    }
    
    var giveMouseCoinsTimer:Timer?
    func showVictoryMessageAndGiveMouseCoins(catsSaved:Int, catsDied:Int) {
        catsSavedCountLabel!.text = "\(catsSaved)";
        catsDeadCountLabel!.text = "\(catsDied)";
        giveMouseCoinsTimer?.invalidate();
        giveMouseCoinsTimer = nil;
        giveMouseCoinsTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
            if (self.alpha == 1.0) {
                self.giveMouseCoins();
                self.mouseCoin!.alpha = 1.0;
                self.watchAdButton!.alpha = 1.0;
                self.giveMouseCoinsTimer!.invalidate();
                print("YESS")
            }
        })
    }
    
    var angleIncrements:CGFloat?
    var currentAngle:CGFloat?
    var mouseCoinX:CGFloat?
    var mouseCoinY:CGFloat?
    var givenMouseCoin:UIMouseCoin?
    func giveMouseCoins() {
        // Set angles
        angleIncrements = 360.0 / CGFloat(awardAmount);
        currentAngle = -90.0;
        // Mouse coin X and Y
        // Radially position mouse coins
        for index in 0..<awardAmount {
            // Set X and Y
            mouseCoinX = mainView.center.x - (settingsMouseCoinFrame!.height * 0.5) + (mainView.frame.width * 0.25) * (cos(currentAngle! * CGFloat.pi / 180.0));
            mouseCoinY = mainView.center.y - (settingsMouseCoinFrame!.width * 0.5) + (mainView.frame.height * 0.25) * (sin(currentAngle! * CGFloat.pi / 180.0));
            // Generate mouse coin
            givenMouseCoin  = UIMouseCoin(parentView: mainView, x: mouseCoinX!, y: mouseCoinY!, width: settingsMouseCoinFrame!.width, height: settingsMouseCoinFrame!.height);
            // Calculate time for translation
            ViewController.staticMainView!.bringSubviewToFront(givenMouseCoin!);
            UIView.animate(withDuration: 1.0, delay: 0.125, options: [.curveEaseInOut], animations: {
               self.givenMouseCoin!.frame = CGRect(x: self.settingsMenuFrame!.minX + self.settingsMouseCoinFrame!.minX, y: self.settingsMenuFrame!.minY + self.settingsMouseCoinFrame!.minY, width: self.settingsMouseCoinFrame!.width, height: self.settingsMouseCoinFrame!.height);
            }, completion: { _ in
                SoundController.coinEarned();
                self.givenMouseCoin!.removeFromSuperview();
                if (index == UIResults.rewardAmount - 1) {
                    ViewController.staticSelf!.settingsButton!.settingsMenu!.mouseCoin!.setMouseCoinValue(newValue: UIResults.mouseCoins + Int64(UIResults.rewardAmount));
                    self.keyValueStore.set(UIResults.mouseCoins + Int64(UIResults.rewardAmount), forKey: "mouseCoins");
                    self.keyValueStore.synchronize();
                    self.settingsButton!.settingsMenu!.mouseCoin!.sendActions(for: .touchUpInside);
                }
            })
            // Increment angle
            currentAngle! += angleIncrements!;
        }
    }
    
    
    func setCompiledStyle() {
        watchAdButton!.setStyle();
        watchAdButton!.layer.borderColor = UIColor.systemYellow.cgColor;
        if (ViewController.uiStyleRawValue == 1) {
            self.backgroundColor = UIColor.white;
            self.layer.borderColor = UIColor.black.cgColor;
        } else {
            self.backgroundColor = UIColor.black;
            self.layer.borderColor = UIColor.white.cgColor;
        }
        
    }
    
}
