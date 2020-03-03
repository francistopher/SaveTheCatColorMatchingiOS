//
//  UIStatistics.swift
//  CatVirus
//
//  Created by Christopher Francisco on 2/20/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIStatistics:UICView {
    
    static var selectedCat:Cat = .fancy;
    static var mouseCoins:Int = 0;
    
    var gameOverLabel:UICLabel?
    
    var catsLivedLabel:UICLabel?
    var catsDiedLabel:UICLabel?
    var catsLivedAmountLabel:UICLabel?
    var catsDiedAmountLabel:UICLabel?
    var livedCatImageButton:UICButton?
    var deadCatImageButton:UICButton?
    
    var stagesLabel:UICLabel?
    var stagesRangeLabel:UICLabel?
    var durationLabel:UICLabel?
    var durationTimeLabel:UICLabel?
    
    var continueButton:UICButton?
    
    var unitHeight:CGFloat?
    
    // Survival and Death Count
    var entiretyOfCatsThatDied:Int = 0;
    var entiretyOfCatsThatSurvived:Int = 0;
    var catsThatDied:Int = 0;
    var catsThatLived:Int = 0;
    
    // Gameplay session time
    var sessionStartTime:Double = 0.0;
    var sessionEndTime:Double = 0.0;
    var sessionDuration:Double = 0.0;
    var maxStage:Int = 0;
    
    // Content panel
    var contentView:UICView?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView) {
        super.init(parentView: parentView, x: 0.0, y: 0.0, width: ViewController.staticUnitViewHeight * 8.0, height: ViewController.staticUnitViewHeight * 9.0, backgroundColor: .black);
        parentView.addSubview(self);
        self.layer.borderWidth = 0.0;
        self.layer.cornerRadius = ViewController.staticUnitViewHeight * 8.0 / 7.0;
        roundCorners(radius: self.frame.width * 0.5, [.topLeft, .topRight], lineWidth: 0.0);
        // Setup contents
        setupContentView();
        self.unitHeight = contentView!.frame.height / 8.0;
        setupGameOverLabel();
        setupCheeringCatLabel();
        setupDeadCatLabel();
        setupStagesLabel();
        setupDurationLabel();
        setupContinueButton();
        super.invertColor = true;
        self.setCompiledStyle();
        UICenterKit.center(childView: self, parentRect: superview!.frame, childRect: self.frame);
        self.alpha = 0.0;
    }
    
    func setupContentView() {
        self.contentView = UICView(parentView: self, x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height, backgroundColor: UIColor.white);
        contentView!.layer.borderWidth = 0.0;
        contentView!.transform = contentView!.transform.scaledBy(x: 0.96, y: 0.96);
        contentView!.layer.cornerRadius = contentView!.frame.width / 7.0;
        contentView!.roundCorners(radius: contentView!.frame.width * 0.5, [.topLeft, .topRight], lineWidth: 0.0)
    }
    
    static func getCatFileName(named:String) -> String {
        // Build cat directory string
        var namedCatImage:String = "";
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            namedCatImage += "light";
        } else{
            namedCatImage += "dark";
        }
        switch (UIStatistics.selectedCat) {
        case Cat.fancy:
            return namedCatImage + "Fancy" + named;
        case Cat.ninja:
            return namedCatImage + "Ninja" + named;
        case Cat.standard:
            return namedCatImage + named;
        }
    }
    
    func setupGameOverLabel() {
        self.gameOverLabel = UICLabel(parentView: contentView!, x: 0.0, y: 0.0, width: contentView!.frame.width + (self.frame.width / 4.0), height: unitHeight! * 2.0);
        gameOverLabel!.font = UIFont.boldSystemFont(ofSize: gameOverLabel!.frame.height * 0.40);
        gameOverLabel!.layer.borderWidth = self.layer.borderWidth;
        gameOverLabel!.setStyle();
        gameOverLabel!.text = "R I P";
        UICenterKit.centerHorizontally(childView: gameOverLabel!, parentRect: self.frame, childRect: gameOverLabel!.frame);
    }
    
    func setupCheeringCatLabel() {
        self.catsLivedLabel = UICLabel(parentView: contentView!, x: self.frame.width * 0.02875, y: gameOverLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight! * 2.0);
        catsLivedLabel!.backgroundColor = UIColor.clear;
        setupLivedCatImage();
        setupCatsLivedAmount();
    }
    
    func setupCatsLivedAmount() {
        self.catsLivedAmountLabel = UICLabel(parentView: contentView!, x: self.frame.width * 0.02875, y: catsLivedLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight!);
        catsLivedAmountLabel!.font = UIFont.boldSystemFont(ofSize: catsLivedAmountLabel!.frame.height * 0.40);
        catsLivedAmountLabel!.backgroundColor = UIColor.clear;
        catsLivedAmountLabel!.textColor = UIColor.black;
    }
    
    func setupLivedCatImage() {
        self.livedCatImageButton = UICButton(parentView: catsLivedLabel!, frame:CGRect( x: 0.0, y: 0.0, width: catsLivedLabel!.frame.width, height: catsLivedLabel!.frame.height * 1.30), backgroundColor: UIColor.clear);
        livedCatImageButton!.layer.borderWidth = 0.0;
        livedCatImageButton!.setImage(UIImage(named: UIStatistics.getCatFileName(named:"CheeringCat.png")), for: .normal);
        livedCatImageButton!.imageView!.contentMode = UIView.ContentMode.scaleAspectFill;
        UICenterKit.center(childView: livedCatImageButton!, parentRect: catsLivedLabel!.frame, childRect: livedCatImageButton!.frame);
    }
    
    func setupDeadCatLabel() {
        self.catsDiedLabel = UICLabel(parentView: contentView!, x: contentView!.frame.width * 0.5, y: gameOverLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight! * 2.0);
        catsDiedLabel!.backgroundColor = UIColor.clear;
        setupDeadCatImage();
        setupCatsDiedAmount();
    }
    
    func setupCatsDiedAmount() {
        self.catsDiedAmountLabel = UICLabel(parentView: contentView!, x: contentView!.frame.width * 0.5, y: catsDiedLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight!);
        catsDiedAmountLabel!.font = UIFont.boldSystemFont(ofSize: catsDiedAmountLabel!.frame.height * 0.40);
        catsDiedAmountLabel!.backgroundColor = UIColor.clear;
        catsDiedAmountLabel!.textColor = UIColor.black;
    }
    
    func setupDeadCatImage() {
        self.deadCatImageButton = UICButton(parentView: catsDiedLabel!, frame:CGRect( x: 0.0, y: 0.0, width: catsDiedLabel!.frame.width, height: catsDiedLabel!.frame.height * 1.30), backgroundColor: UIColor.clear);
        deadCatImageButton!.layer.borderWidth = 0.0;
        deadCatImageButton!.setImage(UIImage(named: UIStatistics.getCatFileName(named: "DeadCat.png")), for: .normal);
        deadCatImageButton!.imageView!.contentMode = UIView.ContentMode.scaleAspectFill;
        UICenterKit.center(childView: deadCatImageButton!, parentRect: catsDiedLabel!.frame, childRect: deadCatImageButton!.frame);
    }
    
    func setupStagesLabel() {
        self.stagesLabel = UICLabel(parentView: contentView!, x: self.frame.width * 0.02875, y: catsLivedAmountLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight!);
        stagesLabel!.text = "Max Stage";
        stagesLabel!.font = UIFont.boldSystemFont(ofSize: stagesLabel!.frame.height * 0.40);
        stagesLabel!.backgroundColor = UIColor.clear;
        setupStagesRangeLabel();
    }
    
    func setupStagesRangeLabel() {
        self.stagesRangeLabel = UICLabel(parentView: contentView!, x: self.frame.width * 0.02875, y:stagesLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight!);
        stagesRangeLabel!.font = UIFont.boldSystemFont(ofSize: stagesRangeLabel!.frame.height * 0.35);
        stagesRangeLabel!.backgroundColor = UIColor.clear;
    }
    
    func setupDurationLabel() {
        self.durationLabel = UICLabel(parentView: contentView!, x: contentView!.frame.width * 0.5, y: catsDiedAmountLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight!);
        durationLabel!.text = "Time";
        durationLabel!.font = UIFont.boldSystemFont(ofSize: durationLabel!.frame.height * 0.40);
        durationLabel!.backgroundColor = UIColor.clear;
        setupDurationTimeLabel();
    }
    
    func setupDurationTimeLabel() {
        self.durationTimeLabel = UICLabel(parentView: contentView!, x: contentView!.frame.width * 0.5, y: durationLabel!.frame.maxY, width: contentView!.frame.width * 0.5, height: unitHeight!);
        durationTimeLabel!.font = UIFont.boldSystemFont(ofSize: durationTimeLabel!.frame.height * 0.35);
        durationTimeLabel!.backgroundColor = UIColor.clear;
    }
    
    func setupContinueButton() {
        self.continueButton = UICButton(parentView: contentView!, frame: CGRect(x: 0.0, y: self.frame.height - (unitHeight! * 1.125), width: contentView!.frame.width * 0.35, height: unitHeight! * 0.8), backgroundColor: .clear);
        continueButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize:continueButton!.frame.height * 0.40);
        continueButton!.layer.cornerRadius = continueButton!.frame.width * 0.1;
        continueButton!.setTitle("Continue", for: .normal);
        continueButton!.setTitleColor(UIColor.black, for: .normal);
        UICenterKit.centerHorizontally(childView: continueButton!, parentRect: contentView!.frame, childRect: continueButton!.frame);
    }

    func setSessionDuration() {
        sessionDuration = sessionEndTime - sessionStartTime;
        sessionDuration = Double(floor(10 * sessionDuration) / 10)
    }
    
    func update() {
        catsLivedAmountLabel!.text = String(catsThatLived);
        catsDiedAmountLabel!.text = String(catsThatDied);
        stagesRangeLabel!.text = "\(maxStage - 1)";
        durationTimeLabel!.text = "\( Int(floor(sessionDuration))) secs";
    }
    
    func setCompiledStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            self.backgroundColor = UIColor.black;
            self.contentView!.backgroundColor = UIColor.white;
            self.gameOverLabel!.setStyle();
            self.livedCatImageButton!.setImage(UIImage(named: UIStatistics.getCatFileName(named:"CheeringCat.png")), for: .normal);
            self.deadCatImageButton!.setImage(UIImage(named: UIStatistics.getCatFileName(named: "DeadCat.png")), for: .normal);
            self.catsLivedAmountLabel!.textColor = UIColor.black;
            self.catsDiedAmountLabel!.textColor = UIColor.black;
            self.stagesLabel!.textColor = UIColor.black;
            self.stagesRangeLabel!.textColor = UIColor.black;
            self.durationLabel!.textColor = UIColor.black;
            self.durationTimeLabel!.textColor = UIColor.black;
            self.continueButton!.setTitleColor(UIColor.black, for: .normal);
            self.continueButton!.layer.borderColor = UIColor.black.cgColor;
        } else {
            self.backgroundColor = UIColor.white;
            self.contentView!.backgroundColor = UIColor.black;
            self.gameOverLabel!.setStyle();
            self.livedCatImageButton!.setImage(UIImage(named: UIStatistics.getCatFileName(named:"CheeringCat.png")), for: .normal);
            self.deadCatImageButton!.setImage(UIImage(named: UIStatistics.getCatFileName(named: "DeadCat.png")), for: .normal);
            self.catsLivedAmountLabel!.textColor = UIColor.white;
            self.catsDiedAmountLabel!.textColor = UIColor.white;
            self.stagesLabel!.textColor = UIColor.white;
            self.stagesRangeLabel!.textColor = UIColor.white;
            self.durationLabel!.textColor = UIColor.white;
            self.durationTimeLabel!.textColor = UIColor.white;
            self.continueButton!.setTitleColor(UIColor.white, for: .normal);
            self.continueButton!.layer.borderColor = UIColor.white.cgColor;
        }
    }
    
    
    
}
