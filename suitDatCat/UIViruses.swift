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
    var catButtons:[UICatButton] = [];
    var virusTypes:[Virus] = [];
    
    enum Virus{
        case corona
        case ebolaSquare
        case bacteriophage
        case ebolaRectangle
    }
    
    func targetCats(cats:UICats) {
        self.cats = cats;
        spawnVirusTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { _ in
            self.selectVirus();
        })
        self.selectVirus();
    }
    
    func selectVirus() {
        saveCatTypes();
        saveVirusTypesAndCatButtons();
        if (catButtons.count == 0) {
            return;
        }
        spawnVirus();
    }
    
    func spawnVirus() {
        let randomIndex:Int = Int.random(in: 0..<catButtons.count);
        let selectedCatButton:UICatButton = catButtons[randomIndex];
        print(virusTypes[randomIndex]);
        selectedCatButton.isTargeted = true;
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
            if (borderedCat.isTargeted){
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
            if (unborderedCat.isTargeted) {
                continue;
            }
            catButtons.append(unborderedCat);
            virusTypes.append(.corona);
        }
        for coloredCat in coloredCats {
            if (coloredCat.isTargeted) {
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
            virus.hide();
        }
    }
    
}
