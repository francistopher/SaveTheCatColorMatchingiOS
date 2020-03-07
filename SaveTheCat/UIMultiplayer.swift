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
            self.activePlayersScrollView!.searchForFoundAndLostPeers();
        } else {
            self.activePlayersScrollView!.searchTimer!.invalidate();
            fadeBackgroundOut();
            mcController!.advertisingAndBrowsing(start: false);
            mcController!.foundPeerIDs = [];
            mcController!.invitationPeerIDs = [:];
            activePlayersScrollView!.removePlayerAds(forever:true);
            activePlayersScrollView!.isSearching = false;
        }
    }
    
    func setupMultiplayerView() {
        multiplayerView = UICView(parentView: self.superview!.superview!, x: 0.0, y: 0.0, width: ViewController.staticUnitViewHeight * 8, height: ViewController.staticUnitViewHeight * 8, backgroundColor: UIColor.white);
        CenterController.centerWithVerticalDisplacement(childView: multiplayerView!, parentRect: self.multiplayerView!.superview!.frame, childRect: multiplayerView!.frame, verticalDisplacement: -ViewController.staticUnitViewHeight * 0.25);
        multiplayerView!.layer.cornerRadius = multiplayerView!.frame.height * 0.2;
        multiplayerView!.layer.borderWidth = self.multiplayerView!.frame.height * 0.015;
        multiplayerView!.layer.borderColor = UIColor.black.cgColor;
        multiplayerView!.alpha = 0.0;
        unitViewHeight = multiplayerView!.frame.height / 6.0;
    }
    
    func setupDisplayNameTextField() {
        displayNameTextField = UICTextField(parentView:self.multiplayerView!, frame: CGRect(x: multiplayerView!.frame.width * 0.15 , y: unitViewHeight * 0.5, width: (multiplayerView!.frame.width * 0.7) - (unitViewHeight * 0.68), height: unitViewHeight * 0.8));
        displayNameTextField!.layer.borderWidth = displayNameTextField!.frame.height * 0.1;
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
            setIconImage(imageName: "multiPlayer.png");
            multiplayerView!.backgroundColor = UIColor.white;
            multiplayerView!.layer.borderColor = UIColor.black.cgColor;
            displayNameTextField!.backgroundColor = UIColor.white;
            displayNameTextField!.layer.borderColor = UIColor.black.cgColor;
            updateDisplayNameButton!.layer.borderColor = UIColor.black.cgColor;
            activePlayersScrollView!.setStyle();
        } else {
            setIconImage(imageName: "multiPlayer.png");
            multiplayerView!.backgroundColor = UIColor.black;
            multiplayerView!.layer.borderColor = UIColor.white.cgColor;
            displayNameTextField!.backgroundColor = UIColor.black;
            displayNameTextField!.layer.borderColor = UIColor.white.cgColor;
            updateDisplayNameButton!.layer.borderColor = UIColor.white.cgColor;
            activePlayersScrollView!.setStyle();
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
    var invitationPacks:[String:InvitationPack] = [:];
    var currentInvitationPack:InvitationPack?
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
                self.playerAdLabels[UUIDString]!.setCompiledStyle();
            }
            y += self.unitHeight;
        }
    }
    
    func addModifyInvitationsOfExistingPeers() {
        for invitationPeerID in Array(self.mcController!.invitationPeerIDs.keys) {
            let invitationDisplayName:String = String(invitationPeerID.displayName.suffix(invitationPeerID.displayName.count - 36));
            let invitationUUID:String = String(invitationPeerID.displayName.prefix(36));
            // Add new found invitation
            if (self.invitationPacks[invitationUUID] == nil) {
                let invitationPack:InvitationPack = InvitationPack(peerID: invitationPeerID, UUID: invitationUUID, displayName:invitationDisplayName, invitationHandler: self.mcController!.invitationPeerIDs[invitationPeerID]!);
                self.invitationPacks[invitationUUID] = invitationPack;
            }
        }
    }
    
    func removeOrModifyNonExistingInvitationPeers() {
        for (UUIDString,invitationPack) in invitationPacks {
            // Verify previous invitations
            var isPresent:Bool = false;
            var finalFoundDisplayName:String = "";
            // Is the peer who sent the invitation exist
            for foundPeerID in self.mcController!.foundPeerIDs {
               let foundDisplayName:String = String(foundPeerID.displayName.suffix(foundPeerID.displayName.count - 36));
               let foundUUID:String = String(foundPeerID.displayName.prefix(36));
               if (UUIDString == foundUUID) {
                    isPresent = true;
                    finalFoundDisplayName = foundDisplayName;
                    break;
               }
            }
        
            var canceledInvitationUUID:String = "";
            // Is the peer who sent the canceling invitation exist
            for canceledInvitationPeerID in self.mcController!.canceledInvitationPeerIDs {
                let possibleCanceledInvitationUUID:String = String(canceledInvitationPeerID.displayName.prefix(36));
                if (UUIDString == possibleCanceledInvitationUUID) {
                    canceledInvitationUUID = possibleCanceledInvitationUUID;
                    isPresent = false;
                    break;
                }
            }
            // If present update the name
            if (isPresent) {
               invitationPack.displayName = finalFoundDisplayName;
               invitationPack.isPresent = isPresent;
            } else {
                if (canceledInvitationUUID.count > 0) {
                    // Remove canceled invitation
                    let peerID:MCPeerID = self.invitationPacks[canceledInvitationUUID]!.peerID!;
                    let index:Int = self.mcController!.canceledInvitationPeerIDs.firstIndex(of: peerID)!;
                    self.mcController!.canceledInvitationPeerIDs.remove(at: index);
                    // Remove the invitation
                    self.mcController!.invitationPeerIDs[peerID] = nil;
                }
               // If not remove it completely
               self.invitationPacks[UUIDString] = nil;
            }
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
                // Check if invitation was ignored
                var wasNotIgnored:Bool = true;
                var ignoredPeerID:MCPeerID?;
                for currentIgnoredPeerID in mcController!.ignoredPeerIDS {
                    let ignoredUUIDString:String = String(currentIgnoredPeerID.displayName.prefix(36));
                    if (playerAdLabel.UUIDString == ignoredUUIDString) {
                        playerAdLabel.invitationSent = false;
                        ignoredPeerID = currentIgnoredPeerID;
                        wasNotIgnored = false;
                    }
                }
                if (!wasNotIgnored) {
                    let index:Int = mcController!.ignoredPeerIDS.firstIndex(of: ignoredPeerID!)!;
                    mcController!.ignoredPeerIDS.remove(at: index);
                }
                // Double height for invitation sent
                if (playerAdLabel.invitationSent && wasNotIgnored){
                    height = (self.unitHeight * 2.0) * 0.8;
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
                playerAdLabel.shrink(colorOptionButton: false);
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
            print("SEARCH TIMING")
            self.addModifyInvitationsOfExistingPeers();
            self.removeOrModifyNonExistingInvitationPeers();
            if (self.invitationPacks.count > 0) {
                print("INVITATION PACKS")
                self.removePlayerAds(forever: false);
                self.isSearching = false;
                self.currentInvitationPack = Array(self.invitationPacks.values)[0];
                self.currentInvitationHandler = self.currentInvitationPack!.invitationHandler;
                let displayName:String = self.currentInvitationPack!.displayName;
                self.invitationLabel!.text = "Invitation from\n\(displayName)";
                self.invitationView!.fadeIn();
                self.searchingForPlayersView!.fadeOut();
                self.acceptButton!.isEnabled = true;
                self.ignoreButton!.isEnabled = true;
            } else {
                self.isSearching = true;
                self.acceptButton!.isEnabled = false;
                self.ignoreButton!.isEnabled = false;
            }
            if (self.isSearching) {
                self.invitationView!.fadeOut();
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
        setupIgnoreButton();
        invitationView!.alpha = 0.0;
        invitationView!.backgroundColor = UIColor.clear;
    }
    
    func setupInvitationLabel() {
        invitationLabel = UICLabel(parentView: invitationView!, x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height * 0.33);
        invitationLabel!.backgroundColor = UIColor.clear;
        invitationLabel!.layer.borderWidth = 0.0;
        invitationLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping;
        invitationLabel!.numberOfLines = 2;
        invitationLabel!.text = "Invited by";
        invitationLabel!.textColor = UIColor.black;
        invitationLabel!.font! = UIFont.boldSystemFont(ofSize: searchingForPlayersLabel!.frame.height * 0.15);
    }
    
    func setupInvitationCatButton() {
        invitationCatButton = UICatButton(parentView: invitationView!, x: 0.0, y: self.frame.height * 0.2625, width: self.frame.width * 0.5, height: self.frame.height * 0.145, backgroundColor: UIColor.clear);
        invitationCatButton!.setCat(named: "CheeringCat", stage: 0);
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
    
    func setupIgnoreButton() {
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
        // Remove message
        invitationPacks[currentInvitationPack!.UUID] = nil;
        mcController!.invitationPeerIDs[currentInvitationPack!.peerID!] = nil;
        // Send ignored message
        print("Ignoring invite sent from \(currentInvitationPack!.displayName)");
        let context:Data = "Ignoring".data(using: .utf8)!;
        mcController!.browser!.invitePeer(currentInvitationPack!.peerID!, to: mcController!.session!, withContext: context, timeout: 30.0);
        
        currentInvitationHandler!(false, self.mcController!.session);
    }
    
    func setupSearchingForPlayersView() {
        searchingForPlayersView = UICView(parentView: self, x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height, backgroundColor: UIColor.clear);
        searchingForPlayersView!.backgroundColor = UIColor.clear;
        setupSearchingForPlayersLabel();
        setupCatButton();
    }
    
    func setupCatButton() {
        searchingCatButton = UICatButton(parentView: searchingForPlayersView!, x: 0.0, y: self.frame.height * 0.075, width: self.frame.width, height: self.frame.height * 0.5, backgroundColor: UIColor.clear);
        searchingCatButton!.layer.borderWidth = 0.0;
        searchingCatButton!.setCat(named: "SmilingCat", stage: 4);
        searchingCatButton!.frame = searchingCatButton!.originalFrame!;
        searchingCatButton!.imageContainerButton!.frame = searchingCatButton!.imageContainerButton!.originalFrame!;
    }
    
    func setupSearchingForPlayersLabel() {
        searchingForPlayersLabel = UICLabel(parentView: searchingForPlayersView!, x: 0.0, y: self.frame.height * 0.5, width: self.frame.width, height: self.frame.height * 0.5);
        searchingForPlayersLabel!.backgroundColor = UIColor.clear;
        searchingForPlayersLabel!.layer.borderWidth = 0.0;
        searchingForPlayersLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping;
        searchingForPlayersLabel!.numberOfLines = 2;
        searchingForPlayersLabel!.text = "Searching for\nNearby Players";
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
    
    func setStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            self.layer.borderColor = UIColor.black.cgColor;
            self.searchingForPlayersLabel!.textColor = UIColor.black;
            self.invitationView!.layer.borderColor = UIColor.black.cgColor;
            self.invitationLabel!.textColor = UIColor.black;
            self.acceptButton!.layer.borderColor = UIColor.black.cgColor;
            self.acceptButton!.setTitleColor(UIColor.black, for: .normal);
            self.ignoreButton!.layer.borderColor = UIColor.black.cgColor;
            self.ignoreButton!.setTitleColor(UIColor.black, for: .normal);
        } else {
            self.layer.borderColor = UIColor.white.cgColor;
            self.searchingForPlayersLabel!.textColor = UIColor.white;
            self.invitationView!.layer.borderColor = UIColor.white.cgColor;
            self.invitationLabel!.textColor = UIColor.white;
            self.acceptButton!.layer.borderColor = UIColor.white.cgColor;
            self.acceptButton!.setTitleColor(UIColor.white, for: .normal);
            self.ignoreButton!.layer.borderColor = UIColor.white.cgColor;
            self.ignoreButton!.setTitleColor(UIColor.white, for: .normal);
        }
        for playerAdLabel in Array(playerAdLabels.values) {
            playerAdLabel.setCompiledStyle();
        }
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
    
    var cancelInvitationButton:UICButton?;
    
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
        setupCancelInvitationButton();
        setCompiledStyle();
    }
    
    func setupCancelInvitationButton() {
        cancelInvitationButton = UICButton(parentView: self, frame: CGRect(x: self.frame.midX, y: self.frame.midY, width: 0.0, height: 0.0), backgroundColor: UIColor.red);
        cancelInvitationButton!.addTarget(self, action: #selector(cancelButtonSelector), for: .touchUpInside);
        
    }
    
    @objc func cancelButtonSelector() {
        print("Canceling invite sent to \(displayName)");
        let context:Data = "Canceling".data(using: .utf8)!;
        invitationSent = false;
        mcController!.browser!.invitePeer(peerID!, to: mcController!.session!, withContext: context, timeout: 30.0);
        mcController!.session!.cancelConnectPeer(peerID!);
    }
    
    func resetPhysicalStyle() {
        if (invitationSent) {
            self.titleLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping;
            self.titleLabel!.textAlignment = NSTextAlignment.center;
            self.titleLabel!.numberOfLines = 3;
            self.setTitle(displayName + "\n.\n.", for: .normal);
            // Reset cancel button
            cancelInvitationButton!.frame = CGRect(x: self.frame.width * 0.2, y: self.frame.height * 0.475, width: self.frame.width * 0.6, height: self.frame.height * 0.4);
            cancelInvitationButton!.layer.cornerRadius = cancelInvitationButton!.frame.height * 0.2;
            cancelInvitationButton!.layer.borderWidth = cancelInvitationButton!.frame.height * 0.1;
            cancelInvitationButton!.setTitle("Cancel Invite", for: .normal);
            cancelInvitationButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: cancelInvitationButton!.frame.height * 0.4);
            self.bringSubviewToFront(cancelInvitationButton!);
        } else {
            self.layer.cornerRadius = self.frame.height * 0.2;
            self.layer.borderWidth = self.frame.height * 0.1;
            self.titleLabel!.font = UIFont.boldSystemFont(ofSize: frame.height * 0.4);
            self.setTitle(displayName, for: .normal);
            self.titleLabel!.numberOfLines = 1;
            // Reset cancel button
            cancelInvitationButton!.frame = CGRect(x: self.frame.midX, y: self.frame.midY, width: 0.0, height: 0.0);
        }
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
        if (!self.invitationSent){
            let context:Data = "Sending".data(using: .utf8)!;
            mcController!.browser!.invitePeer(peerID!, to: mcController!.session!, withContext: context, timeout: 30.0);
            self.invitationSent = true;
        }
    }
    
    func setCompiledStyle() {
        if (UIScreen.main.traitCollection.userInterfaceStyle.rawValue == 1){
            self.layer.borderColor = UIColor.black.cgColor;
            self.setTitleColor(UIColor.black, for: .normal);
            self.cancelInvitationButton!.setTitleColor(UIColor.black, for: .normal);
            self.cancelInvitationButton!.layer.borderColor = UIColor.black.cgColor;
        } else {
            self.layer.borderColor = UIColor.white.cgColor;
            self.setTitleColor(UIColor.white, for: .normal);
            self.cancelInvitationButton!.setTitleColor(UIColor.white, for: .normal);
            self.cancelInvitationButton!.layer.borderColor = UIColor.white.cgColor;
        }
    }
}

class InvitationPack {
    var UUID:String = "";
    var peerID:MCPeerID?
    var displayName:String = "";
    var isPresent:Bool = false;
    var invitationHandler:((Bool, MCSession?) -> Void)?;
    
    init(peerID:MCPeerID, UUID:String, displayName:String, invitationHandler:@escaping (Bool, MCSession?) -> Void) {
        self.peerID = peerID;
        self.UUID = UUID;
        self.invitationHandler = invitationHandler;
    }
}
