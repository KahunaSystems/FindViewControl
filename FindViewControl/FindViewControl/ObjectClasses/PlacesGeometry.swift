//
//	PlacesGeometry.swift
//
//	Create by Krutika Mac Mini on 2/8/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class PlacesGeometry: NSObject {

    var location: PlacesLocation!


    /**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
    init(fromDictionary dictionary: NSDictionary) {
        if let locationData = dictionary["location"] as? NSDictionary {
            location = PlacesLocation(fromDictionary: locationData)
        }
    }

    /**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
    func toDictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        if location != nil {
            dictionary["location"] = location.toDictionary()
        }
        return dictionary
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder) {
        location = aDecoder.decodeObject(forKey: "location") as? PlacesLocation

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encodeWithCoder(aCoder: NSCoder) {
        if location != nil {
            aCoder.encode(location, forKey: "location")
        }

    }

}
