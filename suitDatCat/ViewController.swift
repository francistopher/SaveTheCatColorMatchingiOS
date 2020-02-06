//
//  ViewController.swift
//  bagDatCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import UIKit

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
    
    @IBOutlet var mainViewController: UIView!
    override func viewDidLoad() {
        super.viewDidLoad();
        let userInterfaceStyle:Int = UIScreen.main.traitCollection.userInterfaceStyle.rawValue;
        saveMainViewFoundationalProperties();
        configureIntroLabel(userInterfaceStyle:userInterfaceStyle);
        configureBoardGameView(userInterfaceStyle:userInterfaceStyle);
        configureColorOptionsView(userInterfaceStyle:userInterfaceStyle);
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.boardGameView!.fadeIn();
            self.colorOptionsView!.fadeIn();
        }
    }
    
    func saveMainViewFoundationalProperties() {
        mainViewWidth = mainViewController.frame.height * 9.0 / 16.0;
        mainViewHeight = mainViewController.frame.height;
        unitView = mainViewHeight / 18.0;
    }
    
    func configureIntroLabel(userInterfaceStyle:Int){
        let backgroundColor:UIColor = (userInterfaceStyle == 1 ? UIColor.white : UIColor.black);
        let textColor:UIColor = (userInterfaceStyle == 1 ? UIColor.black : UIColor.white);
        introLabel = UICLabel(parentView: mainViewController, x: 0, y: 0, width: mainViewWidth * 0.5, height: mainViewHeight * 0.15, backgroundColor: backgroundColor, textColor: textColor, font: UIFont.boldSystemFont(ofSize: 48.0), text: "suitDatCat");
        UICenterKit.center(childView: introLabel!, parentRect: mainViewController.frame, childRect: introLabel!.frame);
        introLabel!.alpha = 0.0;
        introLabel!.fadeInAndOut();
    }
        
    func configureBoardGameView(userInterfaceStyle:Int){
        let backgroundColor:UIColor = (userInterfaceStyle == 1 ? UIColor.white : UIColor.black);
        boardGameView = UIBoardGameView(parentView: mainViewController, x: 0, y: 0, width: mainViewWidth * 0.90, height:  mainViewWidth * 0.90, backgroundColor: backgroundColor);
        UICenterKit.centerWithVerticalDisplacement(childView: boardGameView!, parentRect: mainViewController.frame, childRect: boardGameView!.frame, verticalDisplacement: -unitView * 1.5);
        boardGameView!.alpha = 0.0;
    }
    
    func configureColorOptionsView(userInterfaceStyle:Int){
        let backgroundColor:UIColor = (userInterfaceStyle == 1 ? UIColor.white : UIColor.black);
        colorOptionsView = UIColorOptionsView(parentView: mainViewController, x: boardGameView!.frame.minX, y: boardGameView!.frame.minY + boardGameView!.frame.height + unitView, width: boardGameView!.frame.width, height: unitView * 1.5, backgroundColor: backgroundColor);
        colorOptionsView!.alpha = 0.0;
        boardGameView!.colorOptionsView! = colorOptionsView!;
        colorOptionsView!.boardGameView! = boardGameView!;
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Detected A Light User Interface Style
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            introLabel!.fadeOnDark();
            boardGameView!.fadeOnDark();
            colorOptionsView!.fadeOnDark();
        }
        // Detected A Dark User Interface Style
        else {
            introLabel!.fadeOnLight();
            boardGameView!.fadeOnLight();
            colorOptionsView!.fadeOnLight();
        }
    }

}

