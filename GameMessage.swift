//
//  GameMessage.swift
//  SaveTheCat
//
//  Created by Christopher Francisco on 3/13/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import SwiftUI

class UIGameMessage:UIView {
    
    enum Message {
        case noiCloud
        case yesiCloud
        case noGameCenter
        case noInternet
        case yesInternet
    }
    
    var messageQueue:[Message] = [];
    var blurEffect:UIBlurEffect?
    var blurView:UIVisualEffectView?
    var imageButton:UICButton?
    var messageLabel:UICLabel?
    
    var targetFrame:CGRect?
    var defaultFrame:CGRect?
    
    var isShowing:Bool = false;
    var count:Double = 0.0;
    
    var stayALittleLonger:Bool = false;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView, frame:CGRect) {
        targetFrame = frame;
        defaultFrame = CGRect(x: frame.minX, y: -(frame.minY * 2.0 + frame.height), width: frame.width, height: frame.height);
        super.init(frame: defaultFrame!);
        self.backgroundColor = UIColor.clear;
        self.layer.cornerRadius = self.frame.width * 0.07;
        self.clipsToBounds = true;
        setupBlurEffect();
        setupVisualEffectView();
        setupImageButton();
        setupLabel();
        parentView.addSubview(self);
        var littleLongerCount:Double = 0.0;
        Timer.scheduledTimer(withTimeInterval: 0.125, repeats: true, block: { _ in
            parentView.bringSubviewToFront(self);
            if (self.frame == self.defaultFrame && self.messageQueue.count > 0) {
                self.showMessage();
            }
            if (self.messageQueue.count > 0 && self.isShowing) {
                if (self.count == 0.0) {
                    self.displayFirstMessage();
                }
                if (self.count == 3.0) {
                    if (self.messageQueue.count - 1 != 0) {
                        self.messageLabel!.fadeOutAndIn();
                        self.imageButton!.fadeOutAndIn();
                    }
                    self.count = 0.0;
                    self.messageQueue.remove(at: 0);
                } else {
                    if (!self.stayALittleLonger || littleLongerCount > 3.0) {
                        self.count += 0.125;
                        self.stayALittleLonger = false;
                    } else {
                        littleLongerCount += 0.125;
                    }

                }
            } else {
                self.hideMessage();
            }
        })
    }
    
    func displayFirstMessage() {
        switch messageQueue[0] {
        case .noGameCenter:
            setupImage(named: "gameCenter.png");
            messageLabel!.text = "Go to Settings and sign into\nGame Center for more fun!";
        case .noiCloud:
            setupImage(named: "noiCloud.png");
            messageLabel!.text = "Not logged into iCloud.\n Game data will not be saved!";
        case .noInternet:
            setupImage(named: "noInternet.png");
            messageLabel!.text = "No Internet Connection! Game experience will be limited!";
        case .yesiCloud:
            setupImage(named: "yesiCloud.png");
            messageLabel!.text = "Logged into iCloud.\n Game data will be saved!";
        case .yesInternet:
            setupImage(named:"yesInternet.png");
            messageLabel!.text = "Connected to the Internet! Game experience is renewable!";
        }
    }
    
    func addToMessageQueue(message:Message) {
        if (messageQueue.count > 0) {
            var index:Int = 0;
            var remove:Bool = false;
            while (index < messageQueue.count) {
                remove = (message == .noiCloud && (messageQueue[index] == .noInternet || messageQueue[index] == .yesInternet))
                remove = (message == messageQueue[index]) || remove;
                if (remove) {
                    messageQueue.remove(at: index);
                    remove = false;
                } else {
                    index += 1;
                }
            }
        }
        messageQueue.append(message);
    }
    
    func displayNotLoggedIntoiCloudMessage() {
        print("MESSAGE: Not logged into iCloud message")
        addToMessageQueue(message: .noiCloud);
    }
    
    func displayLoggedIntoiCloudMessage() {
        print("MESSAGE: Logged into iCloud message")
        addToMessageQueue(message: .yesiCloud);
    }
    
    func displayGameCenterDirectionsMessage() {
        print("MESSAGE: Game center directions message")
        addToMessageQueue(message: .noGameCenter);
    }
    
    func displayNoInternetConsequencesMessage() {
        print("MESSAGE: No internet connection");
        addToMessageQueue(message: .noInternet);
    }
    
    func displayInternetConnectionEstablishedMessage() {
        print("MESSAGE: Internet connection established")
        addToMessageQueue(message: .yesInternet);
    }
    
    func setupBlurEffect() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            blurEffect = UIBlurEffect(style: .systemThinMaterialDark);
        } else {
            blurEffect = UIBlurEffect(style: .systemThickMaterialDark);
        }
    }
    
    func setupVisualEffectView() {
        blurView = UIVisualEffectView(effect: blurEffect);
        blurView!.frame = self.bounds;
        self.addSubview(blurView!);
    }
    
    func setupImageButton() {
        imageButton = UICButton(parentView: self, frame: CGRect(x: self.frame.width * 0.0839, y: 0.0, width: self.frame.height * 0.65, height: self.frame.height), backgroundColor: UIColor.clear);
        imageButton!.layer.borderWidth = 0.0;
        self.addSubview(imageButton!);
    }
    
    func setupImage(named:String) {
        let image:UIImage = UIImage(named: named)!;
        imageButton!.setImage(image, for: .normal);
        imageButton!.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func setupLabel() {
        let messageLabelWidth:CGFloat = self.imageButton!.frame.minX + self.imageButton!.frame.width * 1.05;
        messageLabel = UICLabel(parentView: self, x:  messageLabelWidth, y: 0.0, width: self.frame.width * 0.75, height: self.frame.height);
        messageLabel!.backgroundColor = UIColor.clear;
        messageLabel!.textColor = UIColor.white;
        messageLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping;
        messageLabel!.numberOfLines = 2;
        messageLabel!.font = UIFont.boldSystemFont(ofSize: messageLabel!.frame.height * 0.25);
    }
    
    func setStyle() {
        setupBlurEffect();
        blurView!.effect = blurEffect;
    }
    
    func showMessage() {
        UIView.animate(withDuration: 0.415, delay: 0.25, options: .curveLinear, animations: {
            self.frame = self.targetFrame!;
        }, completion: { _ in
            self.isShowing = true;
        })
    }
    
    func hideMessage() {
        UIView.animate(withDuration: 0.415, delay: 0.25, options: .curveLinear, animations: {
            self.frame = self.defaultFrame!;
        }, completion: { _ in
            self.isShowing = false;
        })
    }
}
