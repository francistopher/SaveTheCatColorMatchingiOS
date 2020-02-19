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
    var gridColors:[[UIColor]] = [[UIColor]]();
    
    var currentStage:Int = 1;
    var columnsAndRows:[Int] = [];
    let cats:UICatButtons = UICatButtons();
    
    var successGradientLayer:CAGradientLayer? = nil;
    var settingsButton:UISettingsButton? = nil;
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    init(parentView: UIView, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) {
        super.init(frame:CGRect(x: x, y: y, width: width, height: height));
        self.backgroundColor = UIColor.clear;
        self.layer.cornerRadius = width / 5.0;
        parentView.addSubview(self);
    }
    
    func fadeIn(){
       UIView.animate(withDuration: 2, delay: 0.5, options: .curveEaseIn, animations: {
           super.alpha = 1.0;
       })
    }
    
    func buildBoardGame(){
        columnsAndRows = getRowsAndColumns(currentStage: currentStage);
        cats.reset();
        selectSelectionColors();
        buildGridColors();
        buildGridButtons();
        colorOptions!.selectColorsForSelection();
        colorOptions!.buildColorOptionButtons();
    }
    
    func selectSelectionColors(){
        colorOptions!.selectionColors =  [UIColor.systemGreen, UIColor.systemYellow, UIColor.systemOrange, UIColor.systemRed, UIColor.systemPurple, UIColor.systemBlue];
        repeat {
            let index:Int = Int.random(in: 0..<colorOptions!.selectionColors.count);
            colorOptions!.selectionColors.remove(at: index);
            if (colorOptions!.selectionColors.count == columnsAndRows[1] || colorOptions!.selectionColors.count == 6) {
                break;
            }
        } while(true);
        print(colorOptions!.selectionColors.count);
    }
    
    func buildGridColors(){
        // Traverse row indexes and build gridColors
        var columnIndex:Int = 0;
        while(columnIndex < columnsAndRows[0]) {
            var currentColumn:[UIColor] = [UIColor]();
            // Traverse column indexes and build column
            var rowIndex:Int = 0;
            while(rowIndex < columnsAndRows[1]) {
                // Select random color and compare to diversify
                let color = colorOptions!.selectionColors.randomElement()!;
                if (rowIndex > 0) {
                    if (color.cgColor == currentColumn[rowIndex - 1].cgColor){
                        columnIndex -= 1;
                        continue;
                    }
                }
                currentColumn.append(color);
                rowIndex += 1;
            }
            gridColors.append(currentColumn);
            columnIndex += 1;
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
                let catButton:UICatButton = cats.buildCatButton(parent: self, frame: frame, backgroundColor: gridColors[columns][rows]);
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
        if (catButton.originalBackgroundColor.cgColor == colorOptions!.selectedColor.cgColor){
            catImageButton.fadeBackgroundIn(color: colorOptions!.selectedColor);
            catButton.pod();
            catButton.isPodded = true;
            catButton.giveMouseCoin(withNoise: true);
            if (cats.arePodded()) {
                colorOptions!.selectedColor = UIColor.lightGray;
                promote();
                colorOptions!.isTransitioned = false;
            }
        } else {
            catButton.layer.borderColor! = UIColor.clear.cgColor;
            colorOptions!.selectedColor = UIColor.lightGray;
            colorOptions!.isTransitioned = false;
            restart();
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
        settingsButton!.disable();
        resetGame(catsSurvived: false);
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
