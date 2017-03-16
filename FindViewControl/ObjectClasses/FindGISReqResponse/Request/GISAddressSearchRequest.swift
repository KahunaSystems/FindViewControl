//
//	GISAddressSearchRequest.swift
//
//	Create by Krutika Mac Mini on 2/8/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class GISAddressSearchRequest: NSObject {

    var address: String!
    var requestType: String!
    var latitude: Float!
    var longitude: Float!

    override init() {
    }



    /**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
    init(fromDictionary dictionary: NSDictionary) {
        address = dictionary["address"] as? String
        requestType = dictionary["requestType"] as? String
        latitude = dictionary["latitude"] as? Float
        longitude = dictionary["longitude"] as? Float

    }

    /**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
    func toDictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        if address != nil {
            dictionary["address"] = address
        }
        if requestType != nil {
            dictionary["requestType"] = requestType
        }
        if latitude != nil {
            dictionary["latitude"] = latitude
        }
        if longitude != nil {
            dictionary["longitude"] = longitude
        }


        return dictionary
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder) {
        address = aDecoder.decodeObject(forKey: "address") as? String
        requestType = aDecoder.decodeObject(forKey: "requestType") as? String
        latitude = aDecoder.decodeObject(forKey: "latitude") as? Float
        longitude = aDecoder.decodeObject(forKey: "longitude") as? Float


    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encodeWithCoder(aCoder: NSCoder) {
        if address != nil {
            aCoder.encode(address, forKey: "address")
        }
        if requestType != nil {
            aCoder.encode(requestType, forKey: "requestType")
        }
        if latitude != nil {
            aCoder.encode(latitude, forKey: "latitude")
        }
        if longitude != nil {
            aCoder.encode(longitude, forKey: "longitude")
        }


    }

}
