//
//	FindLocationResponse.swift
//
//	Create by Krutika Mac Mini on 2/8/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class FindLocationResponse: NSObject {

    var errorMessage: AnyObject!
    var results: [FindResult]!
    var status: String!


    /**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
    init(fromDictionary dictionary: NSDictionary) {
        errorMessage = dictionary["error_message"]! as AnyObject
        results = [FindResult]()
        if let resultsArray = dictionary["results"] as? [NSDictionary] {
            for dic in resultsArray {
                let value = FindResult(fromDictionary: dic)
                results.append(value)
            }
        }
        status = dictionary["status"] as? String
    }

    /**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
    func toDictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        if errorMessage != nil {
            dictionary["error_message"] = errorMessage
        }
        if results != nil {
            var dictionaryElements = [NSDictionary]()
            for resultsElement in results {
                dictionaryElements.append(resultsElement.toDictionary())
            }
            dictionary["results"] = dictionaryElements
        }
        if status != nil {
            dictionary["status"] = status
        }
        return dictionary
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder) {
        errorMessage = aDecoder.decodeObject(forKey: "error_message")! as AnyObject
        results = aDecoder.decodeObject(forKey: "results") as? [FindResult]
        status = aDecoder.decodeObject(forKey: "status") as? String

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encodeWithCoder(aCoder: NSCoder) {
        if errorMessage != nil {
            aCoder.encode(errorMessage, forKey: "error_message")
        }
        if results != nil {
            aCoder.encode(results, forKey: "results")
        }
        if status != nil {
            aCoder.encode(status, forKey: "status")
        }

    }

}
