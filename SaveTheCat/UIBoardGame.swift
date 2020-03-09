//
//  UIBoardGameView.swift
//  SaveTheCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
// (int)

import SwiftUI

class UIBoardGame: UIView {
    
    var colorOptions:UIColorOptions? = nil;
    
    var gridColorsCount:[CGColor:Int] = [:]
    var gridColors:[[UIColor]]? = nil;
    
    var currentRound:Int = 1;
    var rowAndColumnNums:[Int] = [];
    
    let cats:UICatButtons = UICatButtons();
    
    var successGradientLayer:CAGradientLayer? = nil;
    
    var settingsButton:UISettingsButton? = nil;
    var livesMeter:UILivesMeter?
    var statistics:UIStatistics?
    var attackMeter:UIAttackMeter?
    var viruses:UIViruses?
    var timer:Timer?
    
    var glovePointer:UIGlovedPointer?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    init(parentView: UIView, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) {
        super.init(frame:CGRect(x: x, y: y, width: width, height: height));
        self.backgroundColor = UIColor.clear;
        self.layer.cornerRadius = width / 5.0;
        parentView.addSubview(self);
        self.statistics = UIStatistics(parentView: parentView);
        self.statistics!.continueButton!.addTarget(self, action: #selector(continueSelector), for: .touchUpInside);
        setupAttackMeter();
        setupLivesMeter();
        setupGlovePointer();
    }
    
    func setupGlovePointer() {
        let sideLength:CGFloat = ViewController.staticUnitViewHeight * 1.5;
        let x:CGFloat = self.frame.minX + (self.frame.width * (1.0 / 3.0));
        glovePointer = UIGlovedPointer(parentView: self.superview!, frame: CGRect(x: x, y: ViewController.staticUnitViewHeight * 11.725, width: sideLength, height: sideLength))
    }
    
    func setupAttackMeter() {
        let height:CGFloat = ViewController.staticMainView!.frame.height * ((1.0/300.0) + 0.08);
        var width:CGFloat = ViewController.staticUnitViewWidth * 6.5;
        var y:CGFloat = ViewController.staticUnitViewHeight;
        var x:CGFloat = 0.0;
        if (ViewController.aspectRatio! == .ar19point5by9){
            width *= 1.5;
            x = (self.superview!.frame.width - width) * 0.5;
            y += height * 1.15;
        } else if (ViewController.aspectRatio! == .ar16by9) {
            x = (self.superview!.frame.width - width) * 0.5;
            x += ViewController.staticUnitViewWidth;
            width += ViewController.staticUnitViewWidth * 0.5;
        } else {
            x = (self.superview!.frame.width - width) * 0.5;
        }
        let attackMeterFrame:CGRect = CGRect(x: x, y: y, width: width, height: height);
        attackMeter = UIAttackMeter(parentView:self.superview!, frame: attackMeterFrame, cats: cats);
        attackMeter!.setupComponents();
        attackMeter!.setCompiledStyle();
    }

    func setupLivesMeter() {
        let height:CGFloat = ViewController.staticMainView!.frame.height * ((1.0/300.0) + 0.08);
        var width:CGFloat = height * (1.0 / 60.0 + 1.9)
        var x:CGFloat = ViewController.staticMainView!.frame.width - width - ViewController.staticUnitViewWidth;
        if (ViewController.aspectRatio! == .ar19point5by9){
            
        } else if (ViewController.aspectRatio! == .ar16by9) {
            width = height;
            x = ViewController.staticMainView!.frame.width - width - ViewController.staticUnitViewWidth;
        }
        let livesMeterFrame:CGRect = CGRect(x: x, y: ViewController.staticUnitViewHeight, width: width, height: height);
        livesMeter = UILivesMeter(parentView: self.superview!, frame: livesMeterFrame, backgroundColor: UIColor.white);
    }
    
    @objc func continueSelector() {
        print("Continuing?");
        livesMeter!.resetLivesLeftCount();
        self.statistics!.fadeOut();
        statistics!.catsThatLived = 0;
        statistics!.catsThatDied = 0;
        SoundController.chopinPrelude(play: false);
        SoundController.mozartSonata(play: true);
        colorOptions!.isTransitioned = false;
        colorOptions!.selectedColor = UIColor.lightGray;
        attackMeter!.resetCat();
        restart();
        self.attackMeter!.startFirstRotation(afterDelay: 1.25);
    }
    
    func fadeIn(){
        UIView.animate(withDuration: 2, delay: 0.5, options: .curveEaseIn, animations: {
            super.alpha = 1.0;
        })
    }
    
    func buildBoardGame(){
        rowAndColumnNums = getRowsAndColumns(currentStage: currentRound);
        cats.reset();
        colorOptions!.selectSelectionColors();
        buildGridColors();
        buildGridButtons();
        cats.loadPreviousCats();
        recordGridColorsUsed();
        colorOptions!.buildColorOptionButtons(setup: true);
        attackMeter!.holdVirusAtStart = false;
        if (!glovePointer!.hideForever) {
            glovePointer!.fadeBackgroundIn();
            colorOptions!.selectionButtons[0].addTarget(self, action: #selector(translateGloveToCatButtonCenter), for: .touchUpInside);
        }
    }
    
    @objc func translateGloveToCatButtonCenter() {
        let newFrame:CGRect = CGRect(x: self.frame.midX - self.glovePointer!.frame.width * 0.5, y: self.frame.midY - self.glovePointer!.frame.height * 0.5, width: self.glovePointer!.frame.width, height: self.glovePointer!.frame.height);
        glovePointer!.stopAnimations();
        glovePointer!.translate(newOriginalFrame: newFrame);
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            self.glovePointer!.sway();
        })
    }
    
    func buildGridColors(){
        gridColors = Array(repeating: Array(repeating: UIColor.lightGray, count: rowAndColumnNums[1]), count: rowAndColumnNums[0]);
        var rowIndex:Int = 0;
        while (rowIndex < gridColors!.count) {
            var columnIndex:Int = 0;
            while (columnIndex < gridColors![0].count) {
                let randomInt:Int = Int.random(in: 0...2);
                let randomColor:UIColor = colorOptions!.selectionColors.randomElement()!;
                if (rowIndex > 0) {
                    let previousColumnColor:UIColor = gridColors![rowIndex - 1][columnIndex];
                    if (previousColumnColor.cgColor == randomColor.cgColor) {
                        rowIndex -= 1;
                    }
                }
                if (columnIndex > 0) {
                    let previousRowColor:UIColor = gridColors![rowIndex][columnIndex - 1];
                    if (previousRowColor.cgColor == randomColor.cgColor && randomInt > 1){
                        columnIndex -= 1;
                    }
                }
                gridColors![rowIndex][columnIndex] = randomColor;
                columnIndex += 1;
            }
            rowIndex += 1;
        }
    }
    
    func nonZeroGridColorsCount() -> Int {
        var nonZeroCount:Int = 0;
        for (_, count) in gridColorsCount {
            if (count != 0) {
                nonZeroCount += 1;
            }
        }
        return nonZeroCount;
    }
    
    func recordGridColorsUsed(){
        gridColorsCount = [:];
        for catButton in cats.presentCollection! {
            let color:CGColor = catButton.originalBackgroundColor.cgColor;
            if (gridColorsCount[color] == nil) {
                gridColorsCount[color] = 1;
            } else {
                gridColorsCount[color]! += 1;
            }
        }
    }
    
    func getRowsAndColumns(currentStage:Int) -> [Int] {
        var initialStage:Int = 2;
        var rows:Int = 1;
        var columns:Int = 1;
        while (currentStage >= initialStage) {
            if (initialStage % 2 == 0){
                rows += 1;
            }
            else {
                columns += 1;
            }
            initialStage += 1;
        }
        return [rows, columns];
    }
    
    func buildGridButtons(){
        let rowGap:CGFloat = self.frame.height * 0.1 / CGFloat(rowAndColumnNums[0] + 1);
        let columnGap:CGFloat = self.frame.width * 0.1 / CGFloat(rowAndColumnNums[1] + 1);
        // Sizes
        let buttonHeight:CGFloat = self.frame.width * 0.90 / CGFloat(rowAndColumnNums[0]);
        let buttonWidth:CGFloat = self.frame.height * 0.90 / CGFloat(rowAndColumnNums[1]);
        // Points
        var x:CGFloat = 0.0;
        var y:CGFloat = 0.0;
        for rowIndex in 0..<rowAndColumnNums[0] {
            y += rowGap;
            x = 0.0;
            for columnIndex in 0..<rowAndColumnNums[1] {
                x += columnGap;
                let frame:CGRect = CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight);
                let catButton:UICatButton = cats.buildCatButton(parent: self, frame: frame, backgroundColor: gridColors![rowIndex][columnIndex]);
                catButton.rowIndex = rowIndex;
                catButton.columnIndex = columnIndex;
                catButton.imageContainerButton!.backgroundColor = UIColor.clear;
                catButton.imageContainerButton!.addTarget(self, action: #selector(selectCatImageButton), for: .touchUpInside);
                catButton.addTarget(self, action: #selector(selectCatButton), for: .touchUpInside);
                x += buttonWidth;
            }
            y += buttonHeight;
        }
    }
    
    func gameOverTransition() {
        self.attackMeter!.attack = false;
        self.attackMeter!.attackStarted = false;
        statistics!.maxStage = self.currentRound;
        statistics!.sessionEndTime = CFAbsoluteTimeGetCurrent();
        statistics!.setSessionDuration();
        statistics!.catsThatDied = cats.presentCollection!.count;
        SoundController.mozartSonata(play: false);
        SoundController.chopinPrelude(play: true);
        colorOptions!.removeBorderOfSelectionButtons();
        self.livesMeter!.removeAllHeartLives();
        self.attackMeter!.disperseCatButton();
        self.attackMeter!.sendVirusToStartAndHold();
        self.attackMeter!.previousDisplacementDuration = 3.5;
        self.glovePointer!.reset();
        // App data of dead cats
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            self.reset(catsSurvived: false);
            self.colorOptions!.shrinkColorOptions();
            self.statistics!.update();
            self.statistics!.fadeIn();
        }
    }
    
    @objc func selectCatButton(catButton:UICatButton) {
        if (self.attackMeter!.attackStarted){
            return;
        }
        interaction(catButton: catButton, catImageButton: catButton.imageContainerButton!);
    }
    
    @objc func selectCatImageButton(catImageButton:UICButton){
        if (self.attackMeter!.attackStarted){
            return;
        }
        let catButton:UICatButton = catImageButton.superview! as! UICatButton;
        interaction(catButton: catButton, catImageButton: catImageButton);
    }
    
    @objc func interaction(catButton:UICatButton, catImageButton:UICButton){
        // Selection of a color option is made after fresh new round
        if (cats.isOneAlive() && colorOptions!.selectedColor.cgColor != UIColor.lightGray.cgColor) {
            // Correct matching grid button color and selection color
            if (catButton.backgroundCGColor! == colorOptions!.selectedColor.cgColor){
                if (!catButton.isPodded) {
                    gridColorsCount[catButton.backgroundCGColor!]! -= 1;
                    colorOptions!.buildColorOptionButtons(setup: false);
                    catButton.pod();
                    catButton.isPodded = true;
                    catButton.giveMouseCoin(withNoise: true);
                    verifyThatRemainingCatsArePodded(catButton:catButton);
                }
            } else {
                if (!catButton.isPodded) {
                    attackCatButton(catButton: catButton);
                } else {
                    SoundController.kittenMeow();
                }
            }
        } else {
            SoundController.kittenMeow();
        }
    }
    
    func setAllCatButtonsAsDead() {
        for catButton in cats.presentCollection! {
            if (catButton.isAlive) {
                setCatButtonAsDead(catButton: catButton);
            }
        }
    }
    
    func attackCatButton(catButton:UICatButton) {
        self.attackMeter!.updateDuration(change: -0.80);
        if (livesMeter!.livesLeft > 0) {
            setCatButtonAsDead(catButton: catButton);
            livesMeter!.decrementLivesLeftCount();
        } else {
            setAllCatButtonsAsDead();
        }
        
        if (cats.areAllCatsDead()){
            gameOverTransition();
        } else {
            verifyThatRemainingCatsArePodded(catButton:catButton);

        }
    }
    
    func setCatButtonAsDead(catButton:UICatButton) {
        gridColorsCount[catButton.originalBackgroundColor.cgColor]? -= 1;
        colorOptions!.buildColorOptionButtons(setup: false);
        catButton.isDead();
        self.superview!.sendSubviewToBack(catButton);
        self.viruses!.translateToCatAndBack(catButton:catButton);
        catButton.disperseRadially();
        displaceArea(ofCatButton: catButton);
        SoundController.kittenDie();
    }
    
    @objc func transitionBackgroundColorOfButtonsToClear(){
        if (!colorOptions!.isTransitioned){
            cats.transitionCatButtonBackgroundToClear();
            colorOptions!.isTransitioned = true;
        }
    }
    
    func verifyThatRemainingCatsArePodded(catButton:UICatButton) {
        // Check if all the cats have been podded
        if (cats.aliveCatsArePodded()) {
            SoundController.heaven();
            colorOptions!.selectedColor = UIColor.lightGray;
            colorOptions!.isTransitioned = false;
            // Add data of survived cats
            statistics!.catsThatLived += cats.presentCollection!.count;
            if (cats.didAllSurvive()) {
                livesMeter!.incrementLivesLeftCount(catButton: catButton);
                self.attackMeter!.updateDuration(change: 0.2);
                self.attackMeter!.sendVirusToStart();
                self.glovePointer!.reset();
                self.glovePointer!.hideForever = true;
                promote();
                print("Promoted!");
                return;
            } else {
                self.attackMeter!.sendVirusToStart();
                maintain();
                return;
               
            }
        } else {
            self.attackMeter!.updateDuration(change: 0.1);
            self.attackMeter!.sendVirusToStart();
            self.attackMeter!.startFirstRotation(afterDelay: 1.0);
        }
    }
    
    func displaceArea(ofCatButton:UICatButton) {
        let rowOfAliveCats:[UICatButton] = cats.getRowOfAliveCats(rowIndex: ofCatButton.rowIndex);
        // Row is still occupied
        if (rowOfAliveCats.count > 0) {
            disperseRow(aliveCats: rowOfAliveCats);
        } else {
            // If all cats are alive
            disperseColumns();
        }
    }
    
    func disperseRow(aliveCats:[UICatButton]) {
        // Establish shared y, column gap
        var x:CGFloat = 0.0;
        let y:CGFloat = aliveCats[0].frame.minY;
        let columnGap:CGFloat = self.frame.width * 0.1 / CGFloat(aliveCats.count + 1);
        let buttonWidth:CGFloat = self.frame.height * 0.90 / CGFloat(aliveCats.count);
        for aliveCat in aliveCats {
            x += columnGap;
            let newFrame:CGRect = CGRect(x: x, y: y, width: buttonWidth, height: aliveCats[0].frame.height);
            aliveCat.transformTo(frame: newFrame);
            x += buttonWidth;
        }
    }
    
    func disperseColumns() {
        // Get the dictionary with row index and corresponding count
        var indexesOfRowsWithAliveCatsCount:[Int:Int] = cats.getIndexesOfRowsWithAliveCatsCount();
        // Get count of rows left
        let countOfRowsLeft:Int = indexesOfRowsWithAliveCatsCount.count;
        if (countOfRowsLeft == 0) {
            return;
        }
        // Get max count of cats alive in a row
        let countOfMaxCatButtonsInARow:Int = (indexesOfRowsWithAliveCatsCount.max { a, b in a.value < b.value})!.1;
        // Set dimensions
        var y:CGFloat = 0.0;
        var rowGap:CGFloat = self.frame.height * 0.1 / CGFloat(countOfRowsLeft + 1);
        var buttonHeight:CGFloat = self.frame.width * 0.90 / CGFloat(countOfRowsLeft);
        
        func resetCatButtonsPosition(rowIndexOf:Int) {
            y += rowGap;
            for catButton in cats.getRowOfAliveCats(rowIndex: rowIndexOf) {
               let frame:CGRect = CGRect(x: catButton.frame.minX, y: y, width: catButton.frame.width, height: buttonHeight);
               catButton.transformTo(frame: frame);
            }
            y += buttonHeight;
        }
        
        if (!(countOfMaxCatButtonsInARow > countOfRowsLeft)) {
            for rowIndexOf in Array(indexesOfRowsWithAliveCatsCount.keys).sorted(by:<) {
                resetCatButtonsPosition(rowIndexOf: rowIndexOf);
            }
        } else {
            rowGap = self.frame.height * 0.1 / CGFloat(countOfRowsLeft + 1);
            buttonHeight = self.frame.width * 0.90 / CGFloat(countOfRowsLeft);
            for rowIndexOf in Array(indexesOfRowsWithAliveCatsCount.keys).sorted(by:<) {
                resetCatButtonsPosition(rowIndexOf: rowIndexOf);
            }
        }
    }
    
    func revertSelections() {
        attackMeter!.sendVirusToStartAndHold();
        livesMeter!.resetLivesLeftCount();
        colorOptions!.selectedColor = UIColor.lightGray;
        cats.shrink();
        currentRound = 1;
        configureComponentsAfterBoardGameReset();
    }
    
    func reset(catsSurvived:Bool){
        if (catsSurvived) {
            cats.disperseVertically()
        } else {
            cats.disperseRadially();
        }
        gridColors = [[UIColor]]();
        colorOptions!.selectionColors = [UIColor]();
    }
    
    func restart(){
        currentRound = 1
        configureComponentsAfterBoardGameReset();
    }
    
    func maintain() {
        let countOfAliveCatButtons:Int = cats.countOfAliveCatButtons();
        var newRound:Int = 1;
        while (newRound != currentRound) {
            let newRoundRowsAndColumns:[Int] = getRowsAndColumns(currentStage: newRound);
            let product:Int = newRoundRowsAndColumns[0] * newRoundRowsAndColumns[1];
            if (product == countOfAliveCatButtons) {
                currentRound = newRound;
                break;
            }
            newRound += 1;
        }
        successGradientLayer!.isHidden = false;
        reset(catsSurvived: true);
        self.colorOptions!.shrinkColorOptions();
        configureComponentsAfterBoardGameReset();
    }
    
    func promote(){
        successGradientLayer!.isHidden = false;
        reset(catsSurvived: true);
        colorOptions!.shrinkColorOptions();
        self.colorOptions!.loadSelectionButtonsToSelectedButtons();
        // Build board game
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.currentRound += 1;
            self.buildBoardGame();
            self.attackMeter!.startFirstRotation(afterDelay: 1.50);
        }
        // Remove selected buttons after they've shrunk
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.currentRound -= 1;
            self.colorOptions!.removeSelectedButtons();
            self.currentRound += 1;
            self.successGradientLayer!.isHidden = true;
        }
    }
    func configureComponentsAfterBoardGameReset() {
        colorOptions!.loadSelectionButtonsToSelectedButtons();
        // Build board game
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.buildBoardGame();
            self.attackMeter!.startFirstRotation(afterDelay: 1.50);
        }
        // Remove dispersed buttons after they've dispersed
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.colorOptions!.removeSelectedButtons();
            self.successGradientLayer!.isHidden = true;
        }
    }
}

class UIGlovedPointer:UICButton {
    
    var hideForever:Bool = false;
    var darkImage = UIImage(named: "darkGlovePointer.png");
    var lightImage = UIImage(named: "lightGlovePointer.png");
    var darkTapImage = UIImage(named: "darkGloveTap.png");
    var lightTapImage = UIImage(named: "lightGloveTap.png");

    var xTranslation:CGFloat = 0.0;
    var yTranslation:CGFloat = 0.0;
    
    var isTapping = true;
    
    var translateToTapAnimation:UIViewPropertyAnimator?
    var translateFromTapAnimation:UIViewPropertyAnimator?
    
    init(parentView:UIView, frame:CGRect) {
        super.init(parentView: parentView, frame: frame, backgroundColor: UIColor.clear);
        xTranslation = self.originalFrame!.width / 3.5;
        yTranslation = self.originalFrame!.height / 3.5;
        self.layer.borderWidth = 0.0;
        self.alpha = 0.0;
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            if (isTapping) {
                self.setImage(lightTapImage!, for: .normal);
            } else {
                self.setImage(lightImage!, for: .normal);
            }
            self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
        } else {
            if (isTapping) {
                self.setImage(darkTapImage!, for: .normal);
            } else {
                self.setImage(darkImage!, for: .normal);
            }
            self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
        }
    }
    
    func reset() {
        self.alpha = 0.0;
        stopAnimations();
        self.frame = self.originalFrame!;
        self.hideForever = false;
    }
    
    func stopAnimations() {
        translateToTapAnimation?.stopAnimation(true);
        translateFromTapAnimation?.stopAnimation(true);
    }
    
    override func fadeBackgroundIn() {
        self.superview!.bringSubviewToFront(self);
        if (hideForever) {
            return;
        }
        UIView.animate(withDuration: 2.0, delay: 0.125, options: .curveEaseInOut, animations: {
            self.alpha = 1.0;
        }, completion: { _ in
            self.sway();
        })
    }
    
    func setupTranslateFromTapAnimation() {
        translateFromTapAnimation = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: {
            self.frame = CGRect(x: self.frame.minX - self.xTranslation, y: self.frame.minY - self.yTranslation, width: self.frame.width, height: self.frame.height);
        })
        translateFromTapAnimation!.addCompletion({ _ in
            self.setupTranslateToTapAnimation();
            self.translateToTapAnimation!.startAnimation();
        })
    }
    
    func setupTranslateToTapAnimation() {
        translateToTapAnimation = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: {
            self.frame = CGRect(x: self.frame.minX + self.xTranslation, y: self.frame.minY + self.yTranslation, width: self.frame.width, height: self.frame.height);
        })
        translateToTapAnimation!.addCompletion({ _ in
            self.isTapping = true;
            self.setStyle();
            self.sway();
        })
    }
    
    func sway() {
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: { _ in
            self.isTapping = false;
            self.setStyle();
        })
        setupTranslateFromTapAnimation();
        translateFromTapAnimation!.startAnimation(afterDelay: 0.125);
    }
    
    override func translate(newOriginalFrame:CGRect) {
        UIView.animate(withDuration: 0.5, delay: 0.125, options: .curveEaseInOut, animations: {
            self.frame = newOriginalFrame;
            self.configureShrunkFrame();
        });
    }
    
}
