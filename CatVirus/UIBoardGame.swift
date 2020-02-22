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
    var currentStage:Int = 1;
    var columnsAndRows:[Int] = [];
    let cats:UICatButtons = UICatButtons();
    var successGradientLayer:CAGradientLayer? = nil;
    var settingsButton:UISettingsButton? = nil;
    var statistics:UIStatistics?
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    init(parentView: UIView, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) {
        super.init(frame:CGRect(x: x, y: y, width: width, height: height));
        self.backgroundColor = UIColor.clear;
        self.layer.cornerRadius = width / 5.0;
        self.statistics = UIStatistics(parentView: parentView);
        self.statistics!.continueButton!.addTarget(self, action: #selector(continueSelector), for: .touchUpInside);
        parentView.addSubview(self);
    }
    
    @objc func continueSelector() {
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
        columnsAndRows = getRowsAndColumns(currentStage: currentStage);
        cats.reset();
        colorOptions!.selectSelectionColors();
        buildGridColors();
        recordGridColorsUsed();
        buildGridButtons();
        colorOptions!.buildColorOptionButtons(setup: true);
    }
    
    func buildGridColors(){
        gridColors = Array(repeating: Array(repeating: UIColor.lightGray, count: columnsAndRows[1]), count: columnsAndRows[0]);
        var columnIndex:Int = 0;
        while (columnIndex < gridColors!.count) {
            var rowIndex:Int = 0;
            while (rowIndex < gridColors![0].count) {
                let randomColor:UIColor = colorOptions!.selectionColors.randomElement()!;
                var randomNum:Int = Int.random(in: 0...2);
                if (columnIndex > 0) {
                    let previousColumnColor:UIColor = gridColors![columnIndex - 1][rowIndex];
                    if (previousColumnColor.cgColor == randomColor.cgColor && randomNum != 1) {
                        columnIndex -= 1;
                    }
                }
                randomNum = Int.random(in: 0...4);
                if (rowIndex > 0) {
                    let previousRowColor:UIColor = gridColors![columnIndex][rowIndex - 1];
                    if (previousRowColor.cgColor == randomColor.cgColor && randomNum != 1){
                        rowIndex -= 1;
                    }
                }
                gridColors![columnIndex][rowIndex] = randomColor;
                rowIndex += 1;
            }
            columnIndex += 1;
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
        for columnIndex in 0..<gridColors!.count {
            for rowIndex in 0..<gridColors![0].count {
                let color:CGColor = gridColors![columnIndex][rowIndex].cgColor;
                if (gridColorsCount[color] == nil) {
                    gridColorsCount[color] = 1;
                } else {
                    gridColorsCount[color]! += 1;
                }
            }
        }
    }
    
    func getRowsAndColumns(currentStage:Int) -> [Int] {
        var initialStage:Int = 2;
        var rows:Int = 1;
        var columns:Int = 1;
        while (currentStage >= initialStage) {
            if (initialStage % 2 == 0){
                columns += 1;
            }
            else {
                rows += 1;
            }
            initialStage += 1;
        }
        return [rows, columns];
    }
    
    func buildGridButtons(){
        let rowGap:CGFloat = self.frame.height * 0.1 / CGFloat(columnsAndRows[0] + 1);
        let columnGap:CGFloat = self.frame.width * 0.1 / CGFloat(columnsAndRows[1] + 1);
        // Sizes
        let buttonWidth:CGFloat = self.frame.width * 0.90 / CGFloat(columnsAndRows[0]);
        let buttonHeight:CGFloat = self.frame.height * 0.90 / CGFloat(columnsAndRows[1]);
        // Points
        var x:CGFloat = 0.0;
        var y:CGFloat = 0.0;
        for columns in 0..<columnsAndRows[0] {
            x += columnGap;
            y = 0.0;
            for rows in 0..<columnsAndRows[1] {
                y += rowGap;
                let frame:CGRect = CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight);
                let catButton:UICatButton = cats.buildCatButton(parent: self, frame: frame, backgroundColor: gridColors![columns][rows]);
                catButton.imageContainerButton!.addTarget(self, action: #selector(selectCatImageButton), for: .touchUpInside);
                catButton.addTarget(self, action: #selector(selectCatButton), for: .touchUpInside);
                y += buttonHeight;
            }
            x += buttonWidth;
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
        if (cats.presentCollection![0].isAlive && colorOptions!.selectedColor.cgColor != UIColor.lightGray.cgColor) {
            // Correct matching grid button color and selection color
            if (catButton.originalBackgroundColor.cgColor == colorOptions!.selectedColor.cgColor){
                catImageButton.fadeBackgroundIn(color: colorOptions!.selectedColor);
                catButton.pod();
                catButton.isPodded = true;
                catButton.giveMouseCoin(withNoise: true);
                // Check if all the cats have been podded
                if (cats.arePodded()) {
                    colorOptions!.selectedColor = UIColor.lightGray;
                    colorOptions!.isTransitioned = false;
                    // Add data of survived cats
                    statistics!.finalStage = "\(self.currentStage + 1)";
                    statistics!.catsThatLived += cats.presentCollection!.count;
                    promote();
                }
                // Incorrect match
            } else {
                statistics!.sessionEndTime = CFAbsoluteTimeGetCurrent();
                statistics!.setSessionDuration();
                statistics!.catsThatDied = cats.presentCollection!.count;
                SoundController.kittenDie();
                SoundController.mozartSonata(play: false);
                SoundController.chopinPrelude(play: true);
                colorOptions!.removeBorderOfSelectionButtons();
                cats.areNowDead();
                // App data of dead cats
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
                    self.settingsButton!.disable();
                    self.resetGame(catsSurvived: false);
                    self.colorOptions!.shrinkColorOptions();
                    self.statistics!.update();
                    self.statistics!.fadeIn();
                }
            }
        } else {
            if (!colorOptions!.isTransitioned) {
                SoundController.kittenMeow();
            }
        }
    }
    
    func resetGame(catsSurvived:Bool){
        if (catsSurvived) {
            cats.disperseVertically()
        } else {
            cats.disperseRadially();
        }
        gridColors = [[UIColor]]();
        colorOptions!.selectionColors = [UIColor]();
    }
    
    func restart(){
        currentStage = 1;
        configureComponentsAfterBoardGameReset();
    }
    
    func maintain(){
        settingsButton!.disable();
        resetGame(catsSurvived: true);
        configureComponentsAfterBoardGameReset();
    }
    
    func promote(){
        settingsButton!.disable();
        resetGame(catsSurvived: true);
        successGradientLayer!.isHidden = false;
        colorOptions!.loadSelectionButtonsToSelectedButtons();
        // Build board game
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            self.currentStage += 1;
            self.buildBoardGame();
            self.settingsButton!.enable();
        }
        // Remove selected buttons after they've shrunk
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.currentStage -= 1;
            self.removeGridCatAndColorOptionButtonsAfterDelay();
            self.currentStage += 1;
            self.successGradientLayer!.isHidden = true;
        }
    }
    func configureComponentsAfterBoardGameReset() {
        colorOptions!.loadSelectionButtonsToSelectedButtons();
        // Build board game
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            self.buildBoardGame();
            self.settingsButton!.enable();
        }
        // Remove dispersed buttons after they've dispersed
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.removeGridCatAndColorOptionButtonsAfterDelay();
        }
    }
    func removeGridCatAndColorOptionButtonsAfterDelay() {
        cats.removePreviousCatButtonsFromSuperView();
        self.colorOptions!.removeSelectedButtons();
    }
}
