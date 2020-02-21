//
//  UIStatistics.swift
//  CatVirus
//
//  Created by Christopher Francisco on 2/20/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation

class UIStatistics {
    
    // Survival and Death Count
    var entiretyOfCatsThatDied:Int = 0;
    var entiretyOfCatsThatSurvived:Int = 0;
    var catsThatDied:Int = 0;
    var catsThatLived:Int = 0;
    
    // Stage time
    var stageStartTime:Double = 0.0;
    var stageEndTime:Double = 0.0;
    var stageTimeLength:[Int:Double] = [:];
    var fastestStageTimeLength:[Int:Double] = [:];
    
    func getCurrentStageTimeLength() -> Double {
        return (stageEndTime - stageStartTime);
    }
    
    func loadStageTimeLengths(stage:Int) {
        stageTimeLength[stage] = getCurrentStageTimeLength();
    }
    
    func printSessionStatistics() {
        print("Cats that lived: \(catsThatLived)");
        print("Cats that died: \(catsThatDied)");
        let startTimeLengthTouple:[(key:Int, value:Double)] = stageTimeLength.sorted{$0.value < $1.value};
        for (key, value) in startTimeLengthTouple {
            print("Stage: \(key) TimeLength: \(value)");
        }
    }
    
    
    
}
