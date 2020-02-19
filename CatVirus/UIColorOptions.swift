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
    
    func selectSelectionColors(){
        selectionColors =  [UIColor.systemGreen, UIColor.systemYellow, UIColor.systemOrange, UIColor.systemRed, UIColor.systemPurple, UIColor.systemBlue];
        repeat {
            let index:Int = Int.random(in: 0..<selectionColors.count);
            selectionColors.remove(at: index);
            if (selectionColors.count == boardGameView!.columnsAndRows[1] || selectionColors.count == 6) {
                break;
            }
        } while(true);
    }
    
    func buildColorOptionButtons(){
        let numOfUniqueGridColors:Int = boardGameView!.gridColorsCount.count;
        let rowGap = (self.frame.height * 0.35) / 2.0;
        let columnGap = rowGap;
        let buttonHeight = (self.frame.height * 0.65);
        let buttonWidth = (self.frame.width - (rowGap * CGFloat(numOfUniqueGridColors + 1))) / CGFloat(numOfUniqueGridColors);
        var button:UICButton? = nil;
        var columnDisplacement:CGFloat = 0.0;
        for (selectionColor, _) in boardGameView!.gridColorsCount {
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

