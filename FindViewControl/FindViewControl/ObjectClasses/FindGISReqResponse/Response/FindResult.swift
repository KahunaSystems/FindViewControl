//
//	FindResult.swift
//
//	Create by Krutika Mac Mini on 2/8/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class FindResult: NSObject {

    var formattedAddress: String!
    var geometry: FindGeometry!


    /**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
    init(fromDictionary dictionary: NSDictionary) {
        formattedAddress = dictionary["formatted_address"] as? String
        if let geometryData = dictionary["geometry"] as? NSDictionary {
            geometry = FindGeometry(fromDictionary: geometryData)
        }
    }

    /**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
    func toDictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        if formattedAddress != nil {
            dictionary["formatted_address"] = formattedAddress
        }
        if geometry != nil {
            dictionary["geometry"] = geometry.toDictionary()
        }
        return dictionary
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder) {
        formattedAddress = aDecoder.decodeObject(forKey: "formatted_address") as? String
        geometry = aDecoder.decodeObject(forKey: "geometry") as? FindGeometry

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encodeWithCoder(aCoder: NSCoder) {
        if formattedAddress != nil {
            aCoder.encode(formattedAddress, forKey: "formatted_address")
        }
        if geometry != nil {
            aCoder.encode(geometry, forKey: "geometry")
        }

    }

}
