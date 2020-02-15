//
//  UICat.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/11/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI
import AVFoundation

class UICatButton: UIButton {
    
    enum Cat {
        case fat
        case standard
        
    }
    
    var shrunkX:CGFloat = 0.0;
    var shrunkY:CGFloat = 0.0;
    
    var originalFrame:CGRect? = nil;
    
    var previousFileName:String = "";
    var animationStage:Int = 0;
    
    var selectedCat:Cat = .standard;
    var originalBackgroundColor:UIColor = .clear;
    var imageContainerButton:UICButton? = nil;
    var isAlive:Bool = true;
    var podded:Bool = false;
    
    var kittenMeowPath:String? = nil;
    var kittenMeowUrl:URL? = nil;
    var kittenMeowSoundEffect:AVAudioPlayer?
    
    var kittenDiePath:String? = nil;
    var kittenDieUrl:URL? = nil;
    var kittenDieSoundEffect:AVAudioPlayer?
    
    var coinEarnedPath:String? = nil;
    var coinEarnedUrl:URL? = nil;
    var coinEarnedSoundEffect:AVAudioPlayer?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    init(parentView: UIView, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat, backgroundColor:UIColor) {
        super.init(frame:CGRect(x: x, y: y, width: width, height: height));
        self.originalFrame = CGRect(x: x, y: y, width: width, height: height);
        self.originalBackgroundColor = backgroundColor;
        self.backgroundColor = backgroundColor;
        self.layer.cornerRadius = height / 5.0;
        self.layer.borderWidth = frame.width * 0.01;
        parentView.addSubview(self);
        configureImageContainerButton();
        self.shrink();
        self.setStyle();
        configureKittenMeow();
        configureKittenDie();
        configureCoinEarned();
    }
    
    func giveMouseCoin() {
        let mouseCoin:UIMouseCoin = UIMouseCoin(parentView: self.imageContainerButton!, x: 0.0, y: 0.0, width: self.imageContainerButton!.frame.width / 4.0, height: self.imageContainerButton!.frame.height / 4.0);
        UICenterKit.center(childView: mouseCoin, parentRect: imageContainerButton!.frame, childRect: mouseCoin.frame);
        self.imageContainerButton!.addSubview(mouseCoin);
        self.coinEarned();
    }
    
    func kittenMeow() {
        if (!kittenMeowSoundEffect!.isPlaying){
            kittenMeowSoundEffect!.play();
        }
    }
    
    func kittenDie() {
        if (!kittenDieSoundEffect!.isPlaying){
            kittenDieSoundEffect!.play();
        }
    }
    
    func coinEarned() {
        if (!coinEarnedSoundEffect!.isPlaying) {
            coinEarnedSoundEffect!.play();
        }
    }
    
    func configureKittenMeow() {
        kittenMeowPath = Bundle.main.path(forResource: "kittenMeow.mp3", ofType: nil);
        kittenMeowUrl = URL(fileURLWithPath: kittenMeowPath!);
        do {
            kittenMeowSoundEffect = try AVAudioPlayer(contentsOf: kittenMeowUrl!);
        } catch {
            print("Unable to play kitten meow");
        }
    }
    
    func configureKittenDie() {
        kittenDiePath = Bundle.main.path(forResource: "kittenDie.mp3", ofType: nil);
        kittenDieUrl = URL(fileURLWithPath: kittenDiePath!);
        do {
           kittenDieSoundEffect = try AVAudioPlayer(contentsOf: kittenDieUrl!);
        } catch {
           print("Unable to play kitten die");
        }
    }
    
    func configureCoinEarned() {
        coinEarnedPath = Bundle.main.path(forResource: "coinEarned.mp3", ofType: nil);
        coinEarnedUrl = URL(fileURLWithPath: coinEarnedPath!);
        do {
            coinEarnedSoundEffect = try AVAudioPlayer(contentsOf: coinEarnedUrl!);
        } catch {
            print("Unable to play coin earned");
        }
    }
    
    func configureImageContainerButton() {
        imageContainerButton = UICButton(parentView:self, frame: CGRect(x: ((self.originalFrame!.width - self.originalFrame!.height) / 2.0), y: 0.0, width: self.originalFrame!.height, height: self.originalFrame!.height), backgroundColor:self.originalBackgroundColor);
        self.imageContainerButton!.layer.cornerRadius = self.layer.cornerRadius;
        imageContainerButton!.frame = imageContainerButton!.originalFrame!;
        imageContainerButton!.layer.borderWidth = 0.0;
        imageContainerButton!.shrinked();
    }
    
    func shrink(){
        self.frame = CGRect(x: self.frame.midX, y: self.frame.midY, width: 1.0, height: 1.0);
    }
    
    func grow(){
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseInOut, animations: {
            self.frame = self.originalFrame!;
        });
    }
    
    func getCatFileName(named:String) -> String {
        switch (selectedCat) {
        case Cat.fat:
            return "fat" + named;
        case Cat.standard:
            return named;
        }
    }
    
    func setCat(named:String, stage:Int){
        // Save non empty strings only
        if (named != "") {
            previousFileName = getCatFileName(named:named) + ".png";
        }
        // Build cat directory string
        var namedCatImage:String = "";
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            namedCatImage += "light" + previousFileName;
        } else{
            namedCatImage += "dark" + previousFileName;
        }
        // Clear background if cat dies
        if (stage == 2) {
            self.backgroundColor = UIColor.clear;
        }
        // Configure the image icon
        let iconImage:UIImage? = UIImage(named: namedCatImage);
        self.imageContainerButton!.setImage(iconImage, for: .normal);
        self.imageContainerButton!.imageView!.contentMode = UIView.ContentMode.scaleAspectFill;
        // Set the animation stage
        if (stage != 4 || stage != 5) {
            animationStage = stage;
        }
        // Prepare image view for reveal
        if (animationStage == 0){
            self.imageView!.alpha = 0.0;
            self.imageContainerButton!.imageView!.alpha = 0.0;
        }
        // Configure the dispatch time and animation
        var dispatchTime:DispatchTime? = nil;
        if (stage == 4){
            self.imageView!.layer.removeAllAnimations();
            dispatchTime = .now();
            self.animationStage = 0;
        } else if (stage == 1 || stage == 0){
            dispatchTime = .now() + 1.0;
        } else {
            dispatchTime = .now();
        }
        // Animate based on animation stage
        DispatchQueue.main.asyncAfter(deadline: dispatchTime!) {
            UIView.animate(withDuration: 1.0, delay:0.0, options:[.curveEaseInOut], animations: {
                self.imageContainerButton!.imageView!.alpha = 1.0;
            });
            if (self.animationStage == 0){
                self.setRandomCatAnimation();
            }
        }
    }
    
    func fadeBackgroundIn(){
        UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseIn, animations: {
            self.backgroundColor = self.originalBackgroundColor;
        });
    }
    
    func setRandomCatAnimation() {
        let randomAnimationSelection:Int = Int.random(in: 0...3);
        if (randomAnimationSelection > 2){
            self.imageContainerButton!.imageView!.transform = self.imageContainerButton!.imageView!.transform.rotated(by:-CGFloat.pi / 2.0);
            UIView.animate(withDuration: 1.75, delay: 0.125, options:[.curveEaseInOut, .repeat, .autoreverse], animations: {
                self.imageContainerButton!.imageView!.transform = self.imageContainerButton!.imageView!.transform.rotated(by:-CGFloat.pi);
            });
        } else if (randomAnimationSelection > 1) {
            self.imageContainerButton!.imageView!.transform = self.imageContainerButton!.imageView!.transform.rotated(by:CGFloat.pi / 2.0);
            UIView.animate(withDuration: 1.75, delay: 0.125, options:[.curveEaseInOut, .repeat, .autoreverse], animations: {
                self.imageContainerButton!.imageView!.transform = self.imageContainerButton!.imageView!.transform.rotated(by:-CGFloat.pi);
            });
        } else if (randomAnimationSelection > 0) {
            UIView.animate(withDuration: 1.75, delay: 0.125, options:[.curveEaseInOut, .repeat, .autoreverse], animations: {
                self.imageContainerButton!.imageView!.transform = self.imageContainerButton!.imageView!.transform.rotated(by:-CGFloat.pi);
            });
        } else {
            self.imageContainerButton!.imageView!.transform = self.imageContainerButton!.imageView!.transform.rotated(by:-CGFloat.pi / 2.0);
            UIView.animate(withDuration: 1.75, delay: 0.125, options:[.curveEaseInOut, .repeat, .autoreverse], animations: {
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
    
    func disperseRadially() {
        self.imageContainerButton!.backgroundColor = .clear;
        self.imageContainerButton!.layer.borderWidth = 0.0;
        self.layer.borderWidth = 0.0;
        displaceBoundsOntoMainView();
        self.setCat(named: "DeadCat", stage: 2);
        self.imageView!.layer.removeAllAnimations();
        let angle:CGFloat = CGFloat(Int.random(in: 0...360));
        let targetPointX:CGFloat = getRadialXTargetPoint(parentFrame: self.superview!.frame, childFrame: self.frame, angle: angle);
        let targetPointY:CGFloat = getRadialYTargetPoint(parentFrame: self.superview!.frame, childFrame: self.frame, angle: angle);
        UIView.animate(withDuration: 2.5, delay: 0.25, options: .curveEaseIn, animations: {
            self.transform = self.transform.rotated(by: CGFloat.pi);
            let newFrame:CGRect = CGRect(x: targetPointX, y:targetPointY, width: self.frame.width, height: self.frame.height);
            self.frame = newFrame;
       });
    }

    func disperseVertically() {
        displaceBoundsOntoMainView();
        self.setCat(named: "WavingCat", stage: 1);
        let angle:CGFloat = CGFloat(Int.random(in: 0..<30));
        let targetPointX:CGFloat = generateElevatedTargetX(parentFrame:self.superview!.frame, childFrame:self.frame, angle:angle);
        let targetPointY:CGFloat = generateElevatedTargetY(parentFrame:self.superview!.frame, childFrame:self.frame, angle:angle);
        UIView.animate(withDuration: 2.5, delay: 0.125, options: .curveEaseIn, animations: {
            let newFrame:CGRect = CGRect(x: targetPointX, y:targetPointY, width: self.frame.width, height: self.frame.height);
            self.frame = newFrame;
        });
    }
    
    func pod() {
            self.kittenMeow();
            // New radius and frames
            let newCornerRadius:CGFloat = self.frame.height / 2.0;
            let newCatButtonFrame:CGRect = CGRect(x: self.frame.minX + self.imageContainerButton!.frame.minX, y: self.frame.minY, width: self.imageContainerButton!.frame.width, height: self.frame.height);
            let newImageButtonFrame:CGRect = CGRect(x: 0.0, y: 0.0, width: self.frame.height, height: self.frame.height);
            // Adjust frames if necessary
            if (self.frame.width > self.frame.height) {
                self.frame = newCatButtonFrame;
                self.imageContainerButton!.frame = newImageButtonFrame;
            }
            // Apply adjustments
            self.imageContainerButton!.layer.cornerRadius = newCornerRadius;
            self.backgroundColor = .clear;
            self.layer.borderWidth = 0.0;
            self.imageContainerButton!.layer.borderWidth = self.frame.height / 75.0;
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
    
    func getRadialXTargetPoint(parentFrame:CGRect, childFrame:CGRect, angle:CGFloat) -> CGFloat {
        var targetX:CGFloat = childFrame.minX;
        targetX += parentFrame.width + childFrame.width;
        targetX *= cos((CGFloat.pi * angle) / 180.0);
        return targetX;
    }
    
    
    func getRadialYTargetPoint(parentFrame:CGRect, childFrame:CGRect, angle:CGFloat) -> CGFloat {
        var targetY:CGFloat = childFrame.minY;
        targetY += parentFrame.height + childFrame.height;
        targetY *= sin((CGFloat.pi * angle) / 180.0);
        return targetY;
    }
    
    func animate(AgainWithoutDelay:Bool) {
        if (AgainWithoutDelay) {
            self.setCat(named: "", stage: 4);
        } else {
            self.setCat(named: "", stage: 5);
        }
    }
    
    func hideCat(){
        self.imageView!.alpha = 0.0;
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
    
    func fadeBackgroundIn(color:UIColor){
        UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseIn, animations: {
            self.backgroundColor = color;
        });
    }
}
