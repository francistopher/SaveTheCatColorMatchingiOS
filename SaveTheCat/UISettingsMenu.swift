//
//  SettingsMenu.swift
//  SaveTheCat
//
//  Created by Christopher Francisco on 3/7/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import SwiftUI

class UISettingsMenu:UICView {
    
    var advertisement:UIAds?
    var leaderBoard:UILeadBoard?
    var multiplayer:UIMultiplayer?
    var myCats:UIMyCats?
    var mouseCoin:UIMouseCoin?
    
    var spaceBetween:CGFloat = 0.0;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView, frame:CGRect) {
        super.init(parentView: parentView, x: frame.minX, y: frame.minY, width: frame.width, height: frame.height, backgroundColor: UIColor.clear);
        self.layer.cornerRadius = self.frame.height / 2.0;
        self.layer.borderWidth = self.frame.height / 12.0;
        super.originalFrame = frame;
        self.reducedFrame = CGRect(x: self.frame.minX, y: self.frame.minY, width: (self.frame.height * 2.0) - self.layer.borderWidth, height: self.frame.height);
        setupAdsButton();
        setupMouseCoinButton();
        setupLeaderBoardButton();
        setupMultiPlayerButton();
        setupMoreCatsButton();
        let unAvailableSpace:CGFloat = self.advertisement!.frame.maxX + (self.frame.width - self.mouseCoin!.frame.minX) + (self.leaderBoard!.frame.width * 3.0);
        let availableSpace:CGFloat = self.frame.width - unAvailableSpace;
        spaceBetween = availableSpace / 4.0;
        setupMiddleButtonsPosition();
    }
    
    func setupAdsButton() {
        advertisement = UIAds(parentView: self, x: self.frame.height - (self.layer.borderWidth * 1.25), y: 0.0, width: self.frame.height, height: self.frame.height);
        advertisement!.transform = advertisement!.transform.scaledBy(x: 0.6, y: 0.6);
        advertisement!.originalFrame = advertisement!.frame;
        advertisement!.reducedFrame = CGRect(x: self.frame.height * 0.5, y: self.frame.height * 0.5, width: 0.1, height: 0.1);
    }
    
    func setupLeaderBoardButton() {
        leaderBoard = UILeadBoard(parentView: self, x: 0.0, y: 0.0, width: self.frame.height, height: self.frame.height);
        leaderBoard!.transform = leaderBoard!.transform.scaledBy(x: 0.6, y: 0.6);
        leaderBoard!.originalFrame = leaderBoard!.frame;
        leaderBoard!.reducedFrame = CGRect(x: self.frame.height * 0.5, y: self.frame.height * 0.5, width: 0.1, height: 0.1);
    }

    func setupMultiPlayerButton() {
        multiplayer = UIMultiplayer(parentView: self, x: 0.0, y: 0.0, width: self.frame.height, height: self.frame.height);
        multiplayer!.transform = multiplayer!.transform.scaledBy(x: 0.6, y: 0.6);
        multiplayer!.originalFrame = multiplayer!.frame;
        multiplayer!.reducedFrame = CGRect(x: self.frame.height * 0.5, y: self.frame.height * 0.5, width: 0.1, height: 0.1);
    }

    func setupMoreCatsButton() {
        myCats = UIMyCats(parentView: self, x: 0.0, y: 0.0, width: self.frame.height, height: self.frame.height);
        myCats!.transform = myCats!.transform.scaledBy(x: 0.6, y: 0.6);
        myCats!.originalFrame = myCats!.frame;
        myCats!.reducedFrame = CGRect(x: self.frame.height * 0.5, y: self.frame.height * 0.5, width: 0.1, height: 0.1);
    }
    
    func setupMouseCoinButton(){
        mouseCoin = UIMouseCoin(parentView: self, x: self.frame.width - self.frame.height, y: 0.0, width: self.frame.height, height: self.frame.height);
        mouseCoin!.transform = mouseCoin!.transform.scaledBy(x: 0.75, y: 0.75);
        mouseCoin!.originalFrame = mouseCoin!.frame;
        mouseCoin!.reducedFrame = CGRect(x: self.frame.height + (self.layer.borderWidth * 0.5), y: self.mouseCoin!.frame.minY, width: self.mouseCoin!.frame.width, height: self.mouseCoin!.frame.height);
    }
    
    func reduceSettingsMenuAndContents() {
        self.frame = self.reducedFrame!;
        self.advertisement!.frame = self.advertisement!.reducedFrame!;
        self.leaderBoard!.frame = self.leaderBoard!.reducedFrame!;
        self.multiplayer!.frame = self.multiplayer!.reducedFrame!;
        self.myCats!.frame = self.myCats!.reducedFrame!;
        self.mouseCoin!.frame = self.mouseCoin!.reducedFrame!;
    }
    
    func enlargeSettingsMenuAndContents() {
        self.frame = self.originalFrame!;
        self.advertisement!.frame = self.advertisement!.originalFrame!;
        self.leaderBoard!.frame = self.leaderBoard!.originalFrame!;
        self.multiplayer!.frame = self.multiplayer!.originalFrame!;
        self.myCats!.frame = self.myCats!.originalFrame!;
        self.mouseCoin!.frame = self.mouseCoin!.originalFrame!;
    }
    
    func setupMiddleButtonsPosition() {
        leaderBoard!.frame = CGRect(x: self.advertisement!.frame.maxX + spaceBetween, y: self.leaderBoard!.frame.minY, width: self.leaderBoard!.frame.width, height: self.leaderBoard!.frame.height);
        leaderBoard!.originalFrame = leaderBoard!.frame;
        multiplayer!.frame = CGRect(x: self.advertisement!.frame.maxX + self.multiplayer!.frame.width + (spaceBetween * 2.0), y: self.multiplayer!.frame.minY, width: self.multiplayer!.frame.width, height: self.multiplayer!.frame.height);
        multiplayer!.originalFrame = multiplayer!.frame;
        myCats!.frame = CGRect(x: self.advertisement!.frame.maxX + (self.multiplayer!.frame.width * 2.0) + (spaceBetween * 3.0), y: self.myCats!.frame.minY, width: self.myCats!.frame.width, height: self.myCats!.frame.height);
        myCats!.originalFrame = myCats!.frame;
    }

    
}