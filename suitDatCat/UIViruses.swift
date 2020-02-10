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
    
    init(boardGameView:UIView, mainView:UIView){
        self.boardGameView = boardGameView;
        self.mainView = mainView;
    }
    
    func buildViruses( unitView:CGFloat) {
        // Calculate side and spacing lengths of virus
        let virusesSpacingLength:CGFloat = boardGameView!.frame.width - ((unitView * 2.0) * 3.0);
        let virusSpacingLength:CGFloat = virusesSpacingLength / 4.0;
        let virusSideLength:CGFloat = unitView * 2.0;
        // Create variables to store temporary virus coordinates
        var x:CGFloat = 0.0;
        var y:CGFloat = 0.0;
        // Position viruses
        for side in 0..<4{
            if (side == 0) {
                x = boardGameView!.frame.minX
                y = boardGameView!.frame.minY - (unitView * 2.0);
            } else if (side == 1) {
                x = boardGameView!.frame.minX;
                y = boardGameView!.frame.minY + boardGameView!.frame.height;
            } else if (side == 2) {
                x = boardGameView!.frame.minX - (unitView * 2.0);
                y = boardGameView!.frame.minY;
            } else {
                x = boardGameView!.frame.minX + boardGameView!.frame.width;
                y = boardGameView!.frame.minY;
            }
            for _ in 0..<3{
                if (side == 0 || side == 1){
                    x += virusSpacingLength;
                } else {
                    y += virusSpacingLength;
                }
                let virus:UICButton = UICButton(parentView: mainView!, x: x, y: y, width: unitView * 2.0, height: unitView * 2.0, backgroundColor: .clear);
                virus.alpha = 0.0;
                virus.setVirus();
                if (side == 0 || side == 1){
                    x += virusSideLength;
                } else {
                    y += virusSideLength;
                }
                virusesCollection.append(virus);
            }
        }
        animate();
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
                let xDistance:CGFloat = self.boardGameView!.frame.minX + (self.boardGameView!.center.x / 2.0) - virus.frame.minX;
                let yDistance:CGFloat = self.boardGameView!.frame.minY + (self.boardGameView!.center.y / 2.0) - virus.frame.minY;
                virus.transform = virus.transform.translatedBy(x: xDistance, y: yDistance);
                self.mainView!.bringSubviewToFront(virus);
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
