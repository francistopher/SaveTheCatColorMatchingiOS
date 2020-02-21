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
    
    var scrollView:UIScrollView?
    var unitHeight:CGFloat?
    var contentHeight:CGFloat?
    var contentY:CGFloat = 0.0;
    
    var gameOverLabel:UICLabel?
    var catsDiedLabel:UICLabel?
    var catsLivedLabel:UICLabel?
    var stageLabel:UICLabel?
    var timeLabel:UICLabel?
    
    // Survival and Death Count
    var entiretyOfCatsThatDied:Int = 0;
    var entiretyOfCatsThatSurvived:Int = 0;
    var catsThatDied:Int = 0;
    var catsThatLived:Int = 0;
    
    // Stage time
    var stageStartTime:Double = 0.0;
    var stageEndTime:Double = 0.0;
    var stageTimeLength:[Int:Double] = [:];
    var fastestStageTimeLength:[Int:Double] = [:];
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView) {
        let width:CGFloat = parentView.frame.width * 0.60;
        let height:CGFloat = parentView.frame.height * 0.60;
        super.init(parentView: parentView, x: 0.0, y: 0.0, width: width, height: height, backgroundColor: .black);
        parentView.addSubview(self);
        self.layer.cornerRadius = width / 5.0;
        self.layer.borderWidth = width / 50.0;
        self.unitHeight = height / 5.0 * 0.90;
        self.layer.borderColor = UIColor.black.cgColor;
        UICenterKit.center(childView: self, parentRect: superview!.frame, childRect: self.frame);
        setupScrollView();
        setupGameOverLabel();
        setupCatsLivedLabel();
        setupCatsDiedLabel();
        setupStageTimeLabels();
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
    
    func setupStageTimeLabels() {
        // Setup stage label
        stageLabel = UICLabel(parentView: scrollView!, x: 0.0, y: contentY, width: scrollView!.frame.width * 0.5, height: unitHeight! * 0.5);
        stageLabel!.isInverted = true;
        stageLabel!.setStyle();
        stageLabel!.text = "Stage";
        stageLabel!.font = UIFont.boldSystemFont(ofSize: stageLabel!.frame.height * 0.40);
        contentHeight! += stageLabel!.frame.height;
        // Setup time label
        timeLabel = UICLabel(parentView: scrollView!, x: stageLabel!.frame.width - 1, y: contentY, width: scrollView!.frame.width * 0.5, height: unitHeight! * 0.5);
        timeLabel!.isInverted = true;
        timeLabel!.setStyle();
        timeLabel!.text = "Time";
        timeLabel!.font = UIFont.boldSystemFont(ofSize: timeLabel!.frame.height * 0.40);
        contentY += timeLabel!.frame.height;
        contentY += self.layer.borderWidth;
    }
    
    func setupCatsDiedLabel() {
        catsDiedLabel = UICLabel(parentView: scrollView!, x: 0.0, y: contentY, width: scrollView!.frame.width, height: unitHeight!);
        catsDiedLabel!.textAlignment = NSTextAlignment.right;
        catsDiedLabel!.text = "x" + String(catsThatDied);
        catsDiedLabel!.font = UIFont.boldSystemFont(ofSize: catsDiedLabel!.frame.height * 0.40);
        contentHeight! += catsDiedLabel!.frame.height;
        contentY += catsDiedLabel!.frame.height;
        contentY += self.layer.borderWidth;
        setupDeadCatImage();
    }
    
    func setupDeadCatImage() {
        let deadCatImageButton:UICButton = UICButton(parentView: catsDiedLabel!, frame:CGRect( x: ViewController.staticUnitViewWidth * 0.75, y: 0.0, width: catsDiedLabel!.frame.height * 0.75, height: catsDiedLabel!.frame.height * 0.75), backgroundColor: UIColor.clear);
        deadCatImageButton.layer.borderWidth = 0.0;
        deadCatImageButton.setImage(UIImage(named: UIStatistics.getCatFileName(named: "DeadCat.png")), for: .normal);
        deadCatImageButton.imageView!.contentMode = UIView.ContentMode.scaleAspectFill;
        UICenterKit.centerVertically(childView: deadCatImageButton, parentRect: catsDiedLabel!.frame, childRect: deadCatImageButton.frame);
    }
    
    func setupCatsLivedLabel() {
        catsLivedLabel = UICLabel(parentView: scrollView!, x: 0.0, y: contentY, width: scrollView!.frame.width, height: unitHeight!);
        catsLivedLabel!.textAlignment = NSTextAlignment.right;
        catsLivedLabel!.text = "x" + String(catsThatLived);
        catsLivedLabel!.font = UIFont.boldSystemFont(ofSize: catsLivedLabel!.frame.height * 0.40);
        contentHeight! += catsLivedLabel!.frame.height;
        contentY += catsLivedLabel!.frame.height;
        contentY += self.layer.borderWidth;
        setupLivedCatImage();
    }
    
    func setupLivedCatImage() {
        let livedCatImageButton:UICButton = UICButton(parentView: catsLivedLabel!, frame:CGRect( x: ViewController.staticUnitViewWidth * 0.75, y: 0.0, width: catsLivedLabel!.frame.height * 0.75, height: catsLivedLabel!.frame.height * 0.75), backgroundColor: UIColor.clear);
        livedCatImageButton.layer.borderWidth = 0.0;
        livedCatImageButton.setImage(UIImage(named: UIStatistics.getCatFileName(named:"SmilingCat.png")), for: .normal);
        livedCatImageButton.imageView!.contentMode = UIView.ContentMode.scaleAspectFill;
        UICenterKit.centerVertically(childView: livedCatImageButton, parentRect: catsLivedLabel!.frame, childRect: livedCatImageButton.frame);
    }
    
    func setupGameOverLabel() {
        gameOverLabel = UICLabel(parentView: scrollView!, x: 0.0, y: contentY, width: scrollView!.frame.width, height: unitHeight!);
        gameOverLabel!.layer.cornerRadius = scrollView!.layer.cornerRadius;
        gameOverLabel!.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner];
        gameOverLabel!.text = "Game Over";
        gameOverLabel!.font = UIFont.boldSystemFont(ofSize: gameOverLabel!.frame.height * 0.40);
        gameOverLabel!.isInverted = true;
        gameOverLabel!.setStyle();
        contentHeight = gameOverLabel!.frame.height;
        contentY = gameOverLabel!.frame.maxY;
    }
    
    func setupScrollView() {
        scrollView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height));
        scrollView!.backgroundColor = UIColor.black;
        scrollView!.autoresizingMask = .flexibleHeight;
        scrollView!.showsHorizontalScrollIndicator = false;
        scrollView!.layer.cornerRadius = self.layer.cornerRadius;
        scrollView!.bounces = true;
        scrollView!.contentSize = CGSize(width: scrollView!.frame.width, height: scrollView!.frame.height * 1.5);
        self.addSubview(scrollView!);
    }
    
    func getCurrentStageTimeLength() -> Double {
        return (stageEndTime - stageStartTime);
    }
    
    func loadStageTimeLengths(stage:Int) {
        stageTimeLength[stage] = getCurrentStageTimeLength();
    }
    
    func printSessionStatistics() {
        print("Cats that lived: \(catsThatLived)");
        print("Cats that died: \(catsThatDied)");
        let startTimeLengthTouple:[(key:Int, value:Double)] = stageTimeLength.sorted{$0.value < $1.value};
        for (key, value) in startTimeLengthTouple {
            print("Stage: \(key) TimeLength: \(value)");
        }
    }
    
    func update() {
        catsLivedLabel!.text = "x" + String(catsThatLived);
        catsDiedLabel!.text = "x" + String(catsThatDied);
    }
    
    func style() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            self.layer.borderColor = UIColor.black.cgColor;
            self.backgroundColor = UIColor.white;
            self.scrollView!.backgroundColor = UIColor.black;
        } else {
            self.layer.borderColor = UIColor.white.cgColor;
            self.backgroundColor = UIColor.black;
            self.scrollView!.backgroundColor = UIColor.white;
        }
    }
    
    
    
}
