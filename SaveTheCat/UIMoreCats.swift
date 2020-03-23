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
    var catViewHandler:UICView?
    var catLabelName:UICLabel?
    
    
    var hideButton:UICButton?
    var infoButton:UICButton?
    var previousButton:UICButton?
    var nextButton:UICButton?
    var controlButton:UICButton?
    
    override func viewDidLoad() {
        super.viewDidLoad();
        setupMainView()
        setupContentView()
        setupHideButton()
        setupInfoButton()
        
        setupPresentationCat()
        setupCatViewHandler()
        setupCatLabelName();
        setupPreviousButton();
        setupNextButton();
        setupControlButton();
        setupPresentLabelNameAnimation();
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
        hideButton = UICButton(parentView: contentView!, frame: CGRect(x: contentView!.frame.width * 0.8, y: 0.0, width: contentView!.frame.width * 0.2, height: contentView!.frame.width * 0.12), backgroundColor: UIColor.red);
        hideButton!.addTarget(self, action: #selector(hideButtonSelector), for: .touchUpInside);
        hideButton!.setTitle("x", for: .normal);
        hideButton!.setTitleColor(UIColor.white, for: .normal);
        hideButton!.layer.cornerRadius = hideButton!.frame.height * 0.5;
        hideButton!.layer.borderWidth = contentView!.layer.borderWidth;
        hideButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: hideButton!.frame.height * 0.75)
        hideButton!.layer.maskedCorners = [ .layerMinXMaxYCorner]
    }
    
    @objc func hideButtonSelector() {
        self.dismiss(animated: true, completion: nil);
        self.hideCatButton();
        UIView.animate(withDuration: 0.25, animations: {
            ViewController.staticSelf!.view.alpha = 1.0;
        })
    }
    
    func setupInfoButton() {
        infoButton = UICButton(parentView: contentView!, frame: CGRect(x: 0.0, y: 0.0, width: contentView!.frame.width * 0.2, height: contentView!.frame.width * 0.12), backgroundColor: UIColor.systemBlue);
        infoButton!.addTarget(self, action: #selector(infoButtonSelector), for: .touchUpInside);
        infoButton!.setTitle("i", for: .normal);
        infoButton!.setTitleColor(UIColor.white, for: .normal);
        infoButton!.layer.cornerRadius = infoButton!.frame.height * 0.5;
        infoButton!.layer.borderWidth = contentView!.layer.borderWidth;
        infoButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: infoButton!.frame.height * 0.75)
        infoButton!.layer.maskedCorners = [.layerMaxXMaxYCorner]
    }
    
    @objc func infoButtonSelector() {
        print("Selecting info button")
    }
    
    func setupNextButton() {
        nextButton = UICButton(parentView: contentView!, frame: CGRect(x:contentView!.frame.width * 0.8, y: contentView!.frame.height - contentView!.frame.width * 0.12, width: contentView!.frame.width * 0.2, height: contentView!.frame.width * 0.12), backgroundColor: UIColor.black);
        nextButton!.addTarget(self, action: #selector(nextButtonSelector), for: .touchUpInside);
        nextButton!.setTitle(">", for: .normal);
        nextButton!.setTitleColor(UIColor.white, for: .normal);
        nextButton!.layer.cornerRadius = nextButton!.frame.height * 0.5;
        nextButton!.layer.borderWidth = contentView!.layer.borderWidth;
        nextButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: nextButton!.frame.height * 0.75)
        nextButton!.layer.maskedCorners = [.layerMinXMinYCorner]
    }
    
    @objc func nextButtonSelector() {
        print("Next button selected")
    }
    
    func setupPreviousButton() {
        previousButton = UICButton(parentView: contentView!, frame: CGRect(x: 0.0, y: contentView!.frame.height - contentView!.frame.width * 0.12, width: contentView!.frame.width * 0.2, height:  contentView!.frame.width * 0.12), backgroundColor: UIColor.black);
        previousButton!.addTarget(self, action: #selector(previousButtonSelector), for: .touchUpInside);
        previousButton!.setTitle("<", for: .normal);
        previousButton!.setTitleColor(UIColor.white, for: .normal);
        previousButton!.layer.cornerRadius = previousButton!.frame.height * 0.5;
        previousButton!.layer.borderWidth = contentView!.layer.borderWidth;
        previousButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: previousButton!.frame.height * 0.75)
        previousButton!.layer.maskedCorners = [.layerMaxXMinYCorner]
    }
    
    @objc func previousButtonSelector() {
        print("Previous button selected")
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
        presentationCatButton!.imageContainerButton!.addTarget(self, action: #selector(presentationCatButtonSelector), for: .touchUpInside);
        presentationCatButton!.clipsToBounds = true;
    }
    
    func setupCatViewHandler() {
        catViewHandler = UICView(parentView: contentView!, x: 0.0, y: presentationCatButton!.originalFrame!.minY, width: presentationCatButton!.originalFrame!.width, height: presentationCatButton!.originalFrame!.width, backgroundColor: UIColor.white);
        catViewHandler!.layer.cornerRadius = presentationCatButton!.layer.cornerRadius * 0.75;
        catViewHandler!.backgroundColor = UIColor.white;
        CenterController.centerHorizontally(childView: catViewHandler!, parentRect: contentView!.frame, childRect: catViewHandler!.frame);
        contentView!.bringSubviewToFront(presentationCatButton!);
    }
    
    func setupCatLabelName() {
        catLabelName = UICLabel(parentView: catViewHandler!, x: 0.0, y: presentationCatButton!.layer.borderWidth * 0.75, width: catViewHandler!.frame.width, height: (self.hideButton!.frame.height));
        CenterController.centerHorizontally(childView: catLabelName!, parentRect: catViewHandler!.frame, childRect: catLabelName!.frame);
        catLabelName!.layer.cornerRadius = catViewHandler!.layer.cornerRadius;
        catLabelName!.backgroundColor = UIColor.white;
        catLabelName!.text = "Standard Cat";
        catLabelName!.clipsToBounds = true;
        catLabelName!.font = UIFont.boldSystemFont(ofSize: catLabelName!.frame.height * 0.6);
    }
    
    func setupControlButton() {
        controlButton = UICButton(parentView: catViewHandler!, frame:CGRect(x: 0.0, y: catViewHandler!.frame.height - (presentationCatButton!.layer.borderWidth * 0.75) - self.catLabelName!.frame.height, width: catViewHandler!.frame.width * 0.8, height: self.hideButton!.frame.height), backgroundColor: UIColor.systemGreen);
        CenterController.centerHorizontally(childView: controlButton!, parentRect: catViewHandler!.frame, childRect: controlButton!.frame);
        controlButton!.layer.cornerRadius =  catViewHandler!.layer.cornerRadius * 0.5;
        controlButton!.clipsToBounds = true;
        controlButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: controlButton!.frame.height * 0.5);
        controlButton!.addTarget(self, action: #selector(controlButtonSelector), for: .touchUpInside);
        controlButton!.setTitle("Meow", for: .normal);
        controlButton!.alpha = 0.0;
    }
    
    @objc func controlButtonSelector() {
        SoundController.kittenMeow();
    }
    
    var presentLabelNameTimer:Timer?
    var presentLabelNameAnimation:UIViewPropertyAnimator?
    func setupPresentLabelNameAnimation () {
        self.presentLabelNameAnimation = UIViewPropertyAnimator.init(duration: 1.0, curve: .easeOut, animations: {
            self.catLabelName!.textColor = UIColor.black;
            self.catViewHandler!.frame = CGRect(x: self.catViewHandler!.frame.minX, y: self.presentationCatButton!.frame.minY - (self.hideButton!.frame.height), width: self.presentationCatButton!.frame.width, height: self.presentationCatButton!.frame.height + (self.hideButton!.frame.height) * 2.0);
            self.catViewHandler!.layer.cornerRadius = self.presentationCatButton!.layer.cornerRadius * 0.75;
            // Crap
            self.controlButton!.setTitleColor(UIColor.black, for: .normal);
            self.controlButton!.frame = CGRect(x: self.controlButton!.frame.minX, y: self.catViewHandler!.frame.height - (self.presentationCatButton!.layer.borderWidth * 0.75) - self.catLabelName!.frame.height + self.catViewHandler!.layer.borderWidth, width: self.catViewHandler!.frame.width * 0.8, height: self.hideButton!.frame.height * 1.05);
            self.controlButton!.layer.cornerRadius =  self.catViewHandler!.layer.cornerRadius * 0.5;
            self.controlButton!.alpha = 1.0;
        })
    }
    
    func setupPresentLabelNameTimer() {
        presentLabelNameTimer = Timer.scheduledTimer(withTimeInterval: 1.125, repeats: false, block: { _ in
            self.presentLabelNameAnimation!.startAnimation();
        })
    }
    
    func presentCatButton() {
        presentationCatButton!.setCat(named: "SmilingCat", stage: 3);
        presentationCatButton!.randomAnimationSelection = 0;
        presentationCatButton!.setRandomCatAnimation();
        presentationCatButton!.grow();
        presentationCatButton!.imageContainerButton!.grow();
        setupPresentLabelNameTimer();
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
