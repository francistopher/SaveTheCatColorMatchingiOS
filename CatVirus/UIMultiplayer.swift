//
//  UIMultiPlayer.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/13/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIMultiplayer: UIButton {

    var originalFrame:CGRect? = nil;
    var reducedFrame:CGRect? = nil;
    var multiplayerView:UICView?;

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        self.originalFrame = CGRect(x: x, y: y, width: width, height: height);
        self.backgroundColor = .clear;
        self.layer.cornerRadius = height / 2.0;
        self.addTarget(self, action: #selector(testingSelector), for: .touchUpInside);
        parentView.addSubview(self);
        self.setupMultiplayerView();
        setStyle();
    }

    @objc func testingSelector() {
        if (self.multiplayerView!.alpha == 0.0) {
            fadeBackgroundIn();
        } else {
            fadeBackgroundOut();
        }
    }
    
    func setupMultiplayerView() {
        multiplayerView = UICView(parentView: self.superview!.superview!, x: 0.0, y: 0.0, width: ViewController.staticUnitViewHeight * 8, height: ViewController.staticUnitViewHeight * 8, backgroundColor: UIColor.white);
        UICenterKit.centerWithVerticalDisplacement(childView: multiplayerView!, parentRect: self.multiplayerView!.superview!.frame, childRect: multiplayerView!.frame, verticalDisplacement: -ViewController.staticUnitViewHeight * 0.25);
        multiplayerView!.layer.cornerRadius = self.multiplayerView!.frame.height * 0.25;
        multiplayerView!.layer.borderWidth = self.multiplayerView!.frame.height * 0.015;
        multiplayerView!.layer.borderColor = UIColor.black.cgColor;
        multiplayerView!.alpha = 0.0;
    }
    
    func setIconImage(imageName: String) {
        let iconImage:UIImage? = UIImage(named: imageName);
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func fadeBackgroundIn(){
        UIView.animate(withDuration: 0.5, delay: 0.125, options: .curveEaseIn, animations: {
            self.multiplayerView!.alpha = 1.0;
        });
    }
    
    func fadeBackgroundOut(){
        UIView.animate(withDuration: 0.5, delay: 0.125, options: .curveEaseIn, animations: {
            self.multiplayerView!.alpha = 0.0;
        });
    }
    
    func setStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            setIconImage(imageName: "lightMoreCats.png");
        } else {
            setIconImage(imageName: "darkMoreCats.png");
        }
    }
    
    
}
