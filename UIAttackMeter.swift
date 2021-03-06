//
//  UIAttackMeter.swift
//  SaveTheCat
//
//  Created by Christopher Francisco on 3/9/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import SwiftUI

enum EnemyPhase {
    case FirstRotation
    case SecondRotation
    case TranslationToCat
    case SizeExpansion
    case SizeReduction
    case TranslationToStart
}

class UIAttackMeter:UICView {
    
    var enemy:UIEnemy?
    var cat:UICatButton?
    
    var previousDisplacementDuration:Double = 3.5;
    var displacementDuration:Double = 3.5;
    var enemyToCatDistance:CGFloat = 0.0;
    
    var firstRotationAnimation:UIViewPropertyAnimator?
    var secondRotationAnimation:UIViewPropertyAnimator?
    var translationToCatAnimation:UIViewPropertyAnimator?
    var sizeExpansionAnimation:UIViewPropertyAnimator?
    var sizeReductionAnimation:UIViewPropertyAnimator?
    var translationToStartAnimation:UIViewPropertyAnimator?
    
    var didNotInvokeAttackImpulse:Bool = true;
    var holdEnemyAtStartAndHold:Bool = false;
    var attackStarted:Bool = false;
    var attack:Bool = false;
    
    var firstRotationDegreeCheckpoint:CGFloat = 0.0;
    var secondRotationDegreeCheckpoint:CGFloat = 0.0;
    
    var enemyXBeforeJump:CGFloat = 0.0;
    var enemyXBeforeUnJump:CGFloat = 0.0;
    
    var currentEnemyPhase:EnemyPhase?
    
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
    
    /*
        Starts the first 180 degree rotation of the hairball
     */
    func startFirstRotation(afterDelay:Double) {
        if (currentEnemyPhase != nil || didNotInvokeAttackImpulse) {
            return;
        }
        setupFirstRotationAnimation();
        firstRotationAnimation!.startAnimation(afterDelay: afterDelay);
        currentEnemyPhase = .FirstRotation;
    }
    
    func invokeAttackImpulse(delay:Double) {
        print("MESSAGE: Invoking attack multiple times")
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { _ in
            self.didNotInvokeAttackImpulse = false;
            self.startFirstRotation(afterDelay: 0.25);
        })
    }
    
    /*
        Setup the animation for the hair ball to rotate 180 degrees
     */
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
            self.enemy!.transform = self.enemy!.transform.rotated(by: firstRadian);
        });
        self.firstRotationAnimation!.addCompletion({ _ in
            self.dismantleFirstRotation();
            self.startSecondRotation(afterDelay: 0.0);
        })
    }
    
    func dismantleFirstRotation() {
        self.currentEnemyPhase = nil;
        self.firstRotationAnimation = nil;
    }
    
    /*
        Starts the last 180 degree rotation of the hairball
     */
    func startSecondRotation(afterDelay:Double) {
        if (isEnemyInAPhase()) {
            return;
        }
        self.setupSecondRotationAnimation();
        self.secondRotationAnimation!.startAnimation(afterDelay: afterDelay);
        self.currentEnemyPhase = .SecondRotation;
    }
    
    /*
        Setup the animation for the hair ball to rotate for the last 180 degrees
     */
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
            self.enemy!.transform = self.enemy!.transform.rotated(by: secondRadian);
        })
        self.secondRotationAnimation!.addCompletion({ _ in
            self.dismantleSecondRotation();
            self.startTranslationToCat(afterDelay: 0.125);
        })
    }
    
    func dismantleSecondRotation() {
        self.currentEnemyPhase = nil;
        self.secondRotationAnimation = nil;
    }
    
    /*
        Starts the animation that translates the hairball to the cat
     */
    func startTranslationToCat(afterDelay:Double) {
        if (isEnemyInAPhase()) {
            return;
        }
        self.setupTranslationToCatAnimation();
        self.translationToCatAnimation!.startAnimation(afterDelay: 0.125);
        self.currentEnemyPhase = .TranslationToCat;
    }
    
    /*
        Setup the animation that translates the hairball to the cat
     */
    func setupTranslationToCatAnimation() {
        self.translationToCatAnimation = UIViewPropertyAnimator(duration: getEnemyToCatDuration(), curve: .easeIn, animations: {
            self.enemy!.transform = self.enemy!.transform.translatedBy(x: self.getEnemyToCatDistance(), y: 0.0);
        })
        self.translationToCatAnimation!.addCompletion({ _ in
            self.dismantleTranslationToCat();
            self.startSizeExpansionAnimation(afterDelay: 0.125);
        })
    }
    
    func dismantleTranslationToCat() {
        self.currentEnemyPhase = nil;
        self.translationToCatAnimation = nil;
    }
    
    /*
        Starts the animation of the hairball jumping on the cat
     */
    func startSizeExpansionAnimation(afterDelay:Double) {
        if (isEnemyInAPhase()) {
            return;
        }
        self.setupSizeExpansionAnimation();
        self.sizeExpansionAnimation!.startAnimation(afterDelay: afterDelay);
        self.currentEnemyPhase = .SizeExpansion;
    }
    
    /*
        Setup the animation of the hairball jumping on the cat
     */
    func setupSizeExpansionAnimation() {
        var factor:CGFloat = 1.5;
        var duration:Double = 0.5;
        if (self.attackStarted) {
            factor = (enemy!.originalFrame!.height * 1.5) / (enemy!.frame.height);
            duration *= 1.5 - Double(factor);
            enemyXBeforeJump = 0.0;
        } else {
            enemyXBeforeJump = enemy!.frame.minX;
        }
        self.attackStarted = true;
        sizeExpansionAnimation = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: {
           self.enemy!.transform = self.enemy!.transform.scaledBy(x: factor, y: factor);
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
        self.currentEnemyPhase = nil;
        self.sizeExpansionAnimation = nil;
    }
    
    /*
        Starts the animation of the hairball getting off the cat
     */
    func startSizeReductionAnimation(afterDelay:Double) {
        if (isEnemyInAPhase()) {
            return;
        }
        self.setupSizeReductionAnimation();
        self.sizeReductionAnimation!.startAnimation(afterDelay: afterDelay);
        self.currentEnemyPhase = .SizeReduction;
    }
    
    /*
        Setup the animation of the hairball getting off the cat
     */
    func setupSizeReductionAnimation() {
        var factor:CGFloat = 1.0 / 1.5;
        var duration:Double = 0.5;
        if (!self.attackStarted) {
            factor = (enemy!.originalFrame!.width) / (enemy!.frame.width);
            duration *= (1.0 / Double(factor));
            enemyXBeforeUnJump = 0.0;
        } else {
            enemyXBeforeUnJump = enemy!.frame.minX;
        }
        self.attackStarted = false;
        sizeReductionAnimation = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: {
           self.enemy!.transform = self.enemy!.transform.scaledBy(x: factor, y: factor);
        })
        sizeReductionAnimation!.addCompletion({ _ in
            self.attackRandomCatButton();
            self.dismantleSizeReduction();
            self.startTranslationToStartAnimation(afterDelay: 0.125);
        })
    }
    
    func dismantleSizeReduction() {
        self.currentEnemyPhase = nil;
        self.sizeReductionAnimation = nil;
    }
    
    /*
        Starts the animation of the hariball translating to its spawn point
     */
    func startTranslationToStartAnimation(afterDelay:Double) {
        if (isEnemyInAPhase()) {
            return;
        }
        self.setupTranslationToStartAnimation();
        self.translationToStartAnimation!.startAnimation(afterDelay: afterDelay);
        self.currentEnemyPhase = .TranslationToStart;
    }
    
    /*
        Setup the animation of the hairball translating to its spawn point
     */
    func setupTranslationToStartAnimation() {
        translationToStartAnimation = UIViewPropertyAnimator(duration: getEnemyToStartDuration() , curve: .linear, animations: {
            self.enemy!.transform = .identity;
            self.enemy!.frame = self.enemy!.originalFrame!;
        })
        translationToStartAnimation!.addCompletion({ _ in
            self.displacementDuration = self.previousDisplacementDuration;
            self.dismantleTranslationToStart();
            if (!self.holdEnemyAtStartAndHold) {
                self.startFirstRotation(afterDelay: 0.125);
            }
        })
    }
    
    func dismantleTranslationToStart() {
        self.currentEnemyPhase = nil;
        self.sizeReductionAnimation = nil;
    }
    
    func getEnemyToCatDistance() -> CGFloat {
        return (cat!.originalFrame!.minX - enemy!.frame.minX);
    }
    func getEnemyToStartDistance() -> CGFloat {
        return (enemy!.frame.minX - enemy!.originalFrame!.minX);
    }
    
    func getEnemyToStartDuration() -> Double {
        return displacementDuration * Double(getEnemyToStartDistance()) / Double(enemyToCatDistance);
    }
    
    func getEnemyToCatDuration() -> Double {
        return displacementDuration * Double(getEnemyToCatDistance()) / Double(enemyToCatDistance);
    }
    
    func setupComponents() {
        setupCat();
        setupEnemy();
        self.enemyToCatDistance = cat!.originalFrame!.minX - enemy!.originalFrame!.minX;
    }
    
    /*
        Updates the duration of the hairball translating to the cat
     */
    func updateDuration(change:Double) {
        if (change > 0.0) {
            displacementDuration += change;
            previousDisplacementDuration += change;
        }
        else if (change < 0.0) {
            if (previousDisplacementDuration + change >= 1.5) {
                displacementDuration += change;
                previousDisplacementDuration += change;
            } else {
                displacementDuration = 1.5;
                previousDisplacementDuration = 1.5;
            }
        }
    }
    
    /*
        Stops the current hairball animation
     */
    func pauseEnemyMovement() {
        switch currentEnemyPhase {
        case .TranslationToStart:
            translationToStartAnimation?.stopAnimation(true);
        case .FirstRotation:
            firstRotationAnimation?.stopAnimation(true);
            let radians:CGFloat = atan2(enemy!.transform.b, enemy!.transform.a)
            let degrees:CGFloat = radians * 180 / .pi;
            self.firstRotationDegreeCheckpoint = degrees;
        case .SecondRotation:
            secondRotationAnimation?.stopAnimation(true);
            let radians:CGFloat = atan2(enemy!.transform.b, enemy!.transform.a)
            let degrees:CGFloat = radians * 180 / .pi;
            self.secondRotationDegreeCheckpoint = degrees;
        case .TranslationToCat:
            translationToCatAnimation?.stopAnimation(true);
        case .SizeExpansion:
            sizeExpansionAnimation?.stopAnimation(true);
            let grownEnemyX:CGFloat = enemyXBeforeJump + (enemy!.originalFrame!.width * 0.5) - (enemy!.frame.width * 0.5);
            enemy!.frame = CGRect(x: grownEnemyX, y: enemy!.frame.minY, width: enemy!.frame.width, height: enemy!.frame.height);
        case .SizeReduction:
            sizeReductionAnimation?.stopAnimation(true);
            let shrunkEnemyX:CGFloat = enemyXBeforeUnJump + (enemy!.originalFrame!.width * 0.75) - (enemy!.frame.width * 0.5);
            enemy!.frame = CGRect(x: shrunkEnemyX, y: enemy!.frame.minY, width: enemy!.frame.width, height: enemy!.frame.height)
        default:
            print("")
        }
    }
    
    /*
        Start resuming animations for the hairball
     */
    func resumeEnemyMovement() {
        switch currentEnemyPhase {
        case .TranslationToStart:
            let delay:Double = Double(0.5 * getEnemyToCatDistance() / enemyToCatDistance);
            startTranslationToStartAnimation(afterDelay: delay);
        case .FirstRotation:
            currentEnemyPhase = nil;
            startFirstRotation(afterDelay: 0.25);
            print("Started first rotation again.")
        case .SecondRotation:
            startSecondRotation(afterDelay: 0.25);
            print("Started second rotation again.")
        case .TranslationToCat:
            let delay:Double = Double(0.75 * getEnemyToStartDistance() / enemyToCatDistance);
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
            currentEnemyPhase = .TranslationToStart;
            resumeEnemyMovement();
        }
    }
    
    /*
        Returns a boolean indicating whether or not
        the hairball is currently in being animated
     */
    func isEnemyInAPhase() -> Bool {
      return ((firstRotationAnimation != nil && firstRotationAnimation!.isRunning) || (secondRotationAnimation != nil && secondRotationAnimation!.isRunning) || (secondRotationAnimation != nil && secondRotationAnimation!.isRunning) || (translationToCatAnimation != nil && translationToCatAnimation!.isRunning) || (sizeExpansionAnimation != nil && sizeExpansionAnimation!.isRunning) || (sizeReductionAnimation != nil && sizeReductionAnimation!.isRunning) || (translationToStartAnimation != nil && translationToStartAnimation!.isRunning));
    }
    
    func disperseCatButton() {
        cat!.disperseRadially();
    }
    
    /*
        Holds the hairball at its spawn point
     */
    func holdEnemyOnceAtStart() {
        holdEnemyAtStartAndHold = true;
        displacementDuration = 1.0;
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
           self.displacementDuration = self.previousDisplacementDuration;
        })
    }
    
    /*
        Sends the hairball to the start
        and holds it on its spawn point
     */
    func sendEnemyToStartAndHold() {
        holdEnemyOnceAtStart();
        pauseEnemyMovement();
        self.firstRotationDegreeCheckpoint = 0.0;
        self.secondRotationDegreeCheckpoint = 0.0;
        currentEnemyPhase = .TranslationToStart;
        resumeEnemyMovement();
    }
    
    /*
        Sends the hair ball to its spawn point
     */
    func sendEnemyToStart() {
        if (currentEnemyPhase != nil && currentEnemyPhase! != .TranslationToStart) {
            displacementDuration = 1.0;
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
               self.displacementDuration = self.previousDisplacementDuration;
            })
            pauseEnemyMovement();
            self.firstRotationDegreeCheckpoint = 0.0;
            self.secondRotationDegreeCheckpoint = 0.0;
            currentEnemyPhase = .TranslationToStart;
            resumeEnemyMovement();
        }
    }
    
    func setupEnemy() {
        enemy = UIEnemy(parentView: self, frame: CGRect(x: -self.layer.borderWidth * 0.8, y: 0.0, width: self.frame.height, height: self.frame.height));
        enemy!.frame = CGRect(x: self.frame.minX + enemy!.frame.minX, y: self.frame.minY + enemy!.frame.minY, width: enemy!.frame.width, height: enemy!.frame.height);
        enemy!.originalFrame = enemy!.frame;
        self.superview!.addSubview(enemy!);
    }
    
    /*
        Creates a cat on the meter
     */
    func resetCat() {
        setupCat();
        cat!.selectedCat = .standard;
        cat!.setCat(named: "SmilingCat", stage: 5);
        enemy!.superview!.bringSubviewToFront(enemy!);
        enemy!.superview!.bringSubviewToFront(boardGame!.settingsButton!.settingsMenu!);
        enemy!.superview!.bringSubviewToFront(boardGame!.settingsButton!);
    }
    
    func setupCat() {
        cat = nil;
        cat = UICatButton(parentView: self, x: self.frame.width - self.frame.height, y: 0.0, width: self.frame.height, height: self.frame.height, backgroundColor: UIColor.clear);
        cat!.grown();
        cat!.frame = CGRect(x: self.frame.minX + cat!.frame.minX, y: self.frame.minY + cat!.frame.minY, width: self.frame.height, height: self.frame.height);
        cat!.originalFrame = cat!.frame;
        self.superview!.addSubview(cat!);
        cat!.layer.borderWidth = 0.0;
        cat!.setCat(named: "SmilingCat", stage:0);
    }
    
    /*
        Updates the colors of the attack meter based
        on the theme of the operating systems
     */
    func setCompiledStyle() {
        setStyle();
        self.layer.borderColor = UIColor.systemYellow.cgColor;
        enemy!.setupEnemyImage();
        if (cat!.imageContainerButton != nil) {
            cat!.setCat(named: "SmilingCat", stage: 5);
        }
        
    }
    
    func comiledHide() {
        self.alpha = 0.0;
        self.enemy!.alpha = 0.0;
        self.cat!.alpha = 0.0;
    }
    
    func compiledShow() {
        self.fadeIn();
        self.enemy!.fadeIn();
        self.cat!.fadeIn();
    }
    
}

