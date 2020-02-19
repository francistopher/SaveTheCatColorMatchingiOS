//
//  UIColorOptionsView.swift
//  suitDatCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIColorOptions: UIView {
    
    var colors:[UIColor] = [UIColor.systemGreen, UIColor.systemYellow, UIColor.systemOrange, UIColor.systemRed, UIColor.systemPurple, UIColor.systemBlue];
    var boardGameView:UIBoardGame? = nil;
    var selectedColor:UIColor = UIColor.lightGray;
    var selectionColors:[UIColor] = [UIColor]();
    var selectionButtons:[UICButton] = [UICButton]();
    var selectedButtons:[UICButton] = [UICButton]();
    var isTransitioned:Bool = false;
    
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
        let rowsAndColumns:[Int] = boardGameView!.getRowsAndColumns(currentStage: boardGameView!.currentStage);
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
        var button:UICButton? = nil;
        var columnDisplacement:CGFloat = 0.0;
        for selectionColor in selectionColors {
            columnDisplacement += columnGap;
            button = UICButton(parentView: self,  frame:CGRect(x: columnDisplacement, y: rowGap, width: buttonWidth, height: buttonHeight), backgroundColor: selectionColor);
            button!.frame = button!.shrunkFrame!;
            button!.grow();
            button!.addTarget(self, action: #selector(selectColorOption), for: .touchUpInside);
            selectionButtons.append(button!);
            columnDisplacement += buttonWidth;
        }
    }
    
    @objc func selectColorOption(sender:UICButton!){
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
        if (!isTransitioned){
            print("Transitioning!");
            boardGameView!.cats.transitionCatButtonBackgroundToLightgrey();
            isTransitioned = true;
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

