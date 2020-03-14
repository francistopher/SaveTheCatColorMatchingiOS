//
//  UIAttackMeter.swift
//  SaveTheCat
//
//  Created by Christopher Francisco on 3/9/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import SwiftUI

enum VirusPhase {
    case FirstRotation
    case SecondRotation
    case TranslationToCat
    case SizeExpansion
    case SizeReduction
    case TranslationToStart
}

class UIAttackMeter:UICView {
    
    var virus:UIVirus?
    var cat:UICatButton?
    
    var previousDisplacementDuration:Double = 3.5;
    var displacementDuration:Double = 3.5;
    var virusToCatDistance:CGFloat = 0.0;
    
    var firstRotationAnimation:UIViewPropertyAnimator?
    var secondRotationAnimation:UIViewPropertyAnimator?
    var translationToCatAnimation:UIViewPropertyAnimator?
    var sizeExpansionAnimation:UIViewPropertyAnimator?
    var sizeReductionAnimation:UIViewPropertyAnimator?
    var translationToStartAnimation:UIViewPropertyAnimator?
    
    var didNotInvokeAttackImpulse:Bool = true;
    var holdVirusAtStart:Bool = false;
    var attackStarted:Bool = false;
    var attack:Bool = false;
    
    var firstRotationDegreeCheckpoint:CGFloat = 0.0;
    var secondRotationDegreeCheckpoint:CGFloat = 0.0;
    
    var virusXBeforeJump:CGFloat = 0.0;
    var virusXBeforeUnJump:CGFloat = 0.0;
    
    var currentVirusPhase:VirusPhase?
    var followingVirusPhase:VirusPhase?
    
    var boardGame:UIBoardGame?
    var cats:UICatButtons?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView, frame:CGRect, cats:UICatButtons) {
        super.init(parentView: parentView, x: frame.minX, y: frame.minY, width: frame.width, height: frame.height, backgroundColor: UIColor.clear);
        self.layer.cornerRadius = self.frame.height * 0.5;
        self.layer.borderWidth = self.frame.height / 12.0;
        self.cats = cats;
    }
    
    func startFirstRotation(afterDelay:Double) {
        if (currentVirusPhase != nil || didNotInvokeAttackImpulse) {
            return;
        }
        setupFirstRotationAnimation();
        firstRotationAnimation!.startAnimation(afterDelay: afterDelay);
        currentVirusPhase = .FirstRotation;
    }
    
    func invokeAttackImpulse(delay:Double) {
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { _ in
            self.didNotInvokeAttackImpulse = false;
            self.startFirstRotation(afterDelay: 0.25);
        })
    }
    
    func setupFirstRotationAnimation() {
        var firstDuration:Double = 0.5;
        var firstRadian:CGFloat = -CGFloat.pi;
        if (firstRotationDegreeCheckpoint > 0.0){
            let remainingPercentage:CGFloat = (180.0 - firstRotationDegreeCheckpoint) / 180.0;
            firstDuration *= Double(remainingPercentage);
            firstRadian *= -remainingPercentage;
            self.firstRotationDegreeCheckpoint = 0.0;
        }
        self.firstRotationAnimation = UIViewPropertyAnimator(duration: firstDuration, curve: .easeIn, animations: {
            self.virus!.transform = self.virus!.transform.rotated(by: firstRadian);
        });
        self.firstRotationAnimation!.addCompletion({ _ in
            self.dismantleFirstRotation();
            self.startSecondRotation(afterDelay: 0.0);
        })
    }
    
    func dismantleFirstRotation() {
        self.currentVirusPhase = nil;
        self.followingVirusPhase = .SecondRotation;
        self.firstRotationAnimation = nil;
    }
    
    func startSecondRotation(afterDelay:Double) {
        if (isVirusInAPhase()) {
            return;
        }
        self.setupSecondRotationAnimation();
        self.secondRotationAnimation!.startAnimation(afterDelay: afterDelay);
        self.currentVirusPhase = .SecondRotation;
    }
    
    func setupSecondRotationAnimation() {
        var secondDuration:Double = 0.5;
        var secondRadian:CGFloat = -CGFloat.pi;
        if (-secondRotationDegreeCheckpoint > 0.0) {
            let remainingPercentage:CGFloat = -secondRotationDegreeCheckpoint / 180.0;
            secondDuration *= Double(remainingPercentage);
            secondRadian *= -remainingPercentage;
            self.secondRotationDegreeCheckpoint = 0.0;
        }
        self.secondRotationAnimation = UIViewPropertyAnimator(duration: secondDuration, curve: .easeOut, animations: {
            self.virus!.transform = self.virus!.transform.rotated(by: secondRadian);
        })
        self.secondRotationAnimation!.addCompletion({ _ in
            self.dismantleSecondRotation();
            self.startTranslationToCat(afterDelay: 0.125);
        })
    }
    
    func dismantleSecondRotation() {
        self.currentVirusPhase = nil;
        self.followingVirusPhase = .TranslationToCat;
        self.secondRotationAnimation = nil;
    }
    
    func startTranslationToCat(afterDelay:Double) {
        if (isVirusInAPhase()) {
            return;
        }
        self.setupTranslationToCatAnimation();
        self.translationToCatAnimation!.startAnimation(afterDelay: 0.125);
        self.currentVirusPhase = .TranslationToCat;
    }
    
    func setupTranslationToCatAnimation() {
        self.translationToCatAnimation = UIViewPropertyAnimator(duration: getVirusToCatDuration(), curve: .easeIn, animations: {
            self.virus!.transform = self.virus!.transform.translatedBy(x: self.getVirusToCatDistance(), y: 0.0);
        })
        self.translationToCatAnimation!.addCompletion({ _ in
            self.dismantleTranslationToCat();
            self.startSizeExpansionAnimation(afterDelay: 0.125);
        })
    }
    
    func dismantleTranslationToCat() {
        self.currentVirusPhase = nil;
        self.followingVirusPhase = .SizeExpansion;
        self.translationToCatAnimation = nil;
    }
    
    func startSizeExpansionAnimation(afterDelay:Double) {
        if (isVirusInAPhase()) {
            return;
        }
        self.setupSizeExpansionAnimation();
        self.sizeExpansionAnimation!.startAnimation(afterDelay: afterDelay);
        self.currentVirusPhase = .SizeExpansion;
    }
    
    func setupSizeExpansionAnimation() {
        var factor:CGFloat = 1.5;
        var duration:Double = 0.5;
        if (self.attackStarted) {
            factor = (virus!.originalFrame!.height * 1.5) / (virus!.frame.height);
            duration *= 1.5 - Double(factor);
            virusXBeforeJump = 0.0;
        } else {
            virusXBeforeJump = virus!.frame.minX;
        }
        self.attackStarted = true;
        sizeExpansionAnimation = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: {
           self.virus!.transform = self.virus!.transform.scaledBy(x: factor, y: factor);
        })
        sizeExpansionAnimation!.addCompletion({ _ in
            self.dismantleSizeExpansion();
            self.startSizeReductionAnimation(afterDelay: 0.0);
        })
    }
    
    func attackRandomCatButton() {
        let randomCatButton:UICatButton = cats!.getRandomCatThatIsAlive();
        self.boardGame!.attackCatButton(catButton: randomCatButton);
    }
    
    func dismantleSizeExpansion() {
        self.currentVirusPhase = nil;
        self.followingVirusPhase = .SizeReduction;
        self.sizeExpansionAnimation = nil;
    }
    
    func startSizeReductionAnimation(afterDelay:Double) {
        if (isVirusInAPhase()) {
            return;
        }
        self.setupSizeReductionAnimation();
        self.sizeReductionAnimation!.startAnimation(afterDelay: afterDelay);
        self.currentVirusPhase = .SizeReduction;
    }
    
    func setupSizeReductionAnimation() {
        var factor:CGFloat = 1.0 / 1.5;
        var duration:Double = 0.5;
        if (!self.attackStarted) {
            factor = (virus!.originalFrame!.width) / (virus!.frame.width);
            duration *= (1.0 / Double(factor));
            virusXBeforeUnJump = 0.0;
        } else {
            virusXBeforeUnJump = virus!.frame.minX;
        }
        self.attackStarted = false;
        sizeReductionAnimation = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: {
           self.virus!.transform = self.virus!.transform.scaledBy(x: factor, y: factor);
        })
        sizeReductionAnimation!.addCompletion({ _ in
            self.attackRandomCatButton();
            self.dismantleSizeReduction();
            self.startTranslationToStartAnimation(afterDelay: 0.125);
        })
    }
    
    func dismantleSizeReduction() {
        self.currentVirusPhase = nil;
        self.followingVirusPhase = .TranslationToStart;
        self.sizeReductionAnimation = nil;
    }
    
    func startTranslationToStartAnimation(afterDelay:Double) {
        if (isVirusInAPhase()) {
            return;
        }
        self.setupTranslationToStartAnimation();
        self.translationToStartAnimation!.startAnimation(afterDelay: afterDelay);
        self.currentVirusPhase = .TranslationToStart;
    }
    
    func setupTranslationToStartAnimation() {
        translationToStartAnimation = UIViewPropertyAnimator(duration: getVirusToStartDuration() , curve: .linear, animations: {
            self.virus!.transform = .identity;
            self.virus!.frame = self.virus!.originalFrame!;
        })
        translationToStartAnimation!.addCompletion({ _ in
            self.displacementDuration = self.previousDisplacementDuration;
            self.dismantleTranslationToStart();
            if (!self.holdVirusAtStart) {
                self.startFirstRotation(afterDelay: 0.125);
            }
        })
    }
    
    func dismantleTranslationToStart() {
        self.currentVirusPhase = nil;
        self.followingVirusPhase = .FirstRotation;
        self.sizeReductionAnimation = nil;
    }
    
    func getVirusToCatDistance() -> CGFloat {
        return (cat!.originalFrame!.minX - virus!.frame.minX);
    }
    func getVirusToStartDistance() -> CGFloat {
        return (virus!.frame.minX - virus!.originalFrame!.minX);
    }
    
    func getVirusToStartDuration() -> Double {
        return displacementDuration * Double(getVirusToStartDistance()) / Double(virusToCatDistance);
    }
    
    func getVirusToCatDuration() -> Double {
        return displacementDuration * Double(getVirusToCatDistance()) / Double(virusToCatDistance);
    }
    
    func setupComponents() {
        setupCat();
        setupVirus();
        self.virusToCatDistance = cat!.originalFrame!.minX - virus!.originalFrame!.minX;
    }
    
    func updateDuration(change:Double) {
        if (change > 0.0) {
            displacementDuration += change;
            previousDisplacementDuration += change;
        }
        else if (change < 0.0) {
            if (previousDisplacementDuration + change >= 2.5) {
                displacementDuration += change;
                previousDisplacementDuration += change;
            } else {
                displacementDuration = 2.5;
                previousDisplacementDuration = 2.5;
            }
        }
        print(displacementDuration, "Displacement duration")
        print(previousDisplacementDuration, "Previous Displacement duration")
    }
    
    func pauseVirusMovement() {
        switch currentVirusPhase {
        case .TranslationToStart:
            translationToStartAnimation?.stopAnimation(true);
            print("Stopped translation to start animation");
        case .FirstRotation:
            firstRotationAnimation?.stopAnimation(true);
            let radians:CGFloat = atan2(virus!.transform.b, virus!.transform.a)
            let degrees:CGFloat = radians * 180 / .pi;
            self.firstRotationDegreeCheckpoint = degrees;
            print("Stopped first rotation animation ", firstRotationDegreeCheckpoint);
        case .SecondRotation:
            secondRotationAnimation?.stopAnimation(true);
            let radians:CGFloat = atan2(virus!.transform.b, virus!.transform.a)
            let degrees:CGFloat = radians * 180 / .pi;
            self.secondRotationDegreeCheckpoint = degrees;
            print("Stopped second rotation animation", secondRotationDegreeCheckpoint);
        case .TranslationToCat:
            translationToCatAnimation?.stopAnimation(true);
            print("Stopped translation to cat animation");
        case .SizeExpansion:
            sizeExpansionAnimation?.stopAnimation(true);
            let grownVirusX:CGFloat = virusXBeforeJump + (virus!.originalFrame!.width * 0.5) - (virus!.frame.width * 0.5);
            virus!.frame = CGRect(x: grownVirusX, y: virus!.frame.minY, width: virus!.frame.width, height: virus!.frame.height);
            print("Stopped size expansion animation")
        case .SizeReduction:
            sizeReductionAnimation?.stopAnimation(true);
            let shrunkVirusX:CGFloat = virusXBeforeUnJump + (virus!.originalFrame!.width * 0.75) - (virus!.frame.width * 0.5);
            virus!.frame = CGRect(x: shrunkVirusX, y: virus!.frame.minY, width: virus!.frame.width, height: virus!.frame.height)
            print("Stopped size reduction animation")
        default:
            print("Something went wrong?");
        }
    }
    
    func unPauseVirusMovement() {
        switch currentVirusPhase {
        case .TranslationToStart:
            let delay:Double = Double(0.5 * getVirusToCatDistance() / virusToCatDistance);
            startTranslationToStartAnimation(afterDelay: delay);
        case .FirstRotation:
            currentVirusPhase = nil;
            startFirstRotation(afterDelay: 0.25);
            print("Started first rotation again.")
        case .SecondRotation:
            startSecondRotation(afterDelay: 0.25);
            print("Started second rotation again.")
        case .TranslationToCat:
            let delay:Double = Double(0.75 * getVirusToStartDistance() / virusToCatDistance);
            startTranslationToCat(afterDelay: delay);
            print("Started translation to cat again.")
        case .SizeExpansion:
            startSizeExpansionAnimation(afterDelay: 0.125);
            print("Started size expansion again.")
        case .SizeReduction:
            startSizeReductionAnimation(afterDelay: 0.125);
            print("Started size reduction again.");
        default:
            print("Unpausing");
            currentVirusPhase = .TranslationToStart;
            unPauseVirusMovement();
        }
    }
    
    func isVirusInAPhase() -> Bool {
        let isVirusInAPhase:Bool = ((firstRotationAnimation != nil && firstRotationAnimation!.isRunning) || (secondRotationAnimation != nil && secondRotationAnimation!.isRunning) || (secondRotationAnimation != nil && secondRotationAnimation!.isRunning) || (translationToCatAnimation != nil && translationToCatAnimation!.isRunning) || (sizeExpansionAnimation != nil && sizeExpansionAnimation!.isRunning) || (sizeReductionAnimation != nil && sizeReductionAnimation!.isRunning) || (translationToStartAnimation != nil && translationToStartAnimation!.isRunning));
        return isVirusInAPhase;
    }
    
    func disperseCatButton() {
        cat!.disperseRadially();
    }
    
    func holdVirusOnceAtStart() {
        holdVirusAtStart = true;
        displacementDuration = 1.0;
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
           self.displacementDuration = self.previousDisplacementDuration;
        })
    }
    
    func sendVirusToStartAndHold() {
        holdVirusOnceAtStart();
        pauseVirusMovement();
        self.firstRotationDegreeCheckpoint = 0.0;
        self.secondRotationDegreeCheckpoint = 0.0;
        currentVirusPhase = .TranslationToStart;
        unPauseVirusMovement();
    }
    
    func sendVirusToStart() {
        if (currentVirusPhase != nil && currentVirusPhase! != .TranslationToStart) {
            displacementDuration = 1.0;
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
               self.displacementDuration = self.previousDisplacementDuration;
            })
            pauseVirusMovement();
            self.firstRotationDegreeCheckpoint = 0.0;
            self.secondRotationDegreeCheckpoint = 0.0;
            currentVirusPhase = .TranslationToStart;
            unPauseVirusMovement();
        }
    }
    
    func setupVirus() {
        virus = UIVirus(parentView: self, frame: CGRect(x: -self.layer.borderWidth * 0.8, y: 0.0, width: self.frame.height, height: self.frame.height));
        let newVirusFrame:CGRect = CGRect(x: self.frame.minX + virus!.frame.minX, y: self.frame.minY + virus!.frame.minY, width: virus!.frame.width, height: virus!.frame.height);
        virus!.frame = newVirusFrame;
        virus!.originalFrame = virus!.frame;
        self.superview!.addSubview(virus!);
    }
    
    func resetCat() {
        cat!.setCat(named: "DeadCat", stage: 5);
        setupCat();
        cat!.setCat(named: "SmilingCat", stage: 5);
        virus!.superview!.bringSubviewToFront(virus!);
        virus!.superview!.bringSubviewToFront(boardGame!.settingsButton!.settingsMenu!);
        virus!.superview!.bringSubviewToFront(boardGame!.settingsButton!);
    }
    
    func setupCat() {
        cat = UICatButton(parentView: self, x: self.frame.width - self.frame.height, y: 0.0, width: self.frame.height, height: self.frame.height, backgroundColor: UIColor.clear);
        cat!.grown();
        let newCatFrame:CGRect = CGRect(x: self.frame.minX + cat!.frame.minX, y: self.frame.minY + cat!.frame.minY, width: self.frame.height, height: self.frame.height);
        cat!.frame = newCatFrame;
        cat!.originalFrame = cat!.frame;
        self.superview!.addSubview(cat!);
        cat!.layer.borderWidth = 0.0;
        cat!.setCat(named: "SmilingCat", stage:0);
    }
    
    func setCompiledStyle() {
        setStyle();
        self.layer.borderColor = UIColor.systemYellow.cgColor;
        virus!.setupVirusImage();
        cat!.setCat(named: "SmilingCat", stage: 5);
    }
    
    func comiledHide() {
        self.alpha = 0.0;
        self.virus!.alpha = 0.0;
        self.cat!.alpha = 0.0;
    }
    
    func compiledShow() {
        self.fadeIn();
        self.virus!.fadeIn();
        self.cat!.fadeIn();
    }
    
}

