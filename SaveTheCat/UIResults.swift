//
//  UIStatistics.swift
//  SaveTheCat
//
//  Created by Christopher Francisco on 2/20/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import UIKit
import GoogleMobileAds
import GameKit

class UIResults: UICView {
    
    static var selectedCat:Cat = .standard;
    static var mouseCoins:Int64 = 0;
    
    var gameOverLabel:UICLabel?
    
    var catsLivedLabel:UICLabel?
    var catsDiedLabel:UICLabel?
    var catsLivedAmountLabel:UICLabel?
    var catsDiedAmountLabel:UICLabel?
    var livedCatImageButton:UICButton?
    var deadCatImageButton:UICButton?
    
    var stagesLabel:UICLabel?
    var stagesRangeLabel:UICLabel?
    var durationLabel:UICLabel?
    var durationTimeLabel:UICLabel?
    var watchAdForXMouseCoins:UICButton?
    var adIsShowing:Bool = false;
    
    var unitHeight:CGFloat?
    
    // Survival and Death Count
    var entiretyOfCatsThatDied:Int = 0;
    var entiretyOfCatsThatSurvived:Int = 0;
    var catsThatDied:Int = 0;
    var catsThatLived:Int = 0;
    
    // Gameplay session time
    var sessionStartTime:Double = 0.0;
    var sessionEndTime:Double = 0.0;
    var sessionDuration:Double = 0.0;
    var colorMemoryCapacity:Int = 0;
    
    // Content panel
    var contentView:UICView?
    
    // Reward amount
    static var rewardAmount:Int = 5;
    var rewardAmountQuantity:[Int:Double] = [0:0, 5:1.0, 10:0.8, 15:00.6, 20:0.4, 25:0.2]
    var rewardAmountRate:[Int:Double] = [0:0.0, 5:1.0, 10:0.0, 15:0.0, 20:0.0, 25:0.0]
    var threshold:Double = 0.5;
    
    // Save the value of mouse coins
    var keyValueStore:NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore();
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView) {
        let y:CGFloat = (ViewController.staticMainView!.frame.height * ((1.0/300.0) + 0.08)) + (ViewController.staticUnitViewHeight * 1.9);
        super.init(parentView: parentView, x: 0.0, y: y, width: ViewController.staticUnitViewHeight * 7, height: ViewController.staticUnitViewHeight * 7.75, backgroundColor: .black);
        parentView.addSubview(self);
        self.layer.borderWidth = 0.0;
        self.layer.cornerRadius = ViewController.staticUnitViewHeight * 8.0 / 7.0;
        roundCorners(radius: self.frame.width * 0.5, [.topLeft, .topRight], lineWidth: 0.0);
        // Setup contents
        setupContentView();
        self.unitHeight = contentView!.frame.height / 8.0;
        setupGameOverLabel();
        setupCheeringCatLabel();
        setupDeadCatLabel();
        setupStagesLabel();
        setupDurationLabel();
        setupWatchAdForXMouseCoins();
        super.invertColor = true;
        self.setCompiledStyle();
        CenterController.centerHorizontally(childView: self, parentRect: superview!.frame, childRect: self.frame);
        self.alpha = 0.0;
    }
    
    func setupContentView() {
        self.contentView = UICView(parentView: self, x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height, backgroundColor: UIColor.white);
        contentView!.layer.borderWidth = 0.0;
        contentView!.transform = contentView!.transform.scaledBy(x: 0.96, y: 0.96);
        contentView!.layer.cornerRadius = contentView!.frame.width / 7.0;
        contentView!.roundCorners(radius: contentView!.frame.width * 0.5, [.topLeft, .topRight], lineWidth: 0.0)
    }
    
    static func getCatFileName(named:String) -> String {
        // Build cat directory string
        var namedCatImage:String = "";
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            namedCatImage += "light";
        } else{
            namedCatImage += "dark";
        }
        switch (UIResults.selectedCat) {
        case Cat.fancy:
            return namedCatImage + "Fancy" + named;
        case Cat.ninja:
            return namedCatImage + "Ninja" + named;
        case Cat.standard:
            return namedCatImage + named;
        }
    }
    
    func setupGameOverLabel() {
        self.gameOverLabel = UICLabel(parentView: contentView!, x: 0.0, y: 0.0, width: contentView!.frame.width + (self.frame.width / 4.0), height: unitHeight! * 2.0);
        gameOverLabel!.font = UIFont.boldSystemFont(ofSize: gameOverLabel!.frame.height * 0.40);
        gameOverLabel!.layer.borderWidth = self.layer.borderWidth;
        gameOverLabel!.setStyle();
        gameOverLabel!.text = "R I P";
        CenterController.centerHorizontally(childView: gameOverLabel!, parentRect: self.frame, childRect: gameOverLabel!.frame);
    }
    
    func setupCheeringCatLabel() {
        self.catsLivedLabel = UICLabel(parentView: contentView!, x: self.frame.width * 0.02875, y: gameOverLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight! * 2.0);
        catsLivedLabel!.backgroundColor = UIColor.clear;
        setupLivedCatImage();
        setupCatsLivedAmount();
    }
    
    func setupCatsLivedAmount() {
        self.catsLivedAmountLabel = UICLabel(parentView: contentView!, x: self.frame.width * 0.02875, y: catsLivedLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight!);
        catsLivedAmountLabel!.font = UIFont.boldSystemFont(ofSize: catsLivedAmountLabel!.frame.height * 0.40);
        catsLivedAmountLabel!.backgroundColor = UIColor.clear;
        catsLivedAmountLabel!.textColor = UIColor.black;
    }
    
    func setupLivedCatImage() {
        self.livedCatImageButton = UICButton(parentView: catsLivedLabel!, frame:CGRect( x: 0.0, y: 0.0, width: catsLivedLabel!.frame.width, height: catsLivedLabel!.frame.height * 1.30), backgroundColor: UIColor.clear);
        livedCatImageButton!.layer.borderWidth = 0.0;
        livedCatImageButton!.setImage(UIImage(named: UIResults.getCatFileName(named:"CheeringCat.png")), for: .normal);
        livedCatImageButton!.imageView!.contentMode = UIView.ContentMode.scaleAspectFill;
        CenterController.center(childView: livedCatImageButton!, parentRect: catsLivedLabel!.frame, childRect: livedCatImageButton!.frame);
    }
    
    func setupDeadCatLabel() {
        self.catsDiedLabel = UICLabel(parentView: contentView!, x: contentView!.frame.width * 0.5, y: gameOverLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight! * 2.0);
        catsDiedLabel!.backgroundColor = UIColor.clear;
        setupDeadCatImage();
        setupCatsDiedAmount();
    }
    
    func setupCatsDiedAmount() {
        self.catsDiedAmountLabel = UICLabel(parentView: contentView!, x: contentView!.frame.width * 0.5, y: catsDiedLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight!);
        catsDiedAmountLabel!.font = UIFont.boldSystemFont(ofSize: catsDiedAmountLabel!.frame.height * 0.40);
        catsDiedAmountLabel!.backgroundColor = UIColor.clear;
        catsDiedAmountLabel!.textColor = UIColor.black;
    }
    
    func setupDeadCatImage() {
        self.deadCatImageButton = UICButton(parentView: catsDiedLabel!, frame:CGRect( x: 0.0, y: 0.0, width: catsDiedLabel!.frame.width, height: catsDiedLabel!.frame.height * 1.30), backgroundColor: UIColor.clear);
        deadCatImageButton!.layer.borderWidth = 0.0;
        deadCatImageButton!.setImage(UIImage(named: UIResults.getCatFileName(named: "DeadCat.png")), for: .normal);
        deadCatImageButton!.imageView!.contentMode = UIView.ContentMode.scaleAspectFill;
        CenterController.center(childView: deadCatImageButton!, parentRect: catsDiedLabel!.frame, childRect: deadCatImageButton!.frame);
    }
    
    func setupStagesLabel() {
        self.stagesLabel = UICLabel(parentView: contentView!, x: self.frame.width * 0.02875, y: catsLivedAmountLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight!);
        stagesLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping;
        stagesLabel!.numberOfLines = 2;
        stagesLabel!.text = "Color\nCapacity";
        stagesLabel!.font = UIFont.boldSystemFont(ofSize: stagesLabel!.frame.height * 0.40);
        stagesLabel!.backgroundColor = UIColor.clear;
        setupStagesRangeLabel();
    }
    
    func setupStagesRangeLabel() {
        self.stagesRangeLabel = UICLabel(parentView: contentView!, x: self.frame.width * 0.02875, y:stagesLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight!);
        stagesRangeLabel!.font = UIFont.boldSystemFont(ofSize: stagesRangeLabel!.frame.height * 0.35);
        stagesRangeLabel!.backgroundColor = UIColor.clear;
    }
    
    func setupDurationLabel() {
        self.durationLabel = UICLabel(parentView: contentView!, x: contentView!.frame.width * 0.5, y: catsDiedAmountLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight!);
        durationLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping;
        durationLabel!.numberOfLines = 2;
        durationLabel!.text = "Seconds\nTime";
        durationLabel!.font = UIFont.boldSystemFont(ofSize: durationLabel!.frame.height * 0.40);
        durationLabel!.backgroundColor = UIColor.clear;
        setupDurationTimeLabel();
    }
    
    func setupDurationTimeLabel() {
        self.durationTimeLabel = UICLabel(parentView: contentView!, x: contentView!.frame.width * 0.5, y: durationLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight!);
        durationTimeLabel!.font = UIFont.boldSystemFont(ofSize: durationTimeLabel!.frame.height * 0.35);
        durationTimeLabel!.backgroundColor = UIColor.clear;
    }
    
    @objc func adjustRewardAmount() {
        if (!adIsShowing && watchAdForXMouseCoins!.alpha == 1.0) {
            rewardAmountQuantity[0]! += 0.5;
            threshold -= 0.1 * 25.0 / Double(UIResults.rewardAmount);
        }
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in
            if (UIResults.rewardAmount < 25 && self.threshold < self.rewardAmountRate[UIResults.rewardAmount]!) {
                UIResults.rewardAmount += 5;
                self.threshold = 1.0;
            }
        })
        adIsShowing = false;
    }
    
    var mouseCoin:UIMouseCoin?
    func setupWatchAdForXMouseCoins() {
        self.watchAdForXMouseCoins = UICButton(parentView: contentView!, frame: CGRect(x: 0.0, y: self.frame.height - (unitHeight! * 1.3125), width: contentView!.frame.width * 0.35, height: unitHeight! * 1.25), backgroundColor: .clear);
        watchAdForXMouseCoins!.titleLabel!.font = UIFont.boldSystemFont(ofSize:watchAdForXMouseCoins!.frame.height * 0.35);
        watchAdForXMouseCoins!.layer.cornerRadius = watchAdForXMouseCoins!.frame.width * 0.1;
        self.watchAdForXMouseCoins!.frame = CGRect(x: 0.0, y: unitHeight! * 7.0, width: self.frame.width * 0.8, height: unitHeight!);
        CenterController.centerHorizontally(childView: watchAdForXMouseCoins!, parentRect: self.frame, childRect: watchAdForXMouseCoins!.frame);
        self.watchAdForXMouseCoins!.titleLabel!.textAlignment = NSTextAlignment.center;
        self.watchAdForXMouseCoins!.setTitle("Watch Short Ad to Win ····· !", for: .normal);
        self.watchAdForXMouseCoins!.addTarget(self, action: #selector(showAd), for: .touchUpInside);
        self.watchAdForXMouseCoins!.secondaryFrame = self.watchAdForXMouseCoins!.frame;
        // Setup mouse coin
        var x:CGFloat = 0.0;
        if (ViewController.aspectRatio! == .ar4by3) {
            x = watchAdForXMouseCoins!.frame.width * 0.8;
        } else if (ViewController.aspectRatio! == .ar16by9) {
            x = watchAdForXMouseCoins!.frame.width * 0.82225;
        } else {
            x = watchAdForXMouseCoins!.frame.width * 0.8025;
        }
        mouseCoin = UIMouseCoin(parentView: watchAdForXMouseCoins!, x: x, y: watchAdForXMouseCoins!.frame.height * 0.15, width: watchAdForXMouseCoins!.frame.height * 0.7, height: watchAdForXMouseCoins!.frame.height * 0.7);
        mouseCoin!.isSelectable = false;
        mouseCoin!.addTarget(self, action: #selector(mouseCoinSelector), for: .touchUpInside);
    }
    
    @objc func showAd() {
        print("MESSAGE: IS THE AD ACTAULLY SHOWING")
        // Gathering user selection data
        rewardAmountQuantity[UIResults.rewardAmount]! += 1.0;
        threshold = 1.0;
        adIsShowing = true;
        // load the ad
        ViewController.presentInterstitial();
        // Wait to see if ad will load
        var timer:Timer?
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
            if (ViewController.interstitialWillPresentScreen) {
                ViewController.interstitialWillPresentScreen = false;
                SoundController.chopinPrelude(play: false);
                timer!.invalidate();
                // Wait for the ad to be dismissed
                timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
                    if (ViewController.interstitialWillDismissScreen) {
                        ViewController.interstitialWillDismissScreen = false;
                        SoundController.chopinPrelude(play: true);
                        timer!.invalidate();
                        // Give mouse coins and hide mouse coin and label
                        self.giveMouseCoins();
                        self.watchAdForXMouseCoins!.titleLabel!.alpha = 0.0;
                        self.mouseCoin!.alpha = 0.0;
                        self.watchAdForXMouseCoins!.isUserInteractionEnabled = false;
                    }
                })
            }
        })
    }
    
    func giveMouseCoins() {
        let mainView:UIView = ViewController.staticMainView!;
        // Set angles
        let angleIncrements:CGFloat = 360.0 / CGFloat(UIResults.rewardAmount);
        var currentAngle:CGFloat = -90.0;
        // Settings views
        let settingsButton:UISettingsButton = ViewController.settingsButton!;
        let settingsMenuFrame:CGRect = settingsButton.settingsMenu!.frame;
        let settingsMouseCoinFrame:CGRect = settingsButton.settingsMenu!.mouseCoin!.frame;
        // Mouse coin X and Y
        var mouseCoinX:CGFloat
        var mouseCoinY:CGFloat
        // Radially position mouse coins
        for index in 0..<UIResults.rewardAmount {
            // Set X and Y
            mouseCoinX = mainView.center.x - (settingsMouseCoinFrame.height * 0.5);
            mouseCoinY = mainView.center.y - (settingsMouseCoinFrame.width * 0.5);
            mouseCoinX += (mainView.frame.width * 0.25) * (cos(currentAngle * CGFloat.pi / 180.0));
            mouseCoinY += (mainView.frame.height * 0.25) * (sin(currentAngle * CGFloat.pi / 180.0));
            // Generate mouse coin
            let mouseCoin:UIMouseCoin = UIMouseCoin(parentView: mainView, x: mouseCoinX, y: mouseCoinY, width: settingsMouseCoinFrame.width, height: settingsMouseCoinFrame.height);
            mouseCoin.alpha = 0.0;
            ViewController.staticMainView!.bringSubviewToFront(mouseCoin);
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
                mouseCoin.alpha = 1.0;
            }, completion: { _ in
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
            })
            // Increment angle
            currentAngle += angleIncrements;
        }
    }
    
    @objc func mouseCoinSelector() {
        SoundController.coinEarned();
        watchAdForXMouseCoins!.sendActions(for: .touchUpInside);
    }

    func setSessionDuration() {
        sessionDuration = sessionEndTime - sessionStartTime;
        sessionDuration = Double(floor(10 * sessionDuration) / 10)
    }
    
    func setAmountRate() {
        let total:Double = rewardAmountQuantity[0]! + rewardAmountQuantity[UIResults.rewardAmount]!;
        rewardAmountRate[UIResults.rewardAmount] = rewardAmountQuantity[UIResults.rewardAmount]! / total;
        rewardAmountRate[0] = rewardAmountQuantity[0]! / total;
    }
    
    func isAdButtonAdvertised() -> Bool {
        return true;
    }
    
    func update() -> (UICButton, UIMouseCoin) {
        catsLivedAmountLabel!.text = String(catsThatLived);
        catsDiedAmountLabel!.text = String(catsThatDied);
        stagesRangeLabel!.text = "\(colorMemoryCapacity)";
        durationTimeLabel!.text = "\(Int(floor(sessionDuration)))";
        // Adjust reward amount
        setAmountRate();
        // Determine whether to show ad
        watchAdForXMouseCoins!.frame = watchAdForXMouseCoins!.secondaryFrame!;
        watchAdForXMouseCoins!.alpha = 1.0
        return (watchAdForXMouseCoins!, mouseCoin!);
    }
    
    func setCompiledStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            self.backgroundColor = UIColor.black;
            self.contentView!.backgroundColor = UIColor.white;
            self.gameOverLabel!.setStyle();
            self.livedCatImageButton!.setImage(UIImage(named: UIResults.getCatFileName(named:"CheeringCat.png")), for: .normal);
            self.deadCatImageButton!.setImage(UIImage(named: UIResults.getCatFileName(named: "DeadCat.png")), for: .normal);
            self.catsLivedAmountLabel!.textColor = UIColor.black;
            self.catsDiedAmountLabel!.textColor = UIColor.black;
            self.stagesLabel!.textColor = UIColor.black;
            self.stagesRangeLabel!.textColor = UIColor.black;
            self.durationLabel!.textColor = UIColor.black;
            self.durationTimeLabel!.textColor = UIColor.black;
            self.watchAdForXMouseCoins!.setTitleColor(UIColor.black, for: .normal);
            self.watchAdForXMouseCoins!.layer.borderColor = UIColor.black.cgColor;
        } else {
            self.backgroundColor = UIColor.white;
            self.contentView!.backgroundColor = UIColor.black;
            self.gameOverLabel!.setStyle();
            self.livedCatImageButton!.setImage(UIImage(named: UIResults.getCatFileName(named:"CheeringCat.png")), for: .normal);
            self.deadCatImageButton!.setImage(UIImage(named: UIResults.getCatFileName(named: "DeadCat.png")), for: .normal);
            self.catsLivedAmountLabel!.textColor = UIColor.white;
            self.catsDiedAmountLabel!.textColor = UIColor.white;
            self.stagesLabel!.textColor = UIColor.white;
            self.stagesRangeLabel!.textColor = UIColor.white;
            self.durationLabel!.textColor = UIColor.white;
            self.durationTimeLabel!.textColor = UIColor.white;
            self.watchAdForXMouseCoins!.setTitleColor(UIColor.white, for: .normal);
            self.watchAdForXMouseCoins!.layer.borderColor = UIColor.white.cgColor;
        }
    }
    
}
