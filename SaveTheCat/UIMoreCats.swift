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
    var displayedCatIndex:Int = -1;
    var catNames:[String] = ["Standard Cat", "Cat Breading", "Taco Cat", "Egyptian Cat", "Super Cat", "Chicken Cat", "Cool Cat", "Ninja Cat", "Fat Cat"];
    var catPrices:[Int] = [0, 360, 360, 360, 360, 360, 360, 360, 360];
    var catTypes:[Cat] = [.standard, .breading, .taco, .egyptian, .supeR, .chicken, .cool, .ninja, .fat];
    var contentView:UICView?
    var catViewHandler:UICView?
    var catLabelName:UICLabel?
    
    var hideButton:UICButton?
    var infoButton:UICButton?
    var previousButton:UICButton?
    var nextButton:UICButton?
    var selectionButton:UICButton?
    
    var purchaseAlert:UIAlertController?
    var keyValueStore:NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore();
    
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
        setupSelectionButton();
        if (displayedCatIndex == -1) {
            setPresentationCat(cat: ViewController.getRandomCat());
        }
        setupPresentLabelNameAnimation();
        setupPurchaseAlert();
        setCompiledStyle();
    }
    
    func setupPurchaseAlert() {
        purchaseAlert = UIAlertController(title: "Cat Purchase", message: "", preferredStyle: .alert);
        purchaseAlert!.addAction(UIAlertAction(title: "Buy", style: .default, handler: { _ in
            self.currentSelectionValue = ViewController.staticSelf!.myCats[self.catTypes[self.displayedCatIndex]]!;
            if (self.currentSelectionValue == 0) {
                // Send purchase only if the internet exists
                if (ViewController.staticSelf!.isInternetReachable) {
                    // Set the value to hidden selected
                    ViewController.staticSelf!.myCats[self.catTypes[self.displayedCatIndex]] = -1;
                    // Update my cat purchase status
                    self.updateCatImageNameAndStatus();
                    // Update mouse coin value
                    ViewController.settingsButton!.settingsMenu!.mouseCoin!.setMouseCoinValue(newValue: UIResults.mouseCoins - Int64(self.catPrices[self.displayedCatIndex]));
                    ViewController.settingsButton!.settingsMenu!.mouseCoin!.mouseCoinView!.fadeIn();
                }
                self.saveMyCatsDictAsString();
            }
        }))
        purchaseAlert!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));
    }
    
    func saveMyCatsDictAsString() {
        if (ViewController.staticSelf!.isInternetReachable) {
            // Save my cats string
            ViewController.staticSelf!.saveMyCatsDictAsString(catTypes: self.catTypes);
        }
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
        if (displayedCatIndex == 8) {
            displayedCatIndex = 0;
        } else {
            displayedCatIndex += 1;
        }
        updateCatImageNameAndStatus();
    }
    
    func updateCatImageNameAndStatus() {
        setPresentationCat(cat: catTypes[displayedCatIndex]);
    }
    
    var currentSelectionValue:Int8?
    func setSelectionButtonText() {
        currentSelectionValue = ViewController.staticSelf!.myCats[catTypes[displayedCatIndex]]!;
        if (currentSelectionValue! > 0) {
            selectionButton!.setTitle("Unselect", for: .normal);
            selectionButton!.backgroundColor = UIColor.systemRed;
            mouseCoin!.alpha = 0.0;
        } else if (currentSelectionValue! == 0) {
            selectionButton!.setTitle(repositionMouseCoinAndGetOffer(), for: .normal);
            selectionButton!.backgroundColor = UIColor.systemOrange;
            mouseCoin!.alpha = 1.0;
            setPurchaseAlertMessage();
        } else {
            selectionButton!.setTitle("Select", for: .normal);
            selectionButton!.backgroundColor = UIColor.systemGreen;
            mouseCoin!.alpha = 0.0;
        }
    }
    
    var purchaseAlertMessage:String?
    func setPurchaseAlertMessage() {
        purchaseAlertMessage = "Do you want to buy ";
        purchaseAlertMessage! += "\(catNames[displayedCatIndex])"
        purchaseAlertMessage! += " for \(catPrices[displayedCatIndex]) Mouse Coins?"
        purchaseAlert!.message = purchaseAlertMessage!;
    }
    
    var offer:String?
    var price:String?
    func repositionMouseCoinAndGetOffer() -> String {
        offer = "Get for "
        price = "\(catPrices[displayedCatIndex])";
        mouseCoin!.frame = mouseCoin!.originalFrame!;
        offer! += price! + " "
        for _ in 0..<price!.count {
            mouseCoin!.transform = mouseCoin!.transform.translatedBy(x: selectionButton!.frame.width * 0.069, y: 0.0);
        }
        offer! += "·····"
        return offer!;
    }
    
    func unselectCat() {
        if (ViewController.getSelectedCatsCount() == 1) {
            print("Must maintain at least one cat selected!");
        } else {
            currentSelectionValue = ViewController.staticSelf!.myCats[catTypes[displayedCatIndex]]!;
            ViewController.staticSelf!.myCats[catTypes[displayedCatIndex]] = -1 * currentSelectionValue!;
            // Update selection button
           selectionButton!.backgroundColor = UIColor.systemGreen;
           selectionButton!.setTitle("Select", for: .normal);
        }
        saveMyCatsDictAsString();
    }
    
    func selectCat() {
        for cat in catTypes {
            currentSelectionValue = ViewController.staticSelf!.myCats[cat]!;
            if (currentSelectionValue! > 0) {
                ViewController.staticSelf!.myCats[cat] = -1 * currentSelectionValue!;
            }
        }
        // Set current cat value to positive
        currentSelectionValue = ViewController.staticSelf!.myCats[catTypes[displayedCatIndex]]!;
        ViewController.staticSelf!.myCats[catTypes[displayedCatIndex]] = abs(currentSelectionValue!);
        // Update display
        updateCatImageNameAndStatus();
        saveMyCatsDictAsString();
        // Apply changes across ui
        ViewController.staticSelf!.boardGame!.cats.updateCat();
        ViewController.staticSelf!.boardGame!.cats.suspendCatAnimations();
        ViewController.staticSelf!.boardGame!.cats.resumeCatAnimations();
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
        if (displayedCatIndex == 0) {
            displayedCatIndex = 8;
        } else {
            displayedCatIndex -= 1;
        }
        updateCatImageNameAndStatus();
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
        catViewHandler = UICView(parentView: contentView!, x: 0.0, y: presentationCatButton!.originalFrame!.minY + presentationCatButton!.originalFrame!.height * 0.25, width: presentationCatButton!.originalFrame!.width * 1.05, height: presentationCatButton!.originalFrame!.width * 0.5, backgroundColor: UIColor.clear);
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
    
    var mouseCoin:UIMouseCoin?
    func setupSelectionButton() {
        selectionButton = UICButton(parentView: catViewHandler!, frame:CGRect(x: 0.0, y: catViewHandler!.frame.height - (presentationCatButton!.layer.borderWidth * 0.5) - self.catLabelName!.frame.height, width: catViewHandler!.frame.width * 0.75, height: self.hideButton!.frame.height * 1.025), backgroundColor: UIColor.systemRed);
        CenterController.centerHorizontally(childView: selectionButton!, parentRect: catViewHandler!.frame, childRect: selectionButton!.frame);
        selectionButton!.originalFrame = selectionButton!.frame;
        selectionButton!.layer.cornerRadius =  catViewHandler!.layer.cornerRadius * 0.4;
        selectionButton!.clipsToBounds = true;
        selectionButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: selectionButton!.frame.height * 0.5);
        selectionButton!.addTarget(self, action: #selector(selectionButtonSelector), for: .touchUpInside);
        selectionButton!.setTitle("Unselect", for: .normal);
        setupMouseCoin();
    }
    
    func setupMouseCoin() {
        mouseCoin = UIMouseCoin(parentView: selectionButton!, x: selectionButton!.frame.width * 0.51, y: 0.0, width: selectionButton!.frame.height * 0.7, height: selectionButton!.frame.height * 0.7);
        CenterController.centerVertically(childView: mouseCoin!, parentRect: selectionButton!.frame, childRect: mouseCoin!.frame);
        mouseCoin!.originalFrame = mouseCoin!.frame;
        mouseCoin!.isSelectable = false;
        mouseCoin!.alpha = 0.0;
    }
    
    @objc func selectionButtonSelector() {
        if (selectionButton!.titleLabel!.text == "Select") {
            selectCat();
        } else if (selectionButton!.titleLabel!.text == "Unselect") {
            unselectCat();
        } else {
            print("Get cat for x mouse coins!!!");
            self.present(purchaseAlert!, animated: true, completion: nil);
        }
    }
    
    var presentLabelNameTimer:Timer?
    var presentLabelNameAnimation:UIViewPropertyAnimator?
    func setupPresentLabelNameAnimation () {
        self.presentLabelNameAnimation = UIViewPropertyAnimator.init(duration: 1.125, curve: .easeInOut, animations: {
            self.catViewHandler!.frame = CGRect(x: self.catViewHandler!.frame.minX, y: self.presentationCatButton!.frame.minY - (self.hideButton!.frame.height), width: self.presentationCatButton!.frame.width * 1.05, height: self.presentationCatButton!.frame.height + (self.hideButton!.frame.height) * 2.0);
            // Control button
            self.selectionButton!.frame = CGRect(x: self.selectionButton!.frame.minX, y: self.catViewHandler!.frame.height - (self.presentationCatButton!.layer.borderWidth * 0.5) - self.catLabelName!.frame.height + self.catViewHandler!.layer.borderWidth, width: self.catViewHandler!.frame.width * 0.75, height: self.hideButton!.frame.height * 1.025);
        })
    }
    
    func setupPresentLabelNameTimer() {
        presentLabelNameTimer = Timer.scheduledTimer(withTimeInterval: 0.0, repeats: false, block: { _ in
            self.presentLabelNameAnimation!.startAnimation();
        })
    }
    
    func setPresentationCat(cat:Cat) {
        presentationCatButton!.selectedCat = cat;
        displayedCatIndex = catTypes.firstIndex(of: cat)!;
        catLabelName!.text = catNames[displayedCatIndex];
        presentationCatButton!.setCat(named: "SmilingCat", stage: 3);
        catLabelName!.text = catNames[displayedCatIndex];
        setSelectionButtonText();
    }
    
    func presentCatButton() {
        presentationCatButton!.randomAnimationSelection = 0;
        presentationCatButton!.setRandomCatAnimation();
        presentationCatButton!.grow();
        presentationCatButton!.imageContainerButton!.grow();
        setupPresentLabelNameTimer();
    }
    
    func hideCatButton() {
        // Save my cats string
        ViewController.staticSelf!.saveMyCatsDictAsString(catTypes: catTypes);
        // Reset more cats view
        catLabelName!.frame = catLabelName!.originalFrame!;
        selectionButton!.frame = selectionButton!.originalFrame!;
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
       SoundController.kittenMeow();
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
        selectionButton!.setStyle();
    }
    
}
