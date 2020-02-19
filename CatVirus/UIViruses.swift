//
//  viruses.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/10/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIViruses {
    
    var backgroundVirusCollection:[UIVirus]?
    
    func fadeIn(){
        // Fade each virus in
        for virus in self.backgroundVirusCollection! {
            virus.fadeIn();
        }
    }
    
    func translateToCatsAndBack(){
        // Translate each virus to the center of the grid of cats
        for virus in self.backgroundVirusCollection! {
            virus.translateToCatsAndBack();
        }
    }
    
    func sway(){
        // Animate each virus
        for virus in self.backgroundVirusCollection! {
            virus.sway();
        }
    }
    
    func hide() {
        // Hide each virus
        for virus in self.backgroundVirusCollection! {
            virus.alpha = 0.0;
        }
    }
    
}
