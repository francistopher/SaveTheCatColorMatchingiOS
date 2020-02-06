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
    
    
}
