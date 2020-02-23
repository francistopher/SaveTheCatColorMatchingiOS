//
//  UIMultiplayer.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/13/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI
import MultipeerConnectivity

class UIMultiplayer: UIButton {

    var originalFrame:CGRect? = nil;
    var reducedFrame:CGRect? = nil;
    
    var multiplayerView:UICView?;
    var unitViewHeight:CGFloat = 0.0;
    var multiplayerTitleLabel:UICLabel?
    var displayNameTextField:UICTextField?
    var updateDisplayNameButton:UICButton?
    
    var mcController:MCController?
    var activePlayersScrollView:UICScrollView?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        originalFrame = CGRect(x: x, y: y, width: width, height: height);
        backgroundColor = .clear;
        layer.cornerRadius = height / 2.0;
        addTarget(self, action: #selector(multiplayerViewSelector), for: .touchUpInside);
        parentView.addSubview(self);
        setupMultiplayerView();
        setupDisplayNameTextField();
        setupUpdateDisplayNameButton();
        setupMCController();
        setupActivePlayersScrollView();
        setStyle();
    }

    func setupMCController() {
        mcController = MCController(displayName: displayNameTextField!.text!);
        mcController!.setupFramework();
    }
    
    @objc func multiplayerViewSelector() {
        if (multiplayerView!.alpha == 0.0) {
            fadeBackgroundIn();
            mcController!.advertisingAndBrowsing(start: true);
        } else {
            fadeBackgroundOut();
            mcController!.advertisingAndBrowsing(start: false);
        }
    }
    
    func setupMultiplayerView() {
        multiplayerView = UICView(parentView: self.superview!.superview!, x: 0.0, y: 0.0, width: ViewController.staticUnitViewHeight * 8, height: ViewController.staticUnitViewHeight * 8, backgroundColor: UIColor.white);
        UICenterKit.centerWithVerticalDisplacement(childView: multiplayerView!, parentRect: self.multiplayerView!.superview!.frame, childRect: multiplayerView!.frame, verticalDisplacement: -ViewController.staticUnitViewHeight * 0.25);
        multiplayerView!.layer.cornerRadius = multiplayerView!.frame.height * 0.2;
        multiplayerView!.layer.borderWidth = self.multiplayerView!.frame.height * 0.015;
        multiplayerView!.layer.borderColor = UIColor.black.cgColor;
        multiplayerView!.alpha = 0.0;
        unitViewHeight = multiplayerView!.frame.height / 6.0;
    }
    
    func setupDisplayNameTextField() {
        displayNameTextField = UICTextField(parentView:self.multiplayerView!, frame: CGRect(x: multiplayerView!.frame.width * 0.15 , y: unitViewHeight * 0.5, width: (multiplayerView!.frame.width * 0.7) - (unitViewHeight * 0.68), height: unitViewHeight * 0.8));
        displayNameTextField!.layer.borderWidth = displayNameTextField!.frame.height * 0.1;
        displayNameTextField!.layer.borderColor = UIColor.black.cgColor;
        displayNameTextField!.layer.cornerRadius = displayNameTextField!.frame.height * 0.2;
        displayNameTextField!.addTarget(self, action: #selector(displayNameTextFieldSelector), for: .editingChanged);
        displayNameTextField!.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner];
        displayNameTextField!.text = "EnterDisplayName";
    }
    
    func setupUpdateDisplayNameButton() {
        updateDisplayNameButton = UICButton(parentView: multiplayerView!, frame: CGRect(x: displayNameTextField!.frame.maxX - (unitViewHeight * 0.08), y: displayNameTextField!.frame.minY, width: unitViewHeight * 0.8, height: unitViewHeight * 0.8), backgroundColor: UIColor.white);
        updateDisplayNameButton!.layer.borderWidth = updateDisplayNameButton!.frame.height * 0.1;
        updateDisplayNameButton!.layer.borderColor = UIColor.black.cgColor;
        updateDisplayNameButton!.layer.cornerRadius = updateDisplayNameButton!.frame.height * 0.2;
        updateDisplayNameButton!.addTarget(self, action: #selector(updateDisplayNameSelector), for: .touchUpInside);
        updateDisplayNameButton!.setTitle( "^.^", for: .normal);
        updateDisplayNameButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: updateDisplayNameButton!.frame.height * 0.4);
        updateDisplayNameButton!.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner];
        updateDisplayNameButton!.backgroundColor = UIColor.systemGreen;
    }

    func setupActivePlayersScrollView() {
        activePlayersScrollView = PlayerAdScrollView(parentView: multiplayerView!, frame: CGRect(x: multiplayerView!.frame.width * 0.15, y: unitViewHeight * 1.7, width: multiplayerView!.frame.width * 0.7, height: unitViewHeight * 3.8), mcController: mcController!);
    }
    
    @objc func displayNameTextFieldSelector() {
        if (mcController!.peerID.displayName != displayNameTextField!.text) {
            updateDisplayNameButton!.backgroundColor = UIColor.systemPink;
            updateDisplayNameButton!.setTitle( "OK", for: .normal);
        } else {
            updateDisplayNameButton!.backgroundColor = UIColor.systemGreen;
            updateDisplayNameButton!.setTitle( "^.^", for: .normal);
        }
    }
    
    @objc func updateDisplayNameSelector() {
        if (updateDisplayNameButton!.backgroundColor!.cgColor == UIColor.systemPink.cgColor){
            if (displayNameTextField!.text!.count == 0) {
                displayNameTextField!.text = String(mcController!.peerID!.displayName.suffix(mcController!.peerID!.displayName.count - 36));
                displayNameTextField!.endEditing(true);
                updateDisplayNameButton!.backgroundColor = UIColor.systemGreen;
                updateDisplayNameButton!.setTitle( "^.^", for: .normal);
            } else {
                mcController!.resetFramework(displayName: displayNameTextField!.text!);
                updateDisplayNameButton!.backgroundColor = UIColor.systemGreen;
                updateDisplayNameButton!.setTitle( "^.^", for: .normal);
            }
            
        }
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

class PlayerAdScrollView:UICScrollView {
    
    var mcController:MCController?
    var searchingForPlayersView:UIView?
    var searchingForPlayersLabel:UILabel?
    var catButton:UICatButton?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    init(parentView:UIView, frame:CGRect, mcController:MCController) {
        super.init(parentView: parentView, frame: frame);
        self.mcController = mcController;
        setupSearchingForPlayersView();
    }
    
    func setupSearchingForPlayersView() {
        searchingForPlayersView = UICView(parentView: self, x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height, backgroundColor: UIColor.white);
        setupSearchingForPlayersLabel();
        setupCatButton();
    }
    
    func setupSearchingForPlayersLabel() {
        searchingForPlayersLabel = UICLabel(parentView: searchingForPlayersView!, x: 0.0, y: self.frame.height * 0.725, width: self.frame.width, height: self.frame.height * 0.2);
        searchingForPlayersLabel!.layer.borderWidth = 0.0;
        searchingForPlayersLabel!.text = "Searching...";
        searchingForPlayersLabel!.textColor = UIColor.black;
        searchingForPlayersLabel!.font! = UIFont.boldSystemFont(ofSize: searchingForPlayersLabel!.frame.height * 0.4);
    }
    
    func setupCatButton() {
        catButton = UICatButton(parentView: searchingForPlayersView!, x: 0.0, y: self.frame.height * 0.09, width: self.frame.width, height: self.frame.height * 0.60, backgroundColor: UIColor.clear);
        catButton!.layer.borderWidth = 0.0;
        catButton!.setCat(named: "SmilingCat", stage: 0);
        catButton!.frame = catButton!.originalFrame!;
        catButton!.imageContainerButton!.frame = catButton!.imageContainerButton!.originalFrame!;
    }
    
    func addPlayerAdvertisement(peerID:String) {
        
    }
    
    func setContentSize() {
        self.contentSize = CGSize(width: 1000, height: 100);
    }
    
    func setupPlayerAdvertisementConstraints(playerAdvertisementLabel:UILabel) {
        leadingAnchor.constraint(equalTo: playerAdvertisementLabel.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: playerAdvertisementLabel.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: playerAdvertisementLabel.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: playerAdvertisementLabel.bottomAnchor).isActive = true
    }
    
}

class playerAdvertisementLabel: UILabel {
    
}
