//
//  FindConstants.swift
//  FindViewControl
//
//  Created by Krutika Mac Mini on 3/9/17.
//  Copyright © 2017 Kahuna. All rights reserved.
//

import Foundation
import UIKit

struct FindConstants {

    enum pinDragDropViewConstants {

        static let kCurrentLocationPinType = "Current Location"
        static let kDefaultLocationType = "Default Location"
        static let kCacheLocationType = "Cache Location"
        static let serviceReqTypeGeoCordinate = "GEO_CORDINATE"
        static let serviceReqTypeGeoAddress = "GEO_ADDRESS"
    }

    enum findConstants {
        static let kNeighbourhoodReachUs = "Reach Us:"
        static let kNeighbourhoodGetDirections = "Get Directions"
        static let kGooglePlacesUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    }

    enum UniqueKeyConstants {
        static let GMSLatitudeKey       = "GMSPositionLaitude"
        static let GMSLongitudeKey      = "GMSPositionLongitude"
        static let GMSAddressKey        = "GMSAddress"
    }
    
    enum DefaultValues {
        static let mapZoom: Float = 16
    }
    
    enum ServerResponseCodes {
        static let successCode: Int = 200
    }
}
