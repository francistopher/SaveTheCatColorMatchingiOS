//
//  UIBoardGameView.swift
//  suitDatCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIBoardGameView: UIView {
    
    var colors:[UIColor] = [UIColor.systemGreen, UIColor.systemYellow, UIColor.systemOrange, UIColor.systemRed, UIColor.systemPurple, UIColor.systemBlue];
    var colorOptionsView:UIColorOptionsView? = nil;
    
    var gridCatButtons:[[UICatButton]] = [[UICatButton]]();
    var dispersedGridCatButtons:[[UICatButton]] = [[UICatButton]]();
    
    var viruses:UIViruses? = nil;
    var currentStage:Int = 1;
    
    var gridColors:[[UIColor]] = [[UIColor]]();
    var availableColors:[UIColor] = [UIColor]();
    
    var solved:Bool = true;
    
    var completionGradientLayer:CAGradientLayer? = nil;
    
    var settingsButton:UISettingsButton? = nil;
    
    var bak2sqr1:Bool = false;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    init(parentView: UIView, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat, backgroundColor:UIColor) {
        super.init(frame:CGRect(x: x, y: y, width: width, height: height));
        self.backgroundColor = backgroundColor;
        self.layer.cornerRadius = height / 5.0;
        parentView.addSubview(self);
    }
    
    func fadeIn(){
       UIView.animate(withDuration: 2, delay: 0.5, options: .curveEaseIn, animations: {
           super.alpha = 1.0;
       })
    }
    
    func buildBoardGame(){
        selectAnAvailableColor();
        randomlySelectGridColors();
        buildGridButtons();
        colorOptionsView!.selectColorsForSelection();
        colorOptionsView!.buildColorOptionButtons();
    }
    
    func selectAnAvailableColor(){
        // Load number of rows and columns
        let rowsAndColumns:[Int] = currentStageRowsAndColumns(currentStage: currentStage);
        repeat {
            if (availableColors.count == 6 || availableColors.count + 1 > rowsAndColumns[1]) {
                break;
          }
          let newAvailableColor:UIColor = colors.randomElement()!;
          if (!(availableColors.contains(newAvailableColor))){
              availableColors.append(newAvailableColor);
              break;
          }
        } while(true);
    }
    
    func randomlySelectGridColors(){
        // Load number of rows and columns
        let rowsAndColumns:[Int] = currentStageRowsAndColumns(currentStage: currentStage);
        // Save previous row colors
        var previousRowColors = Array(repeating: UIColor.lightGray, count: rowsAndColumns[1]);
        // Traverse through row index
        var rowIndex:Int = 0;
        while(rowIndex < rowsAndColumns[0]) {
            // Instantiate a row
            var row:[UIColor] = [UIColor]();
            // Save previous column color
            var previousColumnColor:UIColor = UIColor.lightGray;
            // Traverse through the columnIndex
            var columnIndex:Int = 0;
            while(columnIndex < rowsAndColumns[1]) {
                // Select random color
                let randomSelectedColor = availableColors.randomElement()!;
                // Compare selected random color with saved previous row color
                if (randomSelectedColor.cgColor == previousRowColors[columnIndex].cgColor){
                    if (rowIndex - 1 >= 0){
                        rowIndex -= 1;
                    }
                    continue;
                }
                // Compare selected random color with saved previous column colo
                if (randomSelectedColor.cgColor == previousColumnColor.cgColor){
                    if (columnIndex - 1 >= 0){
                        columnIndex -= 1;
                    }
                    continue;
                }
                // Add randomly selected color
                row.append(randomSelectedColor);
                // Save as previous column color and as a row color
                previousColumnColor = randomSelectedColor;
                columnIndex += 1;
            }
            // Save row of colors as the subsequent row of grid colors
            gridColors.append(row);
            previousRowColors = row;
            rowIndex += 1;
        }
    }
    
    func currentStageRowsAndColumns(currentStage:Int) -> [Int] {
        var initialStage:Int = 1;
        var rows:Int = 0;
        var columns:Int = 0;
        while (currentStage >= initialStage) {
            if (initialStage == 1){
                rows = 1;
                columns = 1;
            }
            else if (initialStage % 2 == 0){
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
        let rowsAndColumns:[Int] = currentStageRowsAndColumns(currentStage: currentStage);
        // Gaps
        let rowGap:CGFloat = self.frame.height * 0.1 / CGFloat(rowsAndColumns[0] + 1);
        let columnGap:CGFloat = self.frame.width * 0.1 / CGFloat(rowsAndColumns[1] + 1);
        // Sizes
        let buttonWidth:CGFloat = self.frame.width * 0.90 / CGFloat(rowsAndColumns[0]);
        let buttonHeight:CGFloat = self.frame.height * 0.90 / CGFloat(rowsAndColumns[1]);
        var rowDisplacement:CGFloat = 0.0;
        var columnDisplacement:CGFloat = 0.0;
        var catButton:UICatButton? = nil;
        for rows in 0..<rowsAndColumns[0] {
            rowDisplacement += rowGap;
            columnDisplacement = 0.0;
            var gridButtonsRow:[UICatButton] = [UICatButton]();
            for columns in 0..<rowsAndColumns[1] {
                columnDisplacement += columnGap;
                catButton = UICatButton(parentView: self, x: rowDisplacement, y: columnDisplacement,
                                            width: buttonWidth, height: buttonHeight, backgroundColor: gridColors[rows][columns]);
                catButton!.grow();
                columnDisplacement += buttonHeight;
                catButton!.imageContainerButton!.addTarget(self, action: #selector(selectGridButton), for: .touchUpInside);
                // Add cat image to current button
                catButton!.setCat(named: "SmilingCat", stage:0);
                gridButtonsRow.append(catButton!);
            }
            gridCatButtons.append(gridButtonsRow);
            rowDisplacement += buttonWidth;
        }
    }
    
    @objc func selectGridButton(catButton:UICButton){
        if (!solved){
            if (catButton.originalBackgroundColor!.cgColor == colorOptionsView!.selectedColor.cgColor){
                (catButton.superview! as! UICatButton).fadeBackgroundIn();
                catButton.fadeBackgroundIn();
                if (isBoardCompleted()){
                    print("Moving to next round!")
                    solved = true;
                    colorOptionsView!.selectedColor = UIColor.lightGray;
                    promote();
                }
            } else{
                print("Unable to solve puzzle")
                solved = true;
                colorOptionsView!.selectedColor = UIColor.lightGray;
                if (bak2sqr1) {
                    restart();
                } else {
                    maintain();
                }
            }
        }
    }
    
    @objc func isBoardCompleted() -> Bool{
        let rowsAndColumns:[Int] = currentStageRowsAndColumns(currentStage: currentStage);
        for rows in 0..<rowsAndColumns[0]{
            for columns in 0..<rowsAndColumns[1]{
                if (gridCatButtons[rows][columns].backgroundColor!.cgColor != gridColors[rows][columns].cgColor){
                    return false;
                }
            }
        }
        return true;
    }
    
    func resetGame(promote:Bool){
        let rowsAndColumns:[Int] = currentStageRowsAndColumns(currentStage: currentStage);
        for rows in 0..<rowsAndColumns[0] {
            for columns in 0..<rowsAndColumns[1] {
                if (promote) {
                    gridCatButtons[rows][columns].disperseVertically();
                } else {
                    gridCatButtons[rows][columns].disperseRadially();
                }
            }
        }
        gridColors = [[UIColor]]();
        colorOptionsView!.selectionColors = [UIColor]();
    }
    
    func restart(){
        settingsButton!.disable();
        resetGame(promote: false);
        viruses!.translateToCatsAndBack();
        currentStage = 1;
        configureComponentsAfterBoardGameReset();
    }
    
    func maintain(){
        settingsButton!.disable();
        resetGame(promote: false);
        viruses!.translateToCatsAndBack();
        configureComponentsAfterBoardGameReset();
    }
    
    func promote(){
        settingsButton!.disable();
        resetGame(promote: true);
        completionGradientLayer!.isHidden = false;
        loadGridCatAndColorOptionButtonsBeforeDelayAccess();
        // Build board game
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            self.currentStage += 1;
            self.buildBoardGame();
            self.currentStage -= 1;
            self.settingsButton!.enable();
        }
        // Remove selected buttons after they've shrunk
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.removeGridCatAndColorOptionButtonsAfterDelay();
            self.currentStage += 1;
            self.completionGradientLayer!.isHidden = true;
        }
    }
    
    func configureComponentsAfterBoardGameReset() {
        loadGridCatAndColorOptionButtonsBeforeDelayAccess();
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
    
    func loadGridCatAndColorOptionButtonsBeforeDelayAccess() {
        loadGridButtonsToDispersedGridButtons();
        colorOptionsView!.loadSelectionButtonsToSelectedButtons();
    }
    
    func removeGridCatAndColorOptionButtonsAfterDelay() {
        self.removeDispersedButtonsFromSuperView();
        self.colorOptionsView!.removeSelectedButtons();
    }
    
    func loadGridButtonsToDispersedGridButtons() {
        let rowsAndColumns:[Int] = currentStageRowsAndColumns(currentStage: currentStage);
        for row in 0..<rowsAndColumns[0] {
            var currentButtonRow:[UICatButton] = [UICatButton]();
            for column in 0..<rowsAndColumns[1] {
                currentButtonRow.append(gridCatButtons[row][column]);
            }
            dispersedGridCatButtons.append(currentButtonRow);
        }
        gridCatButtons = [[UICatButton]]();
    }
    
    func removeDispersedButtonsFromSuperView() {
        let rowsAndColumns:[Int] = currentStageRowsAndColumns(currentStage: currentStage);
        for row in 0..<rowsAndColumns[0] {
            for column in 0..<rowsAndColumns[1] {
                if (dispersedGridCatButtons.count != 0){
                    dispersedGridCatButtons[row][column].removeFromSuperview();
                }
            }
        }
        dispersedGridCatButtons = [[UICatButton]]();
    }
    
    func resumeGridButtonImageLayerAnimations(){
        let rowsAndColumns:[Int] = currentStageRowsAndColumns(currentStage: currentStage);
        for row in 0..<rowsAndColumns[0] {
            for column in 0..<rowsAndColumns[1] {
                gridCatButtons[row][column].animate(AgainWithoutDelay: true);
            }
        }
    }
    
    func activateGridButtonsForUserInterfaceStyle() {
        let rowsAndColumns:[Int] = currentStageRowsAndColumns(currentStage: currentStage);
        for row in 0..<rowsAndColumns[0] {
            for column in 0..<rowsAndColumns[1] {
                if (gridCatButtons.count == 0) {
                    dispersedGridCatButtons[row][column].animate(AgainWithoutDelay: false);
                } else {
                    gridCatButtons[row][column].animate(AgainWithoutDelay: false);
                }
            }
        }
    }
    
    func suspendGridButtonImageLayerAnimations() {
        let rowsAndColumns:[Int] = currentStageRowsAndColumns(currentStage: currentStage);
        for row in 0..<rowsAndColumns[0] {
            for column in 0..<rowsAndColumns[1] {
                gridCatButtons[row][column].hideCat();
            }
        }
    }
}
