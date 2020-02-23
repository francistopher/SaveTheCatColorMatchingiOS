//
//  UIMultiPlayer.swift
//  podDatCat
//
//  Created by Christopher Francisco on 2/13/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import SwiftUI
import MultipeerConnectivity

class UIMultiplayer: UIButton, MCSessionDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceBrowserDelegate {

    var originalFrame:CGRect? = nil;
    var reducedFrame:CGRect? = nil;
    
    var multiplayerView:UICView?;
    var unitViewHeight:CGFloat = 0.0;
    var multiplayerTitleLabel:UICLabel?
    var displayNameTextField:UICTextField?
    var localButton:UICButton?
    var globalButton:UICButton?
    
    var peerID:MCPeerID!
    var session:MCSession!
    var advertiserAssistant:MCAdvertiserAssistant!
    var browser:MCBrowserViewController!
    var hosting:Bool = false;
    var displayName:String = UIDevice.current.name;

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(parentView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height));
        self.originalFrame = CGRect(x: x, y: y, width: width, height: height);
        self.backgroundColor = .clear;
        self.layer.cornerRadius = height / 2.0;
        self.addTarget(self, action: #selector(multiplayerViewSelector), for: .touchUpInside);
        parentView.addSubview(self);
        self.setupMultiplayerView();
        self.setupDisplayNameTextField();
        self.setupConnectionFramework();
        self.setStyle();
    }

    @objc func multiplayerViewSelector() {
        if (self.multiplayerView!.alpha == 0.0) {
            self.fadeBackgroundIn();
            print("Start Advertising");
            advertiserAssistant.start();
            browser.browser!.startBrowsingForPeers();
        } else {
            self.fadeBackgroundOut();
            print("Stop Advertising");
            advertiserAssistant.stop();
            browser.browser!.stopBrowsingForPeers();
        }
    }
    
    func setupMultiplayerView() {
        multiplayerView = UICView(parentView: self.superview!.superview!, x: 0.0, y: 0.0, width: ViewController.staticUnitViewHeight * 8, height: ViewController.staticUnitViewHeight * 8, backgroundColor: UIColor.white);
        UICenterKit.centerWithVerticalDisplacement(childView: multiplayerView!, parentRect: self.multiplayerView!.superview!.frame, childRect: multiplayerView!.frame, verticalDisplacement: -ViewController.staticUnitViewHeight * 0.25);
        multiplayerView!.layer.cornerRadius = self.multiplayerView!.frame.height * 0.20;
        multiplayerView!.layer.borderWidth = self.multiplayerView!.frame.height * 0.015;
        multiplayerView!.layer.borderColor = UIColor.black.cgColor;
        multiplayerView!.alpha = 0.0;
        unitViewHeight = multiplayerView!.frame.height / 6.0;
        setupMultiplayerLabel();
//        setupLocalButton();
//        setupGlobalButton();
    }
    
    func setupMultiplayerLabel() {
        multiplayerTitleLabel = UICLabel(parentView: self.multiplayerView!, x: 0.0, y: 0.0, width: multiplayerView!.frame.width, height: unitViewHeight);
        multiplayerTitleLabel!.text = "Multiplayer";
        multiplayerTitleLabel!.font = UIFont.boldSystemFont(ofSize: multiplayerTitleLabel!.frame.height * 0.4);
        multiplayerTitleLabel!.layer.cornerRadius = multiplayerView!.layer.cornerRadius;
        multiplayerTitleLabel!.layer.masksToBounds = true;
        multiplayerTitleLabel!.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner];
    }
    
    func setupDisplayNameTextField() {
        displayNameTextField = UICTextField(parentView:self.multiplayerView!, frame: CGRect(x: self.multiplayerView!.frame.width * 0.1 , y: multiplayerTitleLabel!.frame.maxY, width: self.multiplayerView!.frame.width * 0.8, height: unitViewHeight));
        displayNameTextField!.layer.borderWidth = displayNameTextField!.frame.height * 0.1;
        displayNameTextField!.layer.borderColor = UIColor.black.cgColor;
        displayNameTextField!.layer.cornerRadius = displayNameTextField!.frame.height * 0.2;
        displayNameTextField!.addTarget(self, action: #selector(displayNameTextFieldSelector), for: .editingDidEnd);
        displayNameTextField!.text = "EnterDisplayName";
    }
    
    @objc func displayNameTextFieldSelector() {
        print("Set a new display name!");
        advertiserAssistant.stop();
        advertiserAssistant.start();
    }
    
//    func setupLocalButton() {
//        localButton = UICButton(parentView: self.multiplayerView!, frame: CGRect(x: self.multiplayerView!.frame.width * 0.1, y: unitViewHeight * 2, width: (self.multiplayerView!.frame.width * 0.4) + (unitViewHeight * 0.04), height: unitViewHeight * 0.8), backgroundColor: UIColor.white);
//        localButton!.setTitle("Local", for: .normal);
//        localButton!.layer.cornerRadius = localButton!.frame.height * 0.2;
//        localButton!.layer.borderWidth = localButton!.frame.height * 0.1;
//        localButton!.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner];
//        localButton!.backgroundColor = UIColor.systemPink;
//        localButton!.setTitleColor(UIColor.black, for: .normal);
//        localButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: localButton!.frame.height * 0.4);
//        localButton!.addTarget(self, action: #selector(localButtonSelector), for: .touchUpInside);
//    }
    
//    @objc func localButtonSelector() {
//        if (localButton!.backgroundColor!.cgColor != UIColor.systemPink.cgColor) {
//            localButton!.backgroundColor = UIColor.systemPink;
//            globalButton!.backgroundColor = UIColor.clear;
//        }
//    }
    
//    func setupGlobalButton() {
//        globalButton = UICButton(parentView: self.multiplayerView!, frame: CGRect(x: (self.multiplayerView!.frame.width * 0.5) - (unitViewHeight * 0.04), y: unitViewHeight, width: (self.multiplayerView!.frame.width * 0.4) , height: unitViewHeight * 0.8), backgroundColor: UIColor.white);
//        globalButton!.setTitle("Global", for: .normal);
//        globalButton!.layer.cornerRadius = localButton!.frame.height * 0.2;
//        globalButton!.layer.borderWidth = localButton!.frame.height * 0.1;
//        globalButton!.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner];
//        globalButton!.setTitleColor(UIColor.black, for: .normal);
//        globalButton!.titleLabel!.font = UIFont.boldSystemFont(ofSize: globalButton!.frame.height * 0.4);
//        globalButton!.addTarget(self, action: #selector(globalButtonSelector), for: .touchUpInside);
//    }
    
//    @objc func globalButtonSelector() {
//        if (globalButton!.backgroundColor!.cgColor != UIColor.systemPink.cgColor) {
//            globalButton!.backgroundColor = UIColor.systemPink;
//            localButton!.backgroundColor = UIColor.clear;
//        }
//    }
    
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
    
    func setupConnectionFramework() {
        // Setup framework
        self.peerID = MCPeerID(displayName: self.displayNameTextField!.text!);
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required);
        self.session.delegate = self;
        // Setup advertising framework - to host
        self.advertiserAssistant = MCAdvertiserAssistant(serviceType: "PodDatCat", discoveryInfo: ["peerID":self.peerID.displayName], session: self.session);
        // Setup browser view controller - to join
        self.browser = MCBrowserViewController(serviceType: "PodDatCat", session: self.session);
        self.browser.browser!.delegate = self;
        self.browser.delegate = self;
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found \(peerID.displayName)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
         print("\(peerID.displayName) lost")
    }
}
