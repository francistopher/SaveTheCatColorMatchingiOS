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
    var currentStage:Int = 2;
    var gridButtons:[[UICButton]] = [[UICButton]]();
    var gridColors:[[UIColor]] = [[UIColor]]();
    var availableColors:[UIColor] = [UIColor]();
    var solved:Bool = true;
    
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
    
    func fadeOnDark() {
        UIView.animate(withDuration: 0.0625, delay: 0.0, options: .curveEaseIn, animations: {
            super.backgroundColor = UIColor.white;
        })
    }
    
    func fadeOnLight(){
        UIView.animate(withDuration: 0.0625, delay: 0.0, options: .curveEaseIn, animations: {
            super.backgroundColor = UIColor.black;
        })
    }
    
    func buildBoardGame(){
        selectAnAvailableColor();
        randomlySelectGridColors();
        buildGridButtons();
        colorOptionsView!.selectColorsForSelection();
        colorOptionsView!.buildColorOptionButtons();
        print(colorOptionsView!.selectionColors.count);
        print(availableColors.count);
        print(gridColors.count);
    }
    
    func selectAnAvailableColor(){
      repeat {
          if (availableColors.count == 6){
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
        let rowsAndColumns:[Int] = currentStageRowsAndColumns(currentStage: currentStage);
        for _ in 0..<rowsAndColumns[0] {
            var row:[UIColor] = [UIColor]();
            for _ in 0..<rowsAndColumns[1] {
                row.append(availableColors.randomElement()!);
            }
            gridColors.append(row);
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
        var currentRowDisplacement:CGFloat = 0.0;
        var currentColumnDisplacement:CGFloat = 0.0;
        var currentButton:UICButton? = nil;
        for rows in 0..<rowsAndColumns[0] {
            currentRowDisplacement += rowGap;
            currentColumnDisplacement = 0.0;
            var gridButtonsRow:[UICButton] = [UICButton]();
            for columns in 0..<rowsAndColumns[1] {
                currentColumnDisplacement += columnGap;
                currentButton = UICButton(parentView: self, x: currentRowDisplacement, y: currentColumnDisplacement, width: buttonWidth, height: buttonHeight, backgroundColor: gridColors[rows][columns]);
                currentButton!.grownAndShrunk();
                currentButton!.shrinked();
                currentButton!.grow();
                currentColumnDisplacement += buttonHeight;
                currentButton!.addTarget(self, action: #selector(selectGridButton), for: .touchUpInside);
                gridButtonsRow.append(currentButton!);
            }
            gridButtons.append(gridButtonsRow);
            currentRowDisplacement += buttonWidth;
        }
    }
    
    @objc func selectGridButton(sender:UICButton){
        let receiverButton:UICButton = sender;
        if (!solved){
            if (receiverButton.originalBackgroundColor!.cgColor == colorOptionsView!.selectedColor.cgColor){
                receiverButton.fill();
                if (isBoardCompleted()){
                    print("Moving to next round!")
                    solved = true;
                    colorOptionsView!.selectedColor = UIColor.lightGray;
                    promote();
                }
            } else{
                solved = true;
                colorOptionsView!.selectedColor = UIColor.lightGray;
                maintain();
            }
        }
        print("Selecting a button from the grid!")
    }
    
    @objc func isBoardCompleted() -> Bool{
        let rowsAndColumns:[Int] = currentStageRowsAndColumns(currentStage: currentStage);
        for rows in 0..<rowsAndColumns[0]{
            for columns in 0..<rowsAndColumns[1]{
                if (gridButtons[rows][columns].backgroundColor!.cgColor != gridColors[rows][columns].cgColor){
                    return false;
                }
            }
        }
        return true;
    }
    
    func resetGame(){
        let rowsAndColumns:[Int] = currentStageRowsAndColumns(currentStage: currentStage);
        for rows in 0..<rowsAndColumns[0]{
            for columns in 0..<rowsAndColumns[1]{
                gridButtons[rows][columns].isHidden = true;
                gridButtons[rows][columns].removeFromSuperview();
            }
        }
        gridButtons = [[UICButton]]();
        gridColors = [[UIColor]]();
        print(colorOptionsView!.selectionButtons.count);
        for row in 0..<colorOptionsView!.selectionButtons.count {
            colorOptionsView!.selectionButtons[row].isHidden = true;
            colorOptionsView!.selectionButtons[row].removeFromSuperview();
        }
        colorOptionsView!.selectionButtons = [UICButton]();
        colorOptionsView!.selectionColors = [UIColor]();
    }
    
    func promote(){
        resetGame();
        currentStage += 1;
        buildBoardGame();
    }
    
    func maintain(){
        resetGame();
        buildBoardGame();
    }
    
}
