//
//  UIBoardGameView.swift
//  suitDatCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
// (int)

import SwiftUI

class UIBoardGameView: UIView {
    
    var colors:[UIColor] = [UIColor.systemGreen, UIColor.systemYellow, UIColor.systemOrange, UIColor.systemRed, UIColor.systemPurple, UIColor.systemBlue];
    var colorOptionsView:UIColorOptionsView? = nil;
    
    var currentStage:Int = 1;
    var columnsAndRows:[Int] = [];
    let currentCats:UICats = UICats();
    
    
    var gridCatButtons:[[UICatButton]] = [[UICatButton]]();
    var dispersedGridCatButtons:[[UICatButton]]? = nil;
    
    var viruses:UIViruses? = nil;
  
    
    var gridColors:[[UIColor]] = [[UIColor]]();
    var selectionColors:[UIColor] = [UIColor]();
    
    var solved:Bool = true;
    
    var completionGradientLayer:CAGradientLayer? = nil;
    
    var settingsButton:UISettingsButton? = nil;
    
    var bak2sqr1:Bool = false;
    
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
        currentCats.reset();
        selectSelectionColor();
        buildGridColors();
        buildGridButtons();
        colorOptionsView!.selectColorsForSelection();
        colorOptionsView!.buildColorOptionButtons();
        selectAColorOptionForTheUser();
        
    }
    
    func selectAColorOptionForTheUser() {
        if (currentStage != 1) {
            let dispatchTime:Double = log(Double(gridCatButtons[0].count) + 0.5) * pow(1.1, 5.5 * Double(gridCatButtons.count));
            DispatchQueue.main.asyncAfter(deadline: .now() + dispatchTime, execute: {
                if (!self.colorOptionsView!.isActive) {
                    self.colorOptionsView!.selectionButtons[0].sendActions(for: .touchUpInside);
                }
            })
        }
    }
    
    func selectSelectionColor(){
        repeat {
            if (selectionColors.count == 6 || selectionColors.count >= columnsAndRows[1]) {
                break;
            }
                let newAvailableColor:UIColor = colors.randomElement()!;
                if (!selectionColors.contains(newAvailableColor)){
                  selectionColors.append(newAvailableColor);
                  break;
            }
        } while(true);
    }
    
    func buildGridColors(){
        // Traverse row indexes and build gridColors
        var columnIndex:Int = 0;
        print(selectionColors.count, "checking color count");
        while(columnIndex < columnsAndRows[0]) {
            var currentColumn:[UIColor] = [UIColor]();
            // Traverse column indexes and build row
            var rowIndex:Int = 0;
            while(rowIndex < columnsAndRows[1]) {
                // Select random color and compare to diversify
                let color = selectionColors.randomElement()!;
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
        // Gaps
        let rowGap:CGFloat = self.frame.height * 0.1 / CGFloat(columnsAndRows[0] + 1);
        let columnGap:CGFloat = self.frame.width * 0.1 / CGFloat(columnsAndRows[1] + 1);
        // Sizes
        let buttonWidth:CGFloat = self.frame.width * 0.90 / CGFloat(columnsAndRows[0]);
        let buttonHeight:CGFloat = self.frame.height * 0.90 / CGFloat(columnsAndRows[1]);
        // Points
        var x:CGFloat = 0.0;
        var y:CGFloat = 0.0;
        var catButton:UICatButton? = nil;
        
        for columns in 0..<columnsAndRows[0] {
            x += columnGap;
            y = 0.0;
            var gridButtonsRow:[UICatButton] = [UICatButton]();
            for rows in 0..<columnsAndRows[1] {
                y += rowGap;
                let frame:CGRect = CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight);
                catButton = currentCats.buildCatButton(parent: self, frame: frame, backgroundColor: gridColors[columns][rows]);
                catButton!.imageContainerButton!.addTarget(self, action: #selector(selectGridButton), for: .touchUpInside);
                gridButtonsRow.append(catButton!);
                y += buttonHeight;
            }
            gridCatButtons.append(gridButtonsRow);
            x += buttonWidth;
        }
    }
    
    @objc func selectGridButton(catImageButton:UICButton){
        let catButtonSuperView:UICatButton = catImageButton.superview! as! UICatButton;
        if (!solved){
            if (catButtonSuperView.originalBackgroundColor.cgColor == colorOptionsView!.selectedColor.cgColor){
                catImageButton.fadeBackgroundIn(color: colorOptionsView!.selectedColor);
                catButtonSuperView.pod();
                catButtonSuperView.podded = true;
                if (isBoardCompleted()){
                    print("Moving to next round!")
                    solved = true;
                    colorOptionsView!.selectedColor = UIColor.lightGray;
                    earnMouseCoins();
                    promote();
                }
            } else {
                catImageButton.layer.borderColor! = UIColor.clear.cgColor;
                catButtonSuperView.layer.borderColor! = UIColor.clear.cgColor;
            }
//                else{
//                print("Unable to solve puzzle")
//                solved = true;
//                colorOptionsView!.selectedColor = UIColor.lightGray;
//                catButtonSuperView.kittenDie();
//                UICLabel.mozartSonata(play: true);
//                UICLabel.mozartEine(play: false);
//                maintain();
//            }
        }
    }
    
    @objc func isBoardCompleted() -> Bool{
        for rows in 0..<columnsAndRows[0]{
            for columns in 0..<columnsAndRows[1]{
                if (gridCatButtons[rows][columns].imageContainerButton!.backgroundColor!.cgColor != gridColors[rows][columns].cgColor){
                    return false;
                }
            }
        }
        return true;
    }
    
    func resetGame(promote:Bool){
        for rows in 0..<columnsAndRows[0] {
            for columns in 0..<columnsAndRows[1] {
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
        colorOptionsView!.isActive = false;
        settingsButton!.disable();
        resetGame(promote: false);
        viruses!.translateToCatsAndBack();
        currentStage = 1;
        configureComponentsAfterBoardGameReset();
    }
    
    func maintain(){
        colorOptionsView!.isActive = false;
        settingsButton!.disable();
        resetGame(promote: false);
        viruses!.translateToCatsAndBack();
        configureComponentsAfterBoardGameReset();
    }
    
    func promote(){
        colorOptionsView!.isActive = false;
        settingsButton!.disable();
        resetGame(promote: true);
        completionGradientLayer!.isHidden = false;
        loadGridCatAndColorOptionButtonsBeforeDelayAccess();
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
            self.completionGradientLayer!.isHidden = true;
        }
    }
    
    func earnMouseCoins() {
        for row in 0..<gridCatButtons.count {
            for column in 0..<gridCatButtons[row].count {
                if (row == 0){
                    gridCatButtons[row][column].giveMouseCoin(withNoise: true);
                } else {
                    gridCatButtons[row][column].giveMouseCoin(withNoise: false);
                }
            }
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
        dispersedGridCatButtons = [[UICatButton]]();
        for row in 0..<columnsAndRows[0] {
            var currentButtonRow:[UICatButton] = [UICatButton]();
            for column in 0..<columnsAndRows[1] {
                currentButtonRow.append(gridCatButtons[row][column]);
            }
            
            dispersedGridCatButtons!.append(currentButtonRow);
        }
        gridCatButtons = [[UICatButton]]();
    }
    
    func removeDispersedButtonsFromSuperView() {
        for row in 0..<columnsAndRows[0] {
            for column in 0..<columnsAndRows[1] {
                if (row < dispersedGridCatButtons!.count && column < dispersedGridCatButtons![0].count) {
                    dispersedGridCatButtons![row][column].removeFromSuperview();
                }
            }
        }
    }
    
    func resumeGridButtonImageLayerAnimations(){
        for row in 0..<columnsAndRows[0] {
            for column in 0..<columnsAndRows[1] {
                if (row < gridCatButtons.count && column < gridCatButtons[0].count){
                    gridCatButtons[row][column].animate(AgainWithoutDelay: true);
                }
            }
        }
    }
    
    func activateGridButtonsForUserInterfaceStyle() {
        for row in 0..<columnsAndRows[0] {
            for column in 0..<columnsAndRows[1] {
                if (gridCatButtons.count == 0) {
                    if (row < dispersedGridCatButtons!.count && column < dispersedGridCatButtons![0].count){
                        dispersedGridCatButtons![row][column].animate(AgainWithoutDelay: false);
                        dispersedGridCatButtons![row][column].setStyle();
                    }
                } else {
                    if (row < gridCatButtons.count && column < gridCatButtons.count){
                        gridCatButtons[row][column].animate(AgainWithoutDelay: false);
                        gridCatButtons[row][column].setStyle();
                    }
                }
            }
        }
    }
    
    func suspendGridButtonImageLayerAnimations() {
        for row in 0..<columnsAndRows[0] {
            for column in 0..<columnsAndRows[1] {
                if (row < gridCatButtons.count && column < gridCatButtons[0].count){
                    gridCatButtons[row][column].hideCat();
                }
            }
        }
    }
}
