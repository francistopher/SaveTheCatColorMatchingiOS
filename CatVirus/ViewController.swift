//
//  ViewController.swift
//  bagDatCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import UIKit
import AVFoundation
import GameKit

class ViewController: UIViewController {

    @IBOutlet var mainView: UIView!
    var mainViewWidth:CGFloat = 0.0;
    var mainViewHeight:CGFloat = 0.0;
    var unitViewWidth:CGFloat = 0.0;
    var unitViewHeight:CGFloat = 0.0;
    
    static var staticUnitViewHeight:CGFloat = 0.0;
    static var staticUnitViewWidth:CGFloat = 0.0;
    
    var introLabel:UICLabel?;
    
    var settingsButton:UISettingsButton?
    static var settingsButton:UISettingsButton?
    var boardGame:UIBoardGame?
    var colorOptions:UIColorOptions?
    
    var successGradientLayer:CAGradientLayer?
    let mellowYellow:UIColor = UIColor(red: 252.0/255.0, green: 212.0/255.0, blue: 64.0/255.0, alpha: 1.0);
    
    var viruses:UIViruses?
    
    static var staticSelf:ViewController?
    
    @IBOutlet var mainViewController: UIView!
    override func viewDidLoad() {
        super.viewDidLoad();
        presentGame();
    }
    
    // Game Center Authentication
    func authenticateUser() {
        // Get the local player
        let player:GKLocalPlayer = GKLocalPlayer.local;
        //
        player.authenticateHandler = {mainViewController, error in
            guard  error == nil else {
                print("Error");
                return;
            }
            self.presentGame();
        }
    }
    
    func presentGame() {
        ViewController.staticSelf = self;
        setupSounds();
        setupMainViewDimensionProperties();
        setupIntroLabel();
        setupSuccessGradientLayer();
        setupViruses();
        setupBoardMainView();
        setupColorOptionsView();
        setupSettingsButton();
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.boardGame!.attackMeter!.boardGame = self.boardGame;
            self.viruses!.fadeIn();
            self.boardGame!.fadeIn();
            self.boardGame!.livesMeter!.fadeIn();
            self.boardGame!.attackMeter!.compiledShow();
            self.colorOptions!.fadeIn();
            self.boardGame!.buildBoardGame();
            self.settingsButton!.fadeIn();
            self.setupNotificationCenter();
        }
    }
    
    func setupNotificationCenter() {
        let notificationCenter = NotificationCenter.default;
        notificationCenter.addObserver(self, selector: #selector(self.appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil);
        notificationCenter.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil);
    }
    
    @objc func appMovedToBackground() {
        self.viruses!.hide();
        self.boardGame!.cats.suspendCatAnimations();
        self.settingsButton!.multiplayer!.activePlayersScrollView!.searchingCatButton!.hideCat();
        self.settingsButton!.multiplayer!.activePlayersScrollView!.invitationCatButton!.hideCat();
        print("App backgrounded");
    }
    
    @objc func appMovedToForeground() {
        self.viruses!.sway(immediately: true);
        self.boardGame!.cats.resumeCatAnimations();
        self.settingsButton!.multiplayer!.activePlayersScrollView!.searchingCatButton!.animate(AgainWithoutDelay: true);
        self.settingsButton!.multiplayer!.activePlayersScrollView!.invitationCatButton!.animate(AgainWithoutDelay: true);
        print("App foregrounded");
    }
    
    func setupSounds() {
        SoundController.setupHeaven();
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
        ViewController.staticUnitViewHeight = unitViewHeight;
        ViewController.staticUnitViewWidth = unitViewWidth;
    }
    
    func setupViruses() {
        viruses = UIViruses(mainView: mainView, unitView: unitViewHeight);
        viruses!.sway(immediately: false);
        viruses!.hide();
    }
    
    func setupIntroLabel(){
        introLabel = UICLabel(parentView: mainView, x: 0.0, y: 0.0, width: unitViewWidth * 10, height: unitViewHeight);
        UICenterKit.center(childView: introLabel!, parentRect: mainView.frame, childRect: introLabel!.frame);
        introLabel!.font = UIFont.boldSystemFont(ofSize: unitViewHeight * 0.75);
        introLabel!.backgroundColor = .clear;
        introLabel!.text = "Save Da Cat!";
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
        setSuccessGradientLayerStyle();
    }
    
    func setSuccessGradientLayerStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            self.successGradientLayer!.colors = [self.mellowYellow.cgColor, UIColor.white.cgColor];
        } else {
            self.successGradientLayer!.colors =  [self.mellowYellow.cgColor, UIColor.black.cgColor];
        }
    }
    
    func setupBoardMainView(){
        let boardGameWidth:CGFloat = unitViewHeight * 8;
        boardGame = UIBoardGame(parentView: mainView, x: 0.0, y: 0.0, width: boardGameWidth, height:boardGameWidth);
        UICenterKit.center(childView: boardGame!, parentRect: mainView.frame, childRect: boardGame!.frame);
        boardGame!.successGradientLayer = successGradientLayer!;
        boardGame!.alpha = 0.0;
        boardGame!.viruses = viruses!;
        boardGame!.attackMeter!.comiledHide();
    }

    func setupColorOptionsView(){
        colorOptions = UIColorOptions(parentView: mainView, x: boardGame!.frame.minX, y: boardGame!.frame.maxY, width: boardGame!.frame.width, height: unitViewHeight * 1.5);
        UICenterKit.centerHorizontally(childView: colorOptions!, parentRect: mainView.frame, childRect: colorOptions!.frame);
        boardGame!.colorOptions = colorOptions!;
        colorOptions!.boardGameView = boardGame!;
        boardGame!.livesMeter!.alpha = 0.0;
        colorOptions!.alpha = 0.0;
    }
    
    func setupSettingsButton() {
        settingsButton = UISettingsButton(parentView: mainView, x: unitViewWidth, y: unitViewHeight, width: unitViewWidth * 2, height: unitViewWidth * 2);
        settingsButton!.setBoardGameAndColorOptionsView(boardGameView:boardGame!, colorOptionsView: colorOptions!);
        ViewController.settingsButton = settingsButton!;
        boardGame!.settingsButton = settingsButton!;
        settingsButton!.settingsMenu!.alpha = 0.0;
        settingsButton!.alpha = 0.0;
    }
    
    func setStyle() {
        viruses!.setStyle();
        introLabel!.setStyle();
        setSuccessGradientLayerStyle();
        settingsButton!.setStyle();
        settingsButton!.multiplayer!.setStyle();
        settingsButton!.multiplayer!.activePlayersScrollView!.searchingCatButton!.updateUIStyle();
        settingsButton!.multiplayer!.activePlayersScrollView!.invitationCatButton!.updateUIStyle();
        boardGame!.cats.updateUIStyle();
        boardGame!.livesMeter!.setStyle();
        boardGame!.statistics!.setCompiledStyle();
        boardGame!.attackMeter!.setCompiledStyle();
        colorOptions!.setStyle();
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setStyle();
    }
}


