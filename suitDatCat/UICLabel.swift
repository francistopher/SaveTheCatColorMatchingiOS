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
    
    static var mozartMoltoPath:String? = nil;
    static var mozartMoltoUrl:URL? = nil;
    static var mozartMoltoSoundEffect:AVAudioPlayer?
    
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
        UICLabel.mozartMoltoPath = Bundle.main.path(forResource: "mozartMolto.mp3", ofType: nil);
        UICLabel.mozartMoltoUrl = URL(fileURLWithPath: UICLabel.mozartMoltoPath!);
        do {
            UICLabel.mozartMoltoSoundEffect = try AVAudioPlayer(contentsOf: UICLabel.mozartMoltoUrl!);
        } catch {
            print("Unable to play mozart molto");
        }
    }
    
    static func mozartMolto(play:Bool) {
        if (play) {
           if (!UICLabel.mozartMoltoSoundEffect!.isPlaying) {
               UICLabel.mozartMoltoSoundEffect!.numberOfLoops = -1;
               UICLabel.mozartMoltoSoundEffect!.play();
           }
        } else {
            let timeInterval:TimeInterval = TimeInterval(1.0);
            UICLabel.mozartMoltoSoundEffect!.setVolume(0.0, fadeDuration: timeInterval);
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UICLabel.mozartMoltoSoundEffect!.stop();
            }
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
        } catch {
            print("Unable to play mozart sonata");
        }
    }
    
    static func mozartSonata(play:Bool) {
        if (play) {
            if (!UICLabel.mozartSonataSoundEffect!.isPlaying) {
                UICLabel.mozartSonataSoundEffect!.numberOfLoops = -1;
                UICLabel.mozartSonataSoundEffect!.play();
            }
        } else {
            let timeInterval:TimeInterval = TimeInterval(1.0);
            UICLabel.mozartSonataSoundEffect!.setVolume(0.0, fadeDuration: timeInterval);
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UICLabel.mozartSonataSoundEffect!.stop();
            }
        }
    }
    
    func fadeInAndOut(){
        UIView.animate(withDuration: 2, delay: 0.5, options: .curveEaseIn, animations: {
            super.alpha = 1.0;
        }) { (_) in
            UICLabel.mozartSonata(play: true);
            self.kittenMeow();
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
