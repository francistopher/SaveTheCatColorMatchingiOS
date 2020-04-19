//
//  UICat.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/11/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI
import AVFoundation
import GameKit

enum Cat {
    case standard
    case breading
    case taco
    case egyptian
    case supeR
    case chicken
    case cool
    case ninja
    case fat
}

class UICatButton: UIButton {
    
    var selectedCat:Cat = ViewController.getRandomCat();
    var originalFrame:CGRect?;
    var previousFileName:String = "";
    var animationStage:Int = 0;
    
    var backgroundCGColor:CGColor?
    var originalBackgroundColor:UIColor = .clear;
    var imageContainerButton:UICButton?
    var isAlive:Bool = true;
    var isPodded:Bool = false;
    var isFadedOut = false;
    var rowIndex:Int = 0;
    var columnIndex:Int = 0;
    var clearedOutToSolve:Bool = false;
    
     var keyValueStore:NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore();
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    init(parentView: UIView, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat, backgroundColor:UIColor) {
        super.init(frame:CGRect(x: x, y: y, width: width, height: height));
        self.originalFrame = CGRect(x: x, y: y, width: width, height: height);
        self.originalBackgroundColor = backgroundColor;
        self.backgroundCGColor = backgroundColor.cgColor;
        self.backgroundColor = backgroundColor;
        self.layer.cornerRadius = height / 5.0;
        self.layer.borderWidth = (sqrt(self.frame.width * 0.01) * 10.0) * 0.35;
        parentView.addSubview(self);
        configureImageContainerButton();
        shrunk();
        self.setStyle();
    }
    
    static func getCatFileName(named:String, selectedCat:Cat) -> String {
        // Build cat directory string
        var namedCatImage:String = "";
        // Select current style
        if (ViewController.uiStyleRawValue == 1){
            namedCatImage += "light";
        } else{
            namedCatImage += "dark";
        }
        // Selecting the cat image
        switch (selectedCat) {
        case .standard:
            return namedCatImage + named;
        case .breading:
            return namedCatImage + "Breading" + named;
        case .taco:
            return namedCatImage + "Taco" + named;
        case .egyptian:
            return namedCatImage + "Egyptian" + named;
        case .supeR:
            return namedCatImage + "Super" + named;
        case .chicken:
            return namedCatImage + "Chicken" + named;
        case .cool:
            return namedCatImage + "Cool" + named;
        case .ninja:
            return namedCatImage + "Ninja" + named;
        case .fat:
            return namedCatImage + "Fat" + named;
        }
    }
    

    var mouseCoin:UIMouseCoin?
    var settingsButton:UISettingsButton?
    var settingsMenuFrame:CGRect?
    var settingsMouseCoinFrame:CGRect?
    var mainView:UIView?
    var newMouseCoinFrame:CGRect?
    var mouseCoinX:CGFloat?
    var mouseCoinY:CGFloat?
    func giveMouseCoin(withNoise:Bool) {
        // Generate mouse coin
        settingsMouseCoinFrame = ViewController.settingsButton!.settingsMenu!.mouseCoin!.frame;
        mouseCoin = UIMouseCoin(parentView: self.imageContainerButton!, x: 0.0, y: 0.0, width: self.imageContainerButton!.frame.width / 4.0, height: self.imageContainerButton!.frame.height / 4.0);
        mouseCoin!.isSelectable = false;
        CenterController.center(childView: mouseCoin!, parentRect: imageContainerButton!.frame, childRect: mouseCoin!.frame);
        self.imageContainerButton!.addSubview(mouseCoin!);
        // Create new frame for mouse coin on main view
        mainView = self.superview!.superview!;
        mouseCoinX = mouseCoin!.frame.minX + self.frame.minX + self.superview!.frame.minX;
        mouseCoinY = mouseCoin!.frame.minY + self.frame.minY + self.superview!.frame.minY;
        // Reposition mouse coin
        mainView!.addSubview(mouseCoin!);
        mouseCoin!.frame = CGRect(x: mouseCoinX!, y: mouseCoinY!, width: mouseCoin!.frame.width, height: mouseCoin!.frame.height);
        self.mainView!.bringSubviewToFront(self.mouseCoin!);
        UIView.animate(withDuration: 1.0, delay: 0.125, options: [.curveEaseInOut], animations: {
            if (ViewController.staticSelf!.isInternetReachable && GKLocalPlayer.local.isAuthenticated) {
                self.newMouseCoinFrame = CGRect(x: self.settingsMenuFrame!.minX + self.settingsMouseCoinFrame!.minX, y: self.settingsMenuFrame!.minY + self.settingsMouseCoinFrame!.minY, width: self.settingsMouseCoinFrame!.width, height: self.settingsMouseCoinFrame!.height);
            } else {
                self.newMouseCoinFrame = CGRect(x: CGFloat.random(in: 0.0...ViewController.staticSelf!.mainView.frame.width), y: -self.settingsMouseCoinFrame!.height, width: self.settingsMouseCoinFrame!.width, height: self.settingsMouseCoinFrame!.height);
            }
            self.mouseCoin!.frame = self.newMouseCoinFrame!;
        }, completion: { _ in
            if (ViewController.staticSelf!.isInternetReachable && GKLocalPlayer.local.isAuthenticated) {
                SoundController.coinEarned();
                ViewController.staticSelf!.settingsButton!.settingsMenu!.mouseCoin!.setMouseCoinValue(newValue: UIResults.mouseCoins + 1);
            }
            self.mouseCoin!.removeFromSuperview();
        })
    }
    
    func configureImageContainerButton() {
        imageContainerButton = UICButton(parentView:self, frame: CGRect(x: ((self.originalFrame!.width - self.originalFrame!.height) / 2.0), y: 0.0, width: self.originalFrame!.height, height: self.originalFrame!.height), backgroundColor:self.originalBackgroundColor);
        imageContainerButton!.originalFrame = imageContainerButton!.frame;
        imageContainerButton!.layer.cornerRadius = self.layer.cornerRadius;
        imageContainerButton!.layer.borderWidth = 0.0;
        imageContainerButton!.shrinked();
    }
    
    func transformTo(frame:CGRect) {
        UIView.animate(withDuration: 0.5, delay: 0.125, options: .curveEaseIn, animations: {
            self.frame = frame;
            if (self.frame.height > self.frame.width) {
                 self.imageContainerButton!.frame = CGRect(x: self.imageContainerButton!.frame.minX, y: self.imageContainerButton!.frame.minY, width: frame.width, height: frame.width);
            } else {
                self.imageContainerButton!.frame = CGRect(x: self.imageContainerButton!.frame.minX, y: self.imageContainerButton!.frame.minY, width: frame.height, height: frame.height);
            }
           
            CenterController.center(childView: self.imageContainerButton!, parentRect: frame, childRect: self.imageContainerButton!.frame);
            if (!self.isPodded) {
                if (self.frame.height > self.frame.width) {
                    self.layer.cornerRadius = frame.width * 0.2;
                } else {
                    self.layer.cornerRadius = frame.height * 0.2;
                }
                self.imageContainerButton!.layer.cornerRadius = self.layer.cornerRadius;
            } else {
                if (self.frame.height > self.frame.width) {
                    self.layer.cornerRadius = frame.width * 0.5;
                } else {
                    self.layer.cornerRadius = frame.height * 0.5;
                }
                self.imageContainerButton!.layer.cornerRadius = self.layer.cornerRadius;
            }
        })
    }
    
    func shrink(){
        UIView.animate(withDuration: 0.5, delay: 0.125, options: .curveEaseIn, animations: {
            self.frame = CGRect(x: self.frame.midX, y: self.frame.midY, width: 1.0, height: 1.0);
            self.imageContainerButton!.frame = CGRect(x: 0.0, y:0.0, width: 1.0, height: 1.0);
        })
    }
    
    func shrunk() {
        self.frame = CGRect(x: self.frame.midX, y: self.frame.midY, width: 1.0, height: 1.0);
        self.imageContainerButton!.frame = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
    }
    
    func grow(){
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseInOut, animations: {
            self.frame = self.originalFrame!;
        });
    }
    
    func grown() {
        self.frame = self.originalFrame!;
        self.imageContainerButton!.frame = self.imageContainerButton!.originalFrame!;
    }
    
    var iconImage:UIImage?
    func setCat(named:String, stage:Int){
        // Save non empty strings only
        if (named != "" && named != "updateStyle") {
            previousFileName = UICatButton.getCatFileName(named:named, selectedCat: selectedCat) + ".png";
        }
        if (named == "updateStyle") {
            if (ViewController.uiStyleRawValue == 1) {
                if (previousFileName.contains("light")) {
                    previousFileName = "light" + String(previousFileName.suffix(previousFileName.count - 5));
                } else {
                    previousFileName = "light" + String(previousFileName.suffix(previousFileName.count - 4));
                }
                self.layer.borderColor = UIColor.black.cgColor;
            } else {
                if (previousFileName.contains("dark")) {
                    previousFileName = "dark" + String(previousFileName.suffix(previousFileName.count - 4));
                } else {
                    previousFileName = "dark" + String(previousFileName.suffix(previousFileName.count - 5));
                }
                self.layer.borderColor = UIColor.white.cgColor;
            }
        }
        // Configure the image icon
        iconImage = nil;
        iconImage = UIImage(named: previousFileName);
        self.imageContainerButton!.setImage(iconImage!, for: .normal);
        self.imageContainerButton!.imageView!.contentMode = UIView.ContentMode.scaleAspectFill;
        if (named == "updateStyle") {
            return;
        }
        // Set the animation stage
        if (stage != 4 || stage != 5) {
            animationStage = stage;
        }
        // Prepare image view for reveal
        if (animationStage == 0 || animationStage == 4){
            self.imageView!.alpha = 0.0;
            self.imageContainerButton!.imageView!.alpha = 0.0;
        }
        // Configure the dispatch time and animation
        var dispatchTime:DispatchTime? = nil;
        if (stage == 4){
            self.imageContainerButton!.imageView!.layer.removeAllAnimations();
            dispatchTime = .now();
            self.animationStage = 0;
        } else if (stage == 1 || stage == 0){
            dispatchTime = .now() + 1.0;
        } else {
            dispatchTime = .now();
        }
        // Animate based on animation stage
        DispatchQueue.main.asyncAfter(deadline: dispatchTime!) {
            if (self.animationStage == 4 || stage == 4) {
                self.imageContainerButton!.imageView!.alpha = 1.0;
            } else {
                UIView.animate(withDuration: 1.0, delay:0.0, options:[.curveEaseIn], animations: {
                   self.imageContainerButton!.imageView!.alpha = 1.0;
                });
            }
            if (self.animationStage == 0){
                self.randomAnimationSelection = Int.random(in: 0...3);
                self.setRandomCatAnimation();
            }
        }
    }
    
    func fadeBackgroundIn(){
        UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseIn, animations: {
            self.backgroundColor = self.originalBackgroundColor;
        }, completion: { _ in
            self.isFadedOut = false;
        });
    }
    
    var randomAnimationSelection:Int?
    func setRandomCatAnimation() {
        self.imageContainerButton!.imageView!.transform = self.imageContainerButton!.imageView!.transform.rotated(by:-CGFloat.pi / 2.0);
        UIView.animate(withDuration: 1.75, delay: 0.0, options:[.curveEaseInOut, .repeat, .autoreverse], animations: {
            self.imageContainerButton!.imageView!.transform = self.imageContainerButton!.imageView!.transform.rotated(by:CGFloat.pi);
        });
    }
    
    func displaceBoundsOntoMainView() {
        // Displace the frame onto the main view controller
        self.frame = CGRect(x: self.frame.minX + self.superview!.frame.minX, y: self.frame.minY + self.superview!.frame.minY, width: self.frame.width, height: self.frame.height);
        self.superview!.superview!.addSubview(self);
    }
    
    func isDead() {
        self.isAlive = false;
        self.imageContainerButton!.layer.borderWidth = 0.0;
        self.layer.borderWidth = 0.0;
        self.setCat(named: "DeadCat", stage: 2);
        self.imageContainerButton!.imageView!.layer.removeAllAnimations();
        self.imageContainerButton!.backgroundColor = self.imageContainerButton!.originalBackgroundColor;
        displaceBoundsOntoMainView();
    }
    
    func disperseRadially() {
        ViewController.staticMainView!.insertSubview(self, at: 1);
        UIView.animate(withDuration: 3.0, delay: 0.0, options: .curveEaseInOut, animations: {
            self.imageContainerButton!.transform =  self.imageContainerButton!.transform.rotated(by: CGFloat.pi);
             self.frame = CGRect(x: self.getRadialXTargetPoint(parentFrame: self.superview!.frame, childFrame: self.frame), y: self.getRadialYTargetPoint(parentFrame: self.superview!.frame, childFrame: self.frame), width: 1.0, height: 1.0);
        }, completion: { _ in
            self.imageContainerButton = nil;
            self.removeFromSuperview();
        });
    }

    var angle:CGFloat?
    func disperseVertically() {
        displaceBoundsOntoMainView();
        self.setCat(named: "CheeringCat", stage: 1);
        angle = CGFloat(Int.random(in: 0..<30));
        UIView.animate(withDuration: 2.5, delay: 0.125, options: .curveEaseIn, animations: {
            self.frame = CGRect(x: self.generateElevatedTargetX(parentFrame:self.superview!.frame, childFrame:self.frame, angle:self.angle!), y: self.generateElevatedTargetY(parentFrame:self.superview!.frame, childFrame:self.frame, angle:self.angle!), width: self.frame.width, height: self.frame.height);
        }, completion: { _ in
            self.imageContainerButton = nil;
            self.removeFromSuperview();
        });
    }
    
    func pod() {
        SoundController.kittenMeow();
        UIView.animate(withDuration: 0.5, delay: 0.125, options: [.curveEaseInOut], animations: {
            // Adjust frames if necessary
            if (self.frame.width > self.frame.height) {
                self.frame = CGRect(x: self.frame.minX + self.imageContainerButton!.frame.minX, y: self.frame.minY, width: self.imageContainerButton!.frame.width, height: self.frame.height);
                self.imageContainerButton!.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.height, height: self.frame.height);
            }
            self.backgroundColor = self.originalBackgroundColor;
            if (!(self.frame.width < self.frame.height)) {
                self.layer.cornerRadius = self.frame.height * 0.5;
            }
            self.imageContainerButton!.layer.borderWidth = 0.0;
            self.layer.borderWidth = (sqrt(self.frame.width * 0.01) * 10.0) * 0.35;
        })
    }
    
    func generateElevatedTargetX(parentFrame:CGRect, childFrame:CGRect, angle:CGFloat) -> CGFloat{
        var targetX:CGFloat = parentFrame.width * 0.5;
        if (angle < 15.0) {
            targetX -= childFrame.width;
        } else {
            targetX += childFrame.width;
        }
        targetX *= cos((CGFloat.pi * angle) / 180.0);
        return targetX;
    }
    
    func generateElevatedTargetY(parentFrame:CGRect, childFrame:CGRect, angle:CGFloat) -> CGFloat{
        var targetY:CGFloat = -parentFrame.height;
        targetY += CGFloat(Int.random(in: 0..<Int(parentFrame.height / 2.0)));
        return targetY;
    }
    
    var angleDegree:CGFloat?
    var angleRadian:CGFloat?
    var targetX:CGFloat?
    var targetY:CGFloat?
    
    func  getRadialXTargetPoint(parentFrame:CGRect, childFrame:CGRect) -> CGFloat {
        angleDegree = CGFloat.random(in: 0.0...45.0);
        angleRadian = cos((CGFloat.pi * angleDegree!) / 180.0);
        targetX = ((Int.random(in: 0...1) == 1) ? 1 : -1);
        if (targetX! > 0.0) {
            targetX! *= (parentFrame.width - childFrame.minX) * 1.42;
        } else {
            targetX! *= (childFrame.maxX) * 1.42;
        }
        targetX! *= angleRadian!;
        return targetX!;
    }
    
    func getRadialYTargetPoint(parentFrame:CGRect, childFrame:CGRect) -> CGFloat {
        angleDegree = CGFloat.random(in: 45.0...90.0);
        angleRadian = sin((CGFloat.pi * angleDegree!) / 180.0);
         targetY = ((Int.random(in: 0...1) == 1) ? 1 : -1);
        if (targetY! > 0.0) {
            targetY! *= (parentFrame.height - childFrame.minY) * 1.42;
        } else {
            targetY! *= (childFrame.maxY + childFrame.height) * 1.42;
        }
        targetY! *= angleRadian!;
        return targetY!;
    }
    
    func animate(AgainWithoutDelay:Bool) {
        if (AgainWithoutDelay) {
            self.setCat(named: "", stage: 4);
        } else {
            self.setCat(named: "", stage: 5);
        }
    }
    
    func updateUIStyle() {
        self.setCat(named:"updateStyle", stage: 5);
    }
    
    func hideCat(){
        self.imageContainerButton!.imageView!.alpha = 0.0;
    }
    
    func fadeIn() {
        UIView.animate(withDuration: 0.25, delay: 0.125, options: .curveEaseIn, animations: {
            self.alpha = 1.0;
        });
    }
    
    func setStyle() {
        if (ViewController.uiStyleRawValue == 1){
            self.layer.borderColor = UIColor.black.cgColor;
            self.imageContainerButton!.layer.borderColor = UIColor.black.cgColor;
        } else {
            self.layer.borderColor = UIColor.white.cgColor;
            self.imageContainerButton!.layer.borderColor = UIColor.white.cgColor;
        }
    }
    
    func fadeBackgroundOut() {
        UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseIn, animations: {
            self.backgroundColor = UIColor.clear;
        }, completion: { _ in
            self.isFadedOut = true;
        });
    }
    
    func fadeBackgroundIn(color:UIColor, duration:Double, delay:Double){
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.backgroundColor = color;
        }, completion: { _ in
            if (color.cgColor != UIColor.clear.cgColor) {
                self.isFadedOut = false;
            }
        });
    }
}
