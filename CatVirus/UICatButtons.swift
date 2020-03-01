//
//  UICats.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/16/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UICatButtons {
    
    var presentCollection:[UICatButton]?
    var previousCollection:[UICatButton]?
    
    init() {
        presentCollection = [UICatButton]();
    }
    
    func buildCatButton(parent:UIView, frame:CGRect, backgroundColor:UIColor) -> UICatButton {
        let catButton:UICatButton = UICatButton(parentView: parent, x: frame.minX, y: frame.minY, width: frame.width, height: frame.height, backgroundColor: backgroundColor);
        catButton.grow();
        catButton.imageContainerButton!.grow();
        catButton.setCat(named: "SmilingCat", stage:0);
        presentCollection!.append(catButton);
        return catButton;
    }
    
    func isOneAlive() -> Bool {
        for catButton in presentCollection! {
            if (catButton.isAlive) {
                return true;
            }
        }
        return false;
    }
    
    func didAllSurvive() -> Bool {
        for catButton in presentCollection! {
            if (!catButton.isAlive) {
                return false;
            }
        }
        return true;
    }
    
    func count() -> Int {
        return presentCollection!.count;
    }
    
    func reset() {
        presentCollection!.removeAll();
    }
    
    func loadPreviousCats() {
        previousCollection = [UICatButton]();
        for cat in presentCollection! {
            previousCollection!.append(cat);
        }
    }
    
    func areNowDead() {
        for catButton in presentCollection! {
            catButton.isDead();
        }
    }
    
    func areAllCatsDead() -> Bool {
        for catButton in presentCollection! {
            if (catButton.isAlive) {
                return false;
            }
        }
        return true;
    }
    
    func aliveCatsArePodded() -> Bool{
        for catButton in presentCollection! {
            if (catButton.isAlive){
                if (!catButton.isPodded) {
                    return false;
                }
            }
            
        }
        return true;
    }
    
    func shrink() {
        for catButton in presentCollection! {
            catButton.shrink();
        }
    }
    
    func disperseVertically() {
        for catButton in presentCollection! {
            if (catButton.isAlive) {
                 catButton.disperseVertically();
            }
        }
    }
    
    func getRowOfAliveCats(rowIndex:Int) -> [UICatButton] {
        var rowOfAliveCats:[UICatButton] = [];
        for catButton in presentCollection! {
            if (catButton.rowIndex == rowIndex && catButton.isAlive) {
                rowOfAliveCats.append(catButton);
            }
        }
        return rowOfAliveCats;
    }
    
    func getIndexesOfRowsWithAliveCatsCount() -> [Int:Int] {
        var indexesOfRowsWithAliveCatsCount:[Int:Int] = [:];
        for catButton in presentCollection! {
            if (getRowOfAliveCats(rowIndex: catButton.rowIndex).count > 0) {
                if (indexesOfRowsWithAliveCatsCount[catButton.rowIndex] == nil) {
                    indexesOfRowsWithAliveCatsCount[catButton.rowIndex] = 1;
                } else {
                    indexesOfRowsWithAliveCatsCount[catButton.rowIndex]! += 1;
                }
            }
        }
        return indexesOfRowsWithAliveCatsCount;
    }
    
    func disperseRadially() {
        for catButton in presentCollection! {
            if (catButton.isAlive) {
                catButton.disperseRadially();
            }
        }
    }
    
    func resumeCatAnimations() {
        for catButton in presentCollection! {
            catButton.animate(AgainWithoutDelay: true);
        }
    }
    
    func activateCatsForUIStyle() {
        for catIndex in 0..<presentCollection!.count {
            if (presentCollection!.count == 0) {
                presentCollection![catIndex].animate(AgainWithoutDelay: false);
                presentCollection![catIndex].setStyle();
            } else {
                presentCollection![catIndex].animate(AgainWithoutDelay: false);
                presentCollection![catIndex].setStyle();
            }
        }
    }
    
    func updateUIStyle() {
        for catIndex in 0..<presentCollection!.count {
            if (presentCollection!.count == 0) {
                presentCollection![catIndex].updateUIStyle();
            } else {
                presentCollection![catIndex].updateUIStyle();
            }
        }
    }
    
    func suspendCatAnimations() {
        for catButton in presentCollection! {
            catButton.hideCat();
        }
    }
    
    func transitionCatButtonBackgroundToClear() {
        for catButton in presentCollection! {
            catButton.imageContainerButton!.backgroundColor = UIColor.clear;
            catButton.fadeBackgroundIn(color: UIColor.clear);
        }
    }
    
    func getRandomCatThatIsAlive() -> UICatButton {
        while (true) {
            let randomCatButton:UICatButton = presentCollection!.randomElement()!;
            if (randomCatButton.isAlive && !randomCatButton.isPodded) {
                return randomCatButton;
            }
        }
    }
}
