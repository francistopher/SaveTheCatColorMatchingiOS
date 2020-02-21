//
//  ViewController.swift
//  bagDatCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet var mainView: UIView!
    var mainViewWidth:CGFloat = 0.0;
    var mainViewHeight:CGFloat = 0.0;
    var unitViewWidth:CGFloat = 0.0;
    var unitViewHeight:CGFloat = 0.0;
    static var staticUnitViewWidth:CGFloat = 0.0;
    
    var introLabel:UICLabel?;
    
    var settingsButton:UISettingsButton?
    static var settingsButton:UISettingsButton?
    var boardGame:UIBoardGame?
    var colorOptions:UIColorOptions?
    
    var successGradientLayer:CAGradientLayer?
    let mellowYellow:UIColor = UIColor(red: 252.0/255.0, green: 212.0/255.0, blue: 64.0/255.0, alpha: 1.0);
    
    @IBOutlet var mainViewController: UIView!
    override func viewDidLoad() {
        super.viewDidLoad();
        setupSounds();
        setupMainViewDimensionProperties();
        setupIntroLabel();
        setupSuccessGradientLayer();
        setupBoardMainView();
        setupColorOptionsView();
        setupSettingsButton();
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.boardGame!.fadeIn();
            self.colorOptions!.fadeIn();
            self.boardGame!.buildBoardGame();
            self.settingsButton!.fadeIn();
            self.setupNotificationCenter();
        }
    }
    
    func setupNotificationCenter() {
        let notificationCenter = NotificationCenter.default;
        notificationCenter.addObserver(self, selector: #selector(self.appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil);
        notificationCenter.addObserver(self, selector: #selector(self.appDeactivated), name: UIApplication.willResignActiveNotification, object: nil);
        notificationCenter.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil);
    }
    
    @objc func appMovedToBackground() {
        self.boardGame!.cats.suspendCatAnimations();
        print("App backgrounded");
    }
    
    @objc func appMovedToForeground() {
        self.boardGame!.cats.resumeCatAnimations();
        print("App foregrounded");
    }
    @objc func appDeactivated() {
        self.boardGame!.cats.activateCatsForUIStyle();
        print("App deactivated");
    }
    
    func setupSounds() {
        SoundController.setupCoinEarned();
        SoundController.setupCoinEarned2();
        SoundController.setupCoinEarned3();
        SoundController.setupKittenMeow();
        SoundController.setupKittenMeow2();
        SoundController.setupKittenMeow3();
        SoundController.setupKittenDie();
        SoundController.setupMozartSonata();
        SoundController.setupChopinPrelude();
    }
    
    func setupMainViewDimensionProperties() {
        let decimalRatio:CGFloat = mainView.frame.height / mainView.frame.width;
        var mainViewHeight:CGFloat = mainView.frame.height;
        var mainViewWidth:CGFloat =  mainView.frame.width;
        if (decimalRatio > 2.1) {
            mainViewWidth = mainView.frame.width;
            mainViewHeight = mainView.frame.height * 3.0 / 4.0;
        } else if (decimalRatio > 3.7) {
            mainViewWidth = mainView.frame.width;
            mainViewHeight = mainView.frame.height * 3.0 / 4.0;
        } else {
            mainViewWidth = mainView.frame.width;
            mainViewHeight = mainView.frame.height * 1.2;
        }
        unitViewHeight = mainViewHeight / 18.0;
        unitViewWidth = mainViewWidth / 18.0;
        ViewController.staticUnitViewWidth = unitViewWidth;
    }
    
    func setupIntroLabel(){
        introLabel = UICLabel(parentView: mainView, x: 0.0, y: 0.0, width: unitViewWidth * 6, height: unitViewHeight);
        UICenterKit.center(childView: introLabel!, parentRect: mainView.frame, childRect: introLabel!.frame);
        introLabel!.font = UIFont.boldSystemFont(ofSize: unitViewHeight * 0.75);
        introLabel!.backgroundColor = .clear;
        introLabel!.text = "Cat Virus";
        introLabel!.alpha = 0.0;
        introLabel!.fadeInAndOut();
    }
    
    func setupSuccessGradientLayer() {
        successGradientLayer = CAGradientLayer();
        successGradientLayer!.frame = mainView.frame;
        mainView.layer.addSublayer(successGradientLayer!);
        successGradientLayer!.type = .radial;
        successGradientLayer!.startPoint = CGPoint(x:0.5, y:0.0);
        successGradientLayer!.endPoint = CGPoint(x:-0.5, y:0.15);
        successGradientLayer!.isHidden = true;
    }
    
    func setupBoardMainView(){
        let boardGameWidth:CGFloat = unitViewHeight * 8;
        boardGame = UIBoardGame(parentView: mainView, x: 0.0, y: 0.0, width: boardGameWidth, height:boardGameWidth);
        UICenterKit.centerWithVerticalDisplacement(childView: boardGame!, parentRect: mainView.frame, childRect: boardGame!.frame, verticalDisplacement: -unitViewWidth * 0.75);
        boardGame!.successGradientLayer = successGradientLayer!;
        boardGame!.alpha = 0.0;
    }

    func setupColorOptionsView(){
        colorOptions = UIColorOptions(parentView: mainView, x: boardGame!.frame.minX, y: boardGame!.frame.maxY + unitViewWidth, width: boardGame!.frame.width, height: unitViewWidth * 2.5);
        UICenterKit.centerHorizontally(childView: colorOptions!, parentRect: mainView.frame, childRect: colorOptions!.frame);
        boardGame!.colorOptions = colorOptions!;
        colorOptions!.boardGameView = boardGame!;
        colorOptions!.alpha = 0.0;
    }
    
    func setupSettingsButton() {
        settingsButton = UISettingsButton(parentView: mainView, x: unitViewWidth, y: unitViewHeight * 1.125, width: unitViewWidth * 2, height: unitViewWidth * 2);
        settingsButton!.setBoardGameAndColorOptionsView(boardGameView:boardGame!, colorOptionsView: colorOptions!);
        ViewController.settingsButton = settingsButton!;
        boardGame!.settingsButton = settingsButton!;
        settingsButton!.settingsMenu!.alpha = 0.0;
        settingsButton!.alpha = 0.0;
    }
    
    func setStyle() {
        introLabel!.setStyle();
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            self.successGradientLayer!.colors = [self.mellowYellow.cgColor, UIColor.white.cgColor];
        } else {
            self.successGradientLayer!.colors =  [self.mellowYellow.cgColor, UIColor.black.cgColor];
        }
        settingsButton!.setStyle();
        boardGame!.cats.activateCatsForUIStyle();
        colorOptions!.setStyle();
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setStyle();
    }
}


