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
        let totalWidthSpacing:CGFloat = mainView!.frame.width - (virusSideLength * 5.0);
        let totalHeightSpacing:CGFloat = mainView!.frame.height - (virusSideLength * 6.0);
        
        // Virus Spacing Length
        let virusWidthSpacing:CGFloat = totalWidthSpacing / 5.0;
        let virusHeightSpacing:CGFloat = totalHeightSpacing / 6.7;
        
        var x:CGFloat = 0.0;
        var y:CGFloat = 0.0;
        
        for _ in 0..<5 {
            x += virusWidthSpacing;
            for _ in 0..<6 {
                y += virusHeightSpacing;
                let virus = UICButton(parentView: mainView!, x: x, y: y, width: virusSideLength, height: virusSideLength, backgroundColor: .clear);
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
        for virus in self.virusesCollection {
            UIView.animate(withDuration: 2.0, delay:1.125, options: [.curveEaseInOut], animations: {
                virus.alpha = 1.0;
            })
        }
    }
    
    func centerize(){
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
        for virus in self.virusesCollection {
            virus.setCurrentVirusAnimation();
        }
    }
}
