//
//  MCController.swift
//  CatVirus
//
//  Created by Christopher Francisco on 2/23/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import MultipeerConnectivity
class MCController: ViewController, MCSessionDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceBrowserDelegate {
    
    var peerID:MCPeerID!
    var session:MCSession!
    var advertiserAssistant:MCAdvertiserAssistant!
    var browser:MCBrowserViewController!
    var hosting:Bool = false;
    var displayName:String = "";
    var myUUID:UUID = UUID();
    
    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    init(displayName:String) {
        super.init(nibName: nil, bundle: nil);
        self.displayName = displayName;
    }
    
    func advertisingAndBrowsing(start:Bool) {
        if (start) {
            advertiserAssistant.start();
            browser.browser!.startBrowsingForPeers();
        } else {
            advertiserAssistant.stop();
            browser.browser!.stopBrowsingForPeers();
        }
    }
    
    func invalidateAdvertiserAndBrowser() {
        browser.browser!.delegate = nil;
        browser.delegate = nil;
        browser = nil
        advertiserAssistant = nil;
        session.delegate = nil;
        session = nil;
        peerID = nil;
    }
    
    func resetFramework(displayName:String) {
        self.displayName = displayName;
        advertisingAndBrowsing(start: false);
        invalidateAdvertiserAndBrowser();
        setupFramework();
        advertisingAndBrowsing(start: true);
    }
    
    func setupFramework() {
        peerID = MCPeerID(displayName: myUUID.uuidString + displayName);
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required);
        session.delegate = self;
        advertiserAssistant = MCAdvertiserAssistant(serviceType: "PodDatCat", discoveryInfo: ["peerID":self.peerID.displayName], session: self.session);
        browser = MCBrowserViewController(serviceType: "PodDatCat", session: self.session);
        browser.browser!.delegate = self;
        browser.delegate = self;
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if (peerID.displayName.prefix(36) != displayName.prefix(36)) {
            print("Found peer!");
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if (peerID.displayName.prefix(36) != displayName.prefix(36)) {
            print("Lost peer!");
        }
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
}
