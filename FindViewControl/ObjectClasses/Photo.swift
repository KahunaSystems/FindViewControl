//
//	Photo.swift
//
//	Create by Krutika Mac Mini on 27/12/2016
//	Copyright © 2016. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class Photo: NSObject {

    var height: Int!
    var htmlAttributions: [String]!
    var photoReference: String!
    var width: Int!


    /**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
    init(fromDictionary dictionary: NSDictionary) {
        height = dictionary["height"] as? Int
        htmlAttributions = dictionary["html_attributions"] as? [String]
        photoReference = dictionary["photo_reference"] as? String
        width = dictionary["width"] as? Int
    }

    /**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
    func toDictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        if height != nil {
            dictionary["height"] = height
        }
        if htmlAttributions != nil {
            dictionary["html_attributions"] = htmlAttributions
        }
        if photoReference != nil {
            dictionary["photo_reference"] = photoReference
        }
        if width != nil {
            dictionary["width"] = width
        }
        return dictionary
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder) {
        height = aDecoder.decodeObject(forKey: "height") as? Int
        htmlAttributions = aDecoder.decodeObject(forKey: "html_attributions") as? [String]
        photoReference = aDecoder.decodeObject(forKey: "photo_reference") as? String
        width = aDecoder.decodeObject(forKey: "width") as? Int

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encodeWithCoder(aCoder: NSCoder) {
        if height != nil {
            aCoder.encode(height, forKey: "height")
        }
        if htmlAttributions != nil {
            aCoder.encode(htmlAttributions, forKey: "html_attributions")
        }
        if photoReference != nil {
            aCoder.encode(photoReference, forKey: "photo_reference")
        }
        if width != nil {
            aCoder.encode(width, forKey: "width")
        }

    }

}
