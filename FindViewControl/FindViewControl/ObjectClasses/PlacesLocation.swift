//
//	PlacesLocation.swift
//
//	Create by Krutika Mac Mini on 2/8/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class PlacesLocation: NSObject {

    var lat: Double!
    var lng: Double!


    /**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
    init(fromDictionary dictionary: NSDictionary) {

        lat = dictionary["lat"] as? Double
        lng = dictionary["lng"] as? Double
    }

    /**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
    func toDictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        if lat != nil {
            dictionary["lat"] = lat
        }
        if lng != nil {
            dictionary["lng"] = lng
        }
        return dictionary
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder) {
        lat = aDecoder.decodeObject(forKey: "lat") as? Double
        lng = aDecoder.decodeObject(forKey: "lng") as? Double

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encodeWithCoder(aCoder: NSCoder) {
        if lat != nil {
            aCoder.encode(lat, forKey: "lat")
        }
        if lng != nil {
            aCoder.encode(lng, forKey: "lng")
        }

    }

}
