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
import GoogleMobileAds

enum AspectRatio {
    case ar19point5by9
    case ar16by9
    case ar4by3
}

class ViewController: UIViewController, GKGameCenterControllerDelegate, GKMatchmakerViewControllerDelegate, ReachabilityObserverDelegate, GADInterstitialDelegate, GADBannerViewDelegate {
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true, completion: nil);
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(animated: true, completion: nil);
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        self.boardGame!.setupMatch(match: match);
        viewController.dismiss(animated: true, completion: nil);
        print("A match was found????")
    }
    
    var myCats:[Cat:Int8] = [.standard:1, .breading:0, .taco:0, .egyptian:0, .supeR:0, .chicken:0, .cool:0, .ninja:0, .fat:0];
    var firedITunesStatus:Bool = false;
    var isiCloudReachable:Bool = false;
    var isInternetReachable:Bool = false;
    func reachabilityChanged(_ isReachable: Bool) {
        print("INTERNET CONNECTIVITY CHECKED")
        if (isReachable) {
            self.isInternetReachable = true;
            // Display Internet Message
            gameMessage!.displayInternetConnectionEstablishedMessage();
            // Stop autoloading ads
            bannerView.isAutoloadEnabled = true;
            // Load Online Mouse Coins and cats
            myCats = myCatsStringToDict(myCats: keyValueStore.string(forKey: "myCats"))
            settingsButton!.settingsMenu!.mouseCoin!.setMouseCoinValue(newValue: keyValueStore.longLong(forKey: "mouseCoins"));
        } else {
            self.isInternetReachable = false;
            // Step out of multiplayer session
            self.boardGame!.stopSearchingForOpponentEntirely();
            // Stop autoloading ads
            bannerView.isAutoloadEnabled = false;
            // Display no Internet Message
            gameMessage!.displayNoInternetConsequencesMessage();
            // No internet mouse coinds
            myCats = myCatsStringToDict(myCats: nil);
            settingsButton!.settingsMenu!.mouseCoin!.setMouseCoinValue(newValue: 0);
        }
    }
    
    var myCatsString:String = "";
    var myCatsStringSection:String = "";
    func saveMyCatsDictAsString(catTypes:[Cat]) {
        for cat in catTypes {
            myCatsStringSection = "\(cat)";
            myCatsString += myCatsStringSection.prefix(1);
            myCatsString += String(Array(myCatsStringSection)[(myCatsStringSection.count / 2)]);
            myCatsString += myCatsStringSection.suffix(1);
            if (myCats[cat]! > 0) {
                myCatsString += "+\(myCats[cat]!)"
            } else if (myCats[cat]! == 0) {
                myCatsString += "00"
            }  else {
                myCatsString += "\(myCats[cat]!)"
            }
            myCatsStringSection = "";
        }
        NSUbiquitousKeyValueStore.default.set(myCatsString, forKey: "myCats");
        myCatsString = ""

    }
    
    func myCatsStringToDict(myCats:String?) -> [Cat:Int8] {
        if (myCats == nil) {
            return [.standard:1, .breading:0, .taco:0, .egyptian:0, .supeR:0, .chicken:0, .cool:0, .ninja:0, .fat:0]
        } else {
            print(myCats!, "These are my cats!!!");
            return [.standard:1, .breading:0, .taco:0, .egyptian:0, .supeR:0, .chicken:0, .cool:0, .ninja:0, .fat:0]
        }
    }
    
    static func unSelectSelectedCat() {
        for (cat, value) in ViewController.staticSelf!.myCats {
            if (value > 0) {
                ViewController.staticSelf!.myCats[cat] = -value;
            }
        }
    }
    
    static func getSelectedCatsCount() -> Int {
        return ViewController.staticSelf!.myCats.filter{$1 > 0}.count;
    }
    
    static func getRandomCat() -> Cat {
        return ViewController.staticSelf!.myCats.filter{$1 > 0}.randomElement()!.0;
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil);
    }

    @IBOutlet var mainView: UIView!
    var mainViewWidth:CGFloat = 0.0;
    var mainViewHeight:CGFloat = 0.0;
    var unitViewWidth:CGFloat = 0.0;
    var unitViewHeight:CGFloat = 0.0;
    
    // Static
    static var staticUnitViewHeight:CGFloat = 0.0;
    static var staticUnitViewWidth:CGFloat = 0.0;
    static var staticSelf:ViewController?
    static var staticMainView:UIView?
    
    // Game play components
    var introCatAnimation:UIIntroCatAnimation?;
    var settingsButton:UISettingsButton?
    static var settingsButton:UISettingsButton?
    var boardGame:UIBoardGame?
    var colorOptions:UIColorOptions?
    
    // Sucess gradient layer
    var successGradientLayer:CAGradientLayer?
    let mellowYellow:UIColor = UIColor(red: 252.0/255.0, green: 212.0/255.0, blue: 64.0/255.0, alpha: 1.0);
    var successGradientView:UIView?
    
    // Viruses
    var viruses:UIViruses?
    static var appInBackgroundBeforeFirstAttackImpulse:Bool = false;
    
    // Aspect ratio
    static var aspectRatio:AspectRatio?
    
    // Game center message
    var gameMessage:UIGameMessage?
    var gameCenterMessageWidthHeightY:(CGFloat, CGFloat, CGFloat)?;
    var gameCenterAuthentificationOver:Bool = false;
    
    // Game center leaderboard
    var isGCEnabled:Bool = Bool();
    var gcDefaultLeaderboardID:String = String();
    
    // Ads
    var bannerView: GADBannerView!
    var tempBannerView:GADBannerView?
    private static var interstitial:GADInterstitial!
    static var interstitialWillPresentScreen:Bool = false;
    static var interstitialWillDismissScreen:Bool = false;
    
    var keyValueStore:NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        setupReachability();
        ViewController.staticSelf = self;
        ViewController.staticMainView = mainView;
        setupAspectRatio();
        setupMainViewDimensionProperties();
        setupSaveTheCat();
        setupGameCenterMessage();
        authenticateLocalPlayerForGamePlay();
    }
    
    func setupReachability() {
        try? addReachabilityObserver();
        func isICloudContainerAvailable() -> Bool {
            if FileManager.default.ubiquityIdentityToken != nil {
                return true
            }
            else {
                return false
            }
        }
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true, block: { _ in
            self.isiCloudReachable = isICloudContainerAvailable();
            if (!self.isiCloudReachable && !self.firedITunesStatus) {
                self.gameMessage!.displayNotLoggedIntoiCloudMessage();
                self.gameMessage!.displayGameCenterDirectionsMessage();
                self.firedITunesStatus = true;
                // Step out of multiplayer session
                self.boardGame!.stopSearchingForOpponentEntirely();
            }
            if (self.isiCloudReachable && self.firedITunesStatus) {
                self.gameMessage!.displayLoggedIntoiCloudMessage();
                self.firedITunesStatus = false;
            }
        })
    }
    
    // Aspect ratio
    func setupAspectRatio() {
        let screenDecimalRatio:CGFloat = mainView.frame.height / mainView.frame.width;
        if (screenDecimalRatio > 2.1) {
            ViewController.aspectRatio = .ar19point5by9;
        } else if (screenDecimalRatio > 1.7) {
            ViewController.aspectRatio = .ar16by9;
        } else {
            ViewController.aspectRatio = .ar4by3;
        }
    }
    
    // Ads
    func setupAdvertisement() {
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["2077ef9a63d2b398840261c8221a0c9b"];
        setupBannerView();
        setupInterstitial();
    }
    
    // Interstisial
    func setupInterstitial() {
        ViewController.interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/5135589807");
        ViewController.interstitial.delegate = self;
        ViewController.interstitial.load(GADRequest());
    }
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        ViewController.interstitialWillPresentScreen = true;
        viruses!.hide();
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        boardGame!.glovePointer!.reset();
        ViewController.interstitialWillDismissScreen = true;
        ViewController.staticSelf!.setupInterstitial();
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        viruses!.sway(immediately: true);
    }
    
    static func presentInterstitial() {
        if ViewController.interstitial.isReady {
            ViewController.interstitial.present(fromRootViewController: staticSelf!);
        } else {
            print("MESSAGE:WHY IS THE INTERSTATIAL NOT READY?")
        }
    }
    
    // Banner
    func setupBannerView() {
        var adSize:GADAdSize!
        if (ViewController.aspectRatio! == .ar19point5by9) {
            adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(mainView.frame.width);
        } else if (ViewController.aspectRatio! == .ar16by9) {
            adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(mainView.frame.width);
        } else {
            adSize = kGADAdSizeLeaderboard;
        }
        // Set the banner view
        bannerView = GADBannerView(adSize: adSize);
        bannerView.backgroundColor = UIColor.clear;
        // Set the banner view frame and center
        bannerView.frame = CGRect(x: 0.0, y: mainView.frame.height - bannerView.frame.height, width: bannerView.frame.width + 1, height: bannerView.frame.height + 1);
        CenterController.centerHorizontally(childView: bannerView, parentRect: mainView.frame, childRect: bannerView.frame);
        // Configure for ad to display
        // myBannerID
        bannerView.adUnitID = "ca-app-pub-9248016465919511/3503661709";
        bannerView.rootViewController = self;
        bannerView.load(GADRequest());
        // Save first banner view as temp
        mainView.addSubview(bannerView);
        
    }
    
    // Game Center Authentication
    func authenticateLocalPlayerForGamePlay() {
        let player:GKLocalPlayer = GKLocalPlayer.local;
        player.authenticateHandler = {vc,error in
            guard error == nil else {
                if (self.gameCenterAuthentificationOver) {
                    return;
                }
                if (player.isAuthenticated) {
                    self.gameMessage!.stayALittleLonger = true;
                } else {
                    self.gameMessage!.displayGameCenterDirectionsMessage();
                    // Step out of multiplayer session
                    self.boardGame!.stopSearchingForOpponentEntirely();
                }
                self.gameCenterAuthentificationOver = true;
                print("DISABLE MULTIPLAYER")
                self.presentSaveTheCat();
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
                    self.gameCenterAuthentificationOver = true;
                    self.gameMessage!.stayALittleLonger = true;
                    print("ENABLE MULTIPLAYER")
                    print("PLAYER AUTHENTICATED!")
                    self.presentSaveTheCat();
                }
            }
        }
    }
    
    // Game center memory capacity score submission
    static var bestMemoryCapacityScore:GKScore?
    static func submitMemoryCapacityScore(memoryCapacity:Int) {
        bestMemoryCapacityScore = nil;
        bestMemoryCapacityScore = GKScore(leaderboardIdentifier: "topColorMemorizers");
        bestMemoryCapacityScore!.value = Int64(memoryCapacity);
        GKScore.report([bestMemoryCapacityScore!]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Memory Capacity score submitted to your Leaderboard!");
            }
        }
    }
    
    // Game center saved cats score
    static var bestCatSaverScore:GKScore?
    static var leaderBoard:GKLeaderboard?
    static var leaderBoardScore:Int64?
    static func submitCatsSavedScore(catsSaved:Int) {
        func submitScore(score:Int64) {
            bestCatSaverScore = nil;
            leaderBoard = nil;
            leaderBoardScore = nil;
            bestCatSaverScore = GKScore(leaderboardIdentifier: "topCatSavers");
            bestCatSaverScore!.value = score;
            GKScore.report([bestCatSaverScore!], withCompletionHandler: { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("Cat saver score submitted to your Leaderboard!");
                }
            })
        }
        leaderBoard = GKLeaderboard();
        leaderBoard!.identifier = "topCatSavers";
        // UNEXPECTED ERROR
        leaderBoard!.loadScores(completionHandler: { scores, error in
            if error == nil {
                if (leaderBoard!.localPlayerScore != nil) {
                    leaderBoardScore = Int64(catsSaved) + leaderBoard!.localPlayerScore!.value;
                    print("Now the score should be this", leaderBoardScore!);
                    submitScore(score:leaderBoardScore!);
                } else {
                    submitScore(score:Int64(catsSaved));
                }
            }
        })
    }
    
    // Game center leaderboard
    var gameCenterVC:GKGameCenterViewController?
    func checkMemoryCapacityLeaderBoard() {
        if (gameCenterVC == nil) {
            gameCenterVC = GKGameCenterViewController()
            gameCenterVC!.gameCenterDelegate = self;
            gameCenterVC!.viewState = .leaderboards;
        }
        present(gameCenterVC!, animated: true, completion: nil)
    }
    
    func setupGameCenterMessage() {
        let gameCenterMessageX:CGFloat = (mainView.frame.width - gameCenterMessageWidthHeightY!.0) * 0.5;
        gameMessage = UIGameMessage(parentView: mainView, frame: CGRect(x: gameCenterMessageX, y: gameCenterMessageWidthHeightY!.2, width: gameCenterMessageWidthHeightY!.0, height: gameCenterMessageWidthHeightY!.1));
        CenterController.centerHorizontally(childView: gameMessage!, parentRect: mainView.frame, childRect: gameMessage!.frame);
    }
    
    func setupSaveTheCat() {
        setupSounds();
        setupIntroCatAnimatio();
        setupSuccessGradientViewAndLayer();
        setupViruses();
        setupAdvertisement();
        setupBoardMainView();
        // Save the mouse coins from icloud
        setupColorOptionsView();
        setupGlovePointer();
        setupSettingsButton();
        self.setupNotificationCenter();
        SoundController.mozartSonata(play: true, startOver: true);
    }
    
    func presentSaveTheCat() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.introCatAnimation!.fadeOut();
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.viruses!.sway(immediately: false);
                self.viruses!.fadeIn();
                self.boardGame!.fadeIn();
                self.boardGame!.myLiveMeter!.fadeIn();
                if (ViewController.aspectRatio! != .ar16by9) {
                    self.boardGame!.myLiveMeter!.liveMeterView!.fadeIn();
                }
                self.boardGame!.opponentLiveMeter!.fadeIn();
                self.boardGame!.attackMeter!.compiledShow();
                self.colorOptions!.fadeIn();
                self.settingsButton!.fadeIn();
                self.settingsButton!.settingsMenu!.mouseCoin!.mouseCoinView!.fadeIn();
                self.boardGame!.buildGame();
                self.boardGame!.showSingleAndTwoPlayerButtons();
            }
        }
    }
    
    func setupNotificationCenter() {
        let notificationCenter = NotificationCenter.default;
        notificationCenter.addObserver(self, selector: #selector(self.appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil);
        notificationCenter.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil);
    }
    
    @objc func appMovedToBackground() {
        if (self.settingsButton!.settingsMenu!.moreCats!.moreCatsVC!.isViewLoaded) {
            self.settingsButton!.settingsMenu!.moreCats!.moreCatsVC!.hideCatButton();
        }
        if (self.boardGame!.opponent == nil) {
            self.boardGame!.attackMeter!.pauseVirusMovement();
        }
        self.viruses!.hide();
        self.boardGame!.cats.suspendCatAnimations();
        SoundController.chopinPrelude(play: false);
        SoundController.mozartSonata(play: false, startOver: false);
        print("App backgrounded");
    }
    
    @objc func appMovedToForeground() {
        if (self.settingsButton!.settingsMenu!.moreCats!.moreCatsVC!.isViewLoaded) {
            self.settingsButton!.settingsMenu!.moreCats!.moreCatsVC!.presentCatButton();
        }
        if (self.gameCenterAuthentificationOver){
            self.viruses!.sway(immediately: true);
        }
        self.boardGame!.cats.resumeCatAnimations();
        if (!settingsButton!.isPressed) {
            self.boardGame!.attackMeter!.unPauseVirusMovement();
        }
        if (boardGame!.iLost) {
            SoundController.chopinPrelude(play: true);
        } else {
            SoundController.mozartSonata(play: true, startOver: false);
        }
        print("App foregrounded");
    }
    
    func setupSounds() {
        SoundController.setupCuteLaugh();
        SoundController.setupGearSpinning();
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
        if (ViewController.aspectRatio! == .ar19point5by9) {
            mainViewWidth = mainView.frame.width;
            mainViewHeight = mainView.frame.height;
            setupUnitViewDimension();
            setupStaticUnitViewDimension();
            gameCenterMessageWidthHeightY = (unitViewWidth * 15.85, unitViewHeight * 1.35, unitViewHeight * 1.00);
        } else if (ViewController.aspectRatio! == .ar16by9) {
            mainViewWidth = mainView.frame.width;
            mainViewHeight = mainView.frame.height * 1.2;
            setupUnitViewDimension();
            setupStaticUnitViewDimension()
            gameCenterMessageWidthHeightY = (unitViewWidth * 16.5, unitViewHeight * 1.43, unitViewHeight * 0.6225);
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
    
    func setupIntroCatAnimatio(){
        let sideLength:CGFloat = unitViewWidth * 8.0;
        introCatAnimation = UIIntroCatAnimation(parentView: mainView, frame: CGRect(x: 0.0, y: 0.0, width: sideLength, height: sideLength));
        CenterController.center(childView: introCatAnimation!, parentRect: mainView.frame, childRect: introCatAnimation!.frame);
        introCatAnimation!.layer.borderWidth = 0.0;
        introCatAnimation!.fadeIn();
    }
    
    func setupSuccessGradientViewAndLayer() {
        // Setup success gradient view
        successGradientView = UIView(frame: mainView.frame);
        successGradientView!.backgroundColor = UIColor.clear;
        mainView!.addSubview(successGradientView!);
        mainView.sendSubviewToBack(successGradientView!);
        // Setup success gradient layer
        successGradientLayer = CAGradientLayer();
        successGradientLayer!.frame = successGradientView!.frame;
        successGradientView!.layer.addSublayer(successGradientLayer!);
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
        let boardGameWidth:CGFloat = unitViewHeight * 8.5;
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
        boardGame!.setupSingleAndTwoPlayerButtons();
        boardGame!.myLiveMeter!.alpha = 0.0;
        colorOptions!.alpha = 0.0;
    }
    
    func setupGlovePointer() {
        let sideLength:CGFloat = ViewController.staticUnitViewHeight * 1.5;
        boardGame!.glovePointer = UIGlovedPointer(parentView: ViewController.staticMainView!, frame: CGRect(x: 0.0, y: colorOptions!.frame.minY + colorOptions!.frame.height * 0.13, width: sideLength, height: sideLength));
        boardGame!.glovePointer!.shrinked();
        boardGame!.glovePointer!.reset();
     }
    
    func setupSettingsButton() {
        let sideLength:CGFloat = (mainView.frame.height * ((1.0/300.0) + 0.08));
        settingsButton = UISettingsButton(parentView: mainView, x: unitViewWidth, y: unitViewHeight, width: sideLength, height: sideLength);
        settingsButton!.setBoardGameAndColorOptionsView(boardGameView:boardGame!, colorOptionsView: colorOptions!);
        ViewController.settingsButton = settingsButton!;
        boardGame!.settingsButton = settingsButton!;
        settingsButton!.settingsMenu!.alpha = 0.0;
        settingsButton!.alpha = 0.0;
        settingsButton!.settingsMenu!.mouseCoin!.amountLabel!.text = "0";
        // Settings button for victory view
        self.boardGame!.victoryView!.settingsButton = settingsButton!;
        self.boardGame!.victoryView!.settingsMenuFrame = settingsButton!.settingsMenu!.frame;
        self.boardGame!.victoryView!.settingsMouseCoinFrame = settingsButton!.settingsMenu!.mouseCoin!.frame;
    }
    
    func setStyle() {
        gameMessage!.setStyle();
        viruses!.setStyle();
        introCatAnimation!.setCompiledStyle();
        setSuccessGradientLayerStyle();
        settingsButton!.setStyle();
        settingsButton!.settingsMenu!.multiplayer!.setStyle();
        settingsButton!.settingsMenu!.moreCats!.setCompiledStyle();
        if (settingsButton!.settingsMenu!.mouseCoin!.mouseCoinView!.backgroundColor!.cgColor != UIColor.clear.cgColor) {
            if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
                settingsButton!.settingsMenu!.mouseCoin!.mouseCoinView!.backgroundColor = UIColor.white;
            } else {
                settingsButton!.settingsMenu!.mouseCoin!.mouseCoinView!.backgroundColor = UIColor.black;
            }
        }
        boardGame!.singlePlayerButton!.setStyle();
        boardGame!.twoPlayerButton!.setStyle();
        boardGame!.cats.updateUIStyle();
        boardGame!.myLiveMeter!.setCompiledStyle();
        boardGame!.opponentLiveMeter!.setCompiledStyle();
        boardGame!.results!.setCompiledStyle();
        boardGame!.attackMeter!.setCompiledStyle();
        colorOptions!.setStyle();
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setStyle();
    }
}
