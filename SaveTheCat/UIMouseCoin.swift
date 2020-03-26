//
//  FishCoin.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/13/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI
import CloudKit

class UIMouseCoin: UICButton {
    
    var boardGame:UIBoardGame?
    
    var reducedFrame:CGRect?
    var isSelectable:Bool = true;
    var mouseCoinView:UICView?
    var imageMouseCoinView:UIImageView?
    var amountLabel:UICLabel?
    var updateMouseCoinValueTimer:Timer?
    var valueReached:Bool = false;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(parentView: parentView, frame: CGRect(x: x, y: y, width: width, height: height), backgroundColor: .clear)
        self.layer.borderWidth = 0.0;
        self.layer.cornerRadius = height / 2.0;
        setIconImage(imageName: "mouseCoin.png");
        self.addTarget(self, action: #selector(mouseCoinSelector), for: .touchUpInside);
        setupMouseCoinView();
    }
    
    @objc func mouseCoinSelector() {
        if (isSelectable) {
            SoundController.coinEarned();
            if (ViewController.aspectRatio! != .ar19point5by9 && !ViewController.staticSelf!.settingsButton!.isPressed) {
                return;
            }
            self.amountLabel!.text = "\(UIResults.mouseCoins)";
            var viewShouldFadeOut:Bool = true;
            if (self.mouseCoinView!.alpha == 1.0) {
                viewShouldFadeOut = false;
            }
            self.mouseCoinView!.fadeIn();
            self.mouseCoinView!.layer.borderColor = UIColor.systemYellow.cgColor;
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in
                if (viewShouldFadeOut && ViewController.staticSelf!.settingsButton!.isPressed) {
                    self.mouseCoinView!.fadeOut();
                }
            })
        }
    }
    
    var iconImage:UIImage?
    func setIconImage(imageName:String) {
        iconImage = nil;
        iconImage = UIImage(named:imageName);
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func setMouseCoinValue(newValue:Int64) {
        var timeCounter:Double = 0.0;
        var timeRate:Double = 0.0;
        
        func isDifferencePositive() -> Bool {
            return UIResults.mouseCoins < newValue;
        }
        
        func getDifference() -> Int64 {
            if (isDifferencePositive()) {
                return newValue - UIResults.mouseCoins;
            } else {
                return UIResults.mouseCoins - newValue;
                
            }
        }
        
        func setupUpdateMouseCoinValueAnimation() {
            updateMouseCoinValueTimer?.invalidate();
            updateMouseCoinValueTimer = nil;
            updateMouseCoinValueTimer = Timer.scheduledTimer(withTimeInterval: timeRate, repeats: true, block: { _ in
                if (timeCounter > 1.0 && UIResults.mouseCoins == newValue) {
                    if (ViewController.settingsButton!.isPressed) {
                        self.mouseCoinView!.alpha = 0.99;
                        ViewController.settingsButton!.settingsMenu!.mouseCoin!.sendActions(for: .touchUpInside);
                    }
                    self.updateMouseCoinValueTimer!.invalidate();
                } else {
                    if (isDifferencePositive()) {
                        if (getDifference() > 10) {
                            UIResults.mouseCoins += 10;
                        } else {
                            UIResults.mouseCoins += 1;
                        }
                        
                    } else {
                        if (getDifference() > 10) {
                            UIResults.mouseCoins -= 10;
                        } else {
                            UIResults.mouseCoins -= 1;
                        }
                    }
                    self.amountLabel!.text = "\(UIResults.mouseCoins)";
                }
                timeCounter += timeRate;
            })
        }
        if (getDifference() > 10) {
            timeRate = 1.0 / Double(getDifference()) * 10.0;
        } else {
            timeRate = 1.0 / Double(getDifference());
        }
        timeCounter = timeRate;
        setupUpdateMouseCoinValueAnimation();
        print("MESSAGE: REAL VALUE \(newValue)");
    }
    
    func setupMouseCoinView() {
        if (ViewController.staticMainView!.isEqual(self.superview!)) {
            self.isSelectable = false;
            return;
        }
        self.mouseCoinView = UICView(parentView: self.superview!.superview!, x: 0.0, y: self.superview!.frame.minY, width: ViewController.staticUnitViewWidth * 6.5, height: self.superview!.frame.height, backgroundColor: UIColor.white);
        CenterController.centerHorizontally(childView: mouseCoinView!, parentRect: mouseCoinView!.superview!.frame, childRect: mouseCoinView!.frame);
        self.mouseCoinView!.originalFrame! = self.mouseCoinView!.frame;
        mouseCoinView!.layer.cornerRadius = self.superview!.layer.cornerRadius;
        mouseCoinView!.layer.borderWidth = self.superview!.layer.borderWidth;
        mouseCoinView!.layer.borderColor = UIColor.clear.cgColor;
        mouseCoinView!.backgroundColor = UIColor.clear;
        setupAmountLabel();
        if (ViewController.aspectRatio! == .ar19point5by9) {
            CenterController.center(childView: self.amountLabel!, parentRect: self.mouseCoinView!.frame, childRect: self.amountLabel!.frame);
        }
        mouseCoinView!.alpha = 0.0;
    }
    
    func setupAmountLabel() {
        self.amountLabel = UICLabel(parentView: mouseCoinView!, x: 0.0, y: 0.0, width: self.mouseCoinView!.frame.width, height: self.mouseCoinView!.frame.width * 0.25);
        self.amountLabel!.textColor = UIColor.systemYellow;
        self.amountLabel!.backgroundColor = UIColor.clear;
        self.amountLabel!.font = UIFont.boldSystemFont(ofSize: amountLabel!.frame.height * 0.5);
    }
}
