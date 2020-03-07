//
//  UICat.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/11/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI
import AVFoundation

enum Cat {
    case fancy
    case standard
    case ninja
}

class UICatButton: UIButton {
    
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
    
    func giveMouseCoin(withNoise:Bool) {
        UIStatistics.mouseCoins += 1;
        // Generate mouse coin
        let mouseCoin:UIMouseCoin = UIMouseCoin(parentView: self.imageContainerButton!, x: 0.0, y: 0.0, width: self.imageContainerButton!.frame.width / 4.0, height: self.imageContainerButton!.frame.height / 4.0);
        mouseCoin.removeTarget(self, action: #selector(mouseCoin.mouseCoinSelector), for: .touchUpInside);
        CenterController.center(childView: mouseCoin, parentRect: imageContainerButton!.frame, childRect: mouseCoin.frame);
        self.imageContainerButton!.addSubview(mouseCoin);
        // Create new frame for mouse coin on main view
        let mainView:UIView = self.superview!.superview!;
        var mouseCoinX = mouseCoin.frame.minX;
        var mouseCoinY = mouseCoin.frame.minY;
        mouseCoinX += self.frame.minX;
        mouseCoinY += self.frame.minY;
        mouseCoinX += self.superview!.frame.minX;
        mouseCoinY += self.superview!.frame.minY;
        // Reposition mouse coin
        mainView.addSubview(mouseCoin);
        mouseCoin.frame = CGRect(x: mouseCoinX, y: mouseCoinY, width: mouseCoin.frame.width, height: mouseCoin.frame.height);
        // Calculate time for translation
        let boardGameFrame:CGRect = self.superview!.frame;
        let time:Double = Double(mouseCoin.frame.minX / (boardGameFrame.minX + boardGameFrame.width));
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            mainView.bringSubviewToFront(mouseCoin);
            UIView.animate(withDuration: 1.0, delay: 0.125, options: [.curveEaseInOut], animations: {
                let settingsButton:UISettingsButton = ViewController.settingsButton!;
                let settingsMenuFrame:CGRect = settingsButton.settingsMenu!.frame;
                let settingsMouseCoinFrame:CGRect = settingsButton.mouseCoin!.frame;
                let newMouseCoinFrame:CGRect = CGRect(x: settingsMenuFrame.minX + settingsMouseCoinFrame.minX, y: settingsMenuFrame.minY + settingsMouseCoinFrame.minY, width: settingsMouseCoinFrame.width, height: settingsMouseCoinFrame.height);
                mouseCoin.frame = newMouseCoinFrame;
            }, completion: { _ in
                SoundController.coinEarned();
                mouseCoin.removeFromSuperview();
            })
        }
        
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
    
    func setCat(named:String, stage:Int){
        // Save non empty strings only
        if (named != "" && named != "updateStyle") {
            previousFileName = UIStatistics.getCatFileName(named:named) + ".png";
        }
        if (named == "updateStyle") {
            if (previousFileName.contains("light")) {
                previousFileName = "dark" + String(previousFileName.suffix(previousFileName.count - 5));
                self.layer.borderColor = UIColor.white.cgColor;
            } else {
                previousFileName = "light" + String(previousFileName.suffix(previousFileName.count - 4));
                self.layer.borderColor = UIColor.black.cgColor;
            }
        }
        // Clear background if cat dies
        if (stage == 2) {
            self.backgroundColor = UIColor.clear;
        }
        // Configure the image icon
        let iconImage:UIImage? = UIImage(named: previousFileName);
        self.imageContainerButton!.setImage(iconImage, for: .normal);
        self.imageContainerButton!.imageView!.contentMode = UIView.ContentMode.scaleAspectFill;
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
    
    func setRandomCatAnimation() {
        let randomAnimationSelection:Int = Int.random(in: 0...3);
        if (randomAnimationSelection > 2){
            self.imageContainerButton!.imageView!.transform = self.imageContainerButton!.imageView!.transform.rotated(by:-CGFloat.pi / 2.0);
            UIView.animate(withDuration: 1.75, delay: 0.0, options:[.curveEaseInOut, .repeat, .autoreverse], animations: {
                self.imageContainerButton!.imageView!.transform = self.imageContainerButton!.imageView!.transform.rotated(by:-CGFloat.pi);
            });
        } else if (randomAnimationSelection > 1) {
            self.imageContainerButton!.imageView!.transform = self.imageContainerButton!.imageView!.transform.rotated(by:CGFloat.pi / 2.0);
            UIView.animate(withDuration: 1.75, delay: 0.0, options:[.curveEaseInOut, .repeat, .autoreverse], animations: {
                self.imageContainerButton!.imageView!.transform = self.imageContainerButton!.imageView!.transform.rotated(by:-CGFloat.pi);
            });
        } else if (randomAnimationSelection > 0) {
            UIView.animate(withDuration: 1.75, delay: 0.0, options:[.curveEaseInOut, .repeat, .autoreverse], animations: {
                self.imageContainerButton!.imageView!.transform = self.imageContainerButton!.imageView!.transform.rotated(by:-CGFloat.pi);
            });
        } else {
            self.imageContainerButton!.imageView!.transform = self.imageContainerButton!.imageView!.transform.rotated(by:-CGFloat.pi / 2.0);
            UIView.animate(withDuration: 1.75, delay: 0.0, options:[.curveEaseInOut, .repeat, .autoreverse], animations: {
                self.imageContainerButton!.imageView!.transform = self.imageContainerButton!.imageView!.transform.rotated(by:CGFloat.pi);
            });
        }
    }
    
    func displaceBoundsOntoMainView() {
        // Save the new displaced bounds of the grid button
        let x:CGFloat = self.frame.minX + self.superview!.frame.minX;
        let y:CGFloat = self.frame.minY + self.superview!.frame.minY;
        let width:CGFloat = self.frame.width;
        let height:CGFloat = self.frame.height;
        // Save a frame representing the displacement
        let displacedFrame:CGRect = CGRect(x: x, y: y, width: width, height: height);
        // Displace the frame onto the main view controller
        self.frame = displacedFrame;
        self.superview!.superview!.addSubview(self);
    }
    
    func isDead() {
        self.isAlive = false;
        self.imageContainerButton!.layer.borderWidth = 0.0;
        self.layer.borderWidth = 0.0;
        self.setCat(named: "DeadCat", stage: 2);
        self.imageContainerButton!.imageView!.layer.removeAllAnimations();
        self.imageContainerButton!.backgroundColor = self.imageContainerButton!.originalBackgroundColor;
        self.backgroundColor = UIColor.clear;
        displaceBoundsOntoMainView();
    }
    
    func disperseRadially() {
        self.backgroundColor = UIColor.clear;
        let targetPointX:CGFloat = getRadialXTargetPoint(parentFrame: self.superview!.frame, childFrame: self.frame);
        let targetPointY:CGFloat = getRadialYTargetPoint(parentFrame: self.superview!.frame, childFrame: self.frame);
        UIView.animate(withDuration: 2.0, delay: 0.125, options: .curveEaseIn, animations: {
            self.imageContainerButton!.transform =  self.imageContainerButton!.transform.rotated(by: CGFloat.pi);
            let newFrame:CGRect = CGRect(x: targetPointX, y:targetPointY, width: self.frame.width, height: self.frame.height);
            self.frame = newFrame;
        }, completion: { _ in
            self.removeFromSuperview();
        });
    }

    func disperseVertically() {
        displaceBoundsOntoMainView();
        self.setCat(named: "CheeringCat", stage: 1);
        let angle:CGFloat = CGFloat(Int.random(in: 0..<30));
        let targetPointX:CGFloat = generateElevatedTargetX(parentFrame:self.superview!.frame, childFrame:self.frame, angle:angle);
        let targetPointY:CGFloat = generateElevatedTargetY(parentFrame:self.superview!.frame, childFrame:self.frame, angle:angle);
        UIView.animate(withDuration: 2.5, delay: 0.125, options: .curveEaseIn, animations: {
            let newFrame:CGRect = CGRect(x: targetPointX, y:targetPointY, width: self.frame.width, height: self.frame.height);
            self.frame = newFrame;
        }, completion: { _ in
            self.removeFromSuperview();
        });
    }
    
    func pod() {
        SoundController.kittenMeow();
        // New radius and frames
        let newCornerRadius:CGFloat = self.frame.height * 0.5;
        let newCatButtonFrame:CGRect = CGRect(x: self.frame.minX + self.imageContainerButton!.frame.minX, y: self.frame.minY, width: self.imageContainerButton!.frame.width, height: self.frame.height);
        let newImageButtonFrame:CGRect = CGRect(x: 0.0, y: 0.0, width: self.frame.height, height: self.frame.height);
        UIView.animate(withDuration: 0.5, delay: 0.125, options: [.curveEaseInOut], animations: {
            // Adjust frames if necessary
            if (self.frame.width > self.frame.height) {
                self.frame = newCatButtonFrame;
                self.imageContainerButton!.frame = newImageButtonFrame;
            }
            self.backgroundColor = self.originalBackgroundColor;
            self.layer.cornerRadius = newCornerRadius;
            self.imageContainerButton!.layer.borderWidth = 0.0;
            self.layer.borderWidth = (sqrt(self.frame.width * 0.01) * 10.0) * 0.35;
        })
    }
    
    func generateElevatedTargetX(parentFrame:CGRect, childFrame:CGRect, angle:CGFloat) -> CGFloat{
        var targetX:CGFloat = parentFrame.width / 2.0;
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
    
    func getRadialXTargetPoint(parentFrame:CGRect, childFrame:CGRect) -> CGFloat {
        let angle:CGFloat = CGFloat.random(in: 0.0...45.0);
        var targetX:CGFloat = parentFrame.width + childFrame.width;
        targetX *= cos((CGFloat.pi * angle) / 180.0);
        if (Int.random(in: 0...1) == 1) {
            targetX *= -1;
        }
        return targetX;
    }
    
    func getRadialYTargetPoint(parentFrame:CGRect, childFrame:CGRect) -> CGFloat {
        let angle:CGFloat = CGFloat.random(in: 45.0...90.0);
        var targetY:CGFloat = parentFrame.height + childFrame.height;
        targetY *= sin((CGFloat.pi * angle) / 180.0);
        if (Int.random(in: 0...1) == 1) {
            targetY *= -1;
        }
        return targetY;
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
        UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseIn, animations: {
            self.alpha = 1.0;
        });
    }
    
    func setStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
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
    
    func fadeBackgroundIn(color:UIColor){
        UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseIn, animations: {
            self.backgroundColor = color;
        }, completion: { _ in
            if (color.cgColor != UIColor.clear.cgColor) {
                self.isFadedOut = false;
            }
        });
    }
}