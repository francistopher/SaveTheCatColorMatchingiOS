//
//  UIEnemies.swift
//  SaveTheCat
//
//  Created by Christopher Francisco on 2/10/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIEnemies {
    
    var enemiesCollection:[UIEnemy]?
    var mainView:UIView?
    
    init(mainView:UIView, unitView:CGFloat){
        self.mainView = mainView;
        enemiesCollection = [];
        buildEnemies(unitView: unitView);
    }
    
    /*
        Plot each hairball equidistant from each other
        horizontally and vertically
     */
    var enemySideLength:CGFloat?
    var totalWidthSpacing:CGFloat?
    var totalHeightSpacing:CGFloat?
    var enemyWidthSpacing:CGFloat?
    var enemyHeightSpacing:CGFloat?
    var x:CGFloat?
    var y:CGFloat?
    var enemy:UIEnemy?
    func buildEnemies(unitView:CGFloat) {
        // Calculate side and spacing lengths of enemy
        enemySideLength = unitView * 2.0;
        // Total Spacing Available
        totalWidthSpacing = mainView!.frame.width - (enemySideLength! * 3.0);
        totalHeightSpacing = mainView!.frame.height - (enemySideLength! * 4.0);
        // Enemy Spacing Length
        enemyWidthSpacing = totalWidthSpacing! / 2.625;
        enemyHeightSpacing = totalHeightSpacing! / 4.0;
        // Initial starting coordinates
        x = -enemyWidthSpacing! * 0.665;
        y = -enemyHeightSpacing! * 0.45;
        // Plot and build enemies
        for _ in 0..<3 {
            x! += enemyWidthSpacing!;
            for _ in 0..<4 {
                y! += enemyHeightSpacing!;
                enemy = UIEnemy(parentView: mainView!, frame:CGRect(x: x!, y: y!, width: enemySideLength!, height: enemySideLength!));
                enemy!.isUserInteractionEnabled = false;
                enemiesCollection!.append(enemy!);
                y! += enemySideLength!;
            }
            x! += enemySideLength!;
            y! = -enemyHeightSpacing! * 0.45;
        }
    }
    /*
        Updates the hairball's colors based on the
        theme of the operating system
     */
    func setStyle() {
        for enemy in enemiesCollection! {
            enemy.setupEnemyImage();
        }
    }
    
    /*
        Makes the hairballs appear from nothing
     */
    func fadeIn(){
        // Fade each enemy in
        for enemy in self.enemiesCollection! {
            enemy.fadeIn();
        }
    }
    
    /*
        Translate the hairballs to the cat button
        and back to it's location of origin
     */
    func translateToCatAndBack(catButton:UICatButton){
        // Translate each enemy to the center of the grid of cats
        for enemy in self.enemiesCollection! {
            enemy.translateToAndBackAt(xTarget: catButton.frame.midX, yTarget: catButton.frame.midY);
        }
    }
    
    /*
        Swings the hairballs back and forth near
        their position of origin
     */
    func sway(immediately:Bool){
        // Animate each enemy
        for enemy in self.enemiesCollection! {
            enemy.sway(immediately: immediately);
        }
    }
    
    /*
        Hides the hairballs by making them
        fully transparent
     */
    func hide() {
        // Hide each enemy
        for enemy in self.enemiesCollection! {
            enemy.alpha = 0.0;
            enemy.layer.removeAllAnimations();
            enemy.frame = enemy.originalFrame!;
        }
    }
    
}
