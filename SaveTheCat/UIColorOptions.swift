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
    var selectedColor:UIColor = UIColor.lightGray;
    var selectionButtons:[UICButton] = [UICButton]();
    var selectedButtons:[UICButton] = [UICButton]();
    var selectionColors:[UIColor] = [UIColor]();
    var boardGameView:UIBoardGame? = nil;
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
    
    func shrinkColorOptions() {
        for selectionButton in selectionButtons {
            selectionButton.shrinkType = .mid;
            selectionButton.shrink(colorOptionButton: true);
        }
    }
    
    func selectSelectionColors(){
        selectionColors =  [UIColor.systemGreen, UIColor.systemYellow, UIColor.systemOrange, UIColor.systemRed, UIColor.systemPurple, UIColor.systemBlue];
        repeat {
            let index:Int = Int.random(in: 0..<selectionColors.count);
            selectionColors.remove(at: index);
            if (selectionColors.count == boardGameView!.rowAndColumnNums[0] || selectionColors.count == 6) {
                break;
            }
        } while(true);
    }
    
    func removeBorderOfSelectionButtons() {
        for selectionButton in selectionButtons {
            selectionButton.layer.borderWidth = 0.0;
        }
    }
    
    func buildColorOptionButtons(setup:Bool){
        let numOfUniqueGridColors:Int = boardGameView!.nonZeroGridColorsCount();
        let columnGap = (self.frame.width * 0.1) / CGFloat(numOfUniqueGridColors + 1);
        let rowGap = self.frame.height * 0.1;
        let buttonWidth = (self.frame.width - (columnGap * CGFloat(numOfUniqueGridColors + 1))) / CGFloat(numOfUniqueGridColors);
        let buttonHeight = (self.frame.height - (rowGap * 2.0));
        var button:UICButton? = nil;
        var columnDisplacement:CGFloat = 0.0;
        var index:Int = 0;
        var count:Int = 0;
        for (selectionColor, colorCount) in boardGameView!.gridColorsCount {
            if (setup) {
                columnDisplacement += columnGap;
                button = UICButton(parentView: self,  frame:CGRect(x: columnDisplacement, y: rowGap, width: buttonWidth, height: buttonHeight), backgroundColor: UIColor(cgColor: selectionColor));
                button!.frame = button!.shrunkFrame!;
                button!.grow();
                button!.addTarget(self, action: #selector(selectColorOption), for: .touchUpInside);
                selectionButtons.append(button!);
                columnDisplacement += buttonWidth;
            } else {
                let revisitedButton:UICButton = selectionButtons[index];
                if (colorCount != 0) {
                    columnDisplacement += columnGap;
                    var newFrame:CGRect = CGRect(x: columnDisplacement, y: rowGap, width: buttonWidth, height: buttonHeight);
                    if (revisitedButton.isSelected) {
                        newFrame = CGRect(x: columnDisplacement, y: revisitedButton.frame.minY, width: buttonWidth, height: buttonHeight * 1.375);
                    }
                    revisitedButton.translate(newOriginalFrame: newFrame);
                    if (!revisitedButton.isSelected) {
                        revisitedButton.frame = revisitedButton.originalFrame!;
                    }
                    columnDisplacement += buttonWidth;
                } else {
                    // Select another unshrunk
                    if (revisitedButton.isSelected) {
                        revisitedButton.willBeShrunk = true;
                        for selectionButton in selectionButtons.reversed() {
                            if (!selectionButton.willBeShrunk) {
                                selectionButton.sendActions(for: .touchUpInside);
                            }
                        }
                    }
                    count += 1;
                    if (numOfUniqueGridColors + 1 == 1) {
                        revisitedButton.shrinkType = .mid;
                    } else if (numOfUniqueGridColors + 1 == 2) {
                        if (count > index) {
                            revisitedButton.shrinkType = .left;
                        } else {
                            revisitedButton.shrinkType = .right;
                        }
                    } else {
                        if (count > index) {
                            revisitedButton.shrinkType = .left;
                        } else if (index == numOfUniqueGridColors) {
                            revisitedButton.shrinkType = .right;
                        } else {
                            revisitedButton.shrinkType = .mid;
                        }
                    }
                    revisitedButton.shrink(colorOptionButton: true);
                }
                index += 1;
            }
        }
        if (setup && boardGameView!.currentRound == 1) {
            boardGameView!.statistics!.sessionStartTime = CFAbsoluteTimeGetCurrent();
        }
    }
    
    @objc func selectColorOption(colorOption:UICButton!){
        if (colorOption.backgroundColor!.cgColor == selectedColor.cgColor){
            return;
        }
        selectedColor = colorOption.backgroundColor!;
        boardGameView!.transitionBackgroundColorOfButtonsToClear();
        for selectionButton in selectionButtons{
            if (selectionButton.isEqual(colorOption)){
                colorOption.select();
            } else {
                selectionButton.unSelect();
            }
        }
        
    }
    
    func loadSelectionButtonsToSelectedButtons(){
        for selectionButtons in selectionButtons{
            selectedButtons.append(selectionButtons);
            selectionButtons.shrinkType = .mid;
            selectionButtons.shrink(colorOptionButton: true);
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
