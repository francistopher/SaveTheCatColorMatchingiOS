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
    
    var opponent:GKPlayer?
    var currentMatch:GKMatch?
    var matchMakerVC:GKMatchmakerViewController?
    
    var opponentResignationTimer:Timer?
    var opponentValuePerSecond:Double = 0.0;
    var myValueCounterPerSecond:Double = 0.0;
    
    var singlePlayerButton:UICButton?
    var twoPlayerButton:UICButton?
    var victoryView:UIVictoryView?
    
    var iWon:Bool = false;
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    // Save number of coins
    var keyValueStore:NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore();
    
    init(parentView: UIView, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) {
        super.init(frame:CGRect(x: x, y: y, width: width, height: height));
        self.backgroundColor = UIColor.clear;
        self.layer.cornerRadius = width / 5.0;
        parentView.addSubview(self);
        self.results = UIResults(parentView: parentView);
        self.results!.continueButton!.addTarget(self, action: #selector(continueSelector), for: .touchUpInside);
        setupVictoryView();
        setupOpponentLiveMeter();
        setupLivesMeter();
        setupAttackMeter();
    }
    
    func setupVictoryView() {
        victoryView = UIVictoryView(parentView: self.superview!, frame: self.frame);
        CenterController.center(childView: victoryView!, parentRect: self.superview!.frame, childRect: victoryView!.frame);
        victoryView!.alpha = 0.0;
    }
    
    func setupAttackMeter() {
        let height:CGFloat = ViewController.staticMainView!.frame.height * ((1.0/300.0) + 0.08);
        var width:CGFloat = ViewController.staticUnitViewWidth * 6.5;
        var y:CGFloat = ViewController.staticUnitViewHeight * 0.925;
        var x:CGFloat = 0.0;
        if (ViewController.aspectRatio! == .ar19point5by9){
            width *= 1.4;
            x = (self.superview!.frame.width - width) * 0.5;
            y = myLiveMeter!.frame.maxY + myLiveMeter!.layer.borderWidth;
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
    
    func setupOpponentLiveMeter() {
        let height:CGFloat = ViewController.staticMainView!.frame.height * ((1.0/300.0) + 0.08);
        let x:CGFloat = ViewController.staticMainView!.frame.width - height - ViewController.staticUnitViewWidth;
        opponentLiveMeter = UILiveMeter(parentView: ViewController.staticMainView!, frame: CGRect(x: x, y: ViewController.staticUnitViewHeight * 0.925, width: height, height: height), isOpponent: true);
        opponentLiveMeter!.alpha = 0.0;
    }

    func setupLivesMeter() {
        myLiveMeter = UILiveMeter(parentView: self.superview!, frame:  CGRect(x: opponentLiveMeter!.frame.minX, y: opponentLiveMeter!.frame.minY, width: opponentLiveMeter!.frame.width, height: opponentLiveMeter!.frame.height), isOpponent: false);
        self.superview!.addSubview(opponentLiveMeter!);
        self.superview!.addSubview(myLiveMeter!);
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
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        if (opponent == nil || opponent != player) {
            return;
        }
        self.opponentValuePerSecond += 0.1;
        let value = data.withUnsafeBytes {
            $0.load(as: UInt16.self);
        }
        if (value != opponentLiveMeter!.livesLeft) {
            print("NEW VALUE: \(value) OLD VALUE:\(opponentLiveMeter!.livesLeft)")
            if (value > opponentLiveMeter!.livesLeft) {
                opponentLiveMeter!.incrementLivesLeftCount(catButton: attackMeter!.cat!, forOpponent: true);
            }
            if (value < opponentLiveMeter!.livesLeft) {
                opponentLiveMeter!.decrementLivesLeftCount();
            }
        }
    }
    
    func gameWon() {
        self.clearBoardGameToDisplayVictoryAnimation();
        // Show victory view
        self.victoryView!.fadeIn();
        self.victoryView!.showVictoryMessageAndGifWith(text: "YOU WIN, CAT SAVER!");
        // Disappear cats and selection colors
        // Stop virus from attacking
        self.attackMeter!.didNotInvokeAttackImpulse = true;
        self.attackMeter!.sendVirusToStartAndHold();
        // Invalidate opponent resignation timer and reset value
        self.stopSearchingForOpponentEntirely();
    }
    
    func hideOpponentLiveMeter() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
            self.opponentLiveMeter!.frame = self.opponentLiveMeter!.originalFrame!;
        }, completion: { _ in
            self.opponentLiveMeter!.resetLivesLeftCount();
        })
    }
    
    func displayOpponentLiveMeter() {
        var x:CGFloat = 0.0;
        var y:CGFloat = 0.0;
        if (ViewController.aspectRatio! == .ar4by3 || ViewController.aspectRatio! == .ar19point5by9) {
            x = self.myLiveMeter!.frame.minX + self.myLiveMeter!.layer.borderWidth - self.myLiveMeter!.frame.width;
            y = self.opponentLiveMeter!.frame.minY;
        } else {
            x = self.opponentLiveMeter!.frame.minX
            y = self.myLiveMeter!.frame.minY - self.myLiveMeter!.layer.borderWidth + self.myLiveMeter!.frame.height;
        }
        UIView.animate(withDuration: 1.0, animations: {
            self.opponentLiveMeter!.frame = CGRect(x: x, y: y, width: self.opponentLiveMeter!.frame.width, height: self.opponentLiveMeter!.frame.height);
        })
    }
    
    func setupMatch(match:GKMatch) {
        self.currentMatch = match;
        match.delegate = self;
        setupOpponent(opponent: match.players[0]);
   }
    
    func setupOpponent(opponent:GKPlayer) {
        self.opponent = opponent;
        self.displayOpponentLiveMeter();
        self.shrinkSinglePlayerAndTwoPlayerButtons();
        self.startGame();
        self.setupOpponentResignationTimer();
        self.attackMeter!.invokeAttackImpulse(delay: 0.0);
    }
    
    func setupOpponentResignationTimer() {
        self.opponentResignationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            print("MESSAGE: Sending value counter")
            self.myValueCounterPerSecond += 0.1;
            var livesInt:UInt16 = UInt16(self.myLiveMeter!.livesLeft);
            let data:Data = Data(bytes: &livesInt, count: MemoryLayout.size(ofValue: livesInt));
            do {
                try self.currentMatch!.send(data, to: [self.opponent!], dataMode: GKMatch.SendDataMode.unreliable);
            } catch {
                print("Error encountered, but we will keep trying!")
            }
            if (self.myValueCounterPerSecond > 1.0) {
                if (self.opponentValuePerSecond == 0.0) {
                    self.opponentResignationTimer!.invalidate();
                    self.opponentResignationTimer = nil;
                    self.gameWon();
                }
                self.myValueCounterPerSecond = 0.0;
                self.opponentValuePerSecond = 0.0;
            }
        })
    }

    func startMatchmaking() {
        if (GKLocalPlayer.local.isAuthenticated && ViewController.staticSelf!.isInternetReachable) {
            // Build match maker
            let matchRequest = GKMatchRequest();
            matchRequest.defaultNumberOfPlayers = 2;
            matchRequest.minPlayers = 2;
            matchRequest.maxPlayers = 2;
            matchMakerVC = GKMatchmakerViewController(matchRequest: matchRequest);
            matchMakerVC!.matchmakerDelegate = ViewController.staticSelf!;
            ViewController.staticSelf!.present(matchMakerVC!, animated: true, completion: nil);
        }
    }
    
    func stopSearchingForOpponentEntirely() {
        ViewController.staticSelf!.dismiss(animated: true, completion: nil);
        currentMatch?.disconnect();
        currentMatch = nil;
        hideOpponentLiveMeter();
        opponentResignationTimer?.invalidate();
        opponentResignationTimer = nil;
        self.opponentValuePerSecond = 0.0;
        self.myValueCounterPerSecond = 0.0;
        opponent = nil;
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
    
    func setupSingleAndTwoPlayerButtons() {
        singlePlayerButton = UICButton(parentView: self.superview!, frame: CGRect(x: self.colorOptions!.frame.minX + self.colorOptions!.frame.width * 0.05, y: self.colorOptions!.frame.minY, width: self.frame.width * 0.425, height: self.colorOptions!.frame.height), backgroundColor: UIColor.clear);
        singlePlayerButton!.setTitle("Single Player", for: .normal);
        singlePlayerButton!.styleBackground = true;
        singlePlayerButton!.setStyle();
        singlePlayerButton!.layer.borderWidth = attackMeter!.layer.borderWidth;
        singlePlayerButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: singlePlayerButton!.frame.height * 0.3);
        singlePlayerButton!.addTarget(self, action: #selector(singlePlayerButtonSelector), for: .touchUpInside);
        singlePlayerButton!.shrinked();
        twoPlayerButton = UICButton(parentView: self.superview!, frame: CGRect(x: self.colorOptions!.frame.minX + self.colorOptions!.frame.width * 0.525, y: self.colorOptions!.frame.minY, width: self.colorOptions!.frame.width * 0.425, height: self.colorOptions!.frame.height), backgroundColor: UIColor.clear);
        twoPlayerButton!.setTitle("Two Player", for: .normal);
        twoPlayerButton!.styleBackground = true;
        twoPlayerButton!.setStyle();
        twoPlayerButton!.layer.borderWidth = attackMeter!.layer.borderWidth;
        twoPlayerButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: twoPlayerButton!.frame.height * 0.3);
        twoPlayerButton!.addTarget(self, action: #selector(twoPlayerButtonSelector), for: .touchUpInside);
        twoPlayerButton!.shrinked();
    }
    
    @objc func singlePlayerButtonSelector() {
        shrinkSinglePlayerAndTwoPlayerButtons();
        startGameWithoutMatchmaking();
    }
    
    @objc func twoPlayerButtonSelector() {
        startMatchmaking();
    }
    
    func growSinglePlayerAndTwoPlayerButtons() {
        self.superview!.addSubview(singlePlayerButton!);
        self.superview!.addSubview(twoPlayerButton!);
        singlePlayerButton!.grow();
        twoPlayerButton!.grow();
    }
    
    func shrinkSinglePlayerAndTwoPlayerButtons() {
        singlePlayerButton!.shrink(colorOptionButton: false);
        twoPlayerButton!.shrink(colorOptionButton: false);
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
    
    func startGameWithoutMatchmaking() {
        attackMeter!.invokeAttackImpulse(delay: 1.0);
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
            if (ViewController.staticSelf!.isInternetReachable) {
                self.keyValueStore.set(UIResults.mouseCoins, forKey: "mouseCoins");
                self.keyValueStore.synchronize();
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
        if (myLiveMeter!.livesLeft - 1 > 0) {
            setCatButtonAsDead(catButton: catButton, disperseDownwardOnly:true);
            myLiveMeter!.decrementLivesLeftCount();
            if (cats.areAllCatsDead()) {
                self.attackMeter!.sendVirusToStart();
                maintain();
            } else {
                verifyThatRemainingCatsArePodded(catButton:catButton);
            }
        } else {
            if (currentMatch != nil) {
                print("MESSAGE: I LOST :(")
                stopSearchingForOpponentEntirely();
            }
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
            ViewController.staticSelf!.settingsButton!.settingsMenu!.mouseCoin!.setMouseCoinValue(newValue: UIResults.mouseCoins - 1);
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
                myLiveMeter!.incrementLivesLeftCount(catButton: catButton, forOpponent: false);
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
            self.buildGame();
            self.growSinglePlayerAndTwoPlayerButtons();
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
    
    func clearBoardGameToDisplayVictoryAnimation() {
        // Pod alive cats and shrink color options
        self.iWon = true;
        SoundController.kittenMeow();
        self.cats.podAliveOnesAndGiveMouseCoin();
        self.promote();
        self.colorOptions!.shrinkColorOptions();
        self.glovePointer!.shrink();
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
           self.currentRound -= 1;
           self.colorOptions!.removeSelectedButtons();
           self.currentRound += 1;
           self.successGradientLayer!.isHidden = true;
        }
    }
    
    func promote(){
        reset(catsSurvived: true);
        colorOptions!.shrinkColorOptions();
        colorOptions!.loadSelectionButtonsToSelectedButtons();
        if (self.iWon) {
            return;
        }
        // Build board game
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            if (self.iWon) {
                return;
            }
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

class UIVictoryView:UICView {
    
    var label:UICLabel?
    var unitHeight:CGFloat = 0.0;
    var imageView:UIImageView?
    var image:UIImage?
    
    init(parentView:UIView, frame:CGRect) {
        super.init(parentView: parentView, x: frame.minX, y: frame.minY, width: frame.width * 0.95, height: frame.height * 0.95, backgroundColor: UIColor.clear);
        self.layer.cornerRadius = frame.width / 5.0;
        self.layer.borderWidth = frame.width * 0.02;
        unitHeight = frame.height * 0.1;
        self.clipsToBounds = true;
        setupLabel();
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabel() {
        label = UICLabel(parentView: self, x: 0.0, y: unitHeight * 7.0, width: frame.width, height: unitHeight * 2.0);
        label!.font = UIFont.boldSystemFont(ofSize: label!.frame.height * 0.4);
    }
    
    func showVictoryMessageAndGifWith(text:String) {
        label!.text = text;
        setupImageView();
    }
    
    func setupImageView() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
            SoundController.cuteLaugh();
        })
        imageView?.removeFromSuperview();
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            imageView = UIImageView(image: UIImage.gifImageWithName("blackBorderGal")!);
        } else {
            imageView = UIImageView(image: UIImage.gifImageWithName("whiteBorderGal")!);
        }
        imageView!.frame =  CGRect(x: 0.0, y: unitHeight, width: unitHeight * 6.0, height: unitHeight * 6.0);
        CenterController.centerHorizontally(childView: imageView!, parentRect: self.frame, childRect: imageView!.frame);
        self.addSubview(imageView!);
    }
    
    func setCompiledStyle() {
        if (self.alpha > 0.0) {
            setupImageView();
        }
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            self.backgroundColor = UIColor.white;
            self.layer.borderColor = UIColor.black.cgColor;
        } else {
            self.backgroundColor = UIColor.black;
            self.layer.borderColor = UIColor.white.cgColor;
        }
    }
    
}
