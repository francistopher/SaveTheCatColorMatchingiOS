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
    var myUuidDisplayName:String = "";
    var myUUID:UUID = UUID();
    var foundDisplayNames:[String] = [];
    
    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    init(displayName:String) {
        super.init(nibName: nil, bundle: nil);
        self.myUuidDisplayName =  myUUID.uuidString + displayName;
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
        myUuidDisplayName = myUUID.uuidString + displayName;
        advertisingAndBrowsing(start: false);
        invalidateAdvertiserAndBrowser();
        setupFramework();
        foundDisplayNames = [];
        advertisingAndBrowsing(start: true);
    }
    
    func setupFramework() {
        setupPeerID();
        setupSession();
        setupAdvertiserAssistant();
        setupBrowser();
    }
    
    func setupPeerID() {
        peerID = MCPeerID(displayName: myUuidDisplayName);
    }
    
    func setupSession() {
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required);
        session.delegate = self;
    }
    
    func setupAdvertiserAssistant() {
        advertiserAssistant = MCAdvertiserAssistant(serviceType: "PodDatCat", discoveryInfo: nil, session: self.session);
    }
    
    func setupBrowser() {
        browser = MCBrowserViewController(serviceType: "PodDatCat", session: self.session);
        browser.browser!.delegate = self;
        browser.delegate = self;
    }
    
    func isMyOwnUUID(peerID:MCPeerID) -> Bool {
        return (peerID.displayName.prefix(36) == myUUID.uuidString)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if (!isMyOwnUUID(peerID: peerID)) {
            foundDisplayNames.append(peerID.displayName);
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        var index:Int = 0;
        while(index < foundDisplayNames.count) {
            if (foundDisplayNames[index].prefix(36) == peerID.displayName.prefix(36)) {
                foundDisplayNames.remove(at: index);
                return;
           } else {
               index += 1;
           }
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
