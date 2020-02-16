//
//  UIColorOptionsView.swift
//  suitDatCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIColorOptionsView: UIView {
    
    var boardGameView:UIBoardGameView? = nil;
    var selectedColor:UIColor = UIColor.lightGray;
    var selectionColors:[UIColor] = [UIColor]();
    var selectionButtons:[UICButton] = [UICButton]();
    var selectedButtons:[UICButton] = [UICButton]();
    var isActive:Bool = false;
    
    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented");
    }

    init(parentView: UIView, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) {
        super.init(frame:CGRect(x: x, y: y, width: width, height: height));
        self.layer.cornerRadius = height / 5.0;
        parentView.addSubview(self);
        setStyle();
    }

    func fadeIn(){
      UIView.animate(withDuration: 2, delay: 0.5, options: .curveEaseIn, animations: {
          super.alpha = 1.0;
      })
    }
    
    func selectColorsForSelection(){
        let rowsAndColumns:[Int] = boardGameView!.currentStageRowsAndColumns(currentStage: boardGameView!.currentStage);
        for rows in 0..<rowsAndColumns[0]{
            for columns in 0..<rowsAndColumns[1]{
                if (!selectionColors.contains(boardGameView!.gridColors[rows][columns])){
                    selectionColors.append(boardGameView!.gridColors[rows][columns]);
                }
            }
        }
    }
    
    func buildColorOptionButtons(){
        let rowGap = (self.frame.height * 0.35) / 2.0;
        let columnGap = rowGap;
        let buttonHeight = (self.frame.height * 0.65);
        let buttonWidth = (self.frame.width - (rowGap * CGFloat(selectionColors.count + 1))) / CGFloat(selectionColors.count);
        var currentButton:UICButton? = nil;
        var currentColumnDisplacement:CGFloat = 0.0;
        for index in 0..<selectionColors.count {
            currentColumnDisplacement += columnGap;
            currentButton = UICButton(parentView: self,  frame:CGRect(x: currentColumnDisplacement, y: rowGap, width: buttonWidth, height: buttonHeight), backgroundColor: selectionColors[index]);
            currentButton!.frame = currentButton!.shrunkFrame!;
            currentButton!.grow();
            currentButton!.addTarget(self, action: #selector(selectColorOption), for: .touchUpInside);
            selectionButtons.append(currentButton!);
            currentColumnDisplacement += buttonWidth;
        }
    }
    
    @objc func selectColorOption(sender:UICButton!){
        isActive = true;
        let receiverButton:UICButton = sender;
        selectedColor = receiverButton.backgroundColor!;
        transitionBackgroundColorOfButtonsToLightGray();
        for selectionButton in selectionButtons{
            if (selectionButton.isEqual(receiverButton)){
                receiverButton.select();
            } else {
                selectionButton.unSelect();
            }
            
        }
    }
    
    @objc func transitionBackgroundColorOfButtonsToLightGray(){
        let rowsAndColumns:[Int] = boardGameView!.currentStageRowsAndColumns(currentStage: boardGameView!.currentStage);
        print(boardGameView!.solved);
        if (!boardGameView!.gridCatButtons[0][0].backgroundColor!.isEqual(UIColor.lightGray) && boardGameView!.solved){
            for rows in 0..<rowsAndColumns[0]{
                for columns in 0..<rowsAndColumns[1]{
                    boardGameView!.gridCatButtons[rows][columns].imageContainerButton!.fadeBackgroundIn(color:UIColor.lightGray);
                    boardGameView!.gridCatButtons[rows][columns].fadeBackgroundIn(color: UIColor.lightGray);
                }
            }
            boardGameView!.solved = false;
        }
    }
    
    func loadSelectionButtonsToSelectedButtons(){
        for selectionButtons in selectionButtons{
            selectedButtons.append(selectionButtons);
            selectionButtons.shrink();
        }
        selectionButtons = [UICButton]();
    }
    
    func removeSelectedButtons(){
        for selectedButtons in selectedButtons{
            selectedButtons.removeFromSuperview();
        }
        selectedButtons = [UICButton]();
    }
    
    func setStyle() {
        for selectionButton in selectionButtons {
            selectionButton.setStyle();
        }
        for selectedButton in selectedButtons {
            selectedButton.setStyle();
        }
    }
    
    
    
    
    
    
}
