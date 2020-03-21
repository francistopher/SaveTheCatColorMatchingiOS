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
    var mainView:UIView?
    
    init(mainView:UIView, unitView:CGFloat){
        self.mainView = mainView;
        virusCollection = [];
        buildViruses(unitView: unitView);
    }
    
    var virusSideLength:CGFloat?
    var totalWidthSpacing:CGFloat?
    var totalHeightSpacing:CGFloat?
    var virusWidthSpacing:CGFloat?
    var virusHeightSpacing:CGFloat?
    var x:CGFloat?
    var y:CGFloat?
    
    func buildViruses(unitView:CGFloat) {
        // Calculate side and spacing lengths of virus
        virusSideLength = unitView * 2.0;
        // Total Spacing Available
        totalWidthSpacing = mainView!.frame.width - (virusSideLength! * 3.0);
        totalHeightSpacing = mainView!.frame.height - (virusSideLength! * 4.0);
        // Virus Spacing Length
        virusWidthSpacing = totalWidthSpacing! / 2.625;
        virusHeightSpacing = totalHeightSpacing! / 4.0;
        // Initial starting coordinates
        x = -virusWidthSpacing! * 0.70125;
        y = -virusHeightSpacing! * 0.45;
        // Plot and build viruses
        for _ in 0..<3 {
            x! += virusWidthSpacing!;
            for _ in 0..<4 {
                y! += virusHeightSpacing!;
                let virus = UIVirus(parentView: mainView!, frame:CGRect(x: x!, y: y!, width: virusSideLength!, height: virusSideLength!));
                virusCollection!.append(virus);
                y! += virusSideLength!;
            }
            x! += virusSideLength!;
            y! = -virusHeightSpacing! * 0.45;
        }
    }
    
    func setStyle() {
        for virus in virusCollection! {
            virus.setupVirusImage();
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
    
    func sway(immediately:Bool){
        // Animate each virus
        for virus in self.virusCollection! {
            virus.sway(immediately: immediately);
        }
    }
    
    func hide() {
        // Hide each virus
        for virus in self.virusCollection! {
            virus.alpha = 0.0;
            virus.layer.removeAllAnimations();
            virus.frame = virus.originalFrame!;
        }
    }
    
}
