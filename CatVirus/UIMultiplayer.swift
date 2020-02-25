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
    var activePlayersScrollView:UIPlayerAdScrollView?
    
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
            activePlayersScrollView!.isSearching = true;
        } else {
            fadeBackgroundOut();
            mcController!.advertisingAndBrowsing(start: false);
            mcController!.foundPeerIDs = [];
            mcController!.receivedInvitationPeerIDs = [:];
            activePlayersScrollView!.removePlayerAds(forever:true);
            activePlayersScrollView!.isSearching = false;
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
        activePlayersScrollView = UIPlayerAdScrollView(parentView: multiplayerView!, frame: CGRect(x: multiplayerView!.frame.width * 0.15, y: unitViewHeight * 1.7, width: multiplayerView!.frame.width * 0.7, height: unitViewHeight * 3.8), mcController: mcController!, unitHeight: unitViewHeight);
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

class UIPlayerAdScrollView:UICScrollView {
    
    var mcController:MCController?
    
    var searchingForPlayersView:UICView?
    var searchingForPlayersLabel:UICLabel?
    var searchingCatButton:UICatButton?
    
    var invitationView:UICView?
    var invitationLabel:UICLabel?
    var invitationCatButton:UICatButton?
    var acceptButton:UICButton?
    var ignoreButton:UICButton?
    
    var playerAdLabels:[String:PlayerAdLabel] = [:];
    var contentSizeHeight:CGFloat = 0.0;
    var searchTimer:Timer?
    var unitHeight:CGFloat = 0.0
    var isSearching = false;
    var currentInvitationHandler:((Bool, MCSession?) -> Void)? = nil;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView, frame:CGRect, mcController:MCController, unitHeight:CGFloat) {
        super.init(parentView: parentView, frame: frame);
        self.mcController = mcController;
        self.unitHeight = unitHeight;
        setupSearchingForPlayersView();
        setupInvitationView();
        searchForFoundAndLostPeers();
    }
    
    func removePlayerAds(forever:Bool) {
        for (_, playerAdLabel) in playerAdLabels {
            playerAdLabel.shrink(edForever: forever);
        }
        self.playerAdLabels = [:]
    }
    
    func addOrModifyExistingPlayerAds() {
        // Iterate through found display names
        var y = self.unitHeight * 0.6;
        for foundPeerID in self.mcController!.foundPeerIDs {
            let displayName:String = String(foundPeerID.displayName.suffix(foundPeerID.displayName.count - 36));
            let UUIDString:String = String(foundPeerID.displayName.prefix(36));
            // Add new found player ad label
            if (self.playerAdLabels[UUIDString] == nil) {
                let playerAdLabel = PlayerAdLabel(parentView: self, frame: CGRect(x: self.frame.width * 0.5, y: y, width: 0.0, height: 0.0), mcController: self.mcController!, peerID:foundPeerID, UUIDString:UUIDString, displayName: displayName);
                self.playerAdLabels[UUIDString] = playerAdLabel;
            // Previously added player ad label
            } else {
                self.playerAdLabels[UUIDString]!.isPresent = true;
                if (displayName != self.playerAdLabels[UUIDString]!.displayName){
                    self.playerAdLabels[UUIDString]!.peerID = foundPeerID;
                    self.playerAdLabels[UUIDString]!.displayName = displayName;
                    self.playerAdLabels[UUIDString]!.setTitle(displayName, for: .normal);
                }
            }
            y += self.unitHeight;
        }
    }
    
    func growExistingOrDisposePlayerAds() {
        // Iterate through player ad labels
        var y:CGFloat = 0.0;
        var height:CGFloat = self.unitHeight * 0.8;
        var newFrame:CGRect = CGRect(x: self.frame.width * 0.1, y: y + self.unitHeight * 0.2, width: self.frame.width * 0.8, height: height);
        for (displayName, playerAdLabel) in self.playerAdLabels.reversed() {
            if (playerAdLabel.isPresent && self.searchingForPlayersView!.isFadedOut) {
                playerAdLabel.isPresent = false;
                // Double height for invitation sent
                if (playerAdLabel.invitationSent){
                    height = ((self.unitHeight * 2.0) * 0.8);
                    newFrame = CGRect(x: self.frame.width * 0.1, y: y + self.unitHeight * 0.2, width: self.frame.width * 0.8, height: height);
                }
                playerAdLabel.transformation(frame: newFrame);
                playerAdLabel.resetPhysicalStyle();
                // Height
                y += height;
                self.setContentSize(height: y);
                // Height and new frame renewal
                height = self.unitHeight * 0.8;
                newFrame = CGRect(x: self.frame.width * 0.1, y: y + self.unitHeight * 0.4, width: self.frame.width * 0.8, height: self.unitHeight * 0.8);
            } else {
                playerAdLabel.shrink();
                self.playerAdLabels[displayName] = nil;
            }
        }
    }
    
    func hideOrShowView() {
        // If player ad labels exist hide searching for players view
        if (self.playerAdLabels.count > 0) {
            self.searchingForPlayersView!.fadeOut();
        } else {
            self.searchingForPlayersView!.fadeIn();
        }
    }
    
    
    func searchForFoundAndLostPeers() {
        searchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if (self.mcController!.receivedInvitationPeerIDs.count > 0) {
                self.removePlayerAds(forever: false);
                self.isSearching = false;
                let peerID:MCPeerID = Array(self.mcController!.receivedInvitationPeerIDs.keys)[0];
                self.currentInvitationHandler = self.mcController!.receivedInvitationPeerIDs[peerID];
                let displayName:String = String(peerID.displayName.suffix(peerID.displayName.count - 36));
                self.invitationLabel!.text = "Invitation from\n\(displayName)";
                self.invitationView!.fadeIn();
                self.searchingForPlayersView!.fadeOut();
            }
            if (self.isSearching) {
                self.addOrModifyExistingPlayerAds();
                self.hideOrShowView();
                self.growExistingOrDisposePlayerAds();
            }
        }
    }
    
    func setupInvitationView() {
        invitationView = UICView(parentView: self, x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height, backgroundColor: UIColor.clear);
        setupInvitationLabel();
        setupInvitationCatButton();
        setupAcceptButton();
        setupRejectButton();
        invitationView!.alpha = 0.0;
    }
    
    func setupInvitationLabel() {
        invitationLabel = UICLabel(parentView: invitationView!, x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height * 0.33);
        invitationLabel!.backgroundColor = UIColor.clear;
        invitationLabel!.layer.borderWidth = 0.0;
        invitationLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping;
        invitationLabel!.numberOfLines = 2;
        invitationLabel!.text = "Invited by\nijnjkhvjgvgjvhbjh";
        invitationLabel!.textColor = UIColor.black;
        invitationLabel!.font! = UIFont.boldSystemFont(ofSize: searchingForPlayersLabel!.frame.height * 0.15);
    }
    
    func setupInvitationCatButton() {
        invitationCatButton = UICatButton(parentView: invitationView!, x: 0.0, y: self.frame.height * 0.2625, width: self.frame.width * 0.5, height: self.frame.height * 0.145, backgroundColor: UIColor.clear);
        invitationCatButton!.setCat(named: "WavingCat", stage: 0);
        invitationCatButton!.frame = invitationCatButton!.originalFrame!;
        invitationCatButton!.layer.borderWidth = 0.0;
        invitationCatButton!.imageContainerButton!.frame = searchingCatButton!.imageContainerButton!.originalFrame!;
        invitationCatButton!.imageContainerButton!.transform = invitationCatButton!.imageContainerButton!.transform.scaledBy(x: 0.8, y: 0.8);
    }
    
    func setupAcceptButton() {
        acceptButton = UICButton(parentView: invitationView!, frame: CGRect(x: self.frame.width * 0.1, y: self.frame.height * 0.775, width: self.frame.width * 0.35, height: self.frame.height * 0.16), backgroundColor: UIColor.systemGreen);
        acceptButton!.layer.cornerRadius = acceptButton!.frame.width * 0.1;
        acceptButton!.layer.borderWidth = acceptButton!.frame.width * 0.03;
        acceptButton!.layer.borderColor = UIColor.black.cgColor;
        acceptButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: acceptButton!.frame.height * 0.4);
        acceptButton!.setTitle("Accept", for: .normal);
        acceptButton!.setTitleColor(UIColor.white, for: .normal);
        acceptButton!.addTarget(self, action: #selector(acceptButtonSelector), for: .touchUpInside);
    }
    
    @objc func acceptButtonSelector() {
        print("Invitation Accepted!");
        currentInvitationHandler!(true, self.mcController!.session);
    }
    
    func setupRejectButton() {
        ignoreButton = UICButton(parentView: invitationView!, frame: CGRect(x: self.frame.width * 0.55, y: self.frame.height * 0.775, width: self.frame.width * 0.35, height: self.frame.height * 0.16), backgroundColor: UIColor.systemRed);
        ignoreButton!.layer.cornerRadius = ignoreButton!.frame.width * 0.1;
        ignoreButton!.layer.borderWidth = ignoreButton!.frame.width * 0.03;
        ignoreButton!.layer.borderColor = UIColor.black.cgColor;
        ignoreButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: ignoreButton!.frame.height * 0.4);
        ignoreButton!.setTitle("Ignore", for: .normal);
        ignoreButton!.setTitleColor(UIColor.white, for: .normal);
        ignoreButton!.addTarget(self, action: #selector(ignoreButtonSelector), for: .touchUpInside);
    }
    
    @objc func ignoreButtonSelector() {
        print("Invitation Ignored!");
        currentInvitationHandler!(false, self.mcController!.session);
    }
    
    func setupSearchingForPlayersView() {
        searchingForPlayersView = UICView(parentView: self, x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height, backgroundColor: UIColor.clear);
        setupSearchingForPlayersLabel();
        setupCatButton();
    }
    
    func setupCatButton() {
        searchingCatButton = UICatButton(parentView: searchingForPlayersView!, x: 0.0, y: self.frame.height * 0.075, width: self.frame.width, height: self.frame.height * 0.5, backgroundColor: UIColor.clear);
        searchingCatButton!.layer.borderWidth = 0.0;
        searchingCatButton!.setCat(named: "SmilingCat", stage: 0);
        searchingCatButton!.frame = searchingCatButton!.originalFrame!;
        searchingCatButton!.imageContainerButton!.frame = searchingCatButton!.imageContainerButton!.originalFrame!;
    }
    
    func setupSearchingForPlayersLabel() {
        searchingForPlayersLabel = UICLabel(parentView: searchingForPlayersView!, x: 0.0, y: self.frame.height * 0.5, width: self.frame.width, height: self.frame.height * 0.5);
        searchingForPlayersLabel!.backgroundColor = UIColor.clear;
        searchingForPlayersLabel!.layer.borderWidth = 0.0;
        searchingForPlayersLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping;
        searchingForPlayersLabel!.numberOfLines = 2;
        searchingForPlayersLabel!.text = "Searching for\nPlayers";
        searchingForPlayersLabel!.textColor = UIColor.black;
        searchingForPlayersLabel!.font! = UIFont.boldSystemFont(ofSize: searchingForPlayersLabel!.frame.height * 0.2);
    }
    
    func setContentSize(height:CGFloat) {
        self.contentSize = CGSize(width: self.frame.width, height: height);
    }
    
    func setupPlayerAdvertisementConstraints(playerAdvertisementLabel:UIButton) {
        leadingAnchor.constraint(equalTo: playerAdvertisementLabel.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: playerAdvertisementLabel.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: playerAdvertisementLabel.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: playerAdvertisementLabel.bottomAnchor).isActive = true
    }
}

class PlayerAdLabel: UICButton {
    var UUIDString:String = "";
    var displayName:String = "";
    var isPresent:Bool = true;
    var invitationSent:Bool = false;
    var mcController:MCController?
    var peerID:MCPeerID?
    var colors:[UIColor] = [UIColor.systemGreen, UIColor.systemYellow, UIColor.systemOrange, UIColor.systemRed, UIColor.systemPurple, UIColor.systemBlue];
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView, frame:CGRect, mcController:MCController, peerID:MCPeerID, UUIDString:String, displayName:String) {
        super.init(parentView: parentView, frame: CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height), backgroundColor: colors.randomElement()!);
        self.clipsToBounds = true;
        self.mcController = mcController;
        self.UUIDString = UUIDString;
        self.displayName = displayName;
        self.peerID = peerID;
        self.addTarget(self, action: #selector(playerAdLabelSelector), for: .touchUpInside);
    }
    
    func resetPhysicalStyle() {
        self.layer.cornerRadius = self.frame.height * 0.2;
        self.layer.borderWidth = self.frame.height * 0.1;
        self.layer.borderColor = UIColor.black.cgColor;
        self.titleLabel!.font = UIFont.boldSystemFont(ofSize: frame.height * 0.4);
        self.setTitle(displayName, for: .normal);
        self.setTitleColor(UIColor.white, for: .normal);
    }
    
    func transformation(frame:CGRect) {
        UIView.animate(withDuration: 0.25, delay: 0.125, options: .curveEaseInOut, animations: {
            self.frame = frame;
        })
    }
    
    func shrink(edForever:Bool) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            self.frame = CGRect(x: self.frame.midX, y: self.frame.midY, width: 0.0, height: 0.0);
        }, completion: { _ in
            if (edForever) {
                self.removeFromSuperview();
            }
        });
    }
    
    @objc func playerAdLabelSelector() {
        mcController!.browser!.invitePeer(peerID!, to: mcController!.session!, withContext: nil, timeout: 30.0);
        self.invitationSent = true;
        self.isEnabled = false;
        print("Selected \(UUIDString + displayName)")
    }
    
    
    
}
