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
    var resetButton:UICButton? = nil;
    
    // Add heaven gradient layer
    var heavenGradientLayer:CACGradientLayer? = nil;
    let heavenBlueOnBlack:UIColor = UIColor.white;
    let heavenBlueOnWhite:UIColor = UIColor(red: 252.0/255.0, green: 212.0/255.0, blue: 64.0/255.0, alpha: 1.0);
    
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
        resetButton = UICButton(parentView: mainViewController, x: 0, y: 0, width: unitView, height: unitView, backgroundColor: UIColor.white);
        resetButton!.addTarget(self, action: #selector(resetGrid), for: .touchUpInside);
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.boardGameView!.fadeIn();
            self.colorOptionsView!.fadeIn();
            self.boardGameView!.buildBoardGame();
            // Resume all animations when app is foregrounded and backgrounded
            let notificationCenter = NotificationCenter.default;
            notificationCenter.addObserver(self, selector: #selector(self.appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil);
            notificationCenter.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil);
        }
    }
    @objc func appMovedToBackground(){
        self.boardGameView!.stopGridButtonImageLayerAnimations();
    }

    @objc func appMovedToForeground() {
        self.boardGameView!.resumeGridButtonImageLayerAnimations();
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
        colorOptionsView = UIColorOptionsView(parentView: mainViewController, x: boardGameView!.frame.minX, y: boardGameView!.frame.minY + boardGameView!.frame.height + unitView, width: boardGameView!.frame.width, height: unitView * 1.5, backgroundColor: backgroundColor);
        colorOptionsView!.alpha = 0.0;
        boardGameView!.colorOptionsView = colorOptionsView!;
        colorOptionsView!.boardGameView = boardGameView!;
    }
  
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Detected A Light User Interface Style
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            heavenGradientLayer!.configureForUserInterfaceStyle();
            introLabel!.fadeOnDark();
            boardGameView!.fadeOnDark();
            colorOptionsView!.fadeOnDark();
        }
        // Detected A Dark User Interface Style
        else {
            heavenGradientLayer!.configureForUserInterfaceStyle();
            introLabel!.fadeOnLight();
            boardGameView!.fadeOnLight();
            colorOptionsView!.fadeOnLight();
        }
    }
    
   

}

