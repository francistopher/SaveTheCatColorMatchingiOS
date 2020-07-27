//
//  UIStats.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/13/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UILeadBoard: UIButton {
    
    var originalFrame:CGRect?
    var reducedFrame:CGRect?
    var label1:UICLabel?
    var label2:UICLabel?
    var label3:UICLabel?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        self.originalFrame = CGRect(x: x, y: y, width: width, height: height);
        self.backgroundColor = .clear;
        self.layer.cornerRadius = height / 2.0;
        setIconImage(imageName: "leaderBoard.png");
        setupLabel1();
        setupLabel2();
        setupLabel3();
        setStyle();
        self.addTarget(self, action: #selector(statsSelector), for: .touchUpInside);
        parentView.addSubview(self);
    }

    /*
        Creates the number 1 text label
     */
    func setupLabel1() {
        label1 = UICLabel(parentView: self, x: 0.0, y: frame.height * 0.575, width: frame.width / 3.0, height: frame.width / 3.0);
        label1!.backgroundColor = UIColor.clear;
        label1!.font = UIFont.boldSystemFont(ofSize: label1!.frame.height * 0.9);
        label1!.text = "2";
        ViewController.updateFont(label: label1!);
        self.addSubview(label1!);
    }
    
    /*
        Creates the number 2 text label
     */
    func setupLabel2() {
        label2 = UICLabel(parentView: self, x: frame.width / 3.0, y: frame.height * 0.4, width: frame.width / 3.0, height: frame.width / 3.0);
        label2!.backgroundColor = UIColor.clear;
        label2!.font = UIFont.boldSystemFont(ofSize: label2!.frame.height * 0.9);
        label2!.text = "1";
        ViewController.updateFont(label: label2!);
        self.addSubview(label2!);
    }
    
    /*
        Creates the number 3 text label
     */
    func setupLabel3() {
        label3 = UICLabel(parentView: self,x: 2.0 * frame.width / 3.0, y: frame.height * 0.675, width: frame.width / 3.0, height: frame.width / 3.0);
        label3!.backgroundColor = UIColor.clear;
        label3!.font = UIFont.boldSystemFont(ofSize: label3!.frame.height * 0.9);
        label3!.text = "3";
        ViewController.updateFont(label: label3!);
        self.addSubview(label3!);
    }
    
    @objc func statsSelector() {
        ViewController.staticSelf!.checkMemoryCapacityLeaderBoard();
    }
    
    /*
        Creates the pedestals image of the leaderboard
     */
    var iconImage:UIImage?
    func setIconImage(imageName:String) {
        iconImage = nil;
        iconImage = UIImage(named:imageName);
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func updateLabelNumsTitleColor(color:UIColor) {
        for label in [label1, label2, label3] {
            label!.textColor = color;
        }
    }
    
    /*
        Update the colors of the number labels
        based on the theme of the operating system
     */
    func setStyle() {
        if (ViewController.uiStyleRawValue == 1){
            updateLabelNumsTitleColor(color: UIColor.black);
        } else {
            updateLabelNumsTitleColor(color: UIColor.white);
        }
    }
    
}
