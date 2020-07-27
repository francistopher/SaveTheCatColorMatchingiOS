//
//  UIMoreCatsButton.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/13/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI
import GameKit

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

    /*
        Displays the more cats view
     */
    @objc func moreCatsSelector() {
        if (!ViewController.staticSelf!.isInternetReachable) {
            ViewController.staticSelf!.gameMessage!.addToMessageQueue(message: .noInternet);
            return;
        }
        firstTime = true;
        ViewController.staticSelf!.present(moreCatsVC!, animated: true, completion: {
            self.moreCatsVC!.presentCatButton();
        });
        UIView.animate(withDuration: 0.25, animations: {
            ViewController.staticSelf!.view.alpha = 0.5;
        })
    }
       
    /*
        Sets the image of the button
     */
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
        if (ViewController.uiStyleRawValue == 1){
            setIconImage(named: "darkMoreCats.png");
        } else {
            setIconImage(named: "lightMoreCats.png");
        }
    }
}

class MoreCatsViewController:UIViewController {
    var displayedCatIndex:Int = -1;
    var catNames:[String] = ["Standard Cat", "Cat Breading", "Taco Cat", "Egyptian Cat", "Super Cat", "Chicken Cat", "Cool Cat", "Ninja Cat", "Fat Cat"];
    var catPrices:[Int] = [0, 420, 420, 420, 420, 420, 420, 420, 420];
    var catTypes:[Cat] = [.standard, .breading, .taco, .egyptian, .supeR, .chicken, .cool, .ninja, .fat];
    var contentView:UICView?
    var catViewHandler:UICView?
    var catLabelName:UICLabel?
    
    var closeButton:UICButton?
    
    var infoButton:UICButton?
    var memoriamLabel:UICLabel?
    
    var previousButton:UICButton?
    var nextButton:UICButton?
    var selectionButton:UICButton?
    
    var purchaseAlert:UIAlertController?
    var keyValueStore:NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        setupContentView()
        setupHideButton()
        setupInfoButton()
        setupPresentationCat()
        setupCatViewHandler()
        setupCatLabelName()
        setupPreviousButton()
        setupNextButton()
        setupSelectionButton()
        setupInfoLabel()
        if (displayedCatIndex == -1) {
            setPresentationCat(cat: ViewController.getRandomCat())
        }
        setupPresentLabelNameAnimation()
        setupPurchaseAlert()
        setCompiledStyle()
    }
    
    /*
        Displays an alert regarding
        the selected cat purchase
     */
    func setupPurchaseAlert() {
        purchaseAlert = UIAlertController(title: "Cat Purchase", message: "", preferredStyle: .alert);
        purchaseAlert!.addAction(UIAlertAction(title: "Buy", style: .default, handler: { _ in
            self.currentSelectionValue = ViewController.staticSelf!.myCats[self.catTypes[self.displayedCatIndex]]!;
            if (self.currentSelectionValue == 0) {
                ViewController.submitAchievement(achievement: "\(self.catTypes[self.displayedCatIndex])Unlocked");
                // Send purchase only if the internet exists
                if (ViewController.staticSelf!.isInternetReachable) {
                    // Set the value to hidden selected
                    ViewController.staticSelf!.myCats[self.catTypes[self.displayedCatIndex]] = -1;
                    // Update my cat purchase status
                    self.updateCatImageNameAndStatus();
                    // Update mouse coin value
                    ViewController.settingsButton!.settingsMenu!.mouseCoin!.setMouseCoinValue(newValue: UIResults.mouseCoins - Int64(self.catPrices[self.displayedCatIndex]));
                    ViewController.settingsButton!.settingsMenu!.mouseCoin!.mouseCoinView!.fadeIn();
                    self.keyValueStore.set(UIResults.mouseCoins - Int64(self.catPrices[self.displayedCatIndex]), forKey: "mouseCoins");
                    self.keyValueStore.synchronize();
                    self.saveMyCatsDictAsString();
                }
            }
        }))
        purchaseAlert!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));
    }
    
    /*
        Saves current cat data as a string
     */
    func saveMyCatsDictAsString() {
        if (ViewController.staticSelf!.isInternetReachable) {
            // Save my cats string
            ViewController.staticSelf!.saveMyCatsDictAsString(catTypes: self.catTypes);
        }
    }
    
    /*
     
     */
    var contentViewFrame:CGRect?
    var contentViewBorderWidth:CGFloat?
    var contentViewCornerRadius:CGFloat?
    func setupContentView() {
        if (ViewController.aspectRatio! == .ar4by3) {
            view.backgroundColor = UIColor.clear;
            contentViewFrame = CGRect(x: 0.0, y: 0.0, width: view.frame.width * 0.7, height: view.frame.height * 0.65)
            contentViewBorderWidth = view.frame.width * 0.7 * 0.0125;
            contentViewCornerRadius = view.frame.width * 0.7 * 0.1;
        } else if (ViewController.aspectRatio! == .ar16by9) {
            contentViewFrame = CGRect(x: 0.0, y: view.frame.height * 0.0275, width: view.frame.width, height: view.frame.height * 0.9725)
            contentViewBorderWidth = view.frame.width * 0.0125;
            contentViewCornerRadius = 0.0;
        } else {
            contentViewFrame = CGRect(x: 0.0, y: view.frame.height * 0.0525, width: view.frame.width, height: view.frame.height * 0.9475)
            contentViewBorderWidth = view.frame.width * 0.0125;
            contentViewCornerRadius = view.frame.width * 0.7 * 0.145;
        }
        contentView = UICView(parentView: view, x: contentViewFrame!.minX, y: contentViewFrame!.minY, width: contentViewFrame!.width, height: contentViewFrame!.height, backgroundColor: UIColor.clear);
        contentView!.layer.borderWidth = contentViewBorderWidth!;
        contentView!.layer.cornerRadius = contentViewCornerRadius!;
        if (ViewController.aspectRatio! == .ar4by3) {
            CenterController.center(childView: contentView!, parentRect: view.frame, childRect: contentView!.frame);
        }
        contentView!.clipsToBounds = true;
    }
    
    /*
        Create the button that closes the menu
     */
    func setupHideButton() {
        closeButton = UICButton(parentView: contentView!, frame: CGRect(x: contentView!.frame.width * 0.8, y: 0.0, width: contentView!.frame.width * 0.2, height: contentView!.frame.width * 0.12), backgroundColor: UIColor.red);
        closeButton!.addTarget(self, action: #selector(hideButtonSelector), for: .touchUpInside);
        closeButton!.setTitle("x", for: .normal);
        closeButton!.layer.cornerRadius = closeButton!.frame.height * 0.5;
        closeButton!.layer.borderWidth = contentView!.layer.borderWidth;
        closeButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: closeButton!.frame.height * 0.75)
        closeButton!.layer.maskedCorners = [ .layerMinXMaxYCorner]
        ViewController.updateFont(button: closeButton!);
    }
    
    /*
        Closes the more cats menu
     */
    @objc func hideButtonSelector() {
        self.dismiss(animated: true, completion: nil);
        self.hideCatButton();
        UIView.animate(withDuration: 0.25, animations: {
            ViewController.staticSelf!.view.alpha = 1.0;
            self.memoriamLabel!.frame = self.memoriamLabel!.shrunkFrame!
            self.infoButton!.setTitle("i", for: .normal)
            
        })
    }
    
    /*
        Setup the button that display the memoriam message
     */
    func setupInfoButton() {
        infoButton = UICButton(parentView: contentView!, frame: CGRect(x: 0.0, y: 0.0, width: contentView!.frame.width * 0.2, height: contentView!.frame.width * 0.12), backgroundColor: UIColor.systemBlue);
        infoButton!.addTarget(self, action: #selector(infoButtonSelector), for: .touchUpInside);
        infoButton!.setTitle("i", for: .normal);
        infoButton!.layer.cornerRadius = infoButton!.frame.height * 0.5;
        infoButton!.layer.borderWidth = contentView!.layer.borderWidth;
        infoButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: infoButton!.frame.height * 0.75)
        infoButton!.layer.maskedCorners = [.layerMaxXMaxYCorner]
        ViewController.updateFont(button: infoButton!);
    }
    
    /*
        Displays or closes the memoriam message
     */
    @objc func infoButtonSelector() {
        if (infoButton!.titleLabel!.text == "i") {
            infoButton!.setTitle("x", for: .normal);
            memoriamLabel!.grow();
        } else {
            infoButton!.setTitle("i", for: .normal);
            memoriamLabel!.shrink(removeFromSuperview: false);
        }
    }
    
    /*
        Button that moves on to the next cat
     */
    func setupNextButton() {
        nextButton = UICButton(parentView: contentView!, frame: CGRect(x:contentView!.frame.width * 0.8, y: contentView!.frame.height - contentView!.frame.width * 0.12, width: contentView!.frame.width * 0.2, height: contentView!.frame.width * 0.12), backgroundColor: UIColor.systemYellow);
        nextButton!.addTarget(self, action: #selector(nextButtonSelector), for: .touchUpInside);
        nextButton!.setTitle(">", for: .normal);
        nextButton!.layer.cornerRadius = nextButton!.frame.height * 0.5;
        nextButton!.layer.borderWidth = contentView!.layer.borderWidth;
        nextButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: nextButton!.frame.height * 0.75)
        nextButton!.layer.maskedCorners = [.layerMinXMinYCorner]
        ViewController.updateFont(button: nextButton!);
    }
    
    /*
        Moves to the next cat
     */
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
    
    /*
        Updates the text on the selection button
        based on its current purchase state
     */
    var currentSelectionValue:Int8?
    func setSelectionButtonText() {
        currentSelectionValue = ViewController.staticSelf!.myCats[catTypes[displayedCatIndex]]!;
        if (currentSelectionValue! > 0) {
            presentationCatButton!.imageContainerButton!.alpha = 1.0;
            selectionButton!.setTitle("Selected", for: .normal);
            selectionButton!.backgroundColor = UIColor.systemPink;
            presentationCatButton!.setTitle("", for: .normal);
            mouseCoin!.alpha = 0.0;
        } else if (currentSelectionValue! == 0) {
            selectionButton!.setTitle(repositionMouseCoinAndGetOffer(), for: .normal);
            presentationCatButton!.imageContainerButton!.alpha = 0.0;
            selectionButton!.backgroundColor = UIColor.systemOrange;
            presentationCatButton!.setTitle("?", for: .normal);
            mouseCoin!.alpha = 1.0;
            setPurchaseAlertMessage();
        } else {
            presentationCatButton!.imageContainerButton!.alpha = 1.0;
            selectionButton!.setTitle("Select", for: .normal);
            selectionButton!.backgroundColor = UIColor.systemGreen;
            presentationCatButton!.setTitle("", for: .normal);
            mouseCoin!.alpha = 0.0;
        }
    }
    
    /*
        Display the purchase alert message
     */
    var purchaseAlertMessage:String?
    func setPurchaseAlertMessage() {
        purchaseAlertMessage = "Do you want to buy ";
        purchaseAlertMessage! += "\(catNames[displayedCatIndex])"
        purchaseAlertMessage! += " for \(catPrices[displayedCatIndex]) Mouse Coins?"
        purchaseAlert!.message = purchaseAlertMessage!;
    }
    
    /*
        Update the position of the mouse coin
        on the purchase button
     */
    var offer:String?
    var price:String?
    var translationCoefficient:CGFloat = 0.0;
    func repositionMouseCoinAndGetOffer() -> String {
        mouseCoin!.frame = mouseCoin!.originalFrame!;
        if (catPrices[displayedCatIndex] <= UIResults.mouseCoins) {
            offer = "Get for "
            price = "\(catPrices[displayedCatIndex])";
            offer! += price! + " "
            translationCoefficient = 0.069;
        } else {
            offer = "Not enough "
            translationCoefficient = 0.065;
        }
        for _ in 0..<3 {
            mouseCoin!.transform = mouseCoin!.transform.translatedBy(x: selectionButton!.frame.width * translationCoefficient, y: 0.0);
        }
        offer! += "·····"
        return offer!;
    }
    
    /*
        Updates data to represent that the cat has been unselected
     */
    func unselectCat() {
        if (ViewController.getSelectedCatsCount() == 1) {
            
        } else {
            currentSelectionValue = ViewController.staticSelf!.myCats[catTypes[displayedCatIndex]]!;
            ViewController.staticSelf!.myCats[catTypes[displayedCatIndex]] = -1 * currentSelectionValue!;
            // Update selection button
           selectionButton!.backgroundColor = UIColor.systemGreen;
           selectionButton!.setTitle("Select", for: .normal);
        }
        saveMyCatsDictAsString();
    }
    
    /*
        Updates data to represent that a cat has been selected
     */
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
        // Apply changes across ui
        ViewController.staticSelf!.boardGame!.cats.updateCatType();
        ViewController.staticSelf!.boardGame!.cats.suspendCatAnimations();
        ViewController.staticSelf!.boardGame!.cats.resumeCatAnimations();
        // Update display
        updateCatImageNameAndStatus();
        saveMyCatsDictAsString();
    }
    
    /*
        Creates button that switches to the previous cat
     */
    func setupPreviousButton() {
        previousButton = UICButton(parentView: contentView!, frame: CGRect(x: 0.0, y: contentView!.frame.height - contentView!.frame.width * 0.12, width: contentView!.frame.width * 0.2, height:  contentView!.frame.width * 0.12), backgroundColor: UIColor.systemYellow);
        previousButton!.addTarget(self, action: #selector(previousButtonSelector), for: .touchUpInside);
        previousButton!.setTitle("<", for: .normal);
        previousButton!.layer.cornerRadius = previousButton!.frame.height * 0.5;
        previousButton!.layer.borderWidth = contentView!.layer.borderWidth;
        previousButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: previousButton!.frame.height * 0.75)
        previousButton!.layer.maskedCorners = [.layerMaxXMinYCorner]
        ViewController.updateFont(button: previousButton!);
    }
    
    /*
        Switches to previous cat
     */
    @objc func previousButtonSelector() {
        if (displayedCatIndex == 0) {
            displayedCatIndex = 8;
        } else {
            displayedCatIndex -= 1;
        }
        updateCatImageNameAndStatus();
    }

    /*
        Creates cat button which presents the
        currently selected cat
     */
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
        presentationCatButton!.titleLabel!.font = UIFont(name: "SleepyFatCat", size: presentationCatButton!.titleLabel!.font.pointSize * 7.5);
        ViewController.updateFont(button: presentationCatButton!);
        presentationCatButton!.clipsToBounds = true;
    }
    
    /*
        Creates memoriam label
     */
    func setupInfoLabel() {
        memoriamLabel = UICLabel(parentView: contentView!, x: presentationCatButton!.imageContainerButton!.originalFrame!.minX, y: presentationCatButton!.imageContainerButton!.originalFrame!.minY, width: presentationCatButton!.imageContainerButton!.originalFrame!.width * 0.975, height: presentationCatButton!.imageContainerButton!.originalFrame!.height * 0.975)
        CenterController.center(childView: memoriamLabel!, parentRect: contentView!.frame, childRect: memoriamLabel!.frame);
        memoriamLabel!.setOriginalFrame();
        memoriamLabel!.setShrunkFrame();
        memoriamLabel!.font = UIFont.boldSystemFont(ofSize: memoriamLabel!.frame.height * 0.15);
        memoriamLabel!.layer.cornerRadius = presentationCatButton!.layer.cornerRadius
        memoriamLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        memoriamLabel!.text = "In Memory of\nSchrödinger\nthe Cat"
        ViewController.updateFont(label: memoriamLabel!);
        memoriamLabel!.backgroundColor = UIColor.systemBlue
        memoriamLabel!.clipsToBounds = true
        memoriamLabel!.isInverted = true
        memoriamLabel!.numberOfLines = 3
        memoriamLabel!.shrunk();
    }
    
    /*
        Create view that contains the cat,
        the selection button and the cat name label
     */
    func setupCatViewHandler() {
        catViewHandler = UICView(parentView: contentView!, x: 0.0, y: presentationCatButton!.originalFrame!.minY + presentationCatButton!.originalFrame!.height * 0.25, width: presentationCatButton!.originalFrame!.width * 1.05, height: presentationCatButton!.originalFrame!.width * 0.5, backgroundColor: UIColor.clear);
        catViewHandler!.invertColor = true;
        catViewHandler!.setStyle();
        catViewHandler!.layer.cornerRadius = presentationCatButton!.layer.cornerRadius;
        CenterController.centerHorizontally(childView: catViewHandler!, parentRect: contentView!.frame, childRect: catViewHandler!.frame);
        catViewHandler!.originalFrame = catViewHandler!.frame;
        contentView!.bringSubviewToFront(presentationCatButton!);
    }
    
    /*
        Creates the label that contains the name of the cat
     */
    func setupCatLabelName() {
        catLabelName = UICLabel(parentView: catViewHandler!, x: 0.0, y: presentationCatButton!.layer.borderWidth * 0.75, width: catViewHandler!.frame.width, height: (self.closeButton!.frame.height));
        catLabelName!.isInverted = true;
        catLabelName!.setStyle();
        CenterController.centerHorizontally(childView: catLabelName!, parentRect: catViewHandler!.frame, childRect: catLabelName!.frame);
        catLabelName!.layer.cornerRadius = catViewHandler!.layer.cornerRadius;
        catLabelName!.text = "Standard Cat";
        catLabelName!.clipsToBounds = true;
        catLabelName!.font = UIFont.boldSystemFont(ofSize: catLabelName!.frame.height * 0.6);
        ViewController.updateFont(label: catLabelName!);
    }
    
    /*
        Creates the selection button
        that enables the purchasing and selection
     */
    var mouseCoin:UIMouseCoin?
    func setupSelectionButton() {
        selectionButton = UICButton(parentView: catViewHandler!, frame:CGRect(x: 0.0, y: catViewHandler!.frame.height - (presentationCatButton!.layer.borderWidth * 0.5) - self.catLabelName!.frame.height, width: catViewHandler!.frame.width * 0.75, height: self.closeButton!.frame.height * 1.025), backgroundColor: UIColor.systemRed);
        CenterController.centerHorizontally(childView: selectionButton!, parentRect: catViewHandler!.frame, childRect: selectionButton!.frame);
        selectionButton!.originalFrame = selectionButton!.frame;
        selectionButton!.layer.cornerRadius = catViewHandler!.layer.cornerRadius * 0.4;
        selectionButton!.clipsToBounds = true;
        selectionButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: selectionButton!.frame.height * 0.5);
        selectionButton!.addTarget(self, action: #selector(selectionButtonSelector), for: .touchUpInside);
        selectionButton!.setTitle("Unselect", for: .normal);
        ViewController.updateFont(button: selectionButton!);
        selectionButton!.isStyleInverted = true;
        setupMouseCoin();
    }
    
    /*
        Creates the mouse coin on the
        selection button when a cat hasn't been purchased
     */
    func setupMouseCoin() {
        mouseCoin = UIMouseCoin(parentView: selectionButton!, x: selectionButton!.frame.width * 0.51, y: 0.0, width: selectionButton!.frame.height * 0.7, height: selectionButton!.frame.height * 0.7);
        CenterController.centerVertically(childView: mouseCoin!, parentRect: selectionButton!.frame, childRect: mouseCoin!.frame);
        mouseCoin!.addTarget(self, action: #selector(mouseCoinSelector), for: .touchUpInside);
        mouseCoin!.originalFrame = mouseCoin!.frame;
        mouseCoin!.isSelectable = false;
        mouseCoin!.alpha = 0.0;
    }
    
    @objc func mouseCoinSelector() {
        SoundController.coinEarned();
    }
    
    /*
        Updates data to mark the
        displayed cat as selected
     */
    @objc func selectionButtonSelector() {
        if (selectionButton!.titleLabel!.text == "Select") {
            selectCat();
        } else if (selectionButton!.titleLabel!.text == "Selected") {
            unselectCat();
        } else {
            if (catPrices[displayedCatIndex] <= UIResults.mouseCoins) {
                self.present(purchaseAlert!, animated: true, completion: nil);
            }
        }
    }
    
    /*
        Animation that slides open the label name
     */
    var presentLabelNameTimer:Timer?
    var presentLabelNameAnimation:UIViewPropertyAnimator?
    func setupPresentLabelNameAnimation () {
        self.presentLabelNameAnimation = UIViewPropertyAnimator.init(duration: 1.125, curve: .easeInOut, animations: {
            self.catViewHandler!.frame = CGRect(x: self.catViewHandler!.frame.minX, y: self.presentationCatButton!.frame.minY - (self.closeButton!.frame.height), width: self.presentationCatButton!.frame.width * 1.05, height: self.presentationCatButton!.frame.height + (self.closeButton!.frame.height) * 2.0);
            // Control button
            self.selectionButton!.frame = CGRect(x: self.selectionButton!.frame.minX, y: self.catViewHandler!.frame.height - (self.presentationCatButton!.layer.borderWidth * 0.5) - self.catLabelName!.frame.height + self.catViewHandler!.layer.borderWidth, width: self.catViewHandler!.frame.width * 0.75, height: self.closeButton!.frame.height * 1.025);
        })
    }
    
    func setupPresentLabelNameTimer() {
        presentLabelNameTimer = Timer.scheduledTimer(withTimeInterval: 0.0, repeats: false, block: { _ in
            self.presentLabelNameAnimation!.startAnimation();
        })
    }
    
    /*
        Updates the cat that is
        currently being displayed
     */
    func setPresentationCat(cat:Cat) {
        presentationCatButton!.selectedCat = cat;
        displayedCatIndex = catTypes.firstIndex(of: cat)!;
        catLabelName!.text = catNames[displayedCatIndex];
        presentationCatButton!.setCat(named: "SmilingCat", stage: 3);
        catLabelName!.text = catNames[displayedCatIndex];
        setSelectionButtonText();
    }
    
    /*
        Shows the cat button
     */
    func presentCatButton() {
        presentationCatButton!.randomAnimationSelection = 0;
        presentationCatButton!.setRandomCatAnimation();
        presentationCatButton!.grow();
        presentationCatButton!.imageContainerButton!.grow();
        setupPresentLabelNameTimer();
    }
    
    /*
        Shrinks the cat button
        making it disappear
     */
    func hideCatButton() {
        // Reset more cats view
        if (catLabelName != nil) {
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
    }
    
    @objc func presentationCatButtonSelector() {
       SoundController.kittenMeow();
    }
    
    /*
        Update the appearance of the more
        cats view based on the appearance
        of the OS
     */
    func setCompiledStyle() {
        presentationCatButton!.setStyle();
        presentationCatButton!.setCat(named: "SmilingCat", stage: 5);
        selectionButton!.setStyle();
        if (ViewController.uiStyleRawValue == 1) {
            selectionButton!.layer.borderColor = UIColor.black.cgColor;
            presentationCatButton!.setTitleColor(UIColor.black, for: .normal);
            presentationCatButton!.backgroundColor = UIColor.white;
        } else {
            selectionButton!.layer.borderColor = UIColor.white.cgColor;
            presentationCatButton!.setTitleColor(UIColor.white, for: .normal);
            presentationCatButton!.backgroundColor = UIColor.black;
        }
        contentView!.setStyle();
        catViewHandler!.setStyle();
        catLabelName!.setStyle();
        closeButton!.setStyle();
        infoButton!.setStyle();
        previousButton!.setStyle();
        nextButton!.setStyle();
        
        memoriamLabel!.setStyle();
        memoriamLabel!.backgroundColor = UIColor.systemBlue;
        if (ViewController.uiStyleRawValue == 1) {
            if (ViewController.aspectRatio! != .ar4by3) {
                view.backgroundColor = UIColor.white;
            }
        } else {
            if (ViewController.aspectRatio! == .ar16by9) {
                view.backgroundColor = UIColor.black;
            }
        }
    }
    
}
