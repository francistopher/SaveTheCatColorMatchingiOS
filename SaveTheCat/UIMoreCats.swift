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
    var moreCatsVC:MoreCatsViewController?

    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }

    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        self.originalFrame = CGRect(x: x, y: y, width: width, height: height);
        parentView.addSubview(self);
        self.backgroundColor = .clear;
        self.layer.cornerRadius = height / 2.0;
        self.setupMoreCatsVC();
        self.setStyle();
        self.addTarget(self, action: #selector(moreCatsSelector), for: .touchUpInside);
    }
    
    func setupMoreCatsVC() {
        moreCatsVC = MoreCatsViewController();
        moreCatsVC!.modalPresentationStyle = .overFullScreen;
    }

    @objc func moreCatsSelector() {
//        ViewController.staticMainView!.bringSubviewToFront(moreCatsView!);
//            moreCatsView!.fadeOut();
//            print("Should have been presented?", moreCatsView!.frame)
//            moreCatsView!.fadeIn();
        ViewController.staticSelf!.present(moreCatsVC!, animated: true, completion: {
            self.moreCatsVC!.presentCatButton();
        });
        UIView.animate(withDuration: 0.25, animations: {
            ViewController.staticSelf!.view.alpha = 0.5;
        })

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

class MoreCatsViewController:UIViewController {
    
    var contentView:UICView?
    var hideButton:UICButton?
    override func viewDidLoad() {
        super.viewDidLoad();
        setupMainView()
        setupContentView()
        setupHideButton()
        setupPresentationCat()
        setupCatLabelName();
    }
    
    func setupMainView() {
        view.backgroundColor = UIColor.clear;
    }
    
    func setupContentView() {
        contentView = UICView(parentView: view, x: 0.0, y: 0.0, width: view.frame.width * 0.7, height: view.frame.height * 0.65, backgroundColor: UIColor.red);
        CenterController.center(childView: contentView!, parentRect: view.frame, childRect: contentView!.frame);
        contentView!.layer.borderWidth = contentView!.frame.width * 0.0125;
        contentView!.layer.cornerRadius = contentView!.frame.width * 0.1
        contentView!.clipsToBounds = true;
    }
    
    func setupHideButton() {
        hideButton = UICButton(parentView: contentView!, frame: CGRect(x: contentView!.frame.width * 0.75, y: 0.0, width: contentView!.frame.width * 0.25, height: contentView!.frame.width * 0.125), backgroundColor: UIColor.red);
        hideButton!.addTarget(self, action: #selector(hideButtonSelector), for: .touchUpInside);
        hideButton!.setTitle("Done", for: .normal);
        hideButton!.setTitleColor(UIColor.white, for: .normal);
        hideButton!.layer.cornerRadius = hideButton!.frame.height * 0.5;
        hideButton!.layer.borderWidth = contentView!.layer.borderWidth;
        hideButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: hideButton!.frame.height * 0.4)
        hideButton!.layer.maskedCorners = [ .layerMinXMaxYCorner]
    }
    
    func setupCatLabelName() {
        
    }
    
    @objc func hideButtonSelector() {
        self.dismiss(animated: true, completion: nil);
        self.hideCatButton();
        UIView.animate(withDuration: 0.25, animations: {
            ViewController.staticSelf!.view.alpha = 1.0;
        })
    }
    
    var presentationCatButton:UICatButton?
    var presentationCatButtonX:CGFloat?
    var presentationCatButtonY:CGFloat?
    var presentationCatButtonSideLength:CGFloat?
    func setupPresentationCat() {
        presentationCatButtonSideLength = contentView!.frame.width * 0.7;
        presentationCatButtonX = (self.contentView!.frame.width - presentationCatButtonSideLength!) * 0.5;
        presentationCatButtonY = (self.contentView!.frame.height - presentationCatButtonSideLength!) * 0.5;
        presentationCatButton = UICatButton(parentView: contentView!, x: presentationCatButtonX!, y: presentationCatButtonY!, width: presentationCatButtonSideLength!, height: presentationCatButtonSideLength!, backgroundColor: UIColor.systemRed);
        CenterController.center(childView: presentationCatButton!, parentRect: contentView!.frame, childRect: presentationCatButton!.frame);
        presentationCatButton!.imageContainerButton!.addTarget(self, action: #selector(presentationCatButtonSelector), for: .touchUpInside);
    }
    
    func presentCatButton() {
        presentationCatButton!.setCat(named: "SmilingCat", stage: 3);
        presentationCatButton!.randomAnimationSelection = 0;
        presentationCatButton!.setRandomCatAnimation();
        presentationCatButton!.grow();
        presentationCatButton!.imageContainerButton!.grow();
    }
    
    func hideCatButton() {
        presentationCatButton!.imageContainerButton!.layer.removeAllAnimations();
        presentationCatButton!.imageContainerButton!.transform = .identity;
        presentationCatButton!.imageContainerButton!.shrunked();
        presentationCatButton!.shrunk();
    }
    
    @objc func presentationCatButtonSelector() {
        SoundController.kittenMeow();
    }
    
}
