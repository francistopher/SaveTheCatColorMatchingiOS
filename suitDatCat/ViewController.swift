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
    var boardGameView:UICView? = nil;
    var colorOptionsView:UICView? = nil;
    
    @IBOutlet var mainViewController: UIView!
    override func viewDidLoad() {
        super.viewDidLoad();
        saveMainViewFoundationalProperties();
        configureIntroLabel();
        configureBoardGameView();
        configureColorOptionsView();
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
    
    func configureIntroLabel(){
        introLabel = UICLabel(parentView: mainViewController, x: 0, y: 0, width: mainViewWidth * 0.5, height: mainViewHeight * 0.15, backgroundColor: UIColor.black, textColor: UIColor.white, font: UIFont.boldSystemFont(ofSize: 48.0), text: "suitDatCat");
        UICenterKit.center(childView: introLabel!, parentRect: mainViewController.frame, childRect: introLabel!.frame);
        introLabel!.alpha = 0.0;
        introLabel!.fadeInAndOut();
    }
        
    func configureBoardGameView(){
        boardGameView = UICView(parentView: mainViewController, x: 0, y: 0, width: mainViewWidth * 0.90, height:  mainViewWidth * 0.90, backgroundColor: UIColor.lightGray);
        UICenterKit.centerWithVerticalDisplacement(childView: boardGameView!, parentRect: mainViewController.frame, childRect: boardGameView!.frame, verticalDisplacement: -unitView * 1.5);
        boardGameView!.alpha = 0.0;
    }
    
    func configureColorOptionsView(){
        colorOptionsView = UICView(parentView: mainViewController, x: boardGameView!.frame.minX, y: boardGameView!.frame.minY + boardGameView!.frame.height + unitView, width: boardGameView!.frame.width, height: unitView * 1.5, backgroundColor: UIColor.lightGray);
        colorOptionsView!.alpha = 0.0;
    }


}

