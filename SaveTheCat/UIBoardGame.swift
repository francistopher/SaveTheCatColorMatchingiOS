//
//  UIBoardGameView.swift
//  SaveTheCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
// (int)

import SwiftUI
import CloudKit
import GameKit

class UIBoardGame: UIView, GKMatchDelegate {
    
    var colorOptions:UIColorOptions? = nil;
    
    var gridColorsCount:[CGColor:Int] = [:]
    var gridColors:[[UIColor]]? = nil;
    
    var currentRound:Int = 1;
    var rowAndColumnNums:[Int] = [];
    
    let cats:UICatButtons = UICatButtons();
    
    var successGradientLayer:CAGradientLayer? = nil;
    
    var settingsButton:UISettingsButton? = nil;
    var myLiveMeter:UILiveMeter?
    var opponentLiveMeter:UILiveMeter?
    var results:UIResults?
    var attackMeter:UIAttackMeter?
    var viruses:UIViruses?
    var timer:Timer?
    
    var glovePointer:UIGlovedPointer?
    var searchMagnifyGlass:UISearchMagnifyGlass?
    
    var opponent:GKPlayer?
    var currentMatch:GKMatch?
    var matchMaker:GKMatchmaker?
    var matchmaking:Bool = false;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    // Save number of coins
    var keyValStore:NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore();
    
    init(parentView: UIView, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) {
        super.init(frame:CGRect(x: x, y: y, width: width, height: height));
        self.backgroundColor = UIColor.clear;
        self.layer.cornerRadius = width / 5.0;
        parentView.addSubview(self);
        self.results = UIResults(parentView: parentView);
        self.results!.continueButton!.addTarget(self, action: #selector(continueSelector), for: .touchUpInside);
        setupLivesMeter();
        setupAttackMeter();
        setupSearchMagnifyGlass();
    }
    
    func setupSearchMagnifyGlass() {
         let size:CGSize = CGSize(width: self.frame.height * 0.25, height: self.frame.width * 0.25);
        searchMagnifyGlass = UISearchMagnifyGlass(parentView: self, frame: CGRect(x: (frame.width - size.width) * 0.5, y: (frame.height - size.height) * 0.5, width: size.width, height: size.height));
    }
    
    func setupAttackMeter() {
        let height:CGFloat = ViewController.staticMainView!.frame.height * ((1.0/300.0) + 0.08);
        var width:CGFloat = ViewController.staticUnitViewWidth * 6.5;
        var y:CGFloat = ViewController.staticUnitViewHeight * 0.925;
        var x:CGFloat = 0.0;
        if (ViewController.aspectRatio! == .ar19point5by9 || ViewController.aspectRatio! == .ar16by9){
            width *= 1.5;
            x = (self.superview!.frame.width - width) * 0.5;
            y = myLiveMeter!.frame.maxY + myLiveMeter!.layer.borderWidth;
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
        let x:CGFloat = ViewController.staticMainView!.frame.width - height - ViewController.staticUnitViewWidth;
        let livesMeterFrame:CGRect = CGRect(x: x, y: ViewController.staticUnitViewHeight * 0.925, width: height, height: height);
        myLiveMeter = UILiveMeter(parentView: self.superview!, frame: livesMeterFrame, isOpponent: false);
    }
    
    @objc func continueSelector() {
        if (settingsButton!.isPressed) {
            settingsButton!.sendActions(for: .touchUpInside);
        }
        glovePointer!.adButton = nil;
        glovePointer!.stopAnimations();
        glovePointer!.isTapping = false;
        glovePointer!.setCompiledStyle();
        glovePointer!.doShrink = false;
        myLiveMeter!.resetLivesLeftCount();
        self.results!.fadeOut();
        results!.catsThatLived = 0;
        results!.catsThatDied = 0;
        SoundController.chopinPrelude(play: false);
        SoundController.mozartSonata(play: true);
        colorOptions!.isTransitioned = false;
        colorOptions!.selectedColor = UIColor.lightGray;
        attackMeter!.resetCat();
        restart();
    }
    
    func fadeIn(){
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseIn, animations: {
            super.alpha = 1.0;
        })
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        
    }
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        
    }
    
    func displayOpponentLiveMeter() {
        let x:CGFloat = self.myLiveMeter!.frame.minX + self.myLiveMeter!.layer.borderWidth - self.myLiveMeter!.frame.width;
        UIView.animate(withDuration: 1.0, animations: {
            self.opponentLiveMeter!.frame = CGRect(x: x, y: self.opponentLiveMeter!.frame.minY, width: self.opponentLiveMeter!.frame.width, height: self.opponentLiveMeter!.frame.height);
        })
    }
    
    func setupOpponentLiveMeter() {
        opponentLiveMeter = UILiveMeter(parentView: ViewController.staticMainView!, frame: CGRect(x: myLiveMeter!.frame.minX, y: myLiveMeter!.frame.minY, width: myLiveMeter!.frame.width, height: myLiveMeter!.frame.height), isOpponent: true);
        opponentLiveMeter!.alpha = 1.0;
        ViewController.staticMainView!.bringSubviewToFront(myLiveMeter!);
    }

    func startMatchmaking() {
        // Hold virus
        self.attackMeter!.sendVirusToStartAndHold();
        // Setup the match request
        let matchRequest = GKMatchRequest();
        matchRequest.minPlayers = 2;
        matchRequest.maxPlayers = 2;
        matchRequest.restrictToAutomatch = true;
        // Start match making
        matchMaker = GKMatchmaker();
        print("MESSAGE: Start finding players for match!")
        matchMaker!.findMatch(for: matchRequest, withCompletionHandler: { (match:GKMatch?, error:Error?) -> Void in
            if (match != nil) {
                print("MESSAGE: We found a match")
                self.currentMatch = match!;
                match!.delegate = self;
                self.searchMagnifyGlass!.stopTransitionAnimation(successful: true);
                self.setupOpponentLiveMeter();
                self.displayOpponentLiveMeter();
                // Start hiding search magnify glass
                self.attackMeter!.holdVirusAtStart = false;
                self.attackMeter!.invokeAttackImpulse(delay: 0.0);
                self.startGame();
            }
        })
    }
    
    func buildGame() {
        results!.catsThatLived += cats.countOfAliveCatButtons();
        rowAndColumnNums = getRowsAndColumns(currentStage: currentRound);
        cats.reset();
        colorOptions!.selectSelectionColors();
        buildGridColors();
        buildGridButtons();
        cats.loadPreviousCats();
        recordGridColorsUsed();
    }
    
    func startGame() {
        colorOptions!.buildColorOptionButtons(setup: true);
        attackMeter!.holdVirusAtStart = false;
        // Set glove pointer
        if (currentRound == 1) {
            glovePointer!.setColorAndCatButtons(colorButtons: colorOptions!.selectionButtons, catButtons: cats, first: true);
            glovePointer!.grow();
        }
    }
    
    func prepareGame(){
        if (GKLocalPlayer.local.isAuthenticated && ViewController.staticViewController!.isInternetReachable) {
            prepareGameWithMatchMaking();
        } else {
            prepareGameWithoutMatchMaking();
        }
    }
    
    func prepareGameWithMatchMaking() {
        buildGame();
        searchMagnifyGlass!.startAnimation();
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.startMatchmaking();
        }
    }
    
    func prepareGameWithoutMatchMaking() {
        attackMeter!.invokeAttackImpulse(delay: 1.0);
        buildGame();
        startGame();
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
        if (!settingsButton!.isPressed) {
            settingsButton!.sendActions(for: .touchUpInside);
        }
        self.attackMeter!.attack = false;
        self.attackMeter!.attackStarted = false;
        if (self.currentRound == 1 && self.results!.catsThatLived > 1) {
            results!.colorMemoryCapacity = 1;
        } else if (self.currentRound == 1) {
            results!.colorMemoryCapacity = 0;
        } else {
            var colorMemoryCapacity:Int = 0;
            let rowsAndColumns:[Int] = getRowsAndColumns(currentStage: currentRound - 1);
            colorMemoryCapacity = rowsAndColumns[0] * rowsAndColumns[1];
            results!.colorMemoryCapacity = colorMemoryCapacity;
        }
        results!.sessionEndTime = CFAbsoluteTimeGetCurrent();
        results!.setSessionDuration();
        SoundController.mozartSonata(play: false);
        SoundController.chopinPrelude(play: true);
        colorOptions!.removeBorderOfSelectionButtons();
        self.myLiveMeter!.removeAllHeartLives();
        self.attackMeter!.disperseCatButton();
        self.attackMeter!.sendVirusToStartAndHold();
        self.attackMeter!.previousDisplacementDuration = 3.5;
        self.glovePointer!.stopAnimations();
        // Prepare glove pointer and
        self.glovePointer!.isTapping = false;
        self.glovePointer!.setCompiledStyle();
        let buttons = self.results!.update();
        if (buttons.count == 1) {
            let button:UICButton = buttons[0];
            self.glovePointer!.adButton = button;
            let buttonSuperview:UIView = button.superview!;
            let buttonSuperview2:UIView = button.superview!.superview!;
            let x:CGFloat = button.frame.minX + buttonSuperview.frame.minX + buttonSuperview2.frame.minX - glovePointer!.originalFrame!.width * 0.35;
            let y:CGFloat = button.frame.minY + buttonSuperview.frame.minY + buttonSuperview2.frame.minY - glovePointer!.originalFrame!.height * 0.2;
            let newFrame:CGRect = CGRect(x: x, y: y, width: glovePointer!.originalFrame!.width, height: glovePointer!.originalFrame!.width);
            self.glovePointer!.translate(newOriginalFrame: newFrame);
            self.glovePointer!.alpha = 1.0;
            Timer.scheduledTimer(withTimeInterval: 1.25, repeats: false, block: { _ in
                self.glovePointer!.sway();
            })
        } else {
            self.glovePointer!.shrink();
        }
        ViewController.submitCatsSavedScore(catsSaved: self.results!.catsThatLived);
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            self.reset(catsSurvived: false);
            self.colorOptions!.shrinkColorOptions();
            // Submit memory capacity score
            ViewController.submitMemoryCapacityScore(memoryCapacity: self.results!.colorMemoryCapacity);
            self.results!.fadeIn();
            // Save coins earned for the use
            if (ViewController.staticViewController!.isInternetReachable) {
                self.keyValStore.set(UIResults.mouseCoins, forKey: "mouseCoins");
                self.keyValStore.synchronize();
            }
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
        if (cats.atLeastOneIsAlive() && colorOptions!.selectedColor.cgColor != UIColor.lightGray.cgColor) {
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
                setCatButtonAsDead(catButton: catButton, disperseDownwardOnly:false);
            }
        }
    }
    
    func attackCatButton(catButton:UICatButton) {
        self.attackMeter!.updateDuration(change: -0.75);
        if (myLiveMeter!.livesLeft > 0) {
            setCatButtonAsDead(catButton: catButton, disperseDownwardOnly:true);
            myLiveMeter!.decrementLivesLeftCount();
            if (cats.areAllCatsDead()) {
                self.attackMeter!.sendVirusToStart();
                maintain();
            } else {
                verifyThatRemainingCatsArePodded(catButton:catButton);
            }
        } else {
            setAllCatButtonsAsDead();
            gameOverTransition();
        }
        
    }
    
    func setCatButtonAsDead(catButton:UICatButton, disperseDownwardOnly:Bool) {
        if (disperseDownwardOnly) {
            looseMouseCoin();
        }
        results!.catsThatDied += 1;
        gridColorsCount[catButton.originalBackgroundColor.cgColor]? -= 1;
        colorOptions!.buildColorOptionButtons(setup: false);
        catButton.isDead();
        self.viruses!.translateToCatAndBack(catButton:catButton);
        catButton.disperseRadially();
        displaceArea(ofCatButton: catButton);
        SoundController.kittenDie();
    }
    
    func looseMouseCoin() {
        let x:CGFloat = settingsButton!.settingsMenu!.frame.minX + settingsButton!.settingsMenu!.mouseCoin!.frame.minX;
        let y:CGFloat = settingsButton!.settingsMenu!.frame.minY + settingsButton!.settingsMenu!.mouseCoin!.frame.minY;
        let width:CGFloat = settingsButton!.settingsMenu!.mouseCoin!.frame.width;
        let height:CGFloat = settingsButton!.settingsMenu!.mouseCoin!.frame.height;
        let mouseCoin:UIMouseCoin = UIMouseCoin(parentView: self.superview!, x: x, y: y, width: width, height: height);
        mouseCoin.isSelectable = false;
        let superViewHeight:CGFloat = self.superview!.frame.height;
        let targetY:CGFloat = CGFloat.random(in: superViewHeight...(superViewHeight + height));
        UIView.animate(withDuration: 2.0, delay: 0.125, options: .curveEaseInOut, animations: {
            mouseCoin.frame = CGRect(x: x, y: targetY, width: width, height: height);
        }, completion: { _ in
            mouseCoin.removeFromSuperview();
        })
        if (UIResults.mouseCoins != 0) {
            UIResults.mouseCoins -= 1;
            settingsButton!.settingsMenu!.mouseCoin!.amountLabel!.text = "\(UIResults.mouseCoins)";
        }
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
            successGradientLayer!.isHidden = false;
            colorOptions!.selectedColor = UIColor.lightGray;
            colorOptions!.isTransitioned = false;
            // Add data of survived cats
            if (cats.didAllSurvive()) {
                myLiveMeter!.incrementLivesLeftCount(catButton: catButton);
                self.attackMeter!.updateDuration(change: 0.1);
                self.attackMeter!.sendVirusToStart();
                self.glovePointer!.shrinked();
                self.glovePointer!.stopAnimations();
                promote();
                return;
            } else {
                self.attackMeter!.sendVirusToStart();
                maintain();
                return;
            }
        } else {
            self.attackMeter!.updateDuration(change: 0.05);
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
        myLiveMeter!.resetLivesLeftCount();
        colorOptions!.selectedColor = UIColor.lightGray;
        cats.shrink();
        currentRound = 1;
        configureComponentsAfterBoardGameReset();
    }
    
    func reset(catsSurvived:Bool){
        if (catsSurvived) {
            cats.disperseVertically()
        }
        gridColors = [[UIColor]]();
        colorOptions!.selectionColors = [UIColor]();
    }
    
    func restart(){
        currentRound = 1
        glovePointer!.shrink();
        colorOptions!.loadSelectionButtonsToSelectedButtons();
        // Build board game
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.prepareGame();
        }
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
        reset(catsSurvived: true);
        self.colorOptions!.shrinkColorOptions();
        colorOptions!.loadSelectionButtonsToSelectedButtons();
        // Build board game
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.buildGame();
            self.startGame();
            self.attackMeter!.startFirstRotation(afterDelay: 1.50);
        }
        configureComponentsAfterBoardGameReset();
    }
    
    func configureComponentsAfterBoardGameReset() {
        // Remove dispersed buttons after they've dispersed
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.colorOptions!.removeSelectedButtons();
            self.successGradientLayer!.isHidden = true;
        }
    }
    
    func promote(){
        reset(catsSurvived: true);
        gridColors = [[UIColor]]();
        colorOptions!.selectionColors = [UIColor]();
        colorOptions!.shrinkColorOptions();
        colorOptions!.loadSelectionButtonsToSelectedButtons();
        // Build board game
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.currentRound += 1;
            self.buildGame();
            self.startGame();
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
}
