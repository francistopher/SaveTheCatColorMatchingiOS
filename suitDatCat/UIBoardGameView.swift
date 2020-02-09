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
    var currentStage:Int = 1;
    var gridButtons:[[UICButton]] = [[UICButton]]();
    var dispersedGridButtons:[[UICButton]] = [[UICButton]]();
    var gridColors:[[UIColor]] = [[UIColor]]();
    var availableColors:[UIColor] = [UIColor]();
    var solved:Bool = true;
    var heavenGradientLayer:CACGradientLayer? = nil;
    
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
    }
    
    func selectAnAvailableColor(){
        // Load number of rows and columns
        let rowsAndColumns:[Int] = currentStageRowsAndColumns(currentStage: currentStage);
        repeat {
            if (availableColors.count == 6 || availableColors.count + 1 > rowsAndColumns[1]) {
               // --> Reduces complexity
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
                if (randomSelectedColor.cgColor == previousRowColors[columnIndex].cgColor){ // --> Increases complexity
                    if (rowIndex - 1 >= 0){
                        rowIndex -= 1;
                    }
                    continue;
                }
                // Compare selected random color with saved previous column colo
                if (randomSelectedColor.cgColor == previousColumnColor.cgColor){ // --> Increases complexity
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
            previousRowColors = row; // --> Increases Complexity Heavily
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
                // Add cat image to current button
                currentButton!.setCat(named: "smilingCat.png", stage:0);
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
                    promote(promote: true);
                }
            } else{
                print("Unable to solve puzzle")
                solved = true;
                colorOptionsView!.selectedColor = UIColor.lightGray;
                maintain(promote: false);
            }
        }
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
    
    func resetGame(promote:Bool){
        let rowsAndColumns:[Int] = currentStageRowsAndColumns(currentStage: currentStage);
        var targetPoints:[[[CGFloat]]] = generateRadialTargetPoints(rows: rowsAndColumns[0], columns: rowsAndColumns[1]);
        if (!promote) {
            targetPoints = generateRadialTargetPoints(rows:rowsAndColumns[0], columns:rowsAndColumns[1]);
        } else {
            targetPoints = generateElevatedTargetPoints(rows: rowsAndColumns[0], columns: rowsAndColumns[1]);
        }
        disperse(targetPoints:targetPoints, promote:promote);
        gridColors = [[UIColor]]();
        colorOptionsView!.selectionColors = [UIColor]();
    }
    
    func generateElevatedTargetPoints(rows:Int, columns:Int) -> [[[CGFloat]]] {
        var elevatedTargetPoints:[[[CGFloat]]] = [[[CGFloat]]]();
        // Traverse through the rows of grid of buttons
        for row in 0..<rows {
            // Build row of target points
            var rowOfElevatedDispersementTargetPoints:[[CGFloat]] = [[CGFloat]]();
            // Traverse through the columns of grid of buttons
            for column in 0..<columns {
                // Save the target coordinates in an array
                var coordinateTargetPoints:[CGFloat] = [CGFloat]();
                // Save current grid button
                let gridButton:UICButton = gridButtons[row][column];
                // Save the new displaced bounds of the grid button
                let x:CGFloat = gridButton.frame.minX + self.frame.minX / 2.0;
                let y:CGFloat = gridButton.frame.minY + self.frame.minY / 2.0;
                let width:CGFloat = gridButton.frame.width;
                let height:CGFloat = gridButton.frame.height;
                // Save a frame representing the displacement
                let displacedFrame:CGRect = CGRect(x: x, y: y, width: width, height: height);
                // Displace the frame onto the main view controller
                gridButton.frame = displacedFrame;
                self.superview!.addSubview(gridButton);
                // Add waving cats image to button
                gridButton.setCat(named: "wavingSmilingCat.png", stage: 1);
                // Generate target points and angle
                let angle:CGFloat = CGFloat(Int.random(in: 0..<30));
                let xTargetPoint:CGFloat = generateElevatedTargetX(parentFrame:self.superview!.frame, childFrame:gridButton.frame, angle:angle);
                let yTargetPoint:CGFloat = generateElevatedTargetY(parentFrame:self.superview!.frame, childFrame:gridButton.frame, angle:angle);
                // Build coordinate target points
               coordinateTargetPoints.append(xTargetPoint);
               coordinateTargetPoints.append(yTargetPoint);
               // Add coordinate target points to row
               rowOfElevatedDispersementTargetPoints.append(coordinateTargetPoints);
            }
            // Add row to radial dispersement target points
            elevatedTargetPoints.append(rowOfElevatedDispersementTargetPoints);
        }
        return elevatedTargetPoints;
    }
    
    func generateElevatedTargetX(parentFrame:CGRect, childFrame:CGRect, angle:CGFloat) -> CGFloat{
        var targetX:CGFloat = parentFrame.width / 2.0;
        if (angle < 15.0) {
            targetX -= childFrame.width;
        } else {
            targetX += childFrame.width;
        }
        targetX *= cos((CGFloat.pi * angle) / 180.0);
        return targetX;
    }
    
    func generateElevatedTargetY(parentFrame:CGRect, childFrame:CGRect, angle:CGFloat) -> CGFloat{
        var targetY:CGFloat = -parentFrame.height;
        targetY += CGFloat(Int.random(in: 0..<Int(parentFrame.height/2.0)));
        return targetY;
    }
    
    func generateRadialTargetPoints(rows:Int, columns:Int) -> [[[CGFloat]]] {
        // Angle increment
        let angleIncrement:CGFloat = 360.0 / CGFloat(rows * columns);
        // Starting angle
        var currentAngle:CGFloat = CGFloat(Int.random(in: 0...360));
        // Save radial dispersement target points
        var radialDispersementTargetPoints:[[[CGFloat]]] = [[[CGFloat]]]();
        // Traverse through the rows of grid of buttons
        for row in 0..<rows {
            // Build row of target points
            var rowOfRadialDispersemenTargetPoints:[[CGFloat]] = [[CGFloat]]();
            // Traverse through the columns of grid of buttons
            for column in 0..<columns {
                // Save target coordinates in an array
                var coordinateTargetPoints:[CGFloat] = [CGFloat]();
                // Save current grid button
                let gridButton:UICButton = gridButtons[row][column];
                // Save the new displaced bounds of the grid button
                let x:CGFloat = gridButton.frame.minX + self.frame.minX / 2.0;
                let y:CGFloat = gridButton.frame.minY + self.frame.minY / 2.0;
                let width:CGFloat = gridButton.frame.width;
                let height:CGFloat = gridButton.frame.height;
                // Save a frame representing the displacement
                let displacedFrame:CGRect = CGRect(x: x, y: y, width: width, height: height);
                // Displace the frame onto the main view controller
                gridButton.frame = displacedFrame;
                self.superview!.addSubview(gridButton);
                // Add dead cat image to button
                gridButton.setCat(named: "deadCat.gif", stage: 2);
                gridButton.imageView!.layer.removeAllAnimations();
                // Generate target points
                var xTargetPoint:CGFloat = generateRadialTargetX(parentFrame:gridButton.superview!.frame, childFrame:gridButton.frame, angle:currentAngle);
                var yTargetPoint:CGFloat = generateRadialTargetY(parentFrame:gridButton.superview!.frame, childFrame:gridButton.frame, angle:currentAngle);
                if (row % 2 == 0 && column % 2 == 1) {
                    xTargetPoint *= -1;
                    yTargetPoint *= -1;
                }
                if (row % 2 == 1 && column % 2 == 1) {
                    xTargetPoint *= -1;
                }
                if (row % 2 == 1 && column % 2 == 0) {
                    yTargetPoint *= -1;
                }
                if (column % 2 == 1 && Int.random(in: 1...2) % 2 == 1) {
                    yTargetPoint *= -1;
                }
                // Build coordinate target points
                coordinateTargetPoints.append(xTargetPoint);
                coordinateTargetPoints.append(yTargetPoint);
                // Increment angle
                currentAngle += angleIncrement;
                // Add coordinate target points to row
                rowOfRadialDispersemenTargetPoints.append(coordinateTargetPoints);
            }
            // Add row to radial dispersement target points
            radialDispersementTargetPoints.append(rowOfRadialDispersemenTargetPoints);
        }
        return radialDispersementTargetPoints;
    }
    
    func generateRadialTargetX(parentFrame:CGRect, childFrame:CGRect, angle:CGFloat) -> CGFloat {
        var targetX:CGFloat = childFrame.minX;
        targetX += parentFrame.width + childFrame.width;
        targetX *= cos((CGFloat.pi * angle) / 180.0);
        return targetX;
    }
    
    func generateRadialTargetY(parentFrame:CGRect, childFrame:CGRect, angle:CGFloat) -> CGFloat {
        var targetY:CGFloat = childFrame.minY;
        targetY += parentFrame.height + childFrame.height;
        targetY *= sin((CGFloat.pi * angle) / 180.0);
        return targetY;
    }
    
    func disperse(targetPoints:[[[CGFloat]]], promote: Bool){
        for rows in 0..<targetPoints.count {
            for columns in 0..<targetPoints[rows].count {
                UIView.animate(withDuration: 2.5, delay: 0.25, options: .curveEaseIn, animations: {
                    // Save current grid button
                    let currentButton:UICButton = self.gridButtons[rows][columns];
                    if (!promote){
                        // Add rotation
                        currentButton.transform = currentButton.transform.rotated(by: CGFloat.pi);
                    }
                    // Build new frame
                    let newFrame:CGRect = CGRect(x: targetPoints[rows][columns][0], y: targetPoints[rows][columns][1], width: currentButton.frame.width, height: currentButton.frame.height);
                    // Disperse grid button
                    currentButton.frame = newFrame;
                });
            }
        }
    }
    
    func reset(promote:Bool){
        resetGame(promote: promote);
        currentStage = 1;
        loadGridButtonsToDispersedGridButtons();
        colorOptionsView!.loadSelectionButtonsToSelectedButtons();
        // Build board game
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            self.buildBoardGame();
        }
        // Remove dispersed buttons after they've dispersed
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.removeDispersedButtonsFromSuperView();
            self.colorOptionsView!.removeSelectedButtons();
        }
    }
    
    func promote(promote:Bool){
        resetGame(promote: promote);
        heavenGradientLayer!.configureForHidden(isHidden: false);
        loadGridButtonsToDispersedGridButtons();
        colorOptionsView!.loadSelectionButtonsToSelectedButtons();
        // Build board game
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            self.currentStage += 1;
            self.buildBoardGame();
            self.currentStage -= 1;
        }
        // Remove selected buttons after they've shrunk
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.removeDispersedButtonsFromSuperView();
            self.colorOptionsView!.removeSelectedButtons();
            self.currentStage += 1;
            self.heavenGradientLayer!.configureForHidden(isHidden: true);
        }
    }
    
    func maintain(promote:Bool){
        resetGame(promote: promote);
        loadGridButtonsToDispersedGridButtons();
        colorOptionsView!.loadSelectionButtonsToSelectedButtons();
        // Build board game
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            self.buildBoardGame();
        }
        // Remove dispersed buttons after they've dispersed
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.removeDispersedButtonsFromSuperView();
            self.colorOptionsView!.removeSelectedButtons();
        }
    }
    
    func loadGridButtonsToDispersedGridButtons() {
        let rowsAndColumns:[Int] = currentStageRowsAndColumns(currentStage: currentStage);
        for row in 0..<rowsAndColumns[0] {
            var currentButtonRow:[UICButton] = [UICButton]();
            for column in 0..<rowsAndColumns[1] {
                currentButtonRow.append(gridButtons[row][column]);
            }
            dispersedGridButtons.append(currentButtonRow);
        }
        gridButtons = [[UICButton]]();
    }
    
    func removeDispersedButtonsFromSuperView() {
        let rowsAndColumns:[Int] = currentStageRowsAndColumns(currentStage: currentStage);
        for row in 0..<rowsAndColumns[0] {
            for column in 0..<rowsAndColumns[1] {
                dispersedGridButtons[row][column].removeFromSuperview();
            }
        }
        dispersedGridButtons = [[UICButton]]();
    }
    
}
