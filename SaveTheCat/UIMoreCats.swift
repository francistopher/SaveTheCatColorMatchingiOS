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
        self.addTarget(self, action: #selector(moreCatsSelector), for: .touchUpInside);
        self.setCompiledStyle();
    }
    
    func setupMoreCatsVC() {
        moreCatsVC = MoreCatsViewController();
        moreCatsVC!.modalPresentationStyle = .overFullScreen;
    }

    @objc func moreCatsSelector() {
        firstTime = true;
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
   
    var firstTime:Bool = false;
    func setCompiledStyle() {
        if (firstTime) {
            moreCatsVC!.setCompiledStyle();
        }
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
        setCompiledStyle();
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
        infoButton!.layer.cornerRadius = infoButton!.frame.height * 0.5;
        infoButton!.layer.borderWidth = contentView!.layer.borderWidth;
        infoButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: infoButton!.frame.height * 0.75)
        infoButton!.layer.maskedCorners = [.layerMaxXMaxYCorner]
    }
    
    @objc func infoButtonSelector() {
        print("Selecting info button")
    }
    
    func setupNextButton() {
        nextButton = UICButton(parentView: contentView!, frame: CGRect(x:contentView!.frame.width * 0.8, y: contentView!.frame.height - contentView!.frame.width * 0.12, width: contentView!.frame.width * 0.2, height: contentView!.frame.width * 0.12), backgroundColor: UIColor.systemYellow);
        nextButton!.addTarget(self, action: #selector(nextButtonSelector), for: .touchUpInside);
        nextButton!.setTitle(">", for: .normal);
        nextButton!.layer.cornerRadius = nextButton!.frame.height * 0.5;
        nextButton!.layer.borderWidth = contentView!.layer.borderWidth;
        nextButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: nextButton!.frame.height * 0.75)
        nextButton!.layer.maskedCorners = [.layerMinXMinYCorner]
    }
    
    @objc func nextButtonSelector() {
        print("Next button selected")
    }
    
    func setupPreviousButton() {
        previousButton = UICButton(parentView: contentView!, frame: CGRect(x: 0.0, y: contentView!.frame.height - contentView!.frame.width * 0.12, width: contentView!.frame.width * 0.2, height:  contentView!.frame.width * 0.12), backgroundColor: UIColor.systemYellow);
        previousButton!.addTarget(self, action: #selector(previousButtonSelector), for: .touchUpInside);
        previousButton!.setTitle("<", for: .normal);
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
        presentationCatButton = UICatButton(parentView: contentView!, x: presentationCatButtonX!, y: presentationCatButtonY!, width: presentationCatButtonSideLength!, height: presentationCatButtonSideLength!, backgroundColor: UIColor.clear);
        presentationCatButton!.imageContainerButton!.addTarget(self, action: #selector(presentationCatButtonSelector), for: .touchUpInside);
        presentationCatButton!.clipsToBounds = true;
    }
    
    func setupCatViewHandler() {
        catViewHandler = UICView(parentView: contentView!, x: 0.0, y: presentationCatButton!.originalFrame!.minY, width: presentationCatButton!.originalFrame!.width * 1.05, height: presentationCatButton!.originalFrame!.width, backgroundColor: UIColor.clear);
        catViewHandler!.invertColor = true;
        catViewHandler!.setStyle();
        catViewHandler!.layer.cornerRadius = presentationCatButton!.layer.cornerRadius;
        CenterController.centerHorizontally(childView: catViewHandler!, parentRect: contentView!.frame, childRect: catViewHandler!.frame);
        catViewHandler!.originalFrame = catViewHandler!.frame;
        contentView!.bringSubviewToFront(presentationCatButton!);
    }
    
    func setupCatLabelName() {
        catLabelName = UICLabel(parentView: catViewHandler!, x: 0.0, y: presentationCatButton!.layer.borderWidth * 0.75, width: catViewHandler!.frame.width, height: (self.hideButton!.frame.height));
        catLabelName!.isInverted = true;
        catLabelName!.setStyle();
        CenterController.centerHorizontally(childView: catLabelName!, parentRect: catViewHandler!.frame, childRect: catLabelName!.frame);
        catLabelName!.layer.cornerRadius = catViewHandler!.layer.cornerRadius;
        catLabelName!.text = "Standard Cat";
        catLabelName!.clipsToBounds = true;
        catLabelName!.font = UIFont.boldSystemFont(ofSize: catLabelName!.frame.height * 0.6);
    }
    
    func setupControlButton() {
        controlButton = UICButton(parentView: catViewHandler!, frame:CGRect(x: 0.0, y: catViewHandler!.frame.height - (presentationCatButton!.layer.borderWidth * 0.5) - self.catLabelName!.frame.height, width: catViewHandler!.frame.width * 0.75, height: self.hideButton!.frame.height * 1.025), backgroundColor: UIColor.systemGreen);
        CenterController.centerHorizontally(childView: controlButton!, parentRect: catViewHandler!.frame, childRect: controlButton!.frame);
        controlButton!.originalFrame = controlButton!.frame;
        controlButton!.layer.cornerRadius =  catViewHandler!.layer.cornerRadius * 0.4;
        controlButton!.clipsToBounds = true;
        controlButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: controlButton!.frame.height * 0.5);
        controlButton!.addTarget(self, action: #selector(controlButtonSelector), for: .touchUpInside);
        controlButton!.setTitle("Meow!", for: .normal);
    }
    
    @objc func controlButtonSelector() {
        SoundController.kittenMeow();
    }
    
    var presentLabelNameTimer:Timer?
    var presentLabelNameAnimation:UIViewPropertyAnimator?
    func setupPresentLabelNameAnimation () {
        self.presentLabelNameAnimation = UIViewPropertyAnimator.init(duration: 1.0, curve: .easeOut, animations: {
            self.catViewHandler!.frame = CGRect(x: self.catViewHandler!.frame.minX, y: self.presentationCatButton!.frame.minY - (self.hideButton!.frame.height), width: self.presentationCatButton!.frame.width * 1.05, height: self.presentationCatButton!.frame.height + (self.hideButton!.frame.height) * 2.0);
            // Control button
            self.controlButton!.frame = CGRect(x: self.controlButton!.frame.minX, y: self.catViewHandler!.frame.height - (self.presentationCatButton!.layer.borderWidth * 0.5) - self.catLabelName!.frame.height + self.catViewHandler!.layer.borderWidth, width: self.catViewHandler!.frame.width * 0.75, height: self.hideButton!.frame.height * 1.025);
            
        })
    }
    
    func setupPresentLabelNameTimer() {
        presentLabelNameTimer = Timer.scheduledTimer(withTimeInterval: 0.0, repeats: false, block: { _ in
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
        catLabelName!.frame = catLabelName!.originalFrame!;
        controlButton!.frame = controlButton!.originalFrame!;
        catViewHandler!.frame = catViewHandler!.originalFrame!;
        catViewHandler!.layer.cornerRadius = presentationCatButton!.layer.cornerRadius;
        catLabelName!.layer.cornerRadius = catViewHandler!.layer.cornerRadius;
        presentationCatButton!.imageContainerButton!.shrunked();
        presentationCatButton!.shrunk();
        presentationCatButton!.imageContainerButton!.imageView!.layer.removeAllAnimations();
        presentationCatButton!.imageContainerButton!.imageView!.transform = .identity;
        setupPresentLabelNameAnimation();
    }
    
    @objc func presentationCatButtonSelector() {
       
    }
    
    func setCompiledStyle() {
        presentationCatButton!.setStyle();
        presentationCatButton!.setCat(named: "SmilingCat", stage: 5);
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            presentationCatButton!.backgroundColor = UIColor.white;
        } else {
            presentationCatButton!.backgroundColor = UIColor.black;
        }
        contentView!.setStyle();
        catViewHandler!.setStyle();
        catLabelName!.setStyle();
        hideButton!.setStyle();
        infoButton!.setStyle();
        previousButton!.setStyle();
        nextButton!.setStyle();
        controlButton!.setStyle();
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1) {
            controlButton!.setTitleColor(UIColor.white, for: .normal);
        } else {
            controlButton!.setTitleColor(UIColor.black, for: .normal);
        }
    }
    
}
