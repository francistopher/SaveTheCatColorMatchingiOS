//
//  viruses.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/10/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIViruses {
    
    var virusCollection:[UIVirus]?
    var mainView:UIView? = nil;
    
    init(mainView:UIView, unitView:CGFloat){
        self.mainView = mainView;
        virusCollection = [];
        buildViruses(unitView: unitView);
    }
    
    func buildViruses(unitView:CGFloat) {
        // Calculate side and spacing lengths of virus
        let virusSideLength:CGFloat = unitView * 2.0;
        // Total Spacing Available
        let totalWidthSpacing:CGFloat = mainView!.frame.width - (virusSideLength * 4.0);
        let totalHeightSpacing:CGFloat = mainView!.frame.height - (virusSideLength * 5.0);
        // Virus Spacing Length
        let virusWidthSpacing:CGFloat = totalWidthSpacing / 1.625;
        let virusHeightSpacing:CGFloat = totalHeightSpacing / 2.75;
        // Initial starting coordinates
        var x:CGFloat = -virusWidthSpacing * 0.70125;
        var y:CGFloat = -virusHeightSpacing * 0.5;
        // Plot and build viruses
        for _ in 0..<3 {
            x += virusWidthSpacing;
            for _ in 0..<4 {
                y += virusHeightSpacing;
                let virus = UIVirus(parentView: mainView!, frame:CGRect(x: x, y: y, width: virusSideLength, height: virusSideLength));
                virusCollection!.append(virus);
                y += virusSideLength;
            }
            x += virusSideLength;
            y = -virusHeightSpacing * 0.5;
        }
    }
    
    func setStyle() {
        for virus in virusCollection! {
            virus.setVirusImage();
        }
    }
    
    func fadeIn(){
        // Fade each virus in
        for virus in self.virusCollection! {
            virus.fadeIn();
        }
    }
    
    func translateToCatAndBack(catButton:UICatButton){
        // Translate each virus to the center of the grid of cats
        for virus in self.virusCollection! {
            virus.translateToAndBackAt(xTarget: catButton.frame.midX, yTarget: catButton.frame.midY);
        }
    }
    
    func sway(){
        // Animate each virus
        for virus in self.virusCollection! {
            virus.sway();
        }
    }
    
    func hide() {
        // Hide each virus
        for virus in self.virusCollection! {
            virus.alpha = 0.0;
        }
    }
    
}
