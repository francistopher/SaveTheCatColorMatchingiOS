//
//  ViewController.swift
//  bagDatCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    // Main View Controller Properties
    var mainViewWidth:CGFloat = 0.0;
    var mainViewHeight:CGFloat = 0.0;
    
    var unitViewHeight:CGFloat = 0.0;
    var unitViewWidth:CGFloat = 0.0;
    
    // Intro Label Properties
    var introLabel:UICLabel? = nil;
    
    // Game Play View Properties
    var boardGameView:UIBoardGameView? = nil;
    var colorOptionsView:UIColorOptionsView? = nil;
    var settingsButton:UISettingsButton? = nil;
    var resetButton:UICButton? = nil;
    static var settings:UISettingsButton? = nil;
    
    // Add heaven gradient layer
    var completionGradientLayer:CAGradientLayer? = nil;
    let mellowYellow:UIColor = UIColor(red: 252.0/255.0, green: 212.0/255.0, blue: 64.0/255.0, alpha: 1.0);
    // Viruses
    var viruses:UIViruses? = nil;
    
    @IBOutlet var mainViewController: UIView!
    override func viewDidLoad() {
        super.viewDidLoad();
        // Save the interface style to customize applications
        let userInterfaceStyle:Int = UIScreen.main.traitCollection.userInterfaceStyle.rawValue;
        saveMainViewFoundationalProperties();
        configureIntroLabel(userInterfaceStyle:userInterfaceStyle);
        configureHeavenGradientLayer();
        configureBoardGameView(userInterfaceStyle:userInterfaceStyle);
        configureColorOptionsView(userInterfaceStyle:userInterfaceStyle);
        configureSettingsButton(userInterfaceStyle:userInterfaceStyle);
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.boardGameView!.fadeIn();
            self.colorOptionsView!.fadeIn();
            self.boardGameView!.buildBoardGame();
            self.settingsButton!.show();
            self.settingsButton!.settingsMenu!.fadeIn();
            // Control all animations when app is foregrounded, backgrounded, and deactivated
            let notificationCenter = NotificationCenter.default;
            notificationCenter.addObserver(self, selector: #selector(self.appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil);
            notificationCenter.addObserver(self, selector: #selector(self.appDeactivated), name: UIApplication.willResignActiveNotification, object: nil);
            notificationCenter.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil);
        }
    }
    
    @objc func appMovedToBackground() {
        self.boardGameView!.cats.suspendCatAnimations();
    }
    
    @objc func appMovedToForeground() {
        self.boardGameView!.cats.resumeCatAnimations();
        print("App foregrounded");
    }
    @objc func appDeactivated() {
        self.boardGameView!.cats.activateCatsForUIStyle();
        print("App deactivated");
    }
    
    @objc func resetGrid(sender:UICButton){
        boardGameView!.restart();
    }
    
    func configureHeavenGradientLayer() {
        completionGradientLayer = CAGradientLayer();
        completionGradientLayer!.frame = mainViewController.frame;
        mainViewController.layer.addSublayer(completionGradientLayer!);
        completionGradientLayer!.type = .radial;
        completionGradientLayer!.startPoint = CGPoint(x:0.5, y:0.0);
        completionGradientLayer!.endPoint = CGPoint(x:-0.5, y:0.15);
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
             self.completionGradientLayer!.colors = [self.mellowYellow.cgColor, UIColor.white.cgColor];
         } else {
             self.completionGradientLayer!.colors =  [self.mellowYellow.cgColor, UIColor.black.cgColor];
        }
        completionGradientLayer!.isHidden = true;
    }
    
    func saveMainViewFoundationalProperties() {
        let decimalRatio:CGFloat = mainViewController.frame.height / mainViewController.frame.width;
        var mainViewHeight:CGFloat = mainViewController.frame.height;
        var mainViewWidth:CGFloat =  mainViewController.frame.width;
        if (decimalRatio > 2.1) {
            mainViewWidth = mainViewController.frame.width;
            mainViewHeight = mainViewController.frame.height * 3.0 / 4.0;
        } else if (decimalRatio > 3.7) {
            mainViewWidth = mainViewController.frame.width;
            mainViewHeight = mainViewController.frame.height * 3.0 / 4.0;
        } else {
            mainViewWidth = mainViewController.frame.width;
            mainViewHeight = mainViewController.frame.height * 1.2;
        }
        unitViewHeight = mainViewHeight / 18.0;
        unitViewWidth = mainViewWidth / 18.0;
    }
    
    func configureIntroLabel(userInterfaceStyle:Int){
        introLabel = UICLabel(parentView: mainViewController, x: 0.0, y: 0.0, width: unitViewWidth * 6, height: unitViewHeight);
        UICenterKit.center(childView: introLabel!, parentRect: mainViewController.frame, childRect: introLabel!.frame);
        introLabel!.font = UIFont.boldSystemFont(ofSize: unitViewHeight * 0.75);
        introLabel!.backgroundColor = .clear;
        introLabel!.text = "Viral Cats";
        introLabel!.alpha = 0.0;
        introLabel!.fadeInAndOut();
    }
        
    func configureBoardGameView(userInterfaceStyle:Int){
        let boardGameWidth:CGFloat = unitViewHeight * 8;
        boardGameView = UIBoardGameView(parentView: mainViewController, x: 0.0, y: 0.0, width: boardGameWidth, height:boardGameWidth);
        UICenterKit.centerWithVerticalDisplacement(childView: boardGameView!, parentRect: mainViewController.frame, childRect: boardGameView!.frame, verticalDisplacement: -unitViewWidth * 0.75);
        boardGameView!.completionGradientLayer = completionGradientLayer!;
        boardGameView!.alpha = 0.0;
    }

    func configureColorOptionsView(userInterfaceStyle:Int){
        colorOptionsView = UIColorOptionsView(parentView: mainViewController, x: boardGameView!.frame.minX, y: boardGameView!.frame.maxY + unitViewWidth, width: boardGameView!.frame.width, height: unitViewWidth * 2.5);
        UICenterKit.centerHorizontally(childView: colorOptionsView!, parentRect: mainViewController.frame, childRect: colorOptionsView!.frame);
        boardGameView!.colorOptionsView = colorOptionsView!;
        colorOptionsView!.boardGameView = boardGameView!;
        colorOptionsView!.alpha = 0.0;
    }
    
    func configureSettingsButton(userInterfaceStyle:Int) {
        settingsButton = UISettingsButton(parentView: mainViewController, x: unitViewWidth, y: unitViewHeight * 1.125, width: unitViewWidth * 2, height: unitViewWidth * 2);
        settingsButton!.setBoardGameAndColorOptionsView(boardGameView:boardGameView!, colorOptionsView: colorOptionsView!);
        boardGameView!.settingsButton = settingsButton!;
        settingsButton!.setStyle();
        settingsButton!.alpha = 0.0;
        settingsButton!.settingsMenu!.alpha = 0.0;
        ViewController.settings = settingsButton!;
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        introLabel!.setStyle();
        settingsButton!.setStyle();
        boardGameView!.cats.activateCatsForUIStyle();
        colorOptionsView!.setStyle();
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            self.completionGradientLayer!.colors = [self.mellowYellow.cgColor, UIColor.white.cgColor];
        } else {
            self.completionGradientLayer!.colors =  [self.mellowYellow.cgColor, UIColor.black.cgColor];
       }
    }
}

