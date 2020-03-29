//
//  SoundController.swift
//  Save The Cat: Color Matching
//
//  Created by Christopher Francisco on 2/20/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import AVFoundation

class SoundController {
    
    static var gearSpinningPath:String?
    static var gearSpinningURL:URL?
    static var gearSpinningSoundEffect:AVAudioPlayer?
    
    static var heavenPath:String?
    static var heavenUrl:URL?
    static var heavenSoundEffect:AVAudioPlayer?
    
    static var coinEarnedPath:String?
    static var coinEarnedUrl:URL?
    static var coinEarnedSoundEffect:AVAudioPlayer?
    
    static var coinEarnedPath2:String?
    static var coinEarnedUrl2:URL?
    static var coinEarnedSoundEffect2:AVAudioPlayer?
    
    static var coinEarnedPath3:String?
    static var coinEarnedUrl3:URL?
    static var coinEarnedSoundEffect3:AVAudioPlayer?
    
    static var kittenMeowPath:String?
    static var kittenMeowUrl:URL?
    static var kittenMeowSoundEffect:AVAudioPlayer?
    
    static var kittenMeowPath2:String?
    static var kittenMeowUrl2:URL?
    static var kittenMeowSoundEffect2:AVAudioPlayer?
    
    static var kittenMeowPath3:String?
    static var kittenMeowUrl3:URL?
    static var kittenMeowSoundEffect3:AVAudioPlayer?
    
    static var kittenDiePath:String?
    static var kittenDieUrl:URL?
    static var kittenDieSoundEffect:AVAudioPlayer?

    static var mozartSonataPath:String?
    static var mozartSonataUrl:URL?
    static var mozartSonataSoundEffect:AVAudioPlayer?
    
    static var chopinPreludePath:String?
    static var chopinPreludeUrl:URL?
    static var chopinPreludeSoundEffect:AVAudioPlayer?
    
    static var timeInterval05:TimeInterval = TimeInterval(0.5);
    
    static func gearSpinning() {
        gearSpinningSoundEffect!.stop();
        gearSpinningSoundEffect!.play();
    }
    
    static func setupGearSpinning() {
        gearSpinningPath = nil;
        gearSpinningURL = nil;
        gearSpinningSoundEffect = nil;
        gearSpinningPath = Bundle.main.path(forResource: "gearSpinning.mp3", ofType: nil);
        gearSpinningURL = URL(fileURLWithPath: gearSpinningPath!);
        do {
            gearSpinningSoundEffect = try AVAudioPlayer(contentsOf: gearSpinningURL!);
            gearSpinningSoundEffect!.volume = 0.25;
       } catch {
           print("Unable to play gearSpinning sound effect.");
       }
    }
    
    static func heaven() {
        heavenSoundEffect!.play();
    }
    
    static func setupHeaven() {
        heavenPath = nil;
        heavenUrl = nil;
        heavenSoundEffect = nil;
        heavenPath = Bundle.main.path(forResource: "heaven.mp3", ofType: nil);
        heavenUrl = URL(fileURLWithPath: heavenPath!);
        do {
            heavenSoundEffect = try AVAudioPlayer(contentsOf: heavenUrl!);
        } catch {
            print("Unable to play heaven");
        }
    }
    
    static func coinEarned() {
        if (coinEarnedSoundEffect!.isPlaying) {
            coinEarnedSoundEffect2!.play();
        } else {
            coinEarnedSoundEffect!.play();
        }
    }
    
    static func setupCoinEarned() {
        coinEarnedPath = nil;
        coinEarnedUrl = nil;
        coinEarnedSoundEffect = nil;
        coinEarnedPath = Bundle.main.path(forResource: "coinEarned.mp3", ofType: nil);
        coinEarnedUrl = URL(fileURLWithPath: coinEarnedPath!);
        do {
            coinEarnedSoundEffect = try AVAudioPlayer(contentsOf: coinEarnedUrl!);
        } catch {
            print("Unable to play coin earned");
        }
    }
    
    static func setupCoinEarned2() {
        coinEarnedPath2 = nil;
        coinEarnedUrl2 = nil;
        coinEarnedSoundEffect2 = nil;
        coinEarnedPath2 = Bundle.main.path(forResource: "coinEarned.mp3", ofType: nil);
        coinEarnedUrl2 = URL(fileURLWithPath: coinEarnedPath2!);
        do {
           coinEarnedSoundEffect2 = try AVAudioPlayer(contentsOf: coinEarnedUrl2!);
        } catch {
           print("Unable to play coin earned");
        }
    }
    
    static func setupCoinEarned3() {
        coinEarnedPath3 = nil;
        coinEarnedUrl3 =  nil;
        coinEarnedSoundEffect3 = nil;
        coinEarnedPath3 = Bundle.main.path(forResource: "coinEarned.mp3", ofType: nil);
        coinEarnedUrl3 = URL(fileURLWithPath: coinEarnedPath3!);
        do {
           coinEarnedSoundEffect3 = try AVAudioPlayer(contentsOf: coinEarnedUrl3!);
        } catch {
           print("Unable to play coin earned");
        }
   }
    
    static func kittenMeow() {
        if (kittenMeowSoundEffect!.isPlaying) {
            if (kittenMeowSoundEffect2!.isPlaying) {
                kittenMeowSoundEffect3!.play();
            } else {
                kittenMeowSoundEffect2!.play();
            }
        } else {
            kittenMeowSoundEffect!.play();
        }
    }
    
    static func setupKittenMeow() {
        kittenMeowPath = nil;
        kittenMeowUrl =  nil;
        kittenMeowSoundEffect = nil;
        kittenMeowPath = Bundle.main.path(forResource: "kittenMeow.mp3", ofType: nil);
        kittenMeowUrl = URL(fileURLWithPath: kittenMeowPath!);
        do {
            kittenMeowSoundEffect = try AVAudioPlayer(contentsOf: kittenMeowUrl!);
            kittenMeowSoundEffect!.setVolume(0.50, fadeDuration: 0.0);
        } catch {
            print("Unable to play kitten meow");
        }
    }
    
    static func setupKittenMeow2() {
        kittenMeowPath2 = nil;
        kittenMeowUrl2 = nil;
        kittenMeowSoundEffect2 = nil;
        kittenMeowPath2 = Bundle.main.path(forResource: "kittenMeow.mp3", ofType: nil);
        kittenMeowUrl2 = URL(fileURLWithPath: kittenMeowPath2!);
        do {
            kittenMeowSoundEffect2 = try AVAudioPlayer(contentsOf: SoundController.kittenMeowUrl2!);
            kittenMeowSoundEffect2!.setVolume(0.50, fadeDuration: 0.0);
        } catch {
            print("Unable to play kitten meow");
        }
    }
    
    static func setupKittenMeow3() {
        kittenMeowPath3 = nil;
        kittenMeowUrl3 = nil;
        kittenMeowSoundEffect3 = nil;
        kittenMeowPath3 = Bundle.main.path(forResource: "kittenMeow.mp3", ofType: nil);
        kittenMeowUrl3 = URL(fileURLWithPath: kittenMeowPath3!);
        do {
            kittenMeowSoundEffect3 = try AVAudioPlayer(contentsOf: kittenMeowUrl3!);
            kittenMeowSoundEffect3!.setVolume(0.50, fadeDuration: 0.0);
        } catch {
            print("Unable to play kitten meow");
        }
    }
    
    static func kittenDie() {
        if (!kittenDieSoundEffect!.isPlaying){
            kittenDieSoundEffect!.play();
            kittenDieSoundEffect!.prepareToPlay();
        }
    }
    
    static func setupKittenDie() {
        kittenDiePath = nil;
        kittenDieUrl = nil;
        kittenDieSoundEffect = nil;
        kittenDiePath = Bundle.main.path(forResource: "kittenDie.mp3", ofType: nil);
        kittenDieUrl = URL(fileURLWithPath: kittenDiePath!);
        do {
           kittenDieSoundEffect = try AVAudioPlayer(contentsOf: kittenDieUrl!);
        } catch {
           print("Unable to play kitten die");
        }
    }
    
    static func mozartSonata(play:Bool, startOver:Bool) {
        if (play) {
            if (startOver) {
                mozartSonataSoundEffect!.stop();
                setupMozartSonata();
                mozartSonataSoundEffect!.play();
                if (UIVolume.musicOff) {
                   mozartSonataSoundEffect!.volume = 0.0;
                }
            } else {
                if (UIVolume.musicOff) {
                    mozartSonataSoundEffect!.volume = 0.0;
                } else {
                    mozartSonataSoundEffect!.setVolume(1.0, fadeDuration: timeInterval05);
                }
            }
        } else {
            mozartSonataSoundEffect!.setVolume(0.0, fadeDuration: timeInterval05);
        }
    }
    
    static func setupMozartSonata() {
        mozartSonataPath = nil;
        mozartSonataUrl = nil;
        mozartSonataSoundEffect = nil;
        mozartSonataPath = Bundle.main.path(forResource: "mozartSonata.mp3", ofType: nil);
        mozartSonataUrl = URL(fileURLWithPath: mozartSonataPath!);
        do {
            mozartSonataSoundEffect = try AVAudioPlayer(contentsOf: mozartSonataUrl!);
            mozartSonataSoundEffect!.numberOfLoops = -1;
        } catch {
            print("Unable to play mozart sonata");
        }
    }
    
    static func setMusicVolumeTo0() {
        if (chopinPreludeSoundEffect != nil && chopinPreludeSoundEffect!.isPlaying) {
            chopinPreludeSoundEffect!.volume = 0.0;
        }
        if (mozartSonataSoundEffect != nil && mozartSonataSoundEffect!.isPlaying) {
            mozartSonataSoundEffect!.volume = 0.0;
        }
    }
    
    static func setMusicVolumeTo100() {
        if (chopinPreludeSoundEffect != nil && chopinPreludeSoundEffect!.isPlaying) {
            chopinPreludeSoundEffect!.volume = 1.0;
        }
        if (mozartSonataSoundEffect != nil && mozartSonataSoundEffect!.isPlaying) {
            if (chopinPreludeSoundEffect != nil && chopinPreludeSoundEffect!.isPlaying) {
                mozartSonataSoundEffect!.volume = 0.0;
            } else {
                mozartSonataSoundEffect!.volume = 1.0;
            }
            
        }
    }
    
    static func chopinPrelude(play:Bool) {
        if (play) {
            chopinPreludeSoundEffect!.stop();
            setupChopinPrelude();
            chopinPreludeSoundEffect!.play();
            if (UIVolume.musicOff) {
                chopinPreludeSoundEffect!.volume = 0.0;
            }
        } else {
            timeInterval05 = TimeInterval(0.5);
            chopinPreludeSoundEffect!.setVolume(0.0, fadeDuration: timeInterval05);
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                chopinPreludeSoundEffect!.stop();
                setupChopinPrelude();
            }
        }
    }
    
    static func setupChopinPrelude() {
        chopinPreludePath = nil;
        chopinPreludeUrl = nil;
        chopinPreludeSoundEffect = nil;
        chopinPreludePath = Bundle.main.path(forResource: "chopinPrelude.mp3", ofType: nil);
        chopinPreludeUrl = URL(fileURLWithPath: chopinPreludePath!);
        do {
            chopinPreludeSoundEffect = try AVAudioPlayer(contentsOf: chopinPreludeUrl!);
        } catch {
            print("Unable to play chopin prelude");
        }
    }
}
