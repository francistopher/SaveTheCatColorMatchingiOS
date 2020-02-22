//
//  MPCHandler.swift
//  CatVirus
//
//  Created by Christopher Francisco on 2/22/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MPCHandler:NSObject, MCSessionDelegate {
    
    // Your id in the network
    var peerID:MCPeerID!
    // The session
    var session:MCSession!
    // Browse through
    var browser:MCBrowserViewController!
    // To advertise that your available
    var advertiser:MCAdvertiserAssistant? = nil;
    
    func setupPeerWithDisplayName(displayName:String) {
        peerID = MCPeerID(displayName: displayName);
        
    }
    
    func setupSession() {
        session = MCSession(peer: peerID);
        session.delegate = self;
    }
    
    func setupBrowser() {
        browser = MCBrowserViewController(serviceType: "Pod Dat Cat", session: session);
    }
    
    func advertiseSelf(advertise:Bool) {
        if (advertise) {
            advertiser = MCAdvertiserAssistant(serviceType: "Pod Dat Cat", discoveryInfo: nil, session: session);
            advertiser!.start();
        } else {
            advertiser!.stop();
            advertiser = nil;
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("");
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("");
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("");
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("");
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("");
    }
}
