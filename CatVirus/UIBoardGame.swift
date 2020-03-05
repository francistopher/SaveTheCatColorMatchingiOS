//
//  UIBoardGameView.swift
//  suitDatCat
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
        setupLivesMeter();
        setupAttackMeter();
    }
    
    func setupAttackMeter() {
        let attackMeterFrame:CGRect = CGRect(x: 0.0, y: livesMeter!.frame.minY, width: ViewController.staticUnitViewWidth * 7, height: livesMeter!.frame.height);
        attackMeter = UIAttackMeter(parentView:self.superview!, frame: attackMeterFrame, cats: cats);
        UICenterKit.centerHorizontally(childView: attackMeter!, parentRect: attackMeter!.superview!.frame, childRect: attackMeter!.frame);
        attackMeter!.setupComponents();
        attackMeter!.setCompiledStyle();
    }

    func setupLivesMeter() {
        let livesMeterWidth:CGFloat = (((((ViewController.staticUnitViewWidth * 18.0) * 0.8575) / 8.0) * 1.75) + ViewController.staticUnitViewWidth * 0.5) * 0.955;
        let livesMeterX:CGFloat = ((ViewController.staticUnitViewWidth * 18.0) - (livesMeterWidth * 1.025) - ViewController.staticUnitViewWidth);
        let livesMeterFrame:CGRect = CGRect(x: livesMeterX, y: ViewController.staticUnitViewHeight, width: livesMeterWidth, height: ViewController.staticUnitViewWidth * 2.0);
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
        attackMeter!.startFirstRotation(afterDelay:1.5);
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
        self.attackMeter!.disperseCatButton();
        self.attackMeter!.holdVirusOnceAtStart();
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
            print("\(livesMeter!.livesLeft) lives left.")
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
                self.attackMeter!.sendVirusToStartAndHold();
                promote();
                return;
            } else {
                self.attackMeter!.sendVirusToStartAndHold();
                maintain();
                return;
               
            }
        } else {
            self.attackMeter!.updateDuration(change: 0.1);
            self.attackMeter!.sendVirusToStart();
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
            rowGap = self.frame.height * 0.1 / CGFloat(countOfRowsLeft + 2);
            buttonHeight = self.frame.width * 0.90 / CGFloat(countOfRowsLeft + 1);
            for rowIndexOf in Array(indexesOfRowsWithAliveCatsCount.keys).sorted(by:<) {
                resetCatButtonsPosition(rowIndexOf: rowIndexOf);
            }
        }
    }
    
    func revertSelections() {
        livesMeter!.resetLivesLeftCount();
        print("How many lives left!",livesMeter!.livesLeft);
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
        successGradientLayer!.isHidden = false;
        reset(catsSurvived: true);
        configureComponentsAfterBoardGameReset();
    }
    
    func promote(){
        successGradientLayer!.isHidden = false;
        reset(catsSurvived: true);
        colorOptions!.loadSelectionButtonsToSelectedButtons();
        // Build board game
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.currentRound += 1;
            self.buildBoardGame();
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
        }
        // Remove dispersed buttons after they've dispersed
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.colorOptions!.removeSelectedButtons();
            self.successGradientLayer!.isHidden = true;
        }
    }
}

class UIGameStatus:UICLabel {
    
    var displayingRound:Bool = false;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView, frame:CGRect) {
        super.init(parentView: parentView, x: frame.minX, y: frame.minY, width: frame.width, height: frame.height);
        
        self.layer.borderColor = UIColor.black.cgColor;
        self.layer.borderWidth = self.frame.height * 0.03;
        self.layer.cornerRadius = self.frame.height * 0.2;
        
        self.font = UIFont.boldSystemFont(ofSize: self.frame.height * 0.4);
        self.backgroundColor = UIColor.white;
        self.alpha = 0.0;
        
    }
    
    func fadeInAndOut(text:String) {
        displayingRound = true;
        self.text = "\(text)";
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            self.alpha = 1.0;
        }, completion: { _ in
            let finalDelay:Double = 0.4 + (Double(self.text!.count - 4) * 0.4);
            UIView.animate(withDuration: 0.5, delay: finalDelay, options: .curveEaseOut, animations: {
                self.alpha = 0.0;
            }, completion:  { _ in
                self.displayingRound = false;
            })
        })
    }
    
    func fadeIn(text: String) {
        self.text = "\(text)";
        UIView.animate(withDuration: 0.5, delay: 0.125, options: .curveEaseOut, animations: {
            self.alpha = 1.0;
        })
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 0.5, delay: 0.125, options: .curveEaseOut, animations: {
            self.alpha = 0.0;
        })
    }

}

class UILivesMeter:UICView {
    
    var livesLeft:Int = 3;
    var heartInactiveButtons:[UICButton] = [];
    let heartImage:UIImage = UIImage(named: "heart.png")!;
    var heartInactiveButtonXRange:[CGFloat] = [];
    var currentHeartButton:UICButton?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView: UIView, frame:CGRect, backgroundColor: UIColor) {
        super.init(parentView: parentView, x: frame.minX, y: frame.minY, width: frame.width, height: frame.height, backgroundColor: UIColor.clear);
        self.layer.cornerRadius = self.frame.height * 0.5;
        self.layer.borderWidth = self.frame.height / 12.0;
        heartInactiveButtonXRange = [self.layer.borderWidth, self.frame.width * 0.5];
        setupHeartInactiveButtons();
        setStyle();
    }
    
    func setupHeartInactiveButtons() {
        for _ in (heartInactiveButtons.count + 1)...livesLeft {
            if (heartInactiveButtons.count == 0) {
                buildHeartButton(x: heartInactiveButtonXRange[1]);
            } else if (heartInactiveButtons.count == 1) {
                buildHeartButton(x: (heartInactiveButtonXRange[1] * 0.4625) + heartInactiveButtonXRange[0]);
            } else if (heartInactiveButtons.count == 2) {
                buildHeartButton(x: heartInactiveButtonXRange[0]);
            } else {
                buildHeartButton(x: CGFloat.random(in: heartInactiveButtonXRange[0]..<heartInactiveButtonXRange[1] ));
            }
        }
    }
    
    func buildHeartButton(x:CGFloat) {
        currentHeartButton = UICButton(parentView: self, frame: CGRect(x: x, y: 0.0, width: (self.frame.width * 0.5) - (self.layer.borderWidth * 0.5), height: self.frame.height), backgroundColor: UIColor.clear);
        currentHeartButton!.layer.borderWidth = 0.0;
        currentHeartButton!.setImage(heartImage, for: .normal);
        currentHeartButton!.addTarget(self, action: #selector(heartButtonSelector(sender:)), for: .touchUpInside);
        heartInactiveButtons.append(currentHeartButton!);
        currentHeartButton!.alpha = 0.0;
        currentHeartButton!.show();
    }
    
    @objc func heartButtonSelector(sender:UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0.125, options: [.curveEaseInOut], animations: {
            sender.transform = sender.transform.scaledBy(x: 1.25, y: 1.25);
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0.125, options: [.curveEaseInOut], animations: {
                sender.transform = sender.transform.scaledBy(x: 0.8, y: 0.8);
            })
        })
    }
    
    func decrementLivesLeftCount() {
        if (livesLeft > 0) {
            livesLeft -= 1;
            let lastHeartButton:UICButton = heartInactiveButtons.last!;
            heartInactiveButtons.removeLast();
            lastHeartButton.frame = CGRect(x: self.frame.minX + lastHeartButton.frame.minX, y: self.frame.minY + lastHeartButton.frame.minY, width: lastHeartButton.frame.width, height: lastHeartButton.frame.height);
            self.superview!.addSubview(lastHeartButton);
            UIView.animate(withDuration: 3.0, delay: 0.125, options: [.curveEaseInOut], animations: {
                lastHeartButton.transform = lastHeartButton.transform.translatedBy(x: 0.0, y: self.superview!.frame.height);
            }, completion: { _ in
                lastHeartButton.removeFromSuperview();
            })
        }
    }
    
    func incrementLivesLeftCount(catButton:UICatButton) {
        livesLeft += 1;
        // Get spawn frame
        let x:CGFloat = catButton.frame.midX * 0.5 + catButton.superview!.frame.minX;
        let y:CGFloat = catButton.frame.midY * 0.5 + catButton.superview!.frame.minY;
        let newFrame:CGRect = CGRect(x: x, y: y, width: (self.frame.width * 0.5) - (self.layer.borderWidth * 0.5), height: self.frame.height);
        // Setup the heart button
        setupHeartInactiveButtons();
        // Save the target frame and set the new frame
        self.superview!.addSubview(currentHeartButton!);
        let targetFrame = CGRect(x: self.frame.minX + currentHeartButton!.frame.minX, y: self.frame.minY + currentHeartButton!.frame.minY, width: (self.frame.width * 0.5) - (self.layer.borderWidth * 0.5), height: self.frame.height);
        currentHeartButton!.frame = newFrame;
        self.superview!.bringSubviewToFront(currentHeartButton!);
        // Move heart to target frame
        UIView.animate(withDuration: 3.0, delay: 0.125, options: [.curveEaseInOut], animations: {
            self.currentHeartButton!.transform = self.currentHeartButton!.transform.translatedBy(x: targetFrame.minX - newFrame.minX, y: targetFrame.minY - newFrame.minY);
        }, completion: { _ in
            self.addSubview(self.currentHeartButton!);
            self.currentHeartButton!.frame = CGRect(x: self.currentHeartButton!.frame.minX - self.frame.minX, y: self.currentHeartButton!.frame.minY - self.frame.minY, width: (self.frame.width * 0.5) - (self.layer.borderWidth * 0.5), height: self.frame.height)
        })
    }
    
    func resetLivesLeftCount() {
        if (heartInactiveButtons.count > 3) {
            for _ in 3..<heartInactiveButtons.count {
                decrementLivesLeftCount();
            }
        } else if (heartInactiveButtons.count < 3) {
            livesLeft = 3;
            setupHeartInactiveButtons();
        }
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
        self.layer.borderWidth = self.frame.height / 12.0
        self.cats = cats;
    }
    
    func startFirstRotation(afterDelay:Double) {
        if (firstRotationAnimation != nil) {
            if (firstRotationAnimation!.isRunning){
                return;
            }
        }
        displacementDuration = previousDisplacementDuration;
        setupFirstRotationAnimation();
        firstRotationAnimation!.startAnimation(afterDelay: afterDelay);
        currentVirusPhase = .FirstRotation;
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
        if (secondRotationAnimation != nil) {
            if (secondRotationAnimation!.isRunning){
                return;
            }
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
        if (translationToCatAnimation != nil) {
            if (translationToCatAnimation!.isRunning){
                return;
            }
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
        if (sizeExpansionAnimation != nil) {
            if (sizeExpansionAnimation!.isRunning){
                return;
            }
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
            self.attackRandomCatButton();
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
        if (sizeReductionAnimation != nil) {
            if (sizeReductionAnimation!.isRunning){
                return;
            }
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
        if (translationToStartAnimation != nil) {
            if (translationToStartAnimation!.isRunning){
                return;
            }
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
            if (previousDisplacementDuration + change >= 3.5) {
                displacementDuration += change;
                previousDisplacementDuration += change;
            } else {
                displacementDuration = 3.5;
                previousDisplacementDuration = 3.5;
            }
        }
    }
    
    func pauseVirusMovement() {
        switch currentVirusPhase {
        case .FirstRotation:
            firstRotationAnimation!.stopAnimation(true);
            let radians:CGFloat = atan2(virus!.transform.b, virus!.transform.a)
            let degrees:CGFloat = radians * 180 / .pi;
            self.firstRotationDegreeCheckpoint = degrees;
            print("Stopped first rotation animation ", firstRotationDegreeCheckpoint);
        case .SecondRotation:
            secondRotationAnimation!.stopAnimation(true);
            let radians:CGFloat = atan2(virus!.transform.b, virus!.transform.a)
            let degrees:CGFloat = radians * 180 / .pi;
            self.secondRotationDegreeCheckpoint = degrees;
            print("Stopped second rotation animation", secondRotationDegreeCheckpoint);
        case .TranslationToCat:
            translationToCatAnimation!.stopAnimation(true);
            print("Stopped translation to cat animation");
        case .SizeExpansion:
            sizeExpansionAnimation!.stopAnimation(true);
            let grownVirusX:CGFloat = virusXBeforeJump + (virus!.originalFrame!.width * 0.5) - (virus!.frame.width * 0.5);
            virus!.frame = CGRect(x: grownVirusX, y: virus!.frame.minY, width: virus!.frame.width, height: virus!.frame.height);
            print("Stopped size expansion animation")
        case .SizeReduction:
            sizeReductionAnimation!.stopAnimation(true);
            let shrunkVirusX:CGFloat = virusXBeforeUnJump + (virus!.originalFrame!.width * 0.75) - (virus!.frame.width * 0.5);
            virus!.frame = CGRect(x: shrunkVirusX, y: virus!.frame.minY, width: virus!.frame.width, height: virus!.frame.height)
            print("Stopped size reduction animation")
        case .TranslationToStart:
            translationToStartAnimation!.stopAnimation(true);
            print("Stopped translation to start animation");
        default:
            print("Something went wrong?");
        }
    }
    
    func unPauseVirusMovement() {
        switch currentVirusPhase {
        case .FirstRotation:
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
        case .TranslationToStart:
            let delay:Double = Double(0.5 * getVirusToCatDistance() / virusToCatDistance);
            startTranslationToStartAnimation(afterDelay: delay);
        default:
            currentVirusPhase = .TranslationToStart;
            unPauseVirusMovement();
        }
    }
    
    func disperseCatButton() {
        cat!.disperseRadially();
    }
    
    func holdVirusOnceAtStart() {
        holdVirusAtStart = true;
        displacementDuration = 0.5;
        previousDisplacementDuration = 3.5;
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
        if (currentVirusPhase! != .TranslationToStart && currentVirusPhase! == .TranslationToCat) {
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
        setupCat();
        cat!.setCat(named: "SmilingCat", stage: 5);
        self.sendSubviewToBack(cat!);
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
        virus!.setVirusImage();
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

