//
//  CUILabel.swift
//  bagDatCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class UICLabel:UILabel {
    
    var kittenMeowPath:String? = nil;
    var kittenMeowUrl:URL? = nil;
    var kittenMeowSoundEffect:AVAudioPlayer?
    
    static var mozartSonataPath:String? = nil;
    static var mozartSonataUrl:URL? = nil;
    static var mozartSonataSoundEffect:AVAudioPlayer?
    
    static var mozartEinePath:String? = nil;
    static var mozartEineUrl:URL? = nil;
    static var mozartEineSoundEffect:AVAudioPlayer?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat){
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        self.frame = CGRect(x: x, y: y, width: width, height: height);
        self.textAlignment = NSTextAlignment.center;
        self.setStyle()
        configureKittenMeow();
        configureMozartSonata();
        configureMozartMolto();
        parentView.addSubview(self);
    }
    
    func configureMozartMolto() {
        UICLabel.mozartEinePath = Bundle.main.path(forResource: "mozartEine.mp3", ofType: nil);
        UICLabel.mozartEineUrl = URL(fileURLWithPath: UICLabel.mozartEinePath!);
        do {
            UICLabel.mozartEineSoundEffect = try AVAudioPlayer(contentsOf: UICLabel.mozartEineUrl!);
            UICLabel.mozartEineSoundEffect!.numberOfLoops = -1;
        } catch {
            print("Unable to play mozart molto");
        }
    }

    static func mozartEine(play:Bool) {
        if (play) {
            if (UICLabel.mozartEineSoundEffect!.volume == 0.0) {
                let timeInterval:TimeInterval = TimeInterval(1.0);
                UICLabel.mozartEineSoundEffect!.setVolume(1.0, fadeDuration: timeInterval);
            } else {
                UICLabel.mozartEineSoundEffect!.play();
            }
        } else {
            let timeInterval:TimeInterval = TimeInterval(1.0);
            UICLabel.mozartEineSoundEffect!.setVolume(0.0, fadeDuration: timeInterval);
        }
    }
    
    func kittenMeow() {
        if (!kittenMeowSoundEffect!.isPlaying){
            kittenMeowSoundEffect!.play();
        }
    }
    
    func configureKittenMeow() {
        kittenMeowPath = Bundle.main.path(forResource: "kittenMeow.mp3", ofType: nil);
        kittenMeowUrl = URL(fileURLWithPath: kittenMeowPath!);
        do {
            kittenMeowSoundEffect = try AVAudioPlayer(contentsOf: kittenMeowUrl!);
        } catch {
            print("Unable to play kitten meow");
        }
    }
    
    func configureMozartSonata() {
        UICLabel.mozartSonataPath = Bundle.main.path(forResource: "mozartSonata.mp3", ofType: nil);
        UICLabel.mozartSonataUrl = URL(fileURLWithPath: UICLabel.mozartSonataPath!);
        do {
            UICLabel.mozartSonataSoundEffect = try AVAudioPlayer(contentsOf: UICLabel.mozartSonataUrl!);
            UICLabel.mozartSonataSoundEffect!.numberOfLoops = -1;
        } catch {
            print("Unable to play mozart sonata");
        }
    }
    
    static func mozartSonata(play:Bool) {
        if (play) {
            if (UICLabel.mozartSonataSoundEffect!.volume == 0.0) {
                let timeInterval:TimeInterval = TimeInterval(1.0);
                UICLabel.mozartSonataSoundEffect!.setVolume(1.0, fadeDuration: timeInterval);
            } else {
                UICLabel.mozartSonataSoundEffect!.play();
            }
        } else {
            let timeInterval:TimeInterval = TimeInterval(1.0);
            UICLabel.mozartSonataSoundEffect!.setVolume(0.0, fadeDuration: timeInterval);
        }
    }
    
    func fadeInAndOut(){
        UIView.animate(withDuration: 2, delay: 0.5, options: .curveEaseIn, animations: {
            super.alpha = 1.0;
        }) { (_) in
            self.kittenMeow();
            UICLabel.mozartSonata(play: true);
            UIView.animate(withDuration: 2, delay: 0.5, options: .curveEaseOut, animations: {
                super.alpha = 0.0;
            })
        }
    }
    
    func fadeOnDark() {
        UIView.animate(withDuration: 0.125, delay:0.0, options: .curveEaseIn, animations: {
            super.backgroundColor = UIColor.white;
            super.textColor = UIColor.black;
        })
    }
    
    func fadeOnLight(){
        UIView.animate(withDuration: 0.125, delay: 0.0, options: .curveEaseIn, animations: {
            super.backgroundColor = UIColor.black;
            super.textColor = UIColor.white;
        })
    }
    
    func setStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            self.textColor = UIColor.black;
        } else {
            self.textColor = UIColor.white;
        }
    }
    
   
    
}
