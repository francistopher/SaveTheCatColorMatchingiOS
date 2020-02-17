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
    var virusTypes:[Virus] = [];
    var virusSelected:Virus? = nil;
    var targetCatButton:UICatButton? = nil;
    
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
        saveVirusTypes();
        virusSelected = virusTypes.randomElement()!;
        selectTargetCatButton();
        spawnVirus();
    }
    
    func spawnVirus() {
        print(targetCatButton!.originalBackgroundColor);
    }
    
    func selectTargetCatButton() {
        switch (virusSelected) {
        case .corona:
            targetCatButton = unborderedCats.randomElement();
        case .ebolaSquare:
            targetCatButton = borderedCats.randomElement();
        case .ebolaRectangle:
            targetCatButton = borderedCats.randomElement();
        case .bacteriophage:
            targetCatButton = coloredCats.randomElement();
        case .none:
            print("No none");
        }
    }
    
    func saveCatTypes() {
        borderedCats = cats.borderedCats();
        unborderedCats = cats.unBorderedCats();
        coloredCats = cats.coloredCats();
    }
    
    func saveVirusTypes() {
        virusTypes = [];
        for _ in borderedCats {
            if (cats.isSquared()) {
                virusTypes.append(.ebolaSquare);
            } else {
                virusTypes.append(.ebolaRectangle);
            }
        }
        for _ in unborderedCats {
            virusTypes.append(.corona);
        }
        for _ in coloredCats {
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
