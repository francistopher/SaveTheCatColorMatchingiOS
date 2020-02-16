//
//  UICats.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/16/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UICats {
    
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
    
    func reset() {
        loadPreviousCats();
        cats = [UICatButton]();
    }
    
    func loadPreviousCats() {
        previousCats = [UICatButton]();
        for cat in cats {
            previousCats.append(cat);
        }
    }
    
    func giveMouseCoins() {
        var count:Int = 0;
        for catButtonIndex in 0..<cats.count {
            if (catButtonIndex == count) {
                cats[catButtonIndex].giveMouseCoin(withNoise: true);
                count += 1;
            }
            cats[catButtonIndex].giveMouseCoin(withNoise: false);
            count += count;
        }
    }
    
    func areAllColored() -> Bool {
        for catButton in cats {
            if (catButton.imageContainerButton!.backgroundColor!.cgColor == UIColor.lightGray.cgColor) {
                return false;
            }
        }
        return true;
    }
    
    func disperseVertically() {
        for catButton in cats {
            catButton.disperseVertically();
        }
    }
    
    func disperseRadially() {
        for catButton in cats {
            catButton.disperseRadially();
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
