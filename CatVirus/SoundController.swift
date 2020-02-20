//
//  SoundController.swift
//  CatVirus
//
//  Created by Christopher Francisco on 2/20/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import AVFoundation

class SoundController {
    
       
    static var coinEarnedPath:String? = nil;
    static var coinEarnedUrl:URL? = nil;
    static var coinEarnedSoundEffect:AVAudioPlayer?
    
    static var kittenMeowPath:String?
    static var kittenMeowUrl:URL?
    static var kittenMeowSoundEffect:AVAudioPlayer?
    
    static var kittenMeowPath2:String?
    static var kittenMeowUrl2:URL?
    static var kittenMeowSoundEffect2:AVAudioPlayer?
    
    static var kittenMeowPath3:String?
    static var kittenMeowUrl3:URL?
    static var kittenMeowSoundEffect3:AVAudioPlayer?
    
    static var kittenDiePath:String? = nil;
    static var kittenDieUrl:URL? = nil;
    static var kittenDieSoundEffect:AVAudioPlayer?

    static var mozartSonataPath:String?
    static var mozartSonataUrl:URL?
    static var mozartSonataSoundEffect:AVAudioPlayer?
    
    static func coinEarned() {
        if (!SoundController.coinEarnedSoundEffect!.isPlaying) {
            SoundController.coinEarnedSoundEffect!.play();
            SoundController.coinEarnedSoundEffect!.prepareToPlay();
        }
    }
    
    static func setupCoinEarned() {
        SoundController.coinEarnedPath = Bundle.main.path(forResource: "coinEarned.mp3", ofType: nil);
        SoundController.coinEarnedUrl = URL(fileURLWithPath: SoundController.coinEarnedPath!);
        do {
            SoundController.coinEarnedSoundEffect = try AVAudioPlayer(contentsOf: SoundController.coinEarnedUrl!);
        } catch {
            print("Unable to play coin earned");
        }
    }
    
    static func kittenMeow() {
        if (SoundController.kittenMeowSoundEffect!.isPlaying) {
            if (SoundController.kittenMeowSoundEffect2!.isPlaying) {
                SoundController.kittenMeowSoundEffect3!.play();
            } else {
                SoundController.kittenMeowSoundEffect2!.play();
            }
        } else {
            SoundController.kittenMeowSoundEffect!.play();
        }
    }
    
    static func setupKittenMeow() {
        SoundController.kittenMeowPath = Bundle.main.path(forResource: "kittenMeow.mp3", ofType: nil);
        SoundController.kittenMeowUrl = URL(fileURLWithPath: SoundController.kittenMeowPath!);
        do {
            SoundController.kittenMeowSoundEffect = try AVAudioPlayer(contentsOf: SoundController.kittenMeowUrl!);
        } catch {
            print("Unable to play kitten meow");
        }
    }
    
    static func setupKittenMeow2() {
        SoundController.kittenMeowPath2 = Bundle.main.path(forResource: "kittenMeow.mp3", ofType: nil);
        SoundController.kittenMeowUrl2 = URL(fileURLWithPath: SoundController.kittenMeowPath2!);
        do {
            SoundController.kittenMeowSoundEffect2 = try AVAudioPlayer(contentsOf: SoundController.kittenMeowUrl2!);
        } catch {
            print("Unable to play kitten meow");
        }
    }
    
    static func setupKittenMeow3() {
        SoundController.kittenMeowPath3 = Bundle.main.path(forResource: "kittenMeow.mp3", ofType: nil);
        SoundController.kittenMeowUrl3 = URL(fileURLWithPath: SoundController.kittenMeowPath3!);
        do {
            SoundController.kittenMeowSoundEffect3 = try AVAudioPlayer(contentsOf: SoundController.kittenMeowUrl3!);
        } catch {
            print("Unable to play kitten meow");
        }
    }
    
    static func kittenDie() {
        if (!SoundController.kittenDieSoundEffect!.isPlaying){
            SoundController.kittenDieSoundEffect!.play();
            SoundController.kittenDieSoundEffect!.prepareToPlay();
        }
    }
    
    static func setupKittenDie() {
        SoundController.kittenDiePath = Bundle.main.path(forResource: "kittenDie.mp3", ofType: nil);
        SoundController.kittenDieUrl = URL(fileURLWithPath: SoundController.kittenDiePath!);
        do {
           SoundController.kittenDieSoundEffect = try AVAudioPlayer(contentsOf: SoundController.kittenDieUrl!);
        } catch {
           print("Unable to play kitten die");
        }
    }
    
    static func mozartSonata(play:Bool) {
        if (play) {
            if (SoundController.mozartSonataSoundEffect!.volume == 0.0) {
                let timeInterval:TimeInterval = TimeInterval(1.0);
                SoundController.mozartSonataSoundEffect!.setVolume(1.0, fadeDuration: timeInterval);
            } else {
                SoundController.mozartSonataSoundEffect!.play();
            }
        } else {
            let timeInterval:TimeInterval = TimeInterval(1.0);
            SoundController.mozartSonataSoundEffect!.setVolume(0.0, fadeDuration: timeInterval);
        }
    }
    
    static func setupMozartSonata() {
        SoundController.mozartSonataPath = Bundle.main.path(forResource: "mozartSonata.mp3", ofType: nil);
        SoundController.mozartSonataUrl = URL(fileURLWithPath: SoundController.mozartSonataPath!);
        do {
            SoundController.mozartSonataSoundEffect = try AVAudioPlayer(contentsOf: SoundController.mozartSonataUrl!);
            SoundController.mozartSonataSoundEffect!.numberOfLoops = -1;
        } catch {
            print("Unable to play mozart sonata");
        }
    }
}
