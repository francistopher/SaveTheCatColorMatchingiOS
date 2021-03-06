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
    
    
    static var mouseCoins:Int64 = 0;
    var selectedCat:Cat = ViewController.getRandomCat();
    var gameOverLabel:UICLabel?
    
    var catsLivedLabel:UICLabel?
    var catsDiedLabel:UICLabel?
    var catsLivedAmountLabel:UICLabel?
    var catsDiedAmountLabel:UICLabel?
    var livedCatImageButton:UICButton?
    var deadCatImageButton:UICButton?
    
    var watchAdButton:UICButton?
    static var adIsShowing:Bool = false;
    
    var unitHeight:CGFloat?
    
    // Survival and Death Count
    var entiretyOfCatsThatDied:Int = 0;
    var entiretyOfCatsThatSurvived:Int = 0;
    var catsThatDied:Int = 0;
    var catsThatLived:Int = 0;
    
    // Content panel
    var contentView:UICView?
    
    // Reward amount
    static var rewardAmount:Int = 5;
    
    // Save the value of mouse coins
    var keyValueStore:NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore();
    var localIntersitialAdVC:LocalIntersitialAdVC?
    
    // High Score label
    var highScoreLabel:UICLabel?
    let defaults = UserDefaults.standard;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView) {
        var y:CGFloat = 0.0;
        if (ViewController.aspectRatio! == .ar19point5by9) {
            y = (ViewController.staticMainView!.frame.height * ((1.0/300.0) + 0.08)) + (ViewController.staticUnitViewHeight * 2.9);
        } else {
            y = (ViewController.staticMainView!.frame.height * ((1.0/300.0) + 0.08)) + (ViewController.staticUnitViewHeight * 1.9);
        }
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
        setupWatchAdForXMouseCoins();
        setupLocalIntersitialAdVC();
        super.invertColor = true;
         setupHighScoreLabel();
        self.setCompiledStyle();
        CenterController.centerHorizontally(childView: self, parentRect: superview!.frame, childRect: self.frame);
        self.alpha = 0.0;
    }
    
    /*
        Creates the high score label
     */
    func setupHighScoreLabel() {
        highScoreLabel = UICLabel(parentView: contentView!, x: 0.0, y: -unitHeight!, width: frame.width, height: unitHeight!);
        highScoreLabel!.font = UIFont.boldSystemFont(ofSize: highScoreLabel!.frame.height * 0.5);
        ViewController.updateFont(label: highScoreLabel!);
        highScoreLabel!.isInverted = true;
        highScoreLabel!.setStyle();
    }
    
    /*
        Creates the ad
     */
    var localAdFirstTime:Bool = false;
    func setupLocalIntersitialAdVC() {
        localIntersitialAdVC = LocalIntersitialAdVC();
        localIntersitialAdVC!.modalPresentationStyle = .overFullScreen;
    }
    
    /*
        Shows the ad
     */
    func presentLocalAd() {
        SoundController.chopinPrelude(play: false);
        ViewController.staticSelf!.present(localIntersitialAdVC!, animated: true, completion: {
            self.localAdFirstTime = true;
            if (self.localIntersitialAdVC!.closeButton != nil) {
                self.localIntersitialAdVC!.closeButton!.addTarget(self, action: #selector(self.closeButtonSelector), for: .touchUpInside);
            }
        });
        UIView.animate(withDuration: 0.25, animations: {
            ViewController.staticSelf!.view.alpha = 0.5;
        })
    }
    
    /*
        Closes the ad view
     */
    @objc func closeButtonSelector() {
        ViewController.staticSelf!.gameMessage!.addToMessageQueue(message: .noInternet);
        localIntersitialAdVC!.dismiss(animated: true, completion: nil);
        ViewController.staticSelf!.boardGame!.glovePointer!.reset();
        ViewController.staticSelf!.mainView.alpha = 1.0;
        watchAdButton!.isUserInteractionEnabled = false;
        SoundController.chopinPrelude(play: true);
        watchAdButton!.titleLabel!.alpha = 0.0;
        mouseCoin!.alpha = 0.0;
    }
    
    /*
        Creates the content view
        of the results
     */
    func setupContentView() {
        self.contentView = UICView(parentView: self, x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height, backgroundColor: UIColor.white);
        contentView!.layer.borderWidth = 0.0;
        contentView!.transform = contentView!.transform.scaledBy(x: 0.96, y: 0.96);
        contentView!.layer.cornerRadius = contentView!.frame.width / 7.0;
        contentView!.roundCorners(radius: contentView!.frame.width * 0.5, [.topLeft, .topRight], lineWidth: 0.0)
        contentView!.clipsToBounds = true;
    }
    
    /*
        Create the game over label
     */
    func setupGameOverLabel() {
        self.gameOverLabel = UICLabel(parentView: contentView!, x: 0.0, y: unitHeight! * 0.25, width: contentView!.frame.width + (self.frame.width / 4.0), height: unitHeight! * 2.0);
        gameOverLabel!.font = UIFont.boldSystemFont(ofSize: gameOverLabel!.frame.height * 0.375);
        gameOverLabel!.layer.borderWidth = self.layer.borderWidth;
        gameOverLabel!.setStyle();
        gameOverLabel!.text = "Game Over";
        CenterController.centerHorizontally(childView: gameOverLabel!, parentRect: self.frame, childRect: gameOverLabel!.frame);
        ViewController.updateFont(label: gameOverLabel!);
    }
    
    /*
        Creates the cheering cat image label
     */
    func setupCheeringCatLabel() {
        self.catsLivedLabel = UICLabel(parentView: contentView!, x: self.frame.width * 0.02875, y: gameOverLabel!.frame.maxY * 0.9, width: contentView!.frame.width * 0.5,
            height: contentView!.frame.width * 0.5);
        catsLivedLabel!.backgroundColor = UIColor.clear;
        setupLivedCatImage();
        setupCatsLivedAmount();
    }
    
    /*
        Creates the label with the count of cats saved
     */
    func setupCatsLivedAmount() {
        self.catsLivedAmountLabel = UICLabel(parentView: contentView!, x: self.frame.width * 0.02875, y: catsLivedLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight!);
        catsLivedAmountLabel!.font = UIFont.boldSystemFont(ofSize: catsLivedAmountLabel!.frame.height * 0.5);
        catsLivedAmountLabel!.backgroundColor = UIColor.clear;
        catsLivedAmountLabel!.textColor = UIColor.black;
        ViewController.updateFont(label: catsLivedAmountLabel!);
    }
    
    /*
        Create the image view of the cheering cat
     */
    var image:UIImage?
    func setupLivedCatImage() {
        self.livedCatImageButton = UICButton(parentView: catsLivedLabel!, frame:CGRect( x: 0.0, y: 0.0, width: catsLivedLabel!.frame.width, height: catsLivedLabel!.frame.height * 1.30), backgroundColor: UIColor.clear);
        livedCatImageButton!.layer.borderWidth = 0.0;
        image = UIImage(named: UICatButton.getCatFileName(named:"CheeringCat.png", selectedCat: selectedCat));
        livedCatImageButton!.setImage(image!, for: .normal);
        livedCatImageButton!.imageView!.contentMode = UIView.ContentMode.scaleAspectFill;
        CenterController.center(childView: livedCatImageButton!, parentRect: catsLivedLabel!.frame, childRect: livedCatImageButton!.frame);
    }
    
    /*
        Creates the dead cat label
     */
    func setupDeadCatLabel() {
        self.catsDiedLabel = UICLabel(parentView: contentView!, x: contentView!.frame.width * 0.5, y: gameOverLabel!.frame.maxY * 0.9, width: contentView!.frame.width * 0.5, height: contentView!.frame.width * 0.5);
        catsDiedLabel!.backgroundColor = UIColor.clear;
        setupDeadCatImage();
        setupCatsDiedAmount();
    }
    
    /*
        Creates the label with the count of cats that died
     */
    func setupCatsDiedAmount() {
        self.catsDiedAmountLabel = UICLabel(parentView: contentView!, x: contentView!.frame.width * 0.5, y: catsDiedLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight!);
        catsDiedAmountLabel!.font = UIFont.boldSystemFont(ofSize: catsDiedAmountLabel!.frame.height * 0.5);
        catsDiedAmountLabel!.backgroundColor = UIColor.clear;
        catsDiedAmountLabel!.textColor = UIColor.black;
        ViewController.updateFont(label: catsDiedAmountLabel!);
    }
    
    /*
        Creates the dead cat image button
     */
    func setupDeadCatImage() {
        self.deadCatImageButton = UICButton(parentView: catsDiedLabel!, frame:CGRect( x: 0.0, y: 0.0, width: catsDiedLabel!.frame.width, height: catsDiedLabel!.frame.height * 1.30), backgroundColor: UIColor.clear);
        deadCatImageButton!.layer.borderWidth = 0.0;
        deadCatImageButton!.setImage(UIImage(named: UICatButton.getCatFileName(named: "DeadCat.png", selectedCat:selectedCat)), for: .normal);
        deadCatImageButton!.imageView!.contentMode = UIView.ContentMode.scaleAspectFill;
        CenterController.center(childView: deadCatImageButton!, parentRect: catsDiedLabel!.frame, childRect: deadCatImageButton!.frame);
    }
    
    /*
        Updates the reward amount for
        viewing an ad
     */
    func adjustRewardAmount() {
        if (!UIResults.adIsShowing) {
            if (UIResults.rewardAmount > 5) {
                UIResults.rewardAmount -= 1;
            }
        }
        UIResults.adIsShowing = false;
    }
    
    /*
        Creates the watch ad button
        that displays the ad
     */
    var mouseCoin:UIMouseCoin?
    func setupWatchAdForXMouseCoins() {
        self.watchAdButton = UICButton(parentView: contentView!, frame: CGRect(x: 0.0, y: self.frame.height - (unitHeight! * 1.3125), width: contentView!.frame.width * 0.35, height: unitHeight! * 1.25), backgroundColor: .clear);
        watchAdButton!.layer.cornerRadius = watchAdButton!.frame.width * 0.1;
        self.watchAdButton!.frame = CGRect(x: 0.0, y: unitHeight! * 7.0, width: self.frame.width * 0.8, height: unitHeight!);
        CenterController.centerHorizontally(childView: watchAdButton!, parentRect: self.frame, childRect: watchAdButton!.frame);
        self.watchAdButton!.titleLabel!.textAlignment = NSTextAlignment.center;
        self.watchAdButton!.setTitle("Watch Short Ad to Win + ····· s!", for: .normal);
        self.watchAdButton!.addTarget(self, action: #selector(showAd), for: .touchUpInside);
        self.watchAdButton!.secondaryFrame = self.watchAdButton!.frame;
        // Setup mouse coin based on the screen's aspect ratio
        var x:CGFloat = 0.0;
        if (ViewController.aspectRatio! == .ar4by3) {
            watchAdButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize:watchAdButton!.frame.height * 0.4);
            x = watchAdButton!.frame.width * 0.777;
        } else if (ViewController.aspectRatio! == .ar16by9) {
            watchAdButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize:watchAdButton!.frame.height * 0.38);
            x = watchAdButton!.frame.width * 0.7765;
        } else {
            watchAdButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize:watchAdButton!.frame.height * 0.38);
            x = watchAdButton!.frame.width * 0.771;
        }
        // Create mouse coin
        mouseCoin = UIMouseCoin(parentView: watchAdButton!, x: x, y: watchAdButton!.frame.height * 0.12, width: watchAdButton!.frame.height * 0.75, height: watchAdButton!.frame.height * 0.75);
        mouseCoin!.isSelectable = false;
        mouseCoin!.addTarget(self, action: #selector(mouseCoinSelector), for: .touchUpInside);
        ViewController.updateFont(button: watchAdButton!);
    }
    
    // Shows the ad
    @objc func showAd() {
        // Gathering user selection data
        UIResults.adIsShowing = true;
        // load the ad
        if (ViewController.staticSelf!.isInternetReachable) {
            ViewController.presentInterstitial();
        } else {
            // load local ad
            presentLocalAd();
        }
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
                        self.watchAdButton!.titleLabel!.alpha = 0.0;
                        self.mouseCoin!.alpha = 0.0;
                        self.watchAdButton!.isUserInteractionEnabled = false;
                    }
                })
            }
        })
    }
    
    /*
        Rewards the user with mouse coins that are first plotted
        radially qeuidistant from the center of the screen
     */
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
            // Transition mouse coin to settings menu mouse coin
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
                        if (UIResults.rewardAmount < 10) {
                            UIResults.rewardAmount += 1;
                        }
                    }
                })
            })
            // Increment angle
            currentAngle += angleIncrements;
        }
    }
    
    @objc func mouseCoinSelector() {
        SoundController.coinEarned();
        watchAdButton!.sendActions(for: .touchUpInside);
    }
    
    func isAdButtonAdvertised() -> Bool {
        return true;
    }
    
    func update() {
        catsLivedAmountLabel!.text = String(catsThatLived);
        catsDiedAmountLabel!.text = String(catsThatDied);
    }
    
    /*
        Displays the user's high score
     */
    func showHighScore(new:Bool) {
        if (new) {
            highScoreLabel!.text = "WOW! NEW HIGH SCORE!";
            highScoreLabel!.backgroundColor = UIColor.systemPink;
            highScoreLabel!.textColor = UIColor.black;
        } else {
            highScoreLabel!.text = "High Score: \(ViewController.singleGameHighScore)";
        }
        UIView.animate(withDuration: 4.25, animations: {
            self.highScoreLabel!.transform = self.highScoreLabel!.transform.translatedBy(x: 0.0, y: self.contentView!.frame.height + self.unitHeight! * 1.5);
        }, completion: { _ in
            self.highScoreLabel!.frame = self.highScoreLabel!.originalFrame!;
        })
    }
    
    /*
        Updates the appearance of the game results
        based on the theme of the operating system
     */
    func setCompiledStyle() {
        if (highScoreLabel!.backgroundColor!.cgColor != UIColor.systemPink.cgColor) {
            highScoreLabel!.setStyle();
        }
        if (ViewController.uiStyleRawValue == 1) {
            self.backgroundColor = UIColor.black;
            self.contentView!.backgroundColor = UIColor.white;
            self.gameOverLabel!.setStyle();
            self.livedCatImageButton!.setImage(UIImage(named: UICatButton.getCatFileName(named:"CheeringCat.png", selectedCat: selectedCat)), for: .normal);
            self.deadCatImageButton!.setImage(UIImage(named: UICatButton.getCatFileName(named: "DeadCat.png", selectedCat: selectedCat)), for: .normal);
            self.catsLivedAmountLabel!.textColor = UIColor.black;
            self.catsDiedAmountLabel!.textColor = UIColor.black;
            self.watchAdButton!.setTitleColor(UIColor.black, for: .normal);
            self.watchAdButton!.layer.borderColor = UIColor.black.cgColor;
        } else {
            self.backgroundColor = UIColor.white;
            self.contentView!.backgroundColor = UIColor.black;
            self.gameOverLabel!.setStyle();
            self.livedCatImageButton!.setImage(UIImage(named: UICatButton.getCatFileName(named:"CheeringCat.png", selectedCat:selectedCat)), for: .normal);
            self.deadCatImageButton!.setImage(UIImage(named: UICatButton.getCatFileName(named: "DeadCat.png", selectedCat:selectedCat)), for: .normal);
            self.catsLivedAmountLabel!.textColor = UIColor.white;
            self.catsDiedAmountLabel!.textColor = UIColor.white;
            self.watchAdButton!.setTitleColor(UIColor.white, for: .normal);
            self.watchAdButton!.layer.borderColor = UIColor.white.cgColor;
        }
        
        if (localAdFirstTime) {
            localIntersitialAdVC!.setStyle();
        }
        self.watchAdButton!.layer.borderColor = UIColor.systemYellow.cgColor;
    }
    
}

/*
    A mock ad whenever there isn't an internet connection
 */
class LocalIntersitialAdVC:UIViewController {
    
    var imageView:UIImageView?
    var darkImage:UIImage = UIImage(named: "darkNoInternetIntersitial.png")!;
    var lightImage:UIImage = UIImage(named: "lightNoInternetIntersitial.png")!;
    
    var closeButton:UICButton?
    
    override func viewDidLoad() {
        super.viewDidLoad();
        setupImageView();
        setupCloseButton();
        setStyle();
    }
    
    func setupCloseButton() {
        closeButton = UICButton(parentView: view, frame: CGRect(x: view.frame.width * 0.85, y: (view.frame.width * 0.05) + imageView!.frame.minY, width: view.frame.width * 0.1, height: view.frame.width * 0.1), backgroundColor: UIColor.clear);
        closeButton!.layer.borderWidth = closeButton!.layer.borderWidth * 2.0;
        closeButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: closeButton!.frame.height * 0.75);
        closeButton!.layer.cornerRadius = closeButton!.frame.height * 0.5;
        ViewController.updateFont(button: closeButton!);
        closeButton!.setTitle("x", for: .normal);
    }
    
    func setupImageView() {
        imageView = UIImageView(frame:  CGRect(x: ViewController.staticSelf!.mainView.frame.minX, y: ViewController.staticSelf!.mainView.frame.height * 0.02, width: ViewController.staticSelf!.mainView.frame.width, height: ViewController.staticSelf!.mainView.frame.height * 0.98));
        imageView!.backgroundColor = UIColor.clear;
        imageView!.contentMode = UIView.ContentMode.scaleAspectFill;
        imageView!.clipsToBounds = true;
        view.addSubview(imageView!);
    }
    
    /*
        Update the appearance of the mock ad
        based on the theme of the OS
     */
    func setStyle() {
        closeButton!.backgroundColor = UIColor.white;
        closeButton!.layer.borderColor = UIColor.black.cgColor;
        closeButton!.setTitleColor(UIColor.red, for: .normal);
        if (ViewController.uiStyleRawValue == 1) {
            imageView!.image = lightImage;
            view.backgroundColor = UIColor.white;
        } else {
            imageView!.image = darkImage;
            view.backgroundColor = UIColor.black;
        }
    }
    
    
}
