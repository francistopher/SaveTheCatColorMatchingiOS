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
    // Target frame
    var xTarget:CGFloat = 0.0;
    var yTarget:CGFloat = 0.0;
    var widthTarget:CGFloat = 0.0;
    var heightTarget:CGFloat = 0.0;
    // Spawn frame
    var xSpawn:CGFloat = 0.0;
    var ySpawn:CGFloat = 0.0;
    
    func targetCats(cats:UICats) {
        self.cats = cats;
        boardGameView = (cats.cats[0].superview! as! UIBoardGameView);
        mainView = boardGameView!.superview!;
        spawnVirusTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { _ in
            self.selectVirus();
        })
        self.selectVirus();
    }
    
    func selectVirus() {
        xTarget = 0.0;
        yTarget = 0.0;
        widthTarget = 0.0;
        heightTarget = 0.0;
        saveCatTypes();
        saveVirusTypesAndCatButtons();
        if (catButtons.count == 0) {
            return;
        }
        selectVirusAndCat();
        buildTargetCoordinates();
        buildSpawnCoordinates();
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
    
    func buildSpawnCoordinates() {
        let spawnSide:Int = Int.random(in: 0...3);
        if (spawnSide == 0) {
            xSpawn = CGFloat.random(in: 0..<mainView!.frame.width);
            ySpawn = -targetCatButton!.frame.height;
        } else if (spawnSide == 1) {
            xSpawn = CGFloat.random(in: 0..<mainView!.frame.width);
            ySpawn = mainView!.frame.height;
        } else if (spawnSide == 2) {
            xSpawn = -targetCatButton!.frame.width;
            ySpawn = CGFloat.random(in: 0..<mainView!.frame.height);
        } else if (spawnSide == 3) {
            xSpawn = mainView!.frame.width;
            ySpawn = CGFloat.random(in: 0..<mainView!.frame.height);
        }
    }
    
    func buildVirus() {
        let spawnFrame:CGRect = CGRect(x: xSpawn, y: ySpawn, width: targetCatButton!.frame.width, height: targetCatButton!.frame.height);
        let targetFrame:CGRect = CGRect(x: xTarget, y: yTarget, width: targetCatButton!.frame.width, height: targetCatButton!.frame.height);
        let builtVirus:UIVirus = UIVirus(parentView: mainView!, spawnFrame: spawnFrame, targetFrame:targetFrame, virus: virus!, targetCat: targetCatButton!);
        if (virus == Virus.ebolaRectangle || virus == Virus.ebolaSquare) {
            builtVirus.transform = builtVirus.transform.scaledBy(x: 1.35, y: 1.35);
        }
        targetCatButton!.virus = builtVirus;
        mainView!.bringSubviewToFront(builtVirus);
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
            if (borderedCat.isTargeted || borderedCat.isPodded || !borderedCat.isAlive){
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
            if (unborderedCat.isTargeted || unborderedCat.isPodded || !unborderedCat.isAlive) {
                continue;
            }
            catButtons.append(unborderedCat);
            virusTypes.append(.corona);
        }
        for coloredCat in coloredCats {
            if (coloredCat.isTargeted || coloredCat.isPodded || !coloredCat.isAlive) {
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
