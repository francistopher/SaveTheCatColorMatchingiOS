//
//  UISearchMagnifyGlass.swift
//  SaveTheCat
//
//  Created by Christopher Francisco on 3/14/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import SwiftUI

class UISearchMagnifyGlass:UICButton {
    
    enum Target {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case center
    }
    
    var label:UICLabel?
    var targetFrames:[Target:CGRect] = [:];
    var previousTarget:Target?
    var nextTarget:Target?
    var transitionAnimation:UIViewPropertyAnimator?
    
    init(parentView:UIView, frame:CGRect) {
        super.init(parentView: parentView, frame: frame, backgroundColor: UIColor.clear);
        self.layer.borderWidth = 0.0;
        self.alpha = 0.0;
        setupLabel();
        setupTargetFrames(parentView);
        setupTransitionAnimation();
        setThisStyle();
    }
    
    func setupTargetFrames(_ parentView:UIView) {
        targetFrames[.center] = frame;
        targetFrames[.topLeft] = CGRect(x: frame.width * 0.5, y: frame.height * 0.5, width: frame.width, height: frame.height);
        targetFrames[.topRight] = CGRect(x: parentView.frame.width - frame.width - frame.width * 0.5, y: frame.height * 0.5, width: frame.width, height: frame.height);
        targetFrames[.bottomLeft] = CGRect(x: frame.width * 0.5, y: parentView.frame.height - frame.height - frame.height * 0.9, width: frame.width, height: frame.height);
        targetFrames[.bottomRight] = CGRect(x: parentView.frame.width - frame.width - frame.width * 0.5, y:  parentView.frame.height - frame.height - frame.height * 0.9, width: frame.width, height: frame.height);
    }
    
    func setupLabel() {
        let height:CGFloat = frame.height * 0.25;
        label = UICLabel(parentView: self, x: 0.0, y: frame.height * 0.9, width: frame.width, height: height * 2.0)
        label!.backgroundColor = UIColor.clear;
        label!.numberOfLines = 2;
        label!.lineBreakMode = NSLineBreakMode.byWordWrapping;
        label!.font = UIFont.boldSystemFont(ofSize: height * 0.65);
    }
    
    func setNextTarget() {
        var targets:[Target] = [.topLeft, .topRight, .bottomLeft, .bottomRight, .center];
        var index:Int = -1;
        if (nextTarget != nil) {
            index = targets.firstIndex(of: nextTarget!)!;
            targets.remove(at: index);
            if (previousTarget != nil) {
                index = targets.firstIndex(of: previousTarget!)!;
                targets.remove(at: index);
            }
            previousTarget = nextTarget!;
        }
        nextTarget = targets.randomElement()!;
    }
    
    func setupTransitionAnimation() {
        setNextTarget();
        transitionAnimation = UIViewPropertyAnimator(duration: 1.5, curve: .easeInOut, animations: {
            self.frame = self.targetFrames[self.nextTarget!]!;
        })
        transitionAnimation!.addCompletion({ _ in
            self.setupTransitionAnimation();
            self.transitionAnimation!.startAnimation();
        })
    }
    
    func stopTransitionAnimation() {
        label!.text = "Found\nOpponent";
        transitionAnimation!.stopAnimation(true);
        nextTarget = nil;
        previousTarget = nil;
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
            self.frame = self.targetFrames[.center]!;
        })
    }
    
    func startAnimation() {
        label!.text = "Finding\nOpponent";
        self.superview!.bringSubviewToFront(self);
        self.transitionAnimation!.startAnimation();
        self.alpha = 1.0;
    }
    
    func setThisStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            self.setImage(UIImage(named: "lightMagnifyGlass.png"), for: .normal);
            label!.textColor = UIColor.black;
        } else {
            self.setImage(UIImage(named: "darkMagnifyGlass.png"), for: .normal);
            label!.textColor = UIColor.white;
        }
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
