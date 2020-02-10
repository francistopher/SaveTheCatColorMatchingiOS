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
    var heavenGradientLayer:CACGradientLayer? = nil;
    let heavenBlueOnBlack:UIColor = UIColor.white;
    let heavenBlueOnWhite:UIColor = UIColor(red: 252.0/255.0, green: 212.0/255.0, blue: 64.0/255.0, alpha: 1.0);
    
    // Save viruses
    var viruses:[UICButton] = [UICButton]();
    
    @IBOutlet var mainViewController: UIView!
    override func viewDidLoad() {
        super.viewDidLoad();
        // Save the interface style to customize applications
        let userInterfaceStyle:Int = UIScreen.main.traitCollection.userInterfaceStyle.rawValue;
        saveMainViewFoundationalProperties();
        configureHeavenGradientLayer();
        configureIntroLabel(userInterfaceStyle:userInterfaceStyle);
        configureBoardGameView(userInterfaceStyle:userInterfaceStyle);
        configureColorOptionsView(userInterfaceStyle:userInterfaceStyle);
        buildViruses(userInterfaceStyle:userInterfaceStyle);
        configureSettingsButton(userInterfaceStyle:userInterfaceStyle);
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
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
        print("App foregrounded");
    }
    @objc func appDeactivated() {
        self.boardGameView!.activateGridButtonsForUserInterfaceStyle();
        print("App deactivated");
    }
    
    @objc func resetGrid(sender:UICButton){
        boardGameView!.reset(promote: false);
    }
    
    func configureHeavenGradientLayer() {
        heavenGradientLayer = CACGradientLayer(parentView: mainViewController, type:.radial, startPoint: CGPoint(x:0.5, y:0.0));
        heavenGradientLayer!.setEndingPoints(lightEndingPoint: CGPoint(x:-0.4, y:0.15), darkEndingPoint: CGPoint(x:-0.1, y:0.15));
        heavenGradientLayer!.setColors(lightColors: [heavenBlueOnWhite.cgColor, UIColor.white.cgColor], darkColors: [heavenBlueOnBlack.cgColor, UIColor.black.cgColor]);
        heavenGradientLayer!.configureForUserInterfaceStyle();
        heavenGradientLayer!.isHidden = true;
    }
    
    func saveMainViewFoundationalProperties() {
        mainViewWidth = mainViewController.frame.height * 9.0 / 16.0;
        mainViewHeight = mainViewController.frame.height;
        unitView = mainViewHeight / 18.0;
    }
    
    func configureIntroLabel(userInterfaceStyle:Int){
        let backgroundColor:UIColor = (userInterfaceStyle == 1 ? UIColor.white : UIColor.black);
        let textColor:UIColor = (userInterfaceStyle == 1 ? UIColor.black : UIColor.white);
        introLabel = UICLabel(parentView: mainViewController, x: 0, y: 0, width: mainViewWidth * 0.5, height: mainViewHeight * 0.15, backgroundColor: backgroundColor, textColor: textColor, font: UIFont.boldSystemFont(ofSize: 48.0), text: "podDatCat");
        UICenterKit.center(childView: introLabel!, parentRect: mainViewController.frame, childRect: introLabel!.frame);
        introLabel!.alpha = 0.0;
        introLabel!.fadeInAndOut();
    }
        
    func configureBoardGameView(userInterfaceStyle:Int){
        let backgroundColor:UIColor = (userInterfaceStyle == 1 ? UIColor.white : UIColor.black);
        boardGameView = UIBoardGameView(parentView: mainViewController, x: 0, y: 0, width: mainViewWidth * 0.90, height:  mainViewWidth * 0.90, backgroundColor: backgroundColor);
        UICenterKit.centerWithVerticalDisplacement(childView: boardGameView!, parentRect: mainViewController.frame, childRect: boardGameView!.frame, verticalDisplacement: -unitView * 1.5);
        boardGameView!.alpha = 0.0;
        boardGameView!.heavenGradientLayer = heavenGradientLayer!;
    }
    
    func configureColorOptionsView(userInterfaceStyle:Int){
        let backgroundColor:UIColor = (userInterfaceStyle == 1 ? UIColor.white : UIColor.black);
        colorOptionsView = UIColorOptionsView(parentView: mainViewController, x: boardGameView!.frame.minX, y: boardGameView!.frame.minY + boardGameView!.frame.height + (unitView * 2), width: boardGameView!.frame.width, height: unitView * 1.25, backgroundColor: backgroundColor);
        colorOptionsView!.alpha = 0.0;
        boardGameView!.colorOptionsView = colorOptionsView!;
        colorOptionsView!.boardGameView = boardGameView!;
    }
    
    func configureSettingsButton(userInterfaceStyle:Int) {
        settingsButton = UISettingsButton(parentView: mainViewController, x: unitView, y: unitView, width: unitView * 1.25, height: unitView * 1.25);
        settingsButton!.setStyle();
        settingsButton!.alpha = 0.0;
    }
    
    func buildViruses(userInterfaceStyle:Int) {
        let backgroundColor:UIColor = (userInterfaceStyle == 1 ? UIColor.white : UIColor.black);
        // Calculate side and spacing lengths of virus
        let virusesSpacingLength:CGFloat = boardGameView!.frame.width - ((unitView * 2.0) * 3.0);
        let virusSpacingLength:CGFloat = virusesSpacingLength / 4.0;
        let virusSideLength:CGFloat = unitView * 2.0;
        // Create variables to store temporary virus coordinates
        var x:CGFloat = 0.0;
        var y:CGFloat = 0.0;
        // Position viruses
        for side in 0..<4{
            if (side == 0) {
                x = boardGameView!.frame.minX
                y = boardGameView!.frame.minY - (unitView * 2.0);
            } else if (side == 1) {
                x = boardGameView!.frame.minX;
                y = boardGameView!.frame.minY + boardGameView!.frame.height;
            } else if (side == 2) {
                x = boardGameView!.frame.minX - (unitView * 2.0);
                y = boardGameView!.frame.minY;
            } else {
                x = boardGameView!.frame.minX + boardGameView!.frame.width;
                y = boardGameView!.frame.minY;
            }
            for _ in 0..<3{
                if (side == 0 || side == 1){
                    x += virusSpacingLength;
                } else {
                    y += virusSpacingLength;
                }
                let virus:UICButton = UICButton(parentView: mainViewController, x: x, y: y, width: unitView * 2.0, height: unitView * 2.0, backgroundColor: backgroundColor);
                virus.setCurrentVirusAnimation();
                virus.setVirus();
                if (side == 0 || side == 1){
                    x += virusSideLength;
                } else {
                    y += virusSideLength;
                }
                viruses.append(virus);
            }
        }
    }
  
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Detected A Light User Interface Style
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            boardGameView!.activateGridButtonsForUserInterfaceStyle();
            heavenGradientLayer!.configureForUserInterfaceStyle();
            settingsButton!.setStyle();
            introLabel!.fadeOnDark();
            boardGameView!.fadeOnDark();
            colorOptionsView!.fadeOnDark();
        }
        // Detected A Dark User Interface Style
        else {
            boardGameView!.activateGridButtonsForUserInterfaceStyle();
            heavenGradientLayer!.configureForUserInterfaceStyle();
            settingsButton!.setStyle();
            introLabel!.fadeOnLight();
            boardGameView!.fadeOnLight();
            colorOptionsView!.fadeOnLight();
        }
    }
    
   

}

