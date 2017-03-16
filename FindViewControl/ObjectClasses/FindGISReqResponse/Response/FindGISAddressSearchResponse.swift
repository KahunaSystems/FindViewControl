//
//	FindGISAddressSearchResponse.swift
//
//	Create by Krutika Mac Mini on 2/8/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class FindGISAddressSearchResponse: NSObject {

    var response: FindLocationResponse!
    var status: FindStatus!


    /**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
    init(fromDictionary dictionary: NSDictionary) {
        if let responseData = dictionary["Response"] as? NSDictionary {
            response = FindLocationResponse(fromDictionary: responseData)
        }
        if let statusData = dictionary["status"] as? NSDictionary {
            status = FindStatus(fromDictionary: statusData)
        }
    }

    /**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
    func toDictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        if response != nil {
            dictionary["Response"] = response.toDictionary()
        }
        if status != nil {
            dictionary["status"] = status.toDictionary()
        }
        return dictionary
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder) {
        response = aDecoder.decodeObject(forKey: "Response") as? FindLocationResponse
        status = aDecoder.decodeObject(forKey: "status") as? FindStatus

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encodeWithCoder(aCoder: NSCoder) {
        if response != nil {
            aCoder.encode(response, forKey: "Response")
        }
        if status != nil {
            aCoder.encode(status, forKey: "status")
        }

    }

}
