//
//  viruses.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/10/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIViruses {
    
    var virusCollection:[UIVirus] = [UIVirus]();
    var mainView:UIView? = nil;
    
    init(mainView:UIView, unitView:CGFloat){
        self.mainView = mainView;
    }
    
    func generateVirus() {
        
    }
    
    func fadeIn(){
        // Fade each virus in
        for virus in self.virusCollection {
            virus.fadeIn();
        }
    }
    
    func translateToCatsAndBack(){
        // Translate each virus to the center of the grid of cats
        for virus in self.virusCollection {
            virus.translateToCatsAndBack();
        }
    }
    
    func sway(){
        // Animate each virus
        for virus in self.virusCollection {
            virus.sway();
        }
    }
    
    func hide() {
        // Hide each virus
        for virus in self.virusCollection {
            virus.hide();
        }
    }
    
}
