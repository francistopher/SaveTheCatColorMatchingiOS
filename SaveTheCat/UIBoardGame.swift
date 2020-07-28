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
    
    var colorOptions:UIColorOptions?
    var gridColorsCount:[CGColor:Int] = [:]
    var gridColors:[[UIColor]]?
    
    var currentRound:Int = 1;
    var rowAndColumnNums:[Int] = [];
    
    let cats:UICatButtons = UICatButtons();
    
    var successGradientLayer:CAGradientLayer?
    
    var settingsButton:UISettingsButton?
    var myLiveMeter:UILiveMeter?
    var opponentLiveMeter:UILiveMeter?
    var results:UIResults?
    var attackMeter:UIAttackMeter?
    var enemies:UIEnemies?
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
    
    var iLost:Bool = false;
    var iWon:Bool = false;
    var catsSavedLabel:UICLabel?
    var catsSavedCount:Int = 0;
    let defaults = UserDefaults.standard;
    
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
        setupVictoryView();
        setupOpponentLiveMeter();
        setupLivesMeter();
        setupAttackMeter();
        setupCatsSavedLabel();
    }
    
    /*
        Creates the cats saved label
        that flashes after a cat is saved
     */
    func setupCatsSavedLabel() {
        catsSavedLabel = UICLabel(parentView: self.superview!, x: self.frame.minX, y: self.frame.minY, width: self.superview!.frame.width, height: self.frame.height);
        CenterController.center(childView: catsSavedLabel!, parentRect: self.superview!.frame, childRect: catsSavedLabel!.frame);
        catsSavedLabel!.font = UIFont.boldSystemFont(ofSize: catsSavedLabel!.frame.height * 0.3);
        catsSavedLabel!.backgroundColor = UIColor.clear;
        catsSavedLabel!.layer.borderColor = UIColor.clear.cgColor;
        catsSavedLabel!.alpha = 0.0;
        ViewController.updateFont(label: catsSavedLabel!);
    }
    
    /*
        Flashes the number of cats
        saved in the current round
     */
    var catsSavedCountTimer:Timer?
    func flashCatsSavedCount() {
        catsSavedLabel!.alpha = 1.0;
        catsSavedCount += 1;
        catsSavedLabel!.text = "\(catsSavedCount)";
        catsSavedCountTimer?.invalidate();
        catsSavedCountTimer = nil;
        self.superview!.bringSubviewToFront(catsSavedLabel!);
        catsSavedCountTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: { _ in
            self.catsSavedLabel!.alpha = 0.0;
        })
    }
    
    /*
        Creates the victory vieew based
        on the aspect ratio of the screen
     */
    func setupVictoryView() {
        var y:CGFloat?
        if (ViewController.aspectRatio! == .ar19point5by9) {
            y = (ViewController.staticMainView!.frame.height * ((1.0/300.0) + 0.08)) + (ViewController.staticUnitViewHeight * 2.9);
        } else {
            y = (ViewController.staticMainView!.frame.height * ((1.0/300.0) + 0.08)) + (ViewController.staticUnitViewHeight * 1.9);
        }
        let frame:CGRect = CGRect(x: 0.0, y: y!, width: self.frame.width * 0.975, height: self.frame.height * 0.975);
        victoryView = UIVictoryView(parentView: self.superview!, frame: frame);
        CenterController.centerHorizontally(childView: victoryView!, parentRect: self.superview!.frame, childRect: victoryView!.frame);
        victoryView!.alpha = 0.0;
    }
    
    /*
        Creates the hairball attack meter
        based on the operating system of the screen
     */
    func setupAttackMeter() {
        let height:CGFloat = ViewController.staticMainView!.frame.height * ((1.0/300.0) + 0.08);
        var width:CGFloat = ViewController.staticUnitViewWidth * 6.5;
        var y:CGFloat = ViewController.staticUnitViewHeight;
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
    
    /*
        Creates the opponent lives meter under
        the players lives meter
     */
    func setupOpponentLiveMeter() {
        let height:CGFloat = ViewController.staticMainView!.frame.height * ((1.0/300.0) + 0.08);
        let x:CGFloat = ViewController.staticMainView!.frame.width - height - ViewController.staticUnitViewWidth;
        opponentLiveMeter = UILiveMeter(parentView: ViewController.staticMainView!, frame: CGRect(x: x, y: ViewController.staticUnitViewHeight, width: height, height: height), isOpponent: true);
        opponentLiveMeter!.alpha = 0.0;
    }

    /*
        Creates the players live meter
     */
    func setupLivesMeter() {
        myLiveMeter = UILiveMeter(parentView: self.superview!, frame:  CGRect(x: opponentLiveMeter!.frame.minX, y: opponentLiveMeter!.frame.minY, width: opponentLiveMeter!.frame.width, height: opponentLiveMeter!.frame.height), isOpponent: false);
        self.superview!.addSubview(opponentLiveMeter!);
        self.superview!.addSubview(myLiveMeter!);
    }
    
    /*
        Resets the number the number of cats saved
        Closes the settings menu, and
        resets attack meter, and resets glove pointer
     */
    func continueSelector() {
        victoryView!.mouseCoin!.alpha = 0.0;
        victoryView!.watchAdButton!.alpha = 0.0;
        results!.adjustRewardAmount();
        iLost = false;
        if (settingsButton!.isPressed) {
            settingsButton!.sendActions(for: .touchUpInside);
        }
        // Reset the glove pointer
        glovePointer!.shrink();
        glovePointer!.adButton = nil;
        glovePointer!.isTapping = false;
        glovePointer!.setCompiledStyle();
        glovePointer!.doShrink = false;
        // Reset cats saved results
        myLiveMeter!.resetLivesLeftCount();
        self.results!.fadeOut();
        results!.catsThatLived = 0;
        results!.catsThatDied = 0;
        // Update song playing
        SoundController.chopinPrelude(play: false);
        if (!(SoundController.mozartSonataSoundEffect!.volume > 0.0)) {
            SoundController.mozartSonata(play: true, startOver: true);
        }
        if (attackMeter!.cat!.frame != attackMeter!.cat!.originalFrame!) {
            attackMeter!.resetCat();
        }
        results!.watchAdButton!.isUserInteractionEnabled = true;
        results!.watchAdButton!.titleLabel!.alpha = 1.0;
        results!.mouseCoin!.alpha = 1.0;
    }
    
    /*
        Make the board game opaque over time
     */
    func fadeIn(){
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseIn, animations: {
            super.alpha = 1.0;
        })
    }
    
    /*
        Receives values about the current multiplayer match
     */
    var value:UInt16?
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        // Display the oponent's name
        if (UIGameMessage.opponent == "") {
            UIGameMessage.opponent = player.displayName
            ViewController.staticSelf!.gameMessage!.displayOpponent()
        }
        // Unpack value
        value = data.withUnsafeBytes {
            $0.load(as: UInt16.self);
        }
        // Win game
        if (value == 65535) {
            gameWon();
        }
        self.opponentValuePerSecond += 0.1;
        if (opponent == nil || opponent != player) {
            return;
        }
        // Increase/Decrease player/opponent lives meter
        if (value! != opponentLiveMeter!.livesLeft) {
            if (value! > opponentLiveMeter!.livesLeft) {
                opponentLiveMeter!.incrementLivesLeftCount(catButton: attackMeter!.cat!, forOpponent: true);
            }
            if (value! < opponentLiveMeter!.livesLeft) {
                opponentLiveMeter!.decrementLivesLeftCount();
            }
        }
    }
    
    /*
        Display the victory view and success label
     */
    func gameWon() {
        ViewController.staticSelf!.gameMessage!.displayIWonAgainstOpponent()
        if (!iLost) {
            // Disappear cats and selection colors
            self.victoryView!.awardAmount = abs(results!.catsThatLived - results!.catsThatDied);
            self.clearBoardGameToDisplayVictoryAnimation();
            // Show victory view
            self.victoryView!.fadeIn();
            self.victoryView!.showVictoryMessageAndGiveMouseCoins(catsSaved: results!.catsThatLived, catsDied: results!.catsThatDied);
            self.results!.catsThatLived = 0;
            self.results!.catsThatDied = 0;
            // Stop enemy from attacking
            self.attackMeter!.didNotInvokeAttackImpulse = true;
            self.attackMeter!.sendEnemyToStartAndHold();
            // Invalidate opponent resignation timer and reset value
            self.stopSearchingForOpponentEntirely();
            // Show single and two player
            self.showSingleAndTwoPlayerButtons();
            // Translate glove pointer to victory view
            self.glovePointer!.adButton = victoryView!.watchAdButton!;
            let buttonSuperview:UIView = victoryView!;
            let x:CGFloat = self.glovePointer!.adButton!.frame.minX + buttonSuperview.frame.minX + -(glovePointer!.originalFrame!.width * 0.25);
            let y:CGFloat = self.glovePointer!.adButton!.frame.minY + buttonSuperview.frame.minY + glovePointer!.originalFrame!.height * 0.05;
            let newFrame:CGRect = CGRect(x: x, y: y, width: glovePointer!.originalFrame!.width * 0.9, height: glovePointer!.originalFrame!.width * 0.9);
            self.glovePointer!.translate(newOriginalFrame: newFrame);
            self.glovePointer!.alpha = 1.0;
            Timer.scheduledTimer(withTimeInterval: 1.25, repeats: false, block: { _ in
                self.glovePointer!.sway();
            })
        }
    }
    
    /*
        Slides the opponent live meter beneath the players
     */
    func hideOpponentLiveMeter() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
            self.opponentLiveMeter!.frame = self.opponentLiveMeter!.originalFrame!;
        }, completion: { _ in
            self.opponentLiveMeter!.resetLivesLeftCount();
        })
    }
    
    /*
        Slides open the opponent live meter from the players
     */
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
    
    /*
        Creates the match
     */
    func setupMatch(match:GKMatch) {
        self.currentMatch = match;
        match.delegate = self;
        setupOpponent(opponent: match.players[0]);
   }
    
    /*
        Saves the opponent and starts the game
     */
    func setupOpponent(opponent:GKPlayer) {
        self.opponent = opponent;
        self.displayOpponentLiveMeter();
        self.startGame();
        self.setupOpponentResignationTimer();
        self.twoPlayerButtonSelector(noMatchMaking: true);
    }
    
    /*
        Timer that listens to the opponent
        and idetifies when they close the game
     */
    var data:Data?
    func setupOpponentResignationTimer() {
        self.opponentResignationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            self.myValueCounterPerSecond += 0.1;
            var livesInt:UInt16 = UInt16(self.myLiveMeter!.livesLeft);
            self.data = nil;
            self.data = Data(bytes: &livesInt, count: MemoryLayout.size(ofValue: livesInt));
            do {
                try self.currentMatch!.send(self.data!, to: [self.opponent!], dataMode: GKMatch.SendDataMode.unreliable);
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

    /*
        Starts the matchmaking process
        Displays the matchmaking view controller
     */
    var matchRequest:GKMatchRequest?
    func startMatchmaking() {
        // If Game Center's remote services are accessible, display matchmaking view controller
        if (GKLocalPlayer.local.isAuthenticated && ViewController.staticSelf!.isInternetReachable) {
            // Request match
            if (matchRequest == nil) {
                matchRequest = GKMatchRequest();
                matchRequest!.defaultNumberOfPlayers = 2;
                matchRequest!.minPlayers = 2;
                matchRequest!.maxPlayers = 2;
            }
            // Display the matchmaking view controller
            if (matchMakerVC == nil) {
                matchMakerVC = GKMatchmakerViewController(matchRequest: matchRequest!);
                matchMakerVC!.matchmakerDelegate = ViewController.staticSelf!;
            }
            ViewController.staticSelf!.present(matchMakerVC!, animated: true, completion: nil);
        } else {
            // Display message of internet/game center authentication mishap
            if (!GKLocalPlayer.local.isAuthenticated) {
                ViewController.staticSelf!.gameMessage!.addToMessageQueue(message: .noGameCenter);
            }
            if (!ViewController.staticSelf!.isInternetReachable) {
                ViewController.staticSelf!.gameMessage!.addToMessageQueue(message: .noInternet);
            }
        }
    }
    
    /*
        Cancel match maker view, and reset opponent
     */
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
    
    /*
        Build the components of the board game
     */
    func buildGame() {
        if (self.subviews.count == 0) {
            results!.catsThatLived += cats.countOfAliveCatButtons();
            rowAndColumnNums = getRowsAndColumns(currentStage: currentRound);
            cats.reset();
            colorOptions!.selectSelectionColors();
            buildGridColors();
            buildGridButtons();
            cats.loadPreviousCats();
            recordGridColorsUsed();
        }
    }
    
    /*
        Creates the single and two player buttons
     */
    func setupSingleAndTwoPlayerButtons() {
        singlePlayerButton = UICButton(parentView: self.superview!, frame: CGRect(x: self.colorOptions!.frame.minX + self.colorOptions!.frame.width * 0.05, y: self.colorOptions!.frame.minY + self.colorOptions!.frame.height * 0.1, width: self.frame.width * 0.425, height: self.colorOptions!.frame.height * 0.8), backgroundColor: UIColor.clear);
        singlePlayerButton!.setTitle("Single Player", for: .normal);
        singlePlayerButton!.styleBackground = true;
        singlePlayerButton!.setStyle();
        singlePlayerButton!.layer.borderWidth = attackMeter!.layer.borderWidth;
        singlePlayerButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: singlePlayerButton!.frame.height * 0.35);
        singlePlayerButton!.addTarget(self, action: #selector(singlePlayerButtonSelector), for: .touchUpInside);
        singlePlayerButton!.shrinked();
        singlePlayerButton!.alpha = 0.0;
        ViewController.updateFont(button: singlePlayerButton!);
        twoPlayerButton = UICButton(parentView: self.superview!, frame: CGRect(x: self.colorOptions!.frame.minX + self.colorOptions!.frame.width * 0.525, y: self.colorOptions!.frame.minY + self.colorOptions!.frame.height * 0.1, width: self.colorOptions!.frame.width * 0.425, height: self.colorOptions!.frame.height * 0.8), backgroundColor: UIColor.clear);
        twoPlayerButton!.setTitle("Multi Player", for: .normal);
        twoPlayerButton!.styleBackground = true;
        twoPlayerButton!.setStyle();
        twoPlayerButton!.layer.borderWidth = attackMeter!.layer.borderWidth;
        twoPlayerButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: twoPlayerButton!.frame.height * 0.35);
        twoPlayerButton!.addTarget(self, action: #selector(twoPlayerButtonSelector), for: .touchUpInside);
        twoPlayerButton!.shrinked();
        twoPlayerButton!.alpha = 0.0;
        ViewController.updateFont(button: twoPlayerButton!);
    }
    
    /*
        Starts the single player game
     */
    var colorOption:UICButton?
    @objc func singlePlayerButtonSelector() {
        if (singlePlayerButton!.notSelectable) {
            return;
        }
        // Closes the settings menu
        if (settingsButton!.isPressed) {
            settingsButton!.sendActions(for: .touchUpInside);
        }
        /*
            Hides the victory view/ game over view
         */
        singlePlayerButton!.notSelectable = true;
        if (self.victoryView!.alpha > 0.0) {
            self.cats.resumeCatAnimations();
            self.iWon = false;
            self.victoryView!.fadeOut();
            self.myLiveMeter!.resetLivesLeftCount();
            self.fadeIn();
        }
        if (self.results!.alpha > 0.0) {
            self.cats.resumeCatAnimations();
            continueSelector();
            self.fadeIn();
        }
        startGame();
        // Hide the single and multiplayer button
        twoPlayerButton!.shrink(colorOptionButton: false);
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseOut, animations: {
            self.colorOption = self.colorOptions!.selectionButtons![0];
            self.singlePlayerButton!.frame = CGRect(x: self.colorOptions!.frame.minX + self.colorOption!.frame.minX, y: self.colorOptions!.frame.minY + self.colorOption!.frame.minY, width: self.colorOption!.frame.width, height: self.colorOption!.frame.height);
            self.singlePlayerButton!.backgroundColor = self.colorOption!.backgroundColor!;
        }, completion: { _ in
            self.attackMeter!.invokeAttackImpulse(delay: 0.0);
            UIView.animate(withDuration: 0.75, delay: 0.125, options: .curveEaseOut, animations: {
                self.singlePlayerButton!.alpha = 0.0;
                self.twoPlayerButton!.alpha = 0.0;
            }, completion: { _ in
                self.singlePlayerButton!.frame = self.singlePlayerButton!.originalFrame!;
                self.singlePlayerButton!.shrinked();
                self.singlePlayerButton!.backgroundColor = self.singlePlayerButton!.originalBackgroundColor!;
                self.singlePlayerButton!.setStyle();
                self.singlePlayerButton!.notSelectable = false;
            })
        })
    }
    
    /*
        Start the matchmaking client for the
        multiplayer match
     */
    @objc func twoPlayerButtonSelector(noMatchMaking:Bool) {
        if (noMatchMaking) {
            if (twoPlayerButton!.notSelectable) {
                return;
            }
            if (settingsButton!.isPressed) {
                settingsButton!.sendActions(for: .touchUpInside);
            }
            // Hides the game won/ game lost view
            twoPlayerButton!.notSelectable = true;
            if (self.results!.alpha >= 0.0) {
                continueSelector();
                self.fadeIn();
            }
            if (self.victoryView!.alpha > 0.0) {
                self.iWon = false;
                self.victoryView!.fadeOut();
                self.myLiveMeter!.resetLivesLeftCount();
                self.fadeIn();
            }
            // Hide both the single player and multiplayer button
            twoPlayerButton!.notSelectable = true;
            singlePlayerButton!.shrink(colorOptionButton: false);
            self.attackMeter!.invokeAttackImpulse(delay: 0.75);
            UIView.animate(withDuration: 0.75 , delay: 0.25, options: .curveEaseOut, animations: {
                self.colorOption = self.colorOptions!.selectionButtons![0];
                self.twoPlayerButton!.frame = CGRect(x: self.colorOptions!.frame.minX + self.colorOption!.frame.minX, y: self.colorOptions!.frame.minY + self.colorOption!.frame.minY, width: self.colorOption!.frame.width, height: self.colorOption!.frame.height);
                self.twoPlayerButton!.backgroundColor = self.colorOption!.backgroundColor!;
            }, completion: { _ in
                UIView.animate(withDuration: 0.75, delay: 0.25, options: .curveEaseOut, animations: {
                    self.twoPlayerButton!.alpha = 0.0;
                }, completion: { _ in
                    self.twoPlayerButton!.frame = self.twoPlayerButton!.originalFrame!;
                    self.twoPlayerButton!.shrinked();
                    self.twoPlayerButton!.backgroundColor = self.twoPlayerButton!.originalBackgroundColor!;
                    self.twoPlayerButton!.setStyle();
                    self.twoPlayerButton!.notSelectable = false;
                })
            })
        } else {
            startMatchmaking();
        }
    }
    
    func showSingleAndTwoPlayerButtons() {
        self.superview!.addSubview(singlePlayerButton!);
        self.superview!.addSubview(twoPlayerButton!);
        singlePlayerButton!.show();
        singlePlayerButton!.grow();
        twoPlayerButton!.show();
        twoPlayerButton!.grow();
    }
    
    func startGame() {
        colorOptions!.buildColorOptionButtons(setup: true);
        attackMeter!.holdEnemyAtStartAndHold = false;
        // Set glove pointer
        if (currentRound == 1) {
            glovePointer!.setColorAndCatButtons(colorButtons: colorOptions!.selectionButtons!, catButtons: cats);
            glovePointer!.grow();
        }
    }
   
    var gridColorRowIndex:Int?
    var gridColorColumnIndex:Int?
    var gridRandomColor:UIColor?
    var previousGridColumnColor:UIColor?
    var previousGridRowColor:UIColor?
    
    /*
        Builds the grid colors of the current round
     */
    func buildGridColors(){
        gridColors = Array(repeating: Array(repeating: UIColor.lightGray, count: rowAndColumnNums[1]), count: rowAndColumnNums[0]);
        gridColorRowIndex = 0;
        // Iterates through each row
        while (gridColorRowIndex! < gridColors!.count) {
            gridColorColumnIndex = 0;
            // Iterates through each column
            while (gridColorColumnIndex! < gridColors![0].count) {
                gridRandomColor = colorOptions!.selectionColors!.randomElement()!;
                // If the previous row, same column has the same color, repeat the random selection
                if (gridColorRowIndex! > 0) {
                    previousGridColumnColor = gridColors![gridColorRowIndex! - 1][gridColorColumnIndex!];
                    if (previousGridColumnColor!.cgColor == gridRandomColor!.cgColor) {
                        gridColorRowIndex! -= 1;
                    }
                }
                // If the previous column, same row has the same color, repeat the random seleciton, randomly
                if (gridColorColumnIndex! > 0) {
                    previousGridRowColor = gridColors![gridColorRowIndex!][gridColorColumnIndex! - 1];
                    if (previousGridRowColor!.cgColor == gridRandomColor!.cgColor && Int.random(in: 0...2) > 1){
                        gridColorColumnIndex! -= 1;
                    }
                }
                gridColors![gridColorRowIndex!][gridColorColumnIndex!] = gridRandomColor!;
                gridColorColumnIndex! += 1;
            }
            gridColorRowIndex! += 1;
        }
    }
    
    /*
        Returns the count of colors that haven't been clearned
     */
    func nonZeroGridColorsCount() -> Int {
        var nonZeroCount:Int = 0;
        for (_, count) in gridColorsCount {
            if (count != 0) {
                nonZeroCount += 1;
            }
        }
        return nonZeroCount;
    }
    
    /*
        Saves a record of the grid colors used
        in the game
     */
    var recordedColor:CGColor?
    func recordGridColorsUsed(){
        gridColorsCount = [:];
        for catButton in cats.presentCollection! {
            recordedColor = catButton.originalBackgroundColor.cgColor;
            if (gridColorsCount[recordedColor!] == nil) {
                gridColorsCount[recordedColor!] = 1;
            } else {
                gridColorsCount[recordedColor!]! += 1;
            }
        }
    }
    
    /*
        Returns the rows and columns
        given the current stage of the game
     */
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
    
    /*
        Plots the buttons in a grid
     */
    var gridButtonRowGap:CGFloat?
    var gridButtonColumnGap:CGFloat?
    var gridButtonHeight:CGFloat?
    var gridButtonWidth:CGFloat?
    var gridButtonX:CGFloat?
    var gridButtonY:CGFloat?
    var gridCatButton:UICatButton?
    func buildGridButtons(){
        gridButtonRowGap = self.frame.height * 0.1 / CGFloat(rowAndColumnNums[0] + 1);
        gridButtonColumnGap = self.frame.width * 0.1 / CGFloat(rowAndColumnNums[1] + 1);
        // Sizes
        gridButtonHeight = self.frame.width * 0.90 / CGFloat(rowAndColumnNums[0]);
        gridButtonWidth = self.frame.height * 0.90 / CGFloat(rowAndColumnNums[1]);
        // Points
        gridButtonX = 0.0;
        gridButtonY = 0.0;
        // Iterate through the rows
        for rowIndex in 0..<rowAndColumnNums[0] {
            gridButtonY! += gridButtonRowGap!;
            gridButtonX = 0.0;
            // Iterate through the columns
            for columnIndex in 0..<rowAndColumnNums[1] {
                gridButtonX! += gridButtonColumnGap!;
                gridCatButton = cats.buildCatButton(parent: self, frame: CGRect(x: gridButtonX!, y: gridButtonY!, width: gridButtonWidth!, height: gridButtonHeight!), backgroundColor: gridColors![rowIndex][columnIndex]);
                gridCatButton!.rowIndex = rowIndex;
                gridCatButton!.columnIndex = columnIndex;
                gridCatButton!.imageContainerButton!.backgroundColor = UIColor.clear;
                gridCatButton!.imageContainerButton!.addTarget(self, action: #selector(selectCatImageButton), for: .touchUpInside);
                gridCatButton!.addTarget(self, action: #selector(selectCatButton), for: .touchUpInside);
                gridButtonX! += gridButtonWidth!;
            }
            gridButtonY! += gridButtonHeight!;
        }
    }
    
    /*
        Displays the game over view
        and shows, up-to-date stats
     */
    var iLostUpdateResult:(UICButton, UIMouseCoin)?
    var iLostWatchAdButton:UICButton?
    var iLostMouseCoinButton:UIMouseCoin?
    var iLostButtonSuperView:UIView?
    var iLostButtonSuperView2:UIView?
    var iLostX:CGFloat?
    var iLostY:CGFloat?
    var newHighScore:Bool = false;
    func gameOverTransition() {
        // Flash cats saved count last time
        for _ in 0...cats.count() {
            looseMouseCoin();
        }
        catsSavedCount = results!.catsThatLived - 1;
        flashCatsSavedCount();
        results!.update();
        if (!settingsButton!.isPressed) {
            settingsButton!.sendActions(for: .touchUpInside);
        }
        self.attackMeter!.attack = false;
        self.attackMeter!.attackStarted = false;
        SoundController.mozartSonata(play: false, startOver: false);
        SoundController.chopinPrelude(play: true);
        colorOptions!.removeBorderOfSelectionButtons();
        self.myLiveMeter!.removeAllHeartLives();
        self.attackMeter!.disperseCatButton();
        self.attackMeter!.sendEnemyToStartAndHold();
        self.attackMeter!.previousDisplacementDuration = 3.5;
        self.glovePointer!.stopAnimations();
        // Prepare glove pointer and
        self.glovePointer!.isTapping = false;
        self.glovePointer!.setCompiledStyle();
        // Show glove, watch ad button, and mouse coin
        if (iLostUpdateResult == nil) {
            iLostWatchAdButton = results!.watchAdButton!;
            iLostMouseCoinButton = results!.mouseCoin!;
        }
        self.glovePointer!.adButton = iLostWatchAdButton!;
        if (iLostButtonSuperView == nil) {
            iLostButtonSuperView = iLostWatchAdButton!.superview!;
            iLostButtonSuperView2 = iLostWatchAdButton!.superview!.superview!;
            iLostX = iLostWatchAdButton!.frame.minX + iLostButtonSuperView!.frame.minX + iLostButtonSuperView2!.frame.minX - glovePointer!.originalFrame!.width * 0.35;
            iLostY = iLostWatchAdButton!.frame.minY + iLostButtonSuperView!.frame.minY + iLostButtonSuperView2!.frame.minY - glovePointer!.originalFrame!.height * 0.175;
        }
        self.glovePointer!.translate(newOriginalFrame: CGRect(x: iLostX!, y: iLostY!, width: glovePointer!.originalFrame!.width * 0.9, height: glovePointer!.originalFrame!.width * 0.9));
        self.glovePointer!.alpha = 1.0;
        Timer.scheduledTimer(withTimeInterval: 1.25, repeats: false, block: { _ in
            self.glovePointer!.sway();
        })

        // Housekeeping
        self.reset(catsSurvived: false);
        self.colorOptions!.shrinkColorOptions();
        // Reset color option properties
        self.colorOptions!.isTransitioned = false;
        self.colorOptions!.selectedColor = UIColor.lightGray;
        // Hide board game and restart
        self.alpha = 0.0;
        self.restart();
        ViewController.submitCatsSavedScore(catsSaved: self.results!.catsThatLived);
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            // Store the highest singular score
            if (ViewController.singleGameHighScore < Int64(self.results!.catsThatLived)) {
                if (ViewController.staticSelf!.isInternetReachable) {
                    print("New Hight Score! \(self.results!.catsThatLived)")
                    SoundController.animeWow();
                    self.newHighScore = true;
                }
            }
            // Submit memory capacity score
            self.results!.fadeIn();
            self.results!.showHighScore(new: self.newHighScore);
            self.newHighScore = false;
            // Save coins earned for the use
            if (ViewController.staticSelf!.isInternetReachable) {
                self.keyValueStore.set(UIResults.mouseCoins, forKey: "mouseCoins");
                self.keyValueStore.synchronize();
            }
            ViewController.settingsButton!.settingsMenu!.mouseCoin!.sendActions(for: .touchUpInside);
        }
        self.catsSavedCount = 0;
    }
    
    @objc func selectCatButton(catButton:UICatButton) {
        if (self.attackMeter!.attackStarted){
            return;
        }
        interaction(catButton: catButton, catImageButton: catButton.imageContainerButton!);
    }
    
    var catButton:UICatButton?
    @objc func selectCatImageButton(catImageButton:UICButton){
        if (self.attackMeter!.attackStarted){
            return;
        }
        catButton = (catImageButton.superview! as! UICatButton);
        interaction(catButton: catButton!, catImageButton: catImageButton);
    }
    
    @objc func interaction(catButton:UICatButton, catImageButton:UICButton){
        // Selection of a color option is made after fresh new round
        if (cats.atLeastOneIsAlive() && colorOptions!.selectedColor.cgColor != UIColor.lightGray.cgColor) {
            // Correct matching grid button color and selection color
            if (catButton.backgroundCGColor! == colorOptions!.selectedColor.cgColor){
                if (!catButton.isPodded) {
                    // Save the cat and record cat
                    gridColorsCount[catButton.backgroundCGColor!]! -= 1;
                    colorOptions!.buildColorOptionButtons(setup: false);
                    catButton.pod();
                    catButton.isPodded = true;
                    catButton.giveMouseCoin(withNoise: true);
                    verifyThatRemainingCatsArePodded(catButton:catButton);
                    self.flashCatsSavedCount();
                }
            } else {
                // Kill cat
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
                setCatButtonAsDead(catButton: catButton, singleDeath:false);
            }
        }
        
    }
    
    /*
        Kills the cat button, and sends death count
        to the multiplayer channel if player is
        in a match
     */
    func attackCatButton(catButton:UICatButton) {
        self.attackMeter!.updateDuration(change: -0.75);
        // Updates the lives left meter of the player
        if (myLiveMeter!.livesLeft - 1 > 0) {
            setCatButtonAsDead(catButton: catButton, singleDeath:false);
            myLiveMeter!.decrementLivesLeftCount();
            if (cats.areAllCatsDead()) {
                self.attackMeter!.sendEnemyToStart();
                maintain();
            } else {
                verifyThatRemainingCatsArePodded(catButton:catButton);
            }
        } else {
            // Sends a signal to the multiplayer channel that they have lost
            if (currentMatch != nil) {
                ViewController.staticSelf!.gameMessage!.displayILostAgainstOpponent()
                var livesInt:UInt16 = UInt16(65535);
                data = Data(bytes: &livesInt, count: MemoryLayout.size(ofValue: livesInt));
                do {
                    try self.currentMatch!.send(data!, to: [self.opponent!], dataMode: GKMatch.SendDataMode.unreliable);
                } catch {
                    print("Error encountered, but we will keep trying!")
                }
                stopSearchingForOpponentEntirely();
            }
            iLost = true;
            setAllCatButtonsAsDead();
            gameOverTransition();
        }
        
    }
    
    /*
        Kill the cat button, record data,
        update colors count, and disperse
        the cat button radially
     */
    func setCatButtonAsDead(catButton:UICatButton, singleDeath:Bool) {
        if (!iLost) {
            looseMouseCoin();
        }
        results!.catsThatDied += 1;
        gridColorsCount[catButton.originalBackgroundColor.cgColor]? -= 1;
        colorOptions!.buildColorOptionButtons(setup: false);
        catButton.isDead()
        self.enemies!.translateToCatAndBack(catButton:catButton);
        catButton.disperseRadially();
        displaceArea(ofCatButton: catButton);
        SoundController.kittenDie();
    }
    
    /*
        Strips a mouse coin from the player
     */
    var mouseCoinLossX:CGFloat?
    var mouseCoinLossY:CGFloat?
    var mouseCoinLossSideLength:CGFloat?
    var mouseCoinLoss:UIMouseCoin?
     var mouseCoinLossTargetX:CGFloat?
    var mouseCoinLossTargetY:CGFloat?
    var mouseCoinXRange:[CGFloat] = [];
    func looseMouseCoin() {
        // If the there is an internet connection
        if (ViewController.staticSelf!.isInternetReachable && GKLocalPlayer.local.isAuthenticated && ViewController.staticSelf!.isiCloudReachable) {
            mouseCoinLossX = settingsButton!.settingsMenu!.frame.minX + settingsButton!.settingsMenu!.mouseCoin!.frame.minX;
            mouseCoinLossY = settingsButton!.settingsMenu!.frame.minY + settingsButton!.settingsMenu!.mouseCoin!.frame.minY;
            mouseCoinLossSideLength = settingsButton!.settingsMenu!.mouseCoin!.frame.width;
            // Determines how many mouse coins were lost
            if (mouseCoinXRange.count < 3) {
                mouseCoinXRange.append(settingsButton!.settingsMenu!.frame.minX + settingsButton!.settingsMenu!.mouseCoin!.frame.minX);
                mouseCoinXRange.append(superview!.frame.width);
            }
            mouseCoinLoss = UIMouseCoin(parentView: self.superview!, x: mouseCoinLossX!, y: mouseCoinLossY!, width: mouseCoinLossSideLength!, height: mouseCoinLossSideLength!);
            mouseCoinLoss!.isSelectable = false;
            // Sets mouse coin translation target
            if (Int.random(in: 0...1) > 0) {
                mouseCoinLossTargetX = CGFloat.random(in: mouseCoinXRange[0]...mouseCoinXRange[1]);
                mouseCoinLossTargetY = superview!.frame.height
            } else {
                mouseCoinLossTargetX = CGFloat.random(in: mouseCoinXRange[0]...(mouseCoinXRange[1] * 0.5));
                mouseCoinLossTargetY = superview!.frame.height
            }
            // Translates the mouse coins to their target
            UIView.animate(withDuration: 2.0, delay: 0.125, options: .curveLinear, animations: {
                self.mouseCoinLoss!.frame = CGRect(x: self.mouseCoinLossTargetX!, y: self.mouseCoinLossTargetY!, width: self.mouseCoinLossSideLength!, height: self.mouseCoinLossSideLength!);
            }, completion: { _ in
                self.mouseCoinLoss!.removeFromSuperview();
            })
            // Update mouse coin count
            if (UIResults.mouseCoins != 0) {
                ViewController.staticSelf!.settingsButton!.settingsMenu!.mouseCoin!.setMouseCoinValue(newValue: UIResults.mouseCoins - 1);
            }
        }
    }
    
    @objc func transitionBackgroundColorOfButtonsToClear(){
        if (!colorOptions!.isTransitioned){
            cats.transitionCatButtonBackgroundToClear();
            colorOptions!.isTransitioned = true;
        }
    }
    
    /*
        Verifies that the remaining cats are saved, or not, or dead
     */
    func verifyThatRemainingCatsArePodded(catButton:UICatButton) {
        // Check if all the cats have been podded
        if (cats.aliveCatsArePodded()) {
            SoundController.heaven();
            successGradientLayer!.isHidden = false;
            colorOptions!.selectedColor = UIColor.lightGray;
            colorOptions!.isTransitioned = false;
            // Add data of survived cats
            if (cats.didAllSurvive()) {
                // All cats were saved
                myLiveMeter!.incrementLivesLeftCount(catButton: catButton, forOpponent: false);
                self.attackMeter!.updateDuration(change: 0.075);
                self.attackMeter!.sendEnemyToStart();
                self.glovePointer!.shrinked();
                self.glovePointer!.stopAnimations();
                promote();
                return;
            } else {
                // Some were saved
                self.attackMeter!.sendEnemyToStart();
                maintain();
                return;
            }
        } else {
            // None was saved
            self.attackMeter!.updateDuration(change: 0.025);
            self.attackMeter!.sendEnemyToStart();
            self.attackMeter!.startFirstRotation(afterDelay: 1.0);
        }
    }
    
    /*
        Fills in the gaps produced by cat buttons
        that have perished
     */
    var rowOfAliveCats:[UICatButton]?
    func displaceArea(ofCatButton:UICatButton) {
        rowOfAliveCats = cats.getRowOfAliveCats(rowIndex: ofCatButton.rowIndex);
        // Row is still occupied
        if (rowOfAliveCats!.count > 0) {
            disperseRow(aliveCats: rowOfAliveCats!);
        } else {
            // If all cats are alive
            disperseColumns();
        }
    }
    
    /*
        Fills in the gaps for each row where
        cat buttons have perished
     */
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
    
    /*
        Fills in the gaps for each column where
        cat buttons have perished
     */
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
        
        // Don't update sizes and positions unless there is more space to do so
        if ((countOfMaxCatButtonsInARow <= countOfRowsLeft)) {
            for rowIndexOf in Array(indexesOfRowsWithAliveCatsCount.keys).sorted(by:<) {
                resetCatButtonsPosition(rowIndexOf: rowIndexOf);
            }
        } else { // Do it
            rowGap = self.frame.height * 0.1 / CGFloat(countOfRowsLeft + 1);
            buttonHeight = self.frame.width * 0.90 / CGFloat(countOfRowsLeft);
            for rowIndexOf in Array(indexesOfRowsWithAliveCatsCount.keys).sorted(by:<) {
                resetCatButtonsPosition(rowIndexOf: rowIndexOf);
            }
        }
    }
    
    func revertSelections() {
        attackMeter!.sendEnemyToStartAndHold();
        myLiveMeter!.resetLivesLeftCount();
        colorOptions!.selectedColor = UIColor.lightGray;
        cats.shrink();
        currentRound = 1;
        configureComponentsAfterBoardGameReset();
    }
    
    /*
        Disperse all the dead cats, and
        empty all the colors arrays
     */
    func reset(catsSurvived:Bool){
        if (catsSurvived) {
            cats.disperseVertically()
        }
        gridColors!.removeAll();
        colorOptions!.selectionColors!.removeAll();
    }
    
    /*
        Restart the game to round 1, rebuild the whole game
     */
    func restart(){
        currentRound = 1;
        colorOptions!.loadSelectionButtonsToSelectedButtons();
        // Build board game
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.buildGame();
            self.showSingleAndTwoPlayerButtons();
        }
        configureComponentsAfterBoardGameReset();
    }
    
    /*
        Keep the player at an obtainable round
        , save the cats that survived, update the components
        to satisfy the requirements for the round
     */
    func maintain() {
        let countOfAliveCatButtons:Int = cats.countOfAliveCatButtons();
        var newRound:Int = 1;
        // Select obtainable round
        while (true) {
            let newRoundRowsAndColumns:[Int] = getRowsAndColumns(currentStage: newRound);
            let product:Int = newRoundRowsAndColumns[0] * newRoundRowsAndColumns[1];
            if (countOfAliveCatButtons < product) {
                currentRound = newRound - 1;
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
            self.cats.previousCollection!.removeAll();
        }
    }
    
    func clearBoardGameToDisplayVictoryAnimation() {
        // Save alive cats and shrink color options
        self.iWon = true;
        SoundController.kittenMeow();
        self.cats.podAliveOnesAndGiveMouseCoin();
        self.glovePointer!.shrink();
        self.promote();
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.currentRound -= 1;
            self.colorOptions!.removeSelectedButtons();
            self.currentRound += 1;
            self.successGradientLayer!.isHidden = true;
            self.cats.previousCollection!.removeAll();
        }
    }
    
    /*
        Promote the player to the next round
     */
    func promote(){
        reset(catsSurvived: true);
        colorOptions!.shrinkColorOptions();
        colorOptions!.loadSelectionButtonsToSelectedButtons();
        // Reset the attack meter when the user won
        if (self.iWon) {
            self.alpha = 0.0;
            self.attackMeter!.attack = false;
            self.attackMeter!.attackStarted = false;
            self.colorOptions!.removeBorderOfSelectionButtons();
            self.attackMeter!.previousDisplacementDuration = 3.5;
            self.colorOptions!.isTransitioned = false;
            self.colorOptions!.selectedColor = UIColor.lightGray;
            self.restart();
            return;
        }
        // Build board game
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            // Reset the attack meter when the user won
            if (self.iWon) {
                self.alpha = 0.0;
                self.attackMeter!.attack = false;
                self.attackMeter!.attackStarted = false;
                self.colorOptions!.removeBorderOfSelectionButtons();
                self.attackMeter!.previousDisplacementDuration = 3.5;
                self.colorOptions!.isTransitioned = false;
                self.colorOptions!.selectedColor = UIColor.lightGray;
                self.restart();
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
            self.cats.previousCollection!.removeAll();
        }
    }
}
