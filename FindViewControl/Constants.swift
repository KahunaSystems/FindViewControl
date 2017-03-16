//
//  Constants.swift
//  MyCity311
//
//  Created by Piyush on 6/2/16.
//  Copyright © 2016 Kahuna Systems. All rights reserved.
//

import Foundation
import UIKit

struct Constants {

  
    enum TimeOutIntervals {

        static let kSRRetryCount = 3
        static let kMaxRetryCount = 3
        static let kSRTimeoutInterval = 60
        static let kMaxTimeoutInterval = 240
        static let cacheImageTimeOut = 30.0

        static let kMaxLocationWaitTime = 10
        static let kMinHorizontalAccuracy = 100

        static let horizontalLocationAccuracy = 70
        static let maximumWaitTimeForLocation = 10
        static let defaultImageCompressionValue = 0.7

        static let queryPageSize = 10
    }

    enum UnidentifiedError: Error {
        case emptyHTTPResponse
    }

    enum ServerResponseCodes
    {
        static let successCode: Int = 200
        static let unknownErrorCode: Int = 1000
        static let generalErrorCode = 201
        static let sessionExpireErrorCode = 234
        static let duplicateEntryCode = 203
 
    }

 
}
