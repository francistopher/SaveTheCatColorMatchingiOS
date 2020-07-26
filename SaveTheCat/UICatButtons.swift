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
        previousCollection = [UICatButton]();
    }
    
    /*
        Builds the cat button based on the
        frame and a background color
     */
    var catButton:UICatButton?
    func buildCatButton(parent:UIView, frame:CGRect, backgroundColor:UIColor) -> UICatButton {
        catButton = UICatButton(parentView: parent, x: frame.minX, y: frame.minY, width: frame.width, height: frame.height, backgroundColor: backgroundColor);
        catButton!.settingsButton = ViewController.settingsButton!;
        catButton!.settingsMenuFrame = ViewController.settingsButton!.settingsMenu!.frame;
        catButton!.grow();
        catButton!.imageContainerButton!.grow();
        catButton!.setCat(named: "SmilingCat", stage:0);
        if (ViewController.settingsButton!.isPressed) {
            catButton!.fadeBackgroundOut();
        }
        presentCollection!.append(catButton!);
        return catButton!;
    }
    
    /*
        Returns whether or not a cat is still
        available to become podded
     */
    func oneIsNeitherPoddedOrDead() -> Bool {
        for catButton in presentCollection! {
            if (!catButton.isPodded && catButton.isAlive) {
                return true;
            }
        }
        return false;
    }
    
    /*
        Returns whether or not
        there is a single cat alive
     */
    func onlyOneIsAlive() -> Bool {
        var aliveCount:Int = 0;
        for catButton in presentCollection! {
            if (catButton.isAlive) {
                aliveCount += 1;
            }
        }
        if (aliveCount == 1) {
            return true;
        } else {
            return false;
        }
    }
    
    /*
        Returns whether or not
        a single cat is still alive
     */
    func atLeastOneIsAlive() -> Bool {
        for catButton in presentCollection! {
            if (catButton.isAlive) {
                return true;
            }
        }
        return false;
    }
    
    /*
        Returns whether or not the
        cats all survived
     */
    func didAllSurvive() -> Bool {
        for catButton in presentCollection! {
            if (!catButton.isAlive) {
                return false;
            }
        }
        return true;
    }
    
    /*
        Saves remaining cats and reward
        the user based on the count
     */
    func podAliveOnesAndGiveMouseCoin() {
        for catButton in presentCollection! {
            if (catButton.isAlive) {
                catButton.pod();
                catButton.giveMouseCoin(withNoise: true);
            }
        }
    }
    
    /*
        Returns the number of cats alive
     */
    func countOfAliveCatButtons() -> Int {
        var count:Int = 0;
        for catButton in presentCollection! {
            if (catButton.isAlive) {
                count += 1;
            }
        }
        return count;
    }
    
    /*
        Returns a cat button with a color
     */
    func getCatButtonWith(backgroundColor:UIColor) -> UICatButton {
        for catButton in presentCollection!.reversed() {
            if (catButton.backgroundCGColor! == backgroundColor.cgColor) {
                return catButton;
            }
        }
        return presentCollection![0];
    }
    
    func count() -> Int {
        return presentCollection!.count;
    }
    
    func reset() {
        presentCollection!.removeAll();
    }
    
    func loadPreviousCats() {
        for cat in presentCollection! {
            previousCollection!.append(cat);
        }
    }

    /*
        Returns a boolan indicating whether
        or not the cats are alive
     */
    func areAllCatsDead() -> Bool {
        for catButton in presentCollection! {
            if (catButton.isAlive) {
                return false;
            }
        }
        return true;
    }
    
    /*
        Returns whether or not all
        the alive cats are podded
     */
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
    
    /*
        Shrinks all the cat buttons to their own center
     */
    func shrink() {
        for catButton in presentCollection! {
            catButton.shrink();
        }
    }
    
    /*
        Translate all the cats past the top of the screen
     */
    func disperseVertically() {
        for catButton in presentCollection! {
            if (catButton.isAlive) {
                 catButton.disperseVertically();
            }
        }
    }
    
    /*
        Returns all the cat buttons that
        are still alive in a given row
     */
    func getRowOfAliveCats(rowIndex:Int) -> [UICatButton] {
        var rowOfAliveCats:[UICatButton] = [];
        for catButton in presentCollection! {
            if (catButton.rowIndex == rowIndex && catButton.isAlive) {
                rowOfAliveCats.append(catButton);
            }
        }
        return rowOfAliveCats;
    }
    
    /*
        Updates all the states of the cats
     */
    var previousFileName:String = "";
    func updateCatType() {
        for catButton in presentCollection! {
            catButton.selectedCat = ViewController.getRandomCat();
            previousFileName = catButton.previousFileName;
            if (previousFileName.contains(String("Smiling"))) {
                catButton.setCat(named: "SmilingCat", stage: 3);
            } else if (previousFileName.contains(String("Cheering"))) {
                catButton.setCat(named: "CheeringCat", stage: 3);
            } else {
                catButton.setCat(named: "DeadCat", stage: 3);
            }
        }
    }
    
    /*
        Returns a list of indexes with the
        number of cat buttons alive in each row
     */
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
    
    /*
        Disperses all the cat buttons
        from the center of the screen
     */
    func disperseRadially() {
        for catButton in presentCollection! {
            if (catButton.isAlive) {
                catButton.disperseRadially();
            }
        }
    }
    
    /*
        Start cats swinging back and forth
     */
    func resumeCatAnimations() {
        for catButton in presentCollection! {
            catButton.animate(AgainWithoutDelay: true);
        }
    }
    
    /*
        Updates all the cat buttons colors
        based on the operating system theme
     */
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
            presentCollection![catIndex].updateUIStyle();
        }
    }
    
    /*
        Cancels the back and forth animation
        of all the cat buttons
     */
    func suspendCatAnimations() {
        for catButton in presentCollection! {
            catButton.hideCat();
        }
    }
    
    /*
        Updates all the cat button's background
        color to be transparent
     */
    func transitionCatButtonBackgroundToClear() {
        for catButton in presentCollection! {
            catButton.fadeBackgroundIn(color: UIColor.clear, duration: 0.5, delay: 0.125);
            catButton.clearedOutToSolve = true;
            if (catButton.imageContainerButton != nil) {
                catButton.imageContainerButton!.backgroundColor = UIColor.clear;
            }
            
        }
    }
    
    /*
        Returns a cat button that hasn't perished
     */
    var randomCatButton:UICatButton?
    func getRandomCatThatIsAlive() -> UICatButton {
        while (true) {
            randomCatButton = presentCollection!.randomElement()!;
            if (randomCatButton!.isAlive && !randomCatButton!.isPodded) {
                return randomCatButton!;
            }
        }
    }
    
    func clearCatButtons() {
        for catButton in presentCollection! {
            if (!catButton.isPodded && !catButton.clearedOutToSolve) {
                if (catButton.imageContainerButton != nil) {
                    catButton.imageContainerButton!.backgroundColor = UIColor.clear;
                }
                catButton.fadeBackgroundIn(color: UIColor.clear, duration: 0.5, delay: 0.125);
            }
        }
    }
    
    /*
        Recolor all the cat buttons with their
        original background color
     */
    func unClearCatButtons() {
        for catButton in presentCollection! {
            if (!catButton.isPodded && !catButton.clearedOutToSolve) {
                catButton.fadeBackgroundIn(color: catButton.originalBackgroundColor, duration: 0.5, delay: 0.125);
            }
            
        }
    }
}
