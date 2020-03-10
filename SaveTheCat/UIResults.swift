//
//  UIStatistics.swift
//  SaveTheCat
//
//  Created by Christopher Francisco on 2/20/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import UIKit
import GoogleMobileAds

class UIResults: UICView {
    
    static var selectedCat:Cat = .standard;
    static var mouseCoins:Int = 0;
    
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
    
    var continueButton:UICButton?
    var watchAdForXMouseCoins:UICButton?
    
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
    var maxStage:Int = 0;
    
    // Content panel
    var contentView:UICView?
    
    // Reward amount
    static var rewardAmount:Int = 5;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView) {
        super.init(parentView: parentView, x: 0.0, y: 0.0, width: ViewController.staticUnitViewHeight * 8.0, height: ViewController.staticUnitViewHeight * 9.0, backgroundColor: .black);
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
        setupContinueButton();
        setupWatchAdForXMouseCoins();
        super.invertColor = true;
        self.setCompiledStyle();
        CenterController.center(childView: self, parentRect: superview!.frame, childRect: self.frame);
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
        stagesLabel!.text = "Stage\nReached";
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
    
    func setupContinueButton() {
        self.continueButton = UICButton(parentView: contentView!, frame: CGRect(x: 0.0, y: self.frame.height - (unitHeight! * 1.3125), width: contentView!.frame.width * 0.35, height: unitHeight!), backgroundColor: .clear);
        continueButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize:continueButton!.frame.height * 0.40);
        continueButton!.layer.cornerRadius = continueButton!.frame.width * 0.1;
        continueButton!.setTitle("Continue", for: .normal);
        continueButton!.setTitleColor(UIColor.black, for: .normal);
        CenterController.centerHorizontally(childView: continueButton!, parentRect: contentView!.frame, childRect: continueButton!.frame);
        self.continueButton!.originalFrame = self.continueButton!.frame;
        self.continueButton!.frame = CGRect(x: self.continueButton!.frame.minX - self.continueButton!.frame.width * 0.60, y: self.continueButton!.frame.minY, width: self.continueButton!.frame.width, height: self.continueButton!.frame.height);
    }
    
    func setupWatchAdForXMouseCoins() {
        self.watchAdForXMouseCoins = UICButton(parentView: contentView!, frame: CGRect(x: 0.0, y: self.frame.height - (unitHeight! * 1.3125), width: contentView!.frame.width * 0.35, height: unitHeight!), backgroundColor: .clear);
        watchAdForXMouseCoins!.titleLabel!.font = UIFont.boldSystemFont(ofSize:watchAdForXMouseCoins!.frame.height * 0.35);
        watchAdForXMouseCoins!.layer.cornerRadius = watchAdForXMouseCoins!.frame.width * 0.1;
        self.watchAdForXMouseCoins!.frame = CGRect(x: continueButton!.originalFrame!.minX + continueButton!.originalFrame!.width * 0.7, y: continueButton!.frame.minY, width: continueButton!.frame.width, height: continueButton!.frame.height);
        self.watchAdForXMouseCoins!.titleLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping;
        self.watchAdForXMouseCoins!.titleLabel!.numberOfLines = 2;
        self.watchAdForXMouseCoins!.titleLabel!.textAlignment = NSTextAlignment.center;
        self.watchAdForXMouseCoins!.setTitle("Watch vid\nfor \(UIResults.rewardAmount) ·", for: .normal);
        self.watchAdForXMouseCoins!.addTarget(nil, action: #selector(showAd), for: .touchUpInside);
        // Setup mouse coin
        var x:CGFloat = watchAdForXMouseCoins!.frame.width * 0.64;
        if (UIResults.rewardAmount > 9) {
            self.watchAdForXMouseCoins!.setTitle(self.watchAdForXMouseCoins!.titleLabel!.text! + "·", for: .normal);
            x += watchAdForXMouseCoins!.frame.width * 0.015;
        }
        let mouseCoin:UIMouseCoin = UIMouseCoin(parentView: watchAdForXMouseCoins!, x: x, y: watchAdForXMouseCoins!.frame.height * 0.475, width: watchAdForXMouseCoins!.frame.height * 0.4, height: watchAdForXMouseCoins!.frame.height * 0.45);
        mouseCoin.isSelectable = false;
        mouseCoin.addTarget(self, action: #selector(mouseCoinSelector), for: .touchUpInside);
    }
    
    @objc func showAd() {
        print("Showing add!");
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
                        // Reformat the buttons
                        self.watchAdForXMouseCoins!.hide();
                        self.continueButton!.frame = self.continueButton!.originalFrame!;
                        // Give mouse coins
                        self.giveMouseCoins();
                    }
                })
            }
        })
    }
    
    func giveMouseCoins() {
        let totalSpace:CGFloat = self.frame.width;
        let unavailableSpace:CGFloat = (continueButton!.frame.height * 0.5) * CGFloat(UIResults.rewardAmount);
        let availableSpace:CGFloat = totalSpace - unavailableSpace;
        let spaceBetween:CGFloat = availableSpace / CGFloat(UIResults.rewardAmount + 1);
        for index in 0..<UIResults.rewardAmount {
            UIResults.mouseCoins += 1;
            // Generate mouse coin
            let space:CGFloat = CGFloat(index + 1) * spaceBetween;
            var x:CGFloat = CGFloat(index) * (continueButton!.frame.height * 0.5);
            x += space;
            let mouseCoin:UIMouseCoin = UIMouseCoin(parentView: self, x: x, y: continueButton!.frame.minY, width: continueButton!.frame.height * 0.5, height: continueButton!.frame.height * 0.5);
            // Create frame for mouse coin on view
            var mouseCoinX = mouseCoin.frame.minX;
            var mouseCoinY = mouseCoin.frame.minY;
            mouseCoinX += contentView!.frame.minX + self.frame.minX;
            mouseCoinY += contentView!.frame.minY + self.frame.minY
            // Set new frame and superview for mouse coin
            ViewController.staticMainView!.addSubview(mouseCoin);
            mouseCoin.frame = CGRect(x: mouseCoinX, y: mouseCoinY, width: mouseCoin.frame.width, height: mouseCoin.frame.height);
            // Calculate time for translation
            let boardGameFrame:CGRect = self.superview!.frame;
            let time:Double = Double(mouseCoin.frame.minX / (boardGameFrame.minX + boardGameFrame.width));
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                ViewController.staticMainView!.bringSubviewToFront(mouseCoin);
                UIView.animate(withDuration: 1.0, delay: 0.125, options: [.curveEaseInOut], animations: {
                    let settingsButton:UISettingsButton = ViewController.settingsButton!;
                    let settingsMenuFrame:CGRect = settingsButton.settingsMenu!.frame;
                    let settingsMouseCoinFrame:CGRect = settingsButton.settingsMenu!.mouseCoin!.frame;
                    let newMouseCoinFrame:CGRect = CGRect(x: settingsMenuFrame.minX + settingsMouseCoinFrame.minX, y: settingsMenuFrame.minY + settingsMouseCoinFrame.minY, width: settingsMouseCoinFrame.width, height: settingsMouseCoinFrame.height);
                    mouseCoin.frame = newMouseCoinFrame;
                }, completion: { _ in
                    SoundController.coinEarned();
                    mouseCoin.removeFromSuperview();
                })
            }
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
    
    func update() {
        catsLivedAmountLabel!.text = String(catsThatLived);
        catsDiedAmountLabel!.text = String(catsThatDied);
        stagesRangeLabel!.text = "\(maxStage - 1)";
        durationTimeLabel!.text = "\(Int(floor(sessionDuration)))";
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
            self.continueButton!.setTitleColor(UIColor.black, for: .normal);
            self.continueButton!.layer.borderColor = UIColor.black.cgColor;
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
            self.continueButton!.setTitleColor(UIColor.white, for: .normal);
            self.continueButton!.layer.borderColor = UIColor.white.cgColor;
        }
    }
    
}
