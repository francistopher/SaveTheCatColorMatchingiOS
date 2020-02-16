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
    var gamePlayVirusCollection:[UIVirus] = [UIVirus]();
    var boardGameView:UIBoardGameView? = nil;
    var mainView:UIView? = nil;
    
    init(mainView:UIView, unitView:CGFloat){
        self.mainView = mainView;
    }
    
    func addVirusToGamePlay() {
        
    }
    
    func getNotTargetedIndex() -> [Int] {
        let randomX:Int = Int.random(in: 0..<boardGameView!.gridCatButtons.count);
        let randomY:Int = Int.random(in: 0..<boardGameView!.gridCatButtons[0].count);
        if (!boardGameView!.gridCatButtons[randomX][randomY].isTargeted) {
            
        }
        return [-1, -1];
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
