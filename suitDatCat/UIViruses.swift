//
//  viruses.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/10/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIViruses {
    
    var backgroundVirusCollection:[UIVirus] = [UIVirus]();
    var gameSessionViruses:[UIVirus] = [UIVirus]();
    var cats:UICats = UICats();
    var spawnVirusTimer:Timer?
    // Types of cats
    var borderedCats:[UICatButton] = [];
    var unborderedCats:[UICatButton] = [];
    var coloredCats:[UICatButton] = [];
    // All the cat buttons and virus types
    var catButtons:[UICatButton] = [];
    var virusTypes:[Virus] = [];
    // Select cat and virus
    var targetCatButton:UICatButton? = nil;
    var virus:Virus? = nil;
    // Views
    var boardGameView:UIBoardGameView? = nil;
    var mainView:UIView? = nil;
    // Save target coordinates and width and height
    var xTarget:CGFloat = 0.0;
    var yTarget:CGFloat = 0.0;
    var virusWidth:CGFloat = 0.0;
    var virusHeight:CGFloat = 0.0;
    
    func targetCats(cats:UICats) {
        self.cats = cats;
        boardGameView = (cats.cats[0].superview! as! UIBoardGameView);
        mainView = boardGameView!.superview!;
        spawnVirusTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { _ in
            self.selectVirus();
            print("Firing");
        })
        self.selectVirus();
    }
    
    func selectVirus() {
        xTarget = 0.0;
        yTarget = 0.0;
        virusWidth = 0.0;
        virusHeight = 0.0;
        saveCatTypes();
        saveVirusTypesAndCatButtons();
        if (catButtons.count == 0) {
            return;
        }
        selectVirusAndCat();
        buildTargetCoordinates();
        buildVirus();
    }
    
    func selectVirusAndCat() {
        let randomIndex:Int = Int.random(in: 0..<catButtons.count);
        virus = virusTypes[randomIndex];
        targetCatButton = catButtons[randomIndex];
        targetCatButton!.isTargeted = true;
    }
    
    func buildTargetCoordinates() {
        xTarget += boardGameView!.frame.minX;
        yTarget += boardGameView!.frame.minY;
        xTarget += targetCatButton!.frame.minX;
        yTarget += targetCatButton!.frame.minY;
    }
    
    func buildVirus() {
        let virusFrame:CGRect = CGRect(x: xTarget, y: yTarget, width: targetCatButton!.frame.width, height: targetCatButton!.frame.height);
        let createdVirus:UIVirus = UIVirus(parentView: mainView!, frame: virusFrame, virus: virus!, targetCat: targetCatButton!);
        if (virus == Virus.ebolaRectangle || virus == Virus.ebolaSquare) {
            createdVirus.transform = createdVirus.transform.scaledBy(x: 1.35, y: 1.35);
        }
        mainView!.bringSubviewToFront(createdVirus);
    }
    
    func saveCatTypes() {
        borderedCats = cats.borderedCats();
        unborderedCats = cats.unBorderedCats();
        coloredCats = cats.coloredCats();
    }
    
    func saveVirusTypesAndCatButtons() {
        virusTypes = [];
        catButtons = [];
        for borderedCat in borderedCats {
            if (borderedCat.isTargeted || borderedCat.isPodded){
                continue;
            }
            catButtons.append(borderedCat);
            if (cats.isSquared()) {
                virusTypes.append(.ebolaSquare);
            } else {
                virusTypes.append(.ebolaRectangle);
            }
        }
        for unborderedCat in unborderedCats {
            if (unborderedCat.isTargeted || unborderedCat.isPodded) {
                continue;
            }
            catButtons.append(unborderedCat);
            virusTypes.append(.corona);
        }
        for coloredCat in coloredCats {
            if (coloredCat.isTargeted || coloredCat.isPodded) {
                continue;
            }
            catButtons.append(coloredCat);
            virusTypes.append(.bacteriophage);
        }
    }
    
    func fadeIn(){
        // Fade each virus in
        for virus in self.backgroundVirusCollection {
            virus.fadeIn();
        }
    }
    
    func translateToCatsAndBack(){
        // Translate each virus to the center of the grid of cats
        for virus in self.backgroundVirusCollection {
            virus.translateToCatsAndBack();
        }
    }
    
    func sway(){
        // Animate each virus
        for virus in self.backgroundVirusCollection {
            virus.sway();
        }
    }
    
    func hide() {
        // Hide each virus
        for virus in self.backgroundVirusCollection {
            virus.alpha = 0.0;
        }
    }
    
}
