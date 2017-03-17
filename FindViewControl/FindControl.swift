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

    public init(viewController: UIViewController, googleAPIKey:String, useGooglePlaces: Bool, filterArray: [FilterObject], gisURL: String, googlePlacesKey: String, defaultLattitude: Double, defaultLongitude: Double, defaultAddress: String) {
        GMSServices.provideAPIKey(googleAPIKey)
        let frameworkBundleId = "org.cocoapods.FindViewControl"
        let bundle = Bundle(identifier: frameworkBundleId)
        findView = bundle?.loadNibNamed("FindView", owner: viewController, options: nil)![0] as! FindView
        findView.frame = viewController.view.frame
        findView.parentViewController = viewController
        findView.useGooglePlaces = useGooglePlaces
        findView.filterArray = filterArray
        findView.gisURL = gisURL
        findView.defaultLattitude = defaultLattitude
        findView.defaultLongitude = defaultLongitude
        findView.defaultAddress = defaultAddress
        findView.googlePlacesAPIKey = googlePlacesKey
        findView.isInitialCall = true
        viewController.view.addSubview(findView)

    }

}

