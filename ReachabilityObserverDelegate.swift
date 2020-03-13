//
//  ReachabilityObserverDelegate.swift
//  SaveTheCat
//
//  Created by Christopher Francisco on 3/12/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import Reachability

fileprivate var reachability: Reachability!

protocol ReachabilityActionDelegate {
    func reachabilityChanged(_ isReachable: Bool)
}

protocol ReachabilityObserverDelegate: class, ReachabilityActionDelegate {
    func addReachabilityObserver() throws
    func removeReachabilityObserver()
}

extension ReachabilityObserverDelegate {
    
    func addReachabilityObserver() throws {
        reachability = try Reachability()
        
        reachability.whenReachable = { [weak self] reachability in
            self?.reachabilityChanged(true)
        }
        
        reachability.whenUnreachable = { [weak self] reachability in
            self?.reachabilityChanged(false)
        }
        
        try reachability.startNotifier()
    }
    
    func removeReachabilityObserver() {
        reachability.stopNotifier()
        reachability = nil
    }
}
