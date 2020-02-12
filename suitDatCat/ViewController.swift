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
    var unitView:CGFloat = 0.0;
    
    // Intro Label Properties
    var introLabel:UICLabel? = nil;
    
    // Game Play View Properties
    var boardGameView:UIBoardGameView? = nil;
    var colorOptionsView:UIColorOptionsView? = nil;
    var settingsButton:UISettingsButton? = nil;
    var resetButton:UICButton? = nil;
    
    // Add heaven gradient layer
    var completionGradientLayer:CAGradientLayer? = nil;
    // Viruses
    var viruses:UIViruses? = nil;
    
    @IBOutlet var mainViewController: UIView!
    override func viewDidLoad() {
        super.viewDidLoad();
        // Save the interface style to customize applications
        let userInterfaceStyle:Int = UIScreen.main.traitCollection.userInterfaceStyle.rawValue;
        saveMainViewFoundationalProperties();
        configureHeavenGradientLayer();
        configureIntroLabel(userInterfaceStyle:userInterfaceStyle);
        configureViruses();
        configureBoardGameView(userInterfaceStyle:userInterfaceStyle);
        configureColorOptionsView(userInterfaceStyle:userInterfaceStyle);
        configureSettingsButton(userInterfaceStyle:userInterfaceStyle);
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.viruses!.fadeIn();
            self.boardGameView!.fadeIn();
            self.colorOptionsView!.fadeIn();
            self.boardGameView!.buildBoardGame();
            self.settingsButton!.show();
            // Control all animations when app is foregrounded, backgrounded, and deactivated
            let notificationCenter = NotificationCenter.default;
            notificationCenter.addObserver(self, selector: #selector(self.appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil);
            notificationCenter.addObserver(self, selector: #selector(self.appDeactivated), name: UIApplication.willResignActiveNotification, object: nil);
            notificationCenter.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil);
        }
    }
    
    @objc func appMovedToBackground() {
        self.boardGameView!.suspendGridButtonImageLayerAnimations();
    }
    
    @objc func appMovedToForeground() {
        self.boardGameView!.resumeGridButtonImageLayerAnimations();
        self.viruses!.sway();
        print("App foregrounded");
    }
    @objc func appDeactivated() {
        self.boardGameView!.activateGridButtonsForUserInterfaceStyle();
        print("App deactivated");
    }
    
    @objc func resetGrid(sender:UICButton){
        boardGameView!.restart(promote: false);
    }
    
    func configureHeavenGradientLayer() {
        let mellowYellow:UIColor = UIColor(red: 252.0/255.0, green: 212.0/255.0, blue: 64.0/255.0, alpha: 1.0);
        completionGradientLayer = CAGradientLayer();
        completionGradientLayer!.frame = mainViewController.frame;
        mainViewController.layer.addSublayer(completionGradientLayer!);
        completionGradientLayer!.type = .radial;
        completionGradientLayer!.startPoint = CGPoint(x:0.5, y:0.0);
        completionGradientLayer!.endPoint = CGPoint(x:-0.5, y:0.15);
        completionGradientLayer!.colors = [mellowYellow.cgColor, UIColor.clear.cgColor];
        completionGradientLayer!.isHidden = true;
    }
    
    func saveMainViewFoundationalProperties() {
        mainViewWidth = mainViewController.frame.height * 9.0 / 16.0;
        mainViewHeight = mainViewController.frame.height;
        unitView = mainViewHeight / 18.0;
    }
    
    func configureIntroLabel(userInterfaceStyle:Int){
        let textColor:UIColor = (userInterfaceStyle == 1 ? UIColor.black : UIColor.white);
        introLabel = UICLabel(parentView: mainViewController, x: 0, y: 0, width: mainViewWidth * 0.5, height: mainViewHeight * 0.15);
        introLabel!.backgroundColor = .clear;
        introLabel!.textColor = textColor;
        introLabel!.font = UIFont.boldSystemFont(ofSize: unitView * 0.75);
        introLabel!.text = "podDatCat";
        UICenterKit.center(childView: introLabel!, parentRect: mainViewController.frame, childRect: introLabel!.frame);
        introLabel!.alpha = 0.0;
        introLabel!.fadeInAndOut();
    }
        
    func configureBoardGameView(userInterfaceStyle:Int){
        boardGameView = UIBoardGameView(parentView: mainViewController, x: 0, y: 0, width: mainViewWidth * 0.80, height:  mainViewWidth * 0.80, backgroundColor: .clear);
        UICenterKit.centerWithVerticalDisplacement(childView: boardGameView!, parentRect: mainViewController.frame, childRect: boardGameView!.frame, verticalDisplacement: -unitView * 0.625);
        boardGameView!.completionGradientLayer = completionGradientLayer!;
        boardGameView!.layer.borderColor! = UIColor.clear.cgColor;
        boardGameView!.viruses = viruses!;
        boardGameView!.alpha = 0.0;
    }
    
    func configureColorOptionsView(userInterfaceStyle:Int){
        colorOptionsView = UIColorOptionsView(parentView: mainViewController, x: boardGameView!.frame.minX, y: boardGameView!.frame.minY + boardGameView!.frame.height, width: boardGameView!.frame.width, height: unitView * 1.25, backgroundColor: .clear);
        colorOptionsView!.alpha = 0.0;
        boardGameView!.colorOptionsView = colorOptionsView!;
        colorOptionsView!.boardGameView = boardGameView!;
    }
    
    func configureSettingsButton(userInterfaceStyle:Int) {
        settingsButton = UISettingsButton(parentView: mainViewController, x: unitView, y: unitView, width: unitView * 1.25, height: unitView * 1.25);
        settingsButton!.setStyle();
        settingsButton!.alpha = 0.0;
        settingsButton!.boardGameView = boardGameView!;
        settingsButton!.colorOptionsView = colorOptionsView!;
        boardGameView!.settingsButton = settingsButton!;
    }
    
    func configureViruses() {
        viruses = UIViruses(mainView: mainViewController, unitView:unitView);
        viruses!.hide();
        viruses!.sway();
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Detected A Light User Interface Style
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            boardGameView!.activateGridButtonsForUserInterfaceStyle();
            settingsButton!.setStyle();
        }
        // Detected A Dark User Interface Style
        else {
            boardGameView!.activateGridButtonsForUserInterfaceStyle();
            settingsButton!.setStyle();
        }
    }
    
   

}

