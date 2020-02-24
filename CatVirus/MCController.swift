//
//  MCController.swift
//  CatVirus
//
//  Created by Christopher Francisco on 2/23/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//
import Foundation
import MultipeerConnectivity
class MCController: ViewController,MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    
    var peerID:MCPeerID!
    var session:MCSession!
    var advertiserAssistant:MCNearbyServiceAdvertiser!
    var browser:MCNearbyServiceBrowser!
    var myUuidDisplayName:String = "";
    var myUUID:UUID = UUID();
    var receivedInvitationPeerIDs:[MCPeerID] = [];
    var foundPeerIDs:[MCPeerID] = [];
    var isHosting:Bool = false;
    var hasJoined:Bool = false;
    
    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    init(displayName:String) {
        super.init(nibName: nil, bundle: nil);
        self.myUuidDisplayName =  myUUID.uuidString + displayName;
    }
    
    func advertisingAndBrowsing(start:Bool) {
        if (start) {
            advertiserAssistant.startAdvertisingPeer();
            browser!.startBrowsingForPeers();
        } else {
            advertiserAssistant.stopAdvertisingPeer();
            browser!.stopBrowsingForPeers();
        }
    }
    
    func invalidateAdvertiserAndBrowser() {
        browser!.delegate = nil;
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
        foundPeerIDs = [];
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
        advertiserAssistant = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "PodDatCat");
        advertiserAssistant.delegate = self;
        session.delegate = self;
    }
    
    func setupBrowser() {
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "PodDatCat");
        browser.delegate = self;
        session.delegate = self;
    }
    
    func isMyOwnUUID(peerID:MCPeerID) -> Bool {
        return (peerID.displayName.prefix(36) == myUUID.uuidString)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if (!isMyOwnUUID(peerID: peerID)) {
            foundPeerIDs.append(peerID);
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        var index:Int = 0;
        while(index < foundPeerIDs.count) {
            if (foundPeerIDs[index].displayName.prefix(36) == peerID.displayName.prefix(36)) {
                foundPeerIDs.remove(at: index);
                return;
           } else {
               index += 1;
           }
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print(peerID.displayName + "I think i received an invitation");
        receivedInvitationPeerIDs.append(peerID);
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            print("Not connected with \(peerID.displayName)")
        case .connecting:
            print("Connecting with \(peerID.displayName)")
        case .connected:
            print("Connected with \(peerID.displayName)")
        @unknown default:
            print("Otro");
        }
    }

    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Received data from\(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("Received stream from\(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Started receiving resource from\(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("Finished receiving resource data from\(peerID.displayName)")
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        
    }
}
