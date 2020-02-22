//
//  UIStatistics.swift
//  CatVirus
//
//  Created by Christopher Francisco on 2/20/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIStatistics:UICView {
    
    static var selectedCat:Cat = .standard;
    
    var unitHeight:CGFloat?
    
    var gameOverLabel:UICLabel?
    var catsLivedLabel:UICLabel?
    var catsDiedLabel:UICLabel?
    var stagesLabel:UICLabel?
    var stagesRangeLabel:UICLabel?
    var durationLabel:UICLabel?
    var durationTimeLabel:UICLabel?
    var continueButton:UICButton?
    
    // Survival and Death Count
    var entiretyOfCatsThatDied:Int = 0;
    var entiretyOfCatsThatSurvived:Int = 0;
    var catsThatDied:Int = 0;
    var catsThatLived:Int = 0;
    
    // Gameplay session time
    var sessionStartTime:Double = 0.0;
    var sessionEndTime:Double = 0.0;
    var sessionDuration:Double = 0.0;
    var finalStage:String = "";
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView) {
        let width:CGFloat = parentView.frame.width * 0.75;
        super.init(parentView: parentView, x: 0.0, y: 0.0, width: width * 0.75, height: width, backgroundColor: .black);
        parentView.addSubview(self);
        self.layer.cornerRadius = width / 7.0;
        self.layer.borderWidth = width / 50.0;
        self.unitHeight = width / 6.0;
        self.setStyle();
        setupGameOverLabel();
        setupCatsLivedLabel();
        setupCatsDiedLabel();
        setupStagesLabel();
        setupDurationLabel();
        setupContinueButton();
        UICenterKit.center(childView: self, parentRect: superview!.frame, childRect: self.frame);
        self.alpha = 0.0;
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
        case Cat.fat:
            return namedCatImage + "fat" + named;
        case Cat.standard:
            return namedCatImage + named;
        }
    }
    
    func setupGameOverLabel() {
        gameOverLabel = UICLabel(parentView: self, x: 0.0, y: 0.0, width: self.frame.width, height: unitHeight!);
        gameOverLabel!.font = UIFont.boldSystemFont(ofSize: gameOverLabel!.frame.height * 0.40);
        gameOverLabel!.isInverted = true;
        gameOverLabel!.setStyle();
        gameOverLabel!.layer.cornerRadius = self.layer.cornerRadius;
        gameOverLabel!.clipsToBounds = true;
        gameOverLabel!.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner];
        gameOverLabel!.text = "Game Over";
    }
    
    func setupCatsLivedLabel() {
        catsLivedLabel = UICLabel(parentView: self, x: 0.0, y: gameOverLabel!.frame.maxY, width: self.frame.width, height: unitHeight!);
        catsLivedLabel!.textAlignment = NSTextAlignment.right;
        catsLivedLabel!.text = "x" + String(catsThatLived);
        catsLivedLabel!.font = UIFont.boldSystemFont(ofSize: catsLivedLabel!.frame.height * 0.40);
        catsLivedLabel!.backgroundColor = UIColor.white;
        setupLivedCatImage();
    }
    
    func setupLivedCatImage() {
        let livedCatImageButton:UICButton = UICButton(parentView: catsLivedLabel!, frame:CGRect( x: ViewController.staticUnitViewWidth * 0.75, y: 0.0, width: catsLivedLabel!.frame.height * 0.8, height: catsLivedLabel!.frame.height * 0.75), backgroundColor: UIColor.clear);
        livedCatImageButton.layer.borderWidth = 0.0;
        livedCatImageButton.setImage(UIImage(named: UIStatistics.getCatFileName(named:"WavingCat.png")), for: .normal);
        livedCatImageButton.imageView!.contentMode = UIView.ContentMode.scaleAspectFill;
        UICenterKit.centerVertically(childView: livedCatImageButton, parentRect: catsLivedLabel!.frame, childRect: livedCatImageButton.frame);
    }
    
    func setupCatsDiedLabel() {
        catsDiedLabel = UICLabel(parentView: self, x: 0.0, y: catsLivedLabel!.frame.maxY, width: self.frame.width, height: unitHeight!);
        catsDiedLabel!.textAlignment = NSTextAlignment.right;
        catsDiedLabel!.text = "x" + String(catsThatDied);
        catsDiedLabel!.font = UIFont.boldSystemFont(ofSize: catsDiedLabel!.frame.height * 0.40);
        catsDiedLabel!.backgroundColor = UIColor.clear;
        setupDeadCatImage();
    }
    
    func setupDeadCatImage() {
        let deadCatImageButton:UICButton = UICButton(parentView: catsDiedLabel!, frame:CGRect( x: ViewController.staticUnitViewWidth * 0.75, y: 0.0, width: catsDiedLabel!.frame.height * 0.8, height: catsDiedLabel!.frame.height * 0.75), backgroundColor: UIColor.clear);
        deadCatImageButton.layer.borderWidth = 0.0;
        deadCatImageButton.setImage(UIImage(named: UIStatistics.getCatFileName(named: "DeadCat.png")), for: .normal);
        deadCatImageButton.imageView!.contentMode = UIView.ContentMode.scaleAspectFill;
        UICenterKit.centerVertically(childView: deadCatImageButton, parentRect: catsDiedLabel!.frame, childRect: deadCatImageButton.frame);
    }
    
    func setupStagesLabel() {
        stagesLabel = UICLabel(parentView: self, x: 0.0, y: catsDiedLabel!.frame.maxY, width: self.frame.width * 0.5, height: unitHeight!);
        stagesLabel!.text = "Stages";
        stagesLabel!.font = UIFont.boldSystemFont(ofSize: stagesLabel!.frame.height * 0.35);
        stagesLabel!.backgroundColor = UIColor.clear;
        setupStagesRangeLabel();
    }
    
    func setupStagesRangeLabel() {
        stagesRangeLabel = UICLabel(parentView: self, x: stagesLabel!.frame.width, y:catsDiedLabel!.frame.maxY, width: self.frame.width * 0.5, height: unitHeight!);
        stagesRangeLabel!.font = UIFont.boldSystemFont(ofSize: stagesRangeLabel!.frame.height * 0.30);
        stagesRangeLabel!.backgroundColor = UIColor.clear;
    }
    
    func setupDurationLabel() {
        durationLabel = UICLabel(parentView: self, x: 0.0, y: stagesLabel!.frame.maxY, width: self.frame.width * 0.5, height: unitHeight!);
        durationLabel!.text = "Time";
        durationLabel!.font = UIFont.boldSystemFont(ofSize: durationLabel!.frame.height * 0.35);
        durationLabel!.backgroundColor = UIColor.clear;
        setupDurationTimeLabel();
    }
    
    func setupDurationTimeLabel() {
        durationTimeLabel = UICLabel(parentView: self, x: durationLabel!.frame.width, y: stagesLabel!.frame.maxY, width: self.frame.width * 0.5, height: unitHeight!);
        durationTimeLabel!.font = UIFont.boldSystemFont(ofSize: durationTimeLabel!.frame.height * 0.30);
        durationTimeLabel!.backgroundColor = UIColor.clear;
    }
    
    func setupContinueButton() {
        continueButton = UICButton(parentView: self, frame: CGRect(x: 0.0, y: self.frame.height - (unitHeight!), width: self.frame.width, height: unitHeight!), backgroundColor: .clear);
        continueButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize:continueButton!.frame.height * 0.40);
        continueButton!.layer.cornerRadius = self.layer.cornerRadius;
        continueButton!.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner];
        continueButton!.setTitleColor(UIColor.white, for: .normal);
        continueButton!.backgroundColor = UIColor.black;
        continueButton!.setTitle("Continue", for: .normal);
        continueButton!.clipsToBounds = true;
    }

    func setSessionDuration() {
        sessionDuration = sessionEndTime - sessionStartTime;
        sessionDuration = Double(floor(1000 * sessionDuration) / 1000)
    }
    
    func update() {
        catsLivedLabel!.text = "x" + String(catsThatLived);
        catsDiedLabel!.text = "x" + String(catsThatDied);
        stagesRangeLabel!.text = "1 - " + finalStage;
        durationTimeLabel!.text = "\(sessionDuration)";
    }
    
    override func setStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            self.layer.borderColor = UIColor.black.cgColor;
            self.backgroundColor = UIColor.white;
        } else {
            self.layer.borderColor = UIColor.white.cgColor;
            self.backgroundColor = UIColor.black;
        }
    }
    
    
    
}
