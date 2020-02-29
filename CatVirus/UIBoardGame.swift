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
    var statistics:UIStatistics?

    var viruses:UIViruses?
    
    var livesMeter:UILivesMeter?
    
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
    }
    
    func buildGridColors(){
        gridColors = Array(repeating: Array(repeating: UIColor.lightGray, count: rowAndColumnNums[1]), count: rowAndColumnNums[0]);
        var rowIndex:Int = 0;
        while (rowIndex < gridColors!.count) {
            var columnIndex:Int = 0;
            while (columnIndex < gridColors![0].count) {
                let randomColor:UIColor = colorOptions!.selectionColors.randomElement()!;
                if (rowIndex > 0) {
                    let previousColumnColor:UIColor = gridColors![rowIndex - 1][columnIndex];
                    if (previousColumnColor.cgColor == randomColor.cgColor) {
                        rowIndex -= 1;
                    }
                }
                if (columnIndex > 0) {
                    let previousRowColor:UIColor = gridColors![rowIndex][columnIndex - 1];
                    if (previousRowColor.cgColor == randomColor.cgColor){
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
        statistics!.finalStage = "\(self.currentRound)";
        statistics!.sessionEndTime = CFAbsoluteTimeGetCurrent();
        statistics!.setSessionDuration();
        statistics!.catsThatDied = cats.presentCollection!.count;
        SoundController.mozartSonata(play: false);
        SoundController.chopinPrelude(play: true);
        colorOptions!.removeBorderOfSelectionButtons();
        // App data of dead cats
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            self.settingsButton!.disable();
            self.reset(catsSurvived: false);
            self.colorOptions!.shrinkColorOptions();
            self.statistics!.update();
            self.statistics!.fadeIn();
        }
    }
    
    @objc func selectCatButton(catButton:UICatButton) {
        interaction(catButton: catButton, catImageButton: catButton.imageContainerButton!);
    }
    
    @objc func selectCatImageButton(catImageButton:UICButton){
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
    
    func setCatButtonAsDead(catButton:UICatButton) {
        gridColorsCount[catButton.originalBackgroundColor.cgColor]! -= 1;
        colorOptions!.buildColorOptionButtons(setup: false);
        catButton.isDead();
        self.superview!.sendSubviewToBack(catButton);
        self.viruses!.translateToCatAndBack(catButton:catButton);
        catButton.disperseRadially();
        displaceArea(ofCatButton: catButton);
        SoundController.kittenDie();
    }
    
    @objc func transitionBackgroundColorOfButtonsToLightGray(){
        if (!colorOptions!.isTransitioned){
            cats.transitionCatButtonBackgroundToLightgrey();
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
                promote();
            } else {
                maintain();
            }
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
        settingsButton!.disable();
        reset(catsSurvived: true);
        configureComponentsAfterBoardGameReset();
    }
    
    func promote(){
        successGradientLayer!.isHidden = false;
        settingsButton!.disable();
        reset(catsSurvived: true);
        colorOptions!.loadSelectionButtonsToSelectedButtons();
        // Build board game
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            self.currentRound += 1;
            self.buildBoardGame();
            self.settingsButton!.enable();
        }
        // Remove selected buttons after they've shrunk
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
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
            self.settingsButton!.enable();
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
            print("Ahhhhhhh")
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

