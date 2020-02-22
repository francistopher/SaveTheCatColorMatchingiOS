//
//  FishCoin.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/13/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIMouseCoin: UIButton {
    
    var originalFrame:CGRect? = nil;
    var reducedFrame:CGRect? = nil;
    var isSelectable:Bool = false;
    var mouseCoinView:UICView?
    var imageMouseCoinView:UIImageView?
    var amountLabel:UICLabel?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        self.originalFrame = CGRect(x: x, y: y, width: width, height: height);
        self.backgroundColor = .clear;
        self.layer.cornerRadius = height / 2.0;
        setIconImage(imageName: "mouseCoin.png");
        self.addTarget(self, action: #selector(testingSelector), for: .touchUpInside);
        parentView.addSubview(self);
        setupMouseCoinView();
        mouseCoinView!.alpha = 0.0;
    }
    
    @objc func testingSelector() {
        if (isSelectable) {
            fadeBackgroundOut();
            isSelectable = false;
        } else {
            self.amountLabel!.text = "\(UIStatistics.mouseCoins)";
            mouseCoinView!.superview!.bringSubviewToFront(mouseCoinView!);
            fadeBackgroundIn();
            isSelectable = true;
        }
    }
    
    func setupMouseCoinView() {
        self.mouseCoinView = UICView(parentView: self.superview!.superview!, x: 0.0, y: 0.0, width: ViewController.staticUnitViewHeight * 8, height: ViewController.staticUnitViewHeight * 8, backgroundColor: UIColor.white);
        UICenterKit.centerWithVerticalDisplacement(childView: mouseCoinView!, parentRect: mouseCoinView!.superview!.frame, childRect: mouseCoinView!.frame, verticalDisplacement: -ViewController.staticUnitViewHeight * 0.25);
        mouseCoinView!.layer.cornerRadius = mouseCoinView!.frame.height * 0.25;
        mouseCoinView!.layer.borderWidth = mouseCoinView!.frame.height * 0.015;
        mouseCoinView!.layer.borderColor = UIColor.black.cgColor;
        setupImageMouseCoinView();
        setupAmountLabel();
    }
    
    func setupImageMouseCoinView() {
        self.imageMouseCoinView = UIImageView(frame: CGRect(x: self.mouseCoinView!.frame.width * 0.125, y: self.mouseCoinView!.frame.width * 0.035, width: self.mouseCoinView!.frame.width * 0.75, height: self.mouseCoinView!.frame.width * 0.75));
        self.imageMouseCoinView!.image = UIImage(named: "mouseCoin.png");
        self.mouseCoinView!.addSubview(imageMouseCoinView!);
    }
    
    func setupAmountLabel() {
        self.amountLabel = UICLabel(parentView: mouseCoinView!, x: 0.0, y: self.mouseCoinView!.frame.width * 0.6975, width: self.mouseCoinView!.frame.width, height: self.mouseCoinView!.frame.width * 0.25);
        self.amountLabel!.font = UIFont.boldSystemFont(ofSize: amountLabel!.frame.height * 0.5);
    }
    
    func setIconImage(imageName:String) {
        let iconImage:UIImage? = UIImage(named:imageName);
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
    
    func fadeBackgroundIn(){
        UIView.animate(withDuration: 0.5, delay: 0.125, options: .curveEaseIn, animations: {
            self.mouseCoinView!.alpha = 1.0;
        });
    }
    
    func fadeBackgroundOut(){
        UIView.animate(withDuration: 0.5, delay: 0.125, options: .curveEaseIn, animations: {
            self.mouseCoinView!.alpha = 0.0;
        });
    }

}
