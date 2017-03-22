//
//  FindControl.swift
//  FindViewControl
//
//  Created by Krutika Mac Mini on 3/8/17.
//  Copyright © 2017 Kahuna. All rights reserved.
//

import UIKit
import GoogleMaps

public class FindControl {

    var findView: FindView!
    var viewController: UIViewController!

    //=================================================
    /** Initializing Find View
     * @param viewController for which the nib has to be loaded
     * @param googleAPIKey app related google maps API key
     * @param useGooglePlaces true if you want to load google places, false if you want to display places from DB
     * @param filterArray send list of filters in case when useGooglePlaces is true , else send empty array [FilterObject]()
     * @param gisURL URL to validate GIS location
     * @param googleAPIKey send app sepcific google places key when useGooglePlaces is true , else send empty string
     * @param defaultLattitude default value of latitude
     * @param defaultLongitude default value of Longitude
     * @param defaultAddress default value of address
     * @param individualMarkersCount send max value to displays individual markers when all filterd are selected when useGooglePlaces is flase.
     */
    //=================================================
    public init(viewController: UIViewController, googleAPIKey:String, useGooglePlaces: Bool, filterArray: [FilterObject], gisURL: String, googlePlacesKey: String, defaultLattitude: Double, defaultLongitude: Double, defaultAddress: String, individualMarkersCount: Int) {
        GMSServices.provideAPIKey(googleAPIKey)
        let bundle = Bundle(identifier: FindConstants.findBundleID)
        findView = bundle?.loadNibNamed("FindView", owner: viewController, options: nil)![0] as! FindView
        findView.frame = viewController.view.frame
        findView.parentViewController = viewController
        findView.useGooglePlaces = useGooglePlaces
        if filterArray != nil {
            findView.filterArray = filterArray
        }
        findView.gisURL = gisURL
        findView.defaultLattitude = defaultLattitude
        findView.defaultLongitude = defaultLongitude
        findView.defaultAddress = defaultAddress
        findView.googlePlacesAPIKey = googlePlacesKey
        findView.isInitialCall = true
        findView.individualMarkersCount = individualMarkersCount
        viewController.view.addSubview(findView)

    }

}

