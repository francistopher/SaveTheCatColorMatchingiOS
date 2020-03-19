//
//  UILivesMeter.swift
//  SaveTheCat
//
//  Created by Christopher Francisco on 3/9/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UILiveMeter:UICView {
    
    var livesLeft:Int = 1;
    var heartInactiveButtons:[UICButton] = [];
    var heartImage:UIImage?
    var heartInactiveButtonXRange:[CGFloat] = [];
    var currentHeartButton:UICButton?
    var livesCountLabel:UICLabel?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView: UIView, frame:CGRect, isOpponent:Bool) {
        super.init(parentView: parentView, x: frame.minX, y: frame.minY, width: frame.width, height: frame.height, backgroundColor: UIColor.clear);
        if (isOpponent) {
          heartImage = UIImage(named: "opponentHeart.png")!
        } else {
          heartImage = UIImage(named: "heart.png")!
        }
        self.layer.cornerRadius = self.frame.height * 0.5;
        self.layer.borderWidth = self.frame.height / 12.0;
        heartInactiveButtonXRange = [ 0.0, self.frame.width - (self.frame.height * 1.45), self.frame.width - self.frame.height + (self.layer.borderWidth * 0.05)];
        setupHeartInactiveButtons();
        setupLivesCountLabel();
        setCompiledStyle();
    }
    
    func setupLivesCountLabel() {
        livesCountLabel = UICLabel(parentView: self, x: 0.0, y: frame.height * 0.02, width: frame.width * 1.0, height: frame.height * 1.0);
        livesCountLabel!.font = UIFont.boldSystemFont(ofSize: livesCountLabel!.frame.height * 0.3);
        livesCountLabel!.backgroundColor = UIColor.clear;
        self.livesCountLabel!.text = "\(self.livesLeft)";
    }
    
    func setupHeartInactiveButtons() {
        for _ in (heartInactiveButtons.count + 1)...livesLeft {
            if (heartInactiveButtons.count == 0) {
                buildHeartButton(x: heartInactiveButtonXRange[1]);
            } else if (heartInactiveButtons.count == 1) {
                buildHeartButton(x: heartInactiveButtonXRange[0]);
            } else if (heartInactiveButtons.count == 2) {
                buildHeartButton(x: heartInactiveButtonXRange[2]);
            } else {
                buildHeartButton(x: CGFloat.random(in: heartInactiveButtonXRange[0]..<heartInactiveButtonXRange[2]));
            }
        }
    }
    
    func buildHeartButton(x:CGFloat) {
        currentHeartButton = UICButton(parentView: self, frame: CGRect(x: x, y: 0.0, width: self.frame.height, height: self.frame.height), backgroundColor: UIColor.clear);
        CenterController.center(childView: currentHeartButton!, parentRect: self.frame, childRect: currentHeartButton!.frame);
        currentHeartButton!.layer.borderWidth = 0.0;
        currentHeartButton!.setImage(heartImage, for: .normal);
        currentHeartButton!.addTarget(self, action: #selector(heartButtonSelector(sender:)), for: .touchUpInside);
        currentHeartButton!.addTarget(self, action: #selector(heartButtonSelector(sender:)), for: .touchDown);
        heartInactiveButtons.append(currentHeartButton!);
        currentHeartButton!.alpha = 0.0;
        currentHeartButton!.show();
    }
    
    @objc func heartButtonSelector(sender:UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0.125, options: [.curveEaseInOut], animations: {
            sender.transform = sender.transform.scaledBy(x: 1.25, y: 1.25);
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0.125, options: [.curveEaseInOut], animations: {
                sender.transform = sender.transform.scaledBy(x: 0.8, y: 0.8);
            })
        })
    }
    
    func decrementLivesLeftCount() {
        if (livesLeft > 0) {
            livesLeft -= 1;
            if (livesLeft == 0) {
                 self.livesCountLabel!.text = "";
            } else {
                 self.livesCountLabel!.text = "\(self.livesLeft)";
            }
            // Get the last heart button
            let lastHeartButton:UICButton = heartInactiveButtons.last!;
            heartInactiveButtons.removeLast();
            // Add the last heart button to superview
            self.superview!.addSubview(lastHeartButton);
            lastHeartButton.frame = CGRect(x: lastHeartButton.frame.minX + self.frame.minX, y: lastHeartButton.frame.minY + self.frame.minY, width: lastHeartButton.frame.width, height: lastHeartButton.frame.height);
            let randomTargetY:CGFloat = CGFloat.random(in: self.superview!.frame.height...(self.superview!.frame.height + lastHeartButton.frame.height))
            UIView.animate(withDuration: 3.0, delay: 0.125, options: [.curveEaseInOut], animations: {
                lastHeartButton.transform = lastHeartButton.transform.translatedBy(x: 0.0, y: randomTargetY);
            }, completion: { _ in
                lastHeartButton.removeFromSuperview();
            })
        }
    }
    
    func incrementLivesLeftCount(catButton:UICatButton, forOpponent:Bool) {
        livesLeft += 1;
        // Get spawn frame
        var x:CGFloat = catButton.frame.midX * 0.5 + catButton.superview!.frame.minX;
        var y:CGFloat = catButton.frame.midY * 0.5 + catButton.superview!.frame.minY;
        if (forOpponent) {
            x = self.frame.minX - (self.frame.height * 1.5);
            y = self.frame.minY;
        }
        let newFrame:CGRect = CGRect(x: x, y: y, width: self.frame.height, height: self.frame.height);
        // Setup the heart button
        setupHeartInactiveButtons();
        // Save the target frame and set the new frame
        self.superview!.addSubview(currentHeartButton!);
        let targetFrame = CGRect(x: self.frame.minX + currentHeartButton!.frame.minX, y: self.frame.minY + currentHeartButton!.frame.minY, width: (self.frame.width * 0.5) - (self.layer.borderWidth * 0.5), height: self.frame.height);
        currentHeartButton!.frame = newFrame;
        self.superview!.bringSubviewToFront(currentHeartButton!);
        // Move heart to target frame
        UIView.animate(withDuration: 3.0, delay: 0.125, options: [.curveEaseInOut], animations: {
            self.currentHeartButton!.transform = self.currentHeartButton!.transform.translatedBy(x: targetFrame.minX - newFrame.minX, y: targetFrame.minY - newFrame.minY);
        }, completion: { _ in
            self.addSubview(self.currentHeartButton!);
            self.currentHeartButton!.frame = CGRect(x: targetFrame.minX - self.frame.minX, y: targetFrame.minY - self.frame.minY, width: self.frame.height, height: self.frame.height);
            self.livesCountLabel!.text = "\(self.livesLeft)";
            self.bringSubviewToFront(self.livesCountLabel!);
        })
    }
    
    func removeAllHeartLives() {
        for _ in 0..<heartInactiveButtons.count {
            decrementLivesLeftCount();
        }
    }
    
    func resetLivesLeftCount() {
        if (heartInactiveButtons.count > 1) {
            for _ in 1..<heartInactiveButtons.count {
                decrementLivesLeftCount();
            }
        } else if (heartInactiveButtons.count < 1) {
            livesLeft = 1;
            setupHeartInactiveButtons();
        }
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
            self.bringSubviewToFront(self.livesCountLabel!);
            self.livesCountLabel!.text = "\(self.livesLeft)";
        })
    }
    
    override func fadeIn() {
        UIView.animate(withDuration: 1.0, delay: 0.125, options: .curveEaseInOut, animations: {
            self.alpha = 1.0;
        }, completion: { _ in
            self.isFadedOut = false;
        })
    }
    
    func setCompiledStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            self.layer.borderColor = UIColor.black.cgColor;
            self.backgroundColor = UIColor.white;
            self.livesCountLabel!.textColor = UIColor.black;
        } else {
            self.layer.borderColor = UIColor.white.cgColor;
            self.backgroundColor = UIColor.black;
            self.livesCountLabel!.textColor = UIColor.white;
        }
    }
}
