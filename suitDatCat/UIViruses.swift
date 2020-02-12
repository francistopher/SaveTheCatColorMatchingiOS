//
//  viruses.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/10/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIViruses {
    
    var virusesCollection:[UICButton] = [UICButton]();
    var boardGameView:UIView? = nil;
    var mainView:UIView? = nil;
    
    init(mainView:UIView){
        self.mainView = mainView;
    }
    
    func buildViruses( unitView:CGFloat) {
        // Calculate side and spacing lengths of virus
        let virusSideLength:CGFloat = unitView * 2.0;
        // Total Spacing Available
        let totalWidthSpacing:CGFloat = mainView!.frame.width - (virusSideLength * 4.0);
        let totalHeightSpacing:CGFloat = mainView!.frame.height - (virusSideLength * 5.0);
        // Virus Spacing Length
        let virusWidthSpacing:CGFloat = totalWidthSpacing / 3.75;
        let virusHeightSpacing:CGFloat = totalHeightSpacing / 5.875;
        // Initial starting coordinates
        var x:CGFloat = -virusWidthSpacing * 0.71875;
        var y:CGFloat = -virusHeightSpacing * 0.125;
        // Plot viruses
        for _ in 0..<4 {
            x += virusWidthSpacing;
            for _ in 0..<5 {
                y += virusHeightSpacing;
                let virus = UICButton(parentView: mainView!, x: x, y: y, width: virusSideLength, height: virusSideLength, backgroundColor: .clear);
                virus.alpha = 0.0;
                virus.setVirus();
                virus.setCurrentVirusAnimation();
                virusesCollection.append(virus);
                y += virusSideLength;
            }
            x += virusSideLength;
            y = 0;
        }
    }
    
    func show(){
        // Fade each virus in
        for virus in self.virusesCollection {
            UIView.animate(withDuration: 2.0, delay:1.125, options: [.curveEaseInOut], animations: {
                virus.alpha = 1.0;
            })
        }
    }
    
    func centerize(){
        // Translate each virus to the center of the grid of cats
        for virus in self.virusesCollection {
            UIView.animate(withDuration: 0.25, delay:0.0, options: [.curveEaseInOut], animations: {
                let xDistance:CGFloat = self.mainView!.center.x - virus.frame.midX;
                let yDistance:CGFloat = self.mainView!.center.y - virus.frame.midY;
                virus.transform = virus.transform.translatedBy(x: xDistance, y: yDistance);
            }, completion: { _ in
                UIView.animate(withDuration: 1.5, delay:0.125, options: [.curveEaseInOut], animations: {
                    virus.frame = virus.originalFrame!;
                })
            })
        }
    }
    
    func animate(){
        // Animate each virus
        for virus in self.virusesCollection {
            virus.setCurrentVirusAnimation();
        }
    }
}
