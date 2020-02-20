//
//  UICats.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/16/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UICatButtons {
    
    var cats:[UICatButton] = [UICatButton]();
    var previousCats:[UICatButton] = [UICatButton]();
    
    init() {
        print("Building Cats")
    }
    
    func buildCatButton(parent:UIView, frame:CGRect, backgroundColor:UIColor) -> UICatButton {
        let catButton:UICatButton = UICatButton(parentView: parent, x: frame.minX, y: frame.minY, width: frame.width, height: frame.height, backgroundColor: backgroundColor);
        catButton.grow();
        catButton.imageContainerButton!.grow();
        catButton.setCat(named: "SmilingCat", stage:0);
        cats.append(catButton);
        return catButton;
    }
    
    func coloredCats() -> [UICatButton] {
        var coloredCats:[UICatButton] = [UICatButton]();
        for catButton in cats {
            if (catButton.backgroundColor!.cgColor != UIColor.lightGray.cgColor) {
                coloredCats.append(catButton);
            }
        }
        return coloredCats;
    }
    
    func borderedCats() -> [UICatButton] {
        var borderedCats:[UICatButton] = [UICatButton]();
        for catButton in cats {
            if (catButton.layer.borderWidth != 0.0) {
                borderedCats.append(catButton);
            }
        }
        return borderedCats;
    }
    
    func count() -> Int {
        return cats.count;
    }
    
    func reset() {
        loadPreviousCats();
        cats.removeAll();
    }
    
    func loadPreviousCats() {
        previousCats = [UICatButton]();
        for cat in cats {
            previousCats.append(cat);
        }
    }
    
    func setAsDead() {
        for catButton in cats {
            catButton.setAsDead();
        }
    }
    
    func arePodded() -> Bool{
        for catButton in cats {
            if (!catButton.isPodded) {
                return false;
            }
        }
        return true;
    }
    
    func disperseVertically() {
        for catButton in cats {
            if (catButton.isAlive) {
                 catButton.disperseVertically();
            }
        }
    }
    
    func disperseRadially() {
        for catButton in cats {
            if (catButton.isAlive) {
                catButton.disperseRadially();
            }
        }
    }
    
    func resumeCatAnimations() {
        for catButton in cats {
            catButton.animate(AgainWithoutDelay: true);
        }
    }
    
    func activateCatsForUIStyle() {
        for catIndex in 0..<cats.count {
            if (cats.count == 0) {
                previousCats[catIndex].animate(AgainWithoutDelay: false);
                previousCats[catIndex].setStyle();
            } else {
                cats[catIndex].animate(AgainWithoutDelay: false);
                cats[catIndex].setStyle();
            }
        }
    }
    
    func suspendCatAnimations() {
        for catButton in cats {
            catButton.hideCat();
        }
    }
    
    func transitionCatButtonBackgroundToLightgrey() {
        for catButton in cats {
            catButton.imageContainerButton!.fadeBackgroundIn(color:UIColor.lightGray);
            catButton.fadeBackgroundIn(color: UIColor.lightGray);
        }
    }
    
    func removePreviousCatButtonsFromSuperView() {
        for catButton in previousCats {
            catButton.removeFromSuperview();
        }
    }
}
