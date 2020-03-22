//
//  UIMoreCatsButton.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/13/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI

class UIMoreCats: UIButton {
   
    var originalFrame:CGRect?
    var reducedFrame:CGRect?
    var moreCatsView:UICView?
    var moreCatsViewIsPresented:Bool = false;

    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }

    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        self.originalFrame = CGRect(x: x, y: y, width: width, height: height);
        parentView.addSubview(self);
        self.backgroundColor = .clear;
        self.layer.cornerRadius = height / 2.0;
        self.addTarget(self, action: #selector(moreCatsSelector), for: .touchUpInside);
        self.setupMoreCatsView();
        self.setStyle();
    }
    
    var moreCatsWidth:CGFloat?
    var moreCatsHeight:CGFloat?
    var moreCatsY:CGFloat?
    func setupMoreCatsView() {
        if (ViewController.aspectRatio! == .ar4by3) {
            moreCatsY = self.superview!.frame.minY * 2.0 + self.superview!.frame.height;
            moreCatsWidth = ViewController.staticMainView!.frame.width * 0.755;
            moreCatsHeight = ViewController.staticMainView!.frame.height * 0.66;
        }
        moreCatsView = UICView(parentView: ViewController.staticMainView!, x: 0.0, y: moreCatsY!, width: moreCatsWidth!, height: moreCatsHeight!, backgroundColor: UIColor.red);
        CenterController.centerHorizontally(childView: moreCatsView!, parentRect: ViewController.staticMainView!.frame, childRect: moreCatsView!.frame);
        moreCatsView!.layer.borderWidth = moreCatsWidth! * 0.015;
        moreCatsView!.layer.cornerRadius = moreCatsWidth! * 0.1;
        moreCatsView!.alpha = 0.0;
        setupPresentationCat();
    }
    
    var presentationCatButton:UICatButton?
    var presentationCatButtonX:CGFloat?
    var presentationCatButtonY:CGFloat?
    var presentationCatButtonSideLength:CGFloat?
    func setupPresentationCat() {
        presentationCatButtonSideLength = moreCatsWidth! * 0.7;
        presentationCatButtonX = (self.moreCatsView!.frame.width - presentationCatButtonSideLength!) * 0.5;
        presentationCatButtonY = (self.moreCatsView!.frame.height - presentationCatButtonSideLength!) * 0.5;
        presentationCatButton = UICatButton(parentView: moreCatsView!, x: presentationCatButtonX!, y: presentationCatButtonY!, width: presentationCatButtonSideLength!, height: presentationCatButtonSideLength!, backgroundColor: UIColor.systemRed);
        CenterController.center(childView: presentationCatButton!, parentRect: moreCatsView!.frame, childRect: presentationCatButton!.frame);
        presentationCatButton!.imageContainerButton!.addTarget(self, action: #selector(presentationCatButtonSelector), for: .touchUpInside);
        presentationCatButton!.setCat(named: "SmilingCat", stage: 4);
        presentationCatButton!.randomAnimationSelection = 1;
        presentationCatButton!.setRandomCatAnimation();
    }
    
    @objc func presentationCatButtonSelector() {
        SoundController.kittenMeow();
    }

    @objc func moreCatsSelector() {
        ViewController.staticMainView!.bringSubviewToFront(moreCatsView!);
        if (moreCatsViewIsPresented) {
            moreCatsView!.fadeOut();
            moreCatsViewIsPresented = false;
        } else {
            print("Should have been presented?", moreCatsView!.frame)
            moreCatsView!.fadeIn();
            moreCatsViewIsPresented = true;
            presentationCatButton!.grow();
            presentationCatButton!.imageContainerButton!.grow();
        }
    }
       
    var iconImage:UIImage?
    func setIconImage(named:String) {
        iconImage = nil;
        iconImage = UIImage(named: named);
        self.setImage(iconImage, for: .normal);
        self.imageView!.contentMode = UIView.ContentMode.scaleAspectFit;
    }
   
    func setStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            setIconImage(named: "darkMoreCats.png");
        } else {
            setIconImage(named: "lightMoreCats.png");
        }
    }
}
