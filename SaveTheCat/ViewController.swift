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
    
    static var appInBackgroundBeforeFirstAttackImpulse:Bool = false;
    
    static var staticSelf:ViewController?
    var gameCenterAuthentificationOver:Bool = false;
    
    // Game center message
    var gameCenterMessage:GameCenterMessage?
    var gameCenterMessageWidthHeightY:(CGFloat, CGFloat, CGFloat)?;
    
    @IBOutlet var mainViewController: UIView!
    override func viewDidLoad() {
        super.viewDidLoad();
        setupSaveTheCat();
        setupGameCenterMessage();
        authenticateLocalPlayerForGamePlay();
    }
    
    // Game Center Authentication
    func authenticateLocalPlayerForGamePlay() {
        let player:GKLocalPlayer = GKLocalPlayer.local;
        player.authenticateHandler = {vc,error in
            guard error == nil else {
                if (self.gameCenterAuthentificationOver) {
                    return;
                }
                print("DISABLE MULTIPLAYER")
                self.gameCenterAuthentificationOver = true;
                self.boardGame!.attackMeter!.invokeAttackImpulse(delay: 5.75);
                self.presentSaveTheCat();
                self.gameCenterMessage!.showAndHideMessage();
                return;
            }
            if let vc = vc {
                if (self.gameCenterAuthentificationOver) {
                    return;
                }
                self.present(vc, animated: true, completion: {
                    print("Game center view was presented for sign in");
                })
            } else {
                if (player.isAuthenticated) {
                    if (self.gameCenterAuthentificationOver) {
                        return;
                    }
                    print("ENABLE MULTIPLAYER")
                    self.gameCenterAuthentificationOver = true;
                    self.boardGame!.attackMeter!.invokeAttackImpulse(delay: 5.5);
                    self.presentSaveTheCat();
                }
            }
        }
    }
    
    func setupGameCenterMessage() {
        let gameCenterMessageX:CGFloat = (mainView.frame.width - gameCenterMessageWidthHeightY!.0) * 0.5;
        gameCenterMessage = GameCenterMessage(parentView: mainView, frame: CGRect(x: gameCenterMessageX, y: gameCenterMessageWidthHeightY!.2, width: gameCenterMessageWidthHeightY!.0, height: gameCenterMessageWidthHeightY!.1));
        CenterController.centerHorizontally(childView: gameCenterMessage!, parentRect: mainView.frame, childRect: gameCenterMessage!.frame);
    }
    
    func setupSaveTheCat() {
        ViewController.staticSelf = self;
        setupSounds();
        setupMainViewDimensionProperties();
        setupIntroLabel();
        setupSuccessGradientLayer();
        setupViruses();
        setupBoardMainView();
        setupColorOptionsView();
        setupSettingsButton();
        self.setupNotificationCenter();
        SoundController.mozartSonata(play: true);
    }
    
    func presentSaveTheCat() {
        self.introLabel!.fadeInAndOut();
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.viruses!.sway(immediately: false);
            self.viruses!.fadeIn();
            self.boardGame!.fadeIn();
            self.boardGame!.livesMeter!.fadeIn();
            self.boardGame!.attackMeter!.compiledShow();
            self.colorOptions!.fadeIn();
            self.boardGame!.buildBoardGame();
            self.settingsButton!.fadeIn();
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
        self.boardGame!.attackMeter!.pauseVirusMovement();
        print("App backgrounded");
    }
    
    @objc func appMovedToForeground() {
        if (self.gameCenterAuthentificationOver){
            self.viruses!.sway(immediately: true);
        }
        self.boardGame!.cats.resumeCatAnimations();
        self.settingsButton!.multiplayer!.activePlayersScrollView!.searchingCatButton!.animate(AgainWithoutDelay: true);
        self.settingsButton!.multiplayer!.activePlayersScrollView!.invitationCatButton!.animate(AgainWithoutDelay: true);
        self.boardGame!.attackMeter!.unPauseVirusMovement();
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
        
        func setupUnitViewDimension() {
            unitViewHeight = mainViewHeight / 18.0;
            unitViewWidth = mainViewWidth / 18.0;
        }
        
        func setupStaticUnitViewDimension() {
            ViewController.staticUnitViewHeight = unitViewHeight;
            ViewController.staticUnitViewWidth = unitViewWidth;
        }
        
        if (decimalRatio > 2.1) {
            mainViewWidth = mainView.frame.width;
            mainViewHeight = mainView.frame.height;
            setupUnitViewDimension();
            setupStaticUnitViewDimension();
            gameCenterMessageWidthHeightY = (unitViewWidth * 15.85, unitViewHeight * 1.35, unitViewHeight * 1.00);
            print("21:9?")
        } else if (decimalRatio > 1.7) {
            mainViewWidth = mainView.frame.width;
            mainViewHeight = mainView.frame.height * 1.2;
            setupUnitViewDimension();
            setupStaticUnitViewDimension()
            gameCenterMessageWidthHeightY = (unitViewWidth * 16.5, unitViewHeight * 1.43, unitViewHeight * 0.6225);
            print("Did it even work?")
        } else {
            mainViewWidth = mainView.frame.width;
            mainViewHeight = mainView.frame.height * 1.2;
            setupUnitViewDimension();
            setupStaticUnitViewDimension();
            gameCenterMessageWidthHeightY = (unitViewWidth * 8.45, unitViewHeight * 0.95, unitViewHeight * 0.53);
        }
    }
    
    func setupViruses() {
        viruses = UIViruses(mainView: mainView, unitView: unitViewHeight);
        viruses!.hide();
    }
    
    func setupIntroLabel(){
        introLabel = UICLabel(parentView: mainView, x: 0.0, y: 0.0, width: unitViewWidth * 10, height: unitViewHeight);
        CenterController.center(childView: introLabel!, parentRect: mainView.frame, childRect: introLabel!.frame);
        introLabel!.font = UIFont.boldSystemFont(ofSize: unitViewHeight * 0.75);
        introLabel!.backgroundColor = .clear;
        introLabel!.text = "Save The Cat";
        introLabel!.alpha = 0.0;
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
        CenterController.center(childView: boardGame!, parentRect: mainView.frame, childRect: boardGame!.frame);
        boardGame!.successGradientLayer = successGradientLayer!;
        boardGame!.alpha = 0.0;
        boardGame!.viruses = viruses!;
        boardGame!.attackMeter!.boardGame = boardGame;
        boardGame!.attackMeter!.comiledHide();
    }

    func setupColorOptionsView(){
        colorOptions = UIColorOptions(parentView: mainView, x: boardGame!.frame.minX, y: boardGame!.frame.maxY, width: boardGame!.frame.width, height: unitViewHeight * 1.5);
        CenterController.centerHorizontally(childView: colorOptions!, parentRect: mainView.frame, childRect: colorOptions!.frame);
        boardGame!.colorOptions = colorOptions!;
        colorOptions!.boardGameView = boardGame!;
        boardGame!.livesMeter!.alpha = 0.0;
        colorOptions!.alpha = 0.0;
    }
    
    func setupSettingsButton() {
        settingsButton = UISettingsButton(parentView: mainView, x: unitViewWidth, y: unitViewHeight, width: unitViewWidth * 2, height: unitViewWidth * 2);
        print((unitViewWidth * 2) / (unitViewHeight))
        settingsButton!.setBoardGameAndColorOptionsView(boardGameView:boardGame!, colorOptionsView: colorOptions!);
        ViewController.settingsButton = settingsButton!;
        boardGame!.settingsButton = settingsButton!;
        settingsButton!.settingsMenu!.alpha = 0.0;
        settingsButton!.alpha = 0.0;
    }
    
    func setStyle() {
        gameCenterMessage!.setStyle();
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

class GameCenterMessage:UIView {
    
    var blurEffect:UIBlurEffect?
    var blurView:UIVisualEffectView?
    var imageButton:UIButton?
    var messageLabel:UICLabel?
    
    var targetFrame:CGRect?
    var defaultFrame:CGRect?
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView, frame:CGRect) {
        targetFrame = frame;
        defaultFrame = CGRect(x: frame.minX, y: -(frame.minY * 2.0 + frame.height), width: frame.width, height: frame.height);
        super.init(frame: defaultFrame!);
        self.backgroundColor = UIColor.clear;
        self.layer.cornerRadius = self.frame.width * 0.07;
        self.clipsToBounds = true;
        setupBlurEffect();
        setupVisualEffectView();
        setupImageButton();
        setupLabel();
        parentView.addSubview(self);
    }
    
    func setupBlurEffect() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            blurEffect = UIBlurEffect(style: .systemThinMaterialDark);
        } else {
            blurEffect = UIBlurEffect(style: .systemThickMaterialDark);
        }
    }
    
    func setupVisualEffectView() {
        blurView = UIVisualEffectView(effect: blurEffect);
        blurView!.frame = self.bounds;
        self.addSubview(blurView!);
    }
    
    func setupImageButton() {
        imageButton = UIButton(frame: CGRect(x: self.frame.width * 0.0839, y: 0.0, width: self.frame.height * 0.65, height: self.frame.height));
        imageButton!.backgroundColor = UIColor.clear;
        setupGameCenterButton();
        self.addSubview(imageButton!);
    }
    
    func setupGameCenterButton() {
        let image:UIImage = UIImage(named: "gameCenter.png")!;
        imageButton!.setImage(image, for: .normal);
        imageButton!.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func setupLabel() {
        let messageLabelWidth:CGFloat = self.imageButton!.frame.minX + self.imageButton!.frame.width * 1.05;
        messageLabel = UICLabel(parentView: self, x:  messageLabelWidth, y: 0.0, width: self.frame.width * 0.75, height: self.frame.height);
        messageLabel!.backgroundColor = UIColor.clear;
        messageLabel!.textColor = UIColor.white;
        messageLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping;
        messageLabel!.numberOfLines = 2;
        messageLabel!.font = UIFont.boldSystemFont(ofSize: messageLabel!.frame.height * 0.25);
        messageLabel!.text = "Go to Settings and sign into\nGame Center for more fun!";
    }
    
    func setStyle() {
        setupBlurEffect();
        blurView!.effect = blurEffect;
    }
    
    func showAndHideMessage() {
        UIView.animate(withDuration: 0.415, delay: 0.25, options: .curveLinear, animations: {
            self.frame = self.targetFrame!;
        })
        Timer.scheduledTimer(withTimeInterval: 4.1, repeats: false, block: { _ in
            UIView.animate(withDuration: 0.415, delay: 0.0, options: .curveLinear, animations: {
                self.frame = self.defaultFrame!;
            })
        })
    }
}

