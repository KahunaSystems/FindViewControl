//
//  FindCheckConnectivitySwift.swift
//  FIMS
//
//  Created by Piyush Rathi on 23/01/17.
//  Copyright © 2017 Kahuna Systems. All rights reserved.
//

import UIKit


class FindCheckConnectivitySwift: NSObject {

    static let sharedInstance: FindCheckConnectivitySwift = {
        let instance = FindCheckConnectivitySwift()
        return instance
    }()

    override init() {
        super.init()
    }

    /* *
     Connectivity testing code
     * */
    class func hasConnectivity() -> Bool {

        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)

        return (isReachable && !needsConnection)
    }

}
