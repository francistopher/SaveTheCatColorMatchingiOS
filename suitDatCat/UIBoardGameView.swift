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
    var gridColors:[[UIColor]] = [[UIColor]]();
    var selectionColors:[UIColor] = [UIColor]();
    
    var currentStage:Int = 1;
    var columnsAndRows:[Int] = [];
    let cats:UICats = UICats();
    let viruses:UIViruses = UIViruses();
    
    var solved:Bool = true;
    var completionGradientLayer:CAGradientLayer? = nil;
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
        selectSelectionColor();
        buildGridColors();
        buildGridButtons();
        colorOptionsView!.selectColorsForSelection();
        colorOptionsView!.buildColorOptionButtons();
        selectAColorOptionForTheUser();
    }
    
    func selectAColorOptionForTheUser() {
        if (currentStage != 1) {
            let dispatchTime:Double = log(Double(columnsAndRows[1]) + 0.5) * pow(1.1, 5.5 * Double(columnsAndRows[0]));
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
        while(columnIndex < columnsAndRows[0]) {
            var currentColumn:[UIColor] = [UIColor]();
            // Traverse column indexes and build column
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
        if (!solved){
            if (catButton.originalBackgroundColor.cgColor == colorOptionsView!.selectedColor.cgColor){
                catImageButton.fadeBackgroundIn(color: colorOptionsView!.selectedColor);
                catButton.pod();
                catButton.podded = true;
                if (cats.areAllColored()){
                    print("Moving to next round!")
                    solved = true;
                    colorOptionsView!.selectedColor = UIColor.lightGray;
                    cats.giveMouseCoins();
                    promote();
                }
            } else {
                catImageButton.layer.borderColor! = UIColor.clear.cgColor;
                catButton.layer.borderColor! = UIColor.clear.cgColor;
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
    
    func resetGame(promote:Bool){
        if (promote) {
            cats.disperseVertically()
        } else {
            cats.disperseRadially();
        }
        gridColors = [[UIColor]]();
        colorOptionsView!.selectionColors = [UIColor]();
    }
    
    func restart(){
        colorOptionsView!.isActive = false;
        settingsButton!.disable();
        resetGame(promote: false);
        currentStage = 1;
        configureComponentsAfterBoardGameReset();
    }
    
    func maintain(){
        colorOptionsView!.isActive = false;
        settingsButton!.disable();
        resetGame(promote: false);
        configureComponentsAfterBoardGameReset();
    }
    
    func promote(){
        colorOptionsView!.isActive = false;
        settingsButton!.disable();
        resetGame(promote: true);
        completionGradientLayer!.isHidden = false;
        colorOptionsView!.loadSelectionButtonsToSelectedButtons();
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
    func configureComponentsAfterBoardGameReset() {
        colorOptionsView!.loadSelectionButtonsToSelectedButtons();
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
        self.colorOptionsView!.removeSelectedButtons();
    }
}
