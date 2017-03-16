//
//  FindView.swift
//  FindViewControl
//
//  Created by Krutika Mac Mini on 3/8/17.
//  Copyright © 2017 Kahuna. All rights reserved.
//

import UIKit
import GoogleMaps
import MBProgressHUD

class FindView: UIView, UITextFieldDelegate, FindFilterTableViewControllerDelegate, GMSMapViewDelegate, FindHTTPRequestDelegate, FindMultipleLocationViewControllerDelegate {
    var parentViewController: UIViewController?
    var filterArray: [FilterObject]!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var useCurrentLocButton: UIButton!
    var useGooglePlaces: Bool!
    var gisURL: String!
    var infoWindowView: InfoWindowView!
    var infoWindowTable: UITableView!
    var currentLocationMarker: GMSMarker!
    var selectedLocation: String!
    var isUseCurrentLocationClicked = false
    var isInitialLoading = false
    var gisAddressResultArray: NSMutableArray!
    var serviceRequestType: String!
    var selectedLocationInfoDict: FindResult!
    var pinLocationType: String!
    var selectedFiltersArray: [FilterObject]!
    var markerIndex: Int! = 0
    var radiusOfEarth: Double = 6371
    let searchRadius: Double = 1000
    var placesArray: [PlacesObject]! = [PlacesObject]()
    var selectedPlace: PlacesObject!
    var googlePlacesAPIKey: String!
    var defaultLattitude: Double!
    var defaultLongitude: Double!
    var defaultAddress: String!
    var isInitialCall: Bool!
    var prevSelectedMarker: GMSMarker!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setNeedsDisplay()
        //Setting notification to get current location

    }

    override func layoutSubviews() {
        if isInitialCall == true {
            isInitialCall = false
            NotificationCenter.default.addObserver(self, selector: #selector(locationFound(notify:)), name: NSNotification.Name(rawValue: "LocationFound"), object: nil)
            self.goButton.setTitle("goText".localized, for: UIControlState.normal)

            self.useCurrentLocButton.setTitle("useCurrentLocation".localized, for: UIControlState.normal)
            prevSelectedMarker = nil
            if selectedFiltersArray == nil {
                self.selectedFiltersArray = [FilterObject]()
                self.selectedFiltersArray.append(contentsOf: filterArray)
            }

            if CLLocationManager.locationServicesEnabled() == true && CLLocationManager.authorizationStatus() != CLAuthorizationStatus.denied {
                self.getCurrentLocationIntitally()
            }
                else {
                self.setUpView()
            }

        }


    }

    //MARK:- Initializing View

    func setUpView() {

        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud?.labelText = "gatheringLocInfoHudTitle".localized

        self.setPaddingToTextField(textField: self.searchTextField, padding: 5)
        self.setUpGoogleMap()

        // check current location
        if(self.selectedLocationInfoDict != nil) {
            if((Double(self.selectedLocationInfoDict.geometry.location.lat) != 0) && (Double(self.selectedLocationInfoDict.geometry.location.lng) != 0)) {
                let mapLocation = CLLocationCoordinate2D(
                                                         latitude: Double(self.selectedLocationInfoDict.geometry.location.lat),
                                                         longitude: Double(self.selectedLocationInfoDict.geometry.location.lng))
                self.currentLocationMarker.position = mapLocation
                self.searchTextField.text = self.selectedLocationInfoDict.formattedAddress
                self.pinLocationType = FindConstants.pinDragDropViewConstants.kCurrentLocationPinType

            }
        }

        if(self.pinLocationType == FindConstants.pinDragDropViewConstants.kCurrentLocationPinType) {
            self.currentLocationMarker.title = "currentLocationText".localized
        }
            else if(self.pinLocationType == FindConstants.pinDragDropViewConstants.kDefaultLocationType) {
            self.currentLocationMarker.title = "defaultLocationText".localized
        }
            else if(self.pinLocationType == FindConstants.pinDragDropViewConstants.kCacheLocationType) {
            self.currentLocationMarker.title = "cacheLocationText".localized
        }

        self.currentLocationMarker.snippet = self.addressStringForLocationType()
        self.currentLocationMarker.isDraggable = false
        self.currentLocationMarker.map = self.mapView

    }

    func addressStringForLocationType() -> (String) {
        var address = ""
        print(self.pinLocationType)
        if(self.pinLocationType == FindConstants.pinDragDropViewConstants.kDefaultLocationType) {
            address = defaultAddress

        }
            else if(self.pinLocationType == FindConstants.pinDragDropViewConstants.kCacheLocationType) {
            let userDefault = UserDefaults.standard
            if(userDefault.object(forKey: FindConstants.UniqueKeyConstants.GMSAddressKey) != nil) {
                address = userDefault.object(forKey: FindConstants.UniqueKeyConstants.GMSAddressKey) as! String
            }
        }
            else if(self.pinLocationType == FindConstants.pinDragDropViewConstants.kCurrentLocationPinType) {
            if(self.selectedLocationInfoDict != nil) {
                address = self.selectedLocationInfoDict.formattedAddress
            }
        }
        return address
    }


    func setUpGoogleMap() {
        let userDefault = UserDefaults.standard
        var latitude = defaultLattitude
        var longitude = defaultLongitude
        var addressString = defaultAddress
        self.pinLocationType = FindConstants.pinDragDropViewConstants.kDefaultLocationType
        if (userDefault.object(forKey: FindConstants.UniqueKeyConstants.GMSLatitudeKey) != nil) && (userDefault.object(forKey: FindConstants.UniqueKeyConstants.GMSLongitudeKey) != nil) && (userDefault.object(forKey: FindConstants.UniqueKeyConstants.GMSAddressKey) != nil) {
            latitude = userDefault.object(forKey: FindConstants.UniqueKeyConstants.GMSLatitudeKey) as? Double
            longitude = userDefault.object(forKey: FindConstants.UniqueKeyConstants.GMSLongitudeKey) as? Double
            addressString = userDefault.object(forKey: FindConstants.UniqueKeyConstants.GMSAddressKey) as? String
            self.pinLocationType = FindConstants.pinDragDropViewConstants.kCacheLocationType
        }
        let position = CLLocationCoordinate2DMake(latitude!, longitude!)
        self.addMarkerOnMap(location: position, address: addressString!)

        MBProgressHUD.hide(for: self, animated: true)

    }


    func setPaddingToTextField(textField: UITextField, padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = UITextFieldViewMode.always
    }

    func addMarkerOnMap(location: CLLocationCoordinate2D, address: String) {

        let cameraPosition = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: FindConstants.DefaultValues.mapZoom)
        self.mapView.camera = cameraPosition
        self.mapView.delegate = self
        self.mapView.isMyLocationEnabled = true


        self.mapView.clear()
        self.placesArray = [PlacesObject]()
        if(self.currentLocationMarker != nil) {
            self.currentLocationMarker.map = nil
        }
        self.currentLocationMarker = GMSMarker(position: location)

        if(self.pinLocationType == FindConstants.pinDragDropViewConstants.kCurrentLocationPinType) {
            self.currentLocationMarker.title = "currentLocationText".localized
        }
            else if(self.pinLocationType == FindConstants.pinDragDropViewConstants.kDefaultLocationType) {
            self.currentLocationMarker.title = "defaultLocationText".localized
        }
            else if(self.pinLocationType == FindConstants.pinDragDropViewConstants.kCacheLocationType) {
            self.currentLocationMarker.title = "cacheLocationText".localized
        }

        self.currentLocationMarker.snippet = address
        self.currentLocationMarker.isDraggable = false
        self.currentLocationMarker.map = self.mapView
        let zoomLevel = self.mapView.camera.zoom
        let position = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: zoomLevel)
        self.mapView.camera = position
        markerIndex = 0
        self.searchTextField.text = address
        if self.selectedFiltersArray.count > 0 && FindCheckConnectivitySwift.hasConnectivity() {
            if self.useGooglePlaces == true {
                self.perform(#selector(self.queryGooglePlaces), with: "", afterDelay: 0.1)
            }
        }
    }


    //MARK:- Loading & Validating Location

    /**
     When no address is cached then get current location not called in case of previous selected sr
     */
    func getCurrentLocationIntitally() {
        self.isInitialLoading = true
        self.myLocationButtonClick(sender: UIButton())
    }

    //MARK:- My Current location Button Click
    @IBAction func myLocationButtonClick(sender: AnyObject) {

        if self.infoWindowView != nil && self.infoWindowView.superview != nil {
            self.infoWindowView.removeFromSuperview()
        }

        self.searchTextField.resignFirstResponder()
        if(FindCheckConnectivitySwift.hasConnectivity()) {
            if (CLLocationManager.locationServicesEnabled() == false || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied) {
                if(!self.isInitialLoading) {
                    self.isInitialLoading = false
                    self.displayAlert(title: "locServiceDisabledMsg".localized, message: "gpsDisabledMsg".localized)
                }
            }
                else {
                //self.searchTextField.text = ""
                let hud = MBProgressHUD.showAdded(to: self, animated: true)
                hud?.labelText = "gatheringLocInfoHudTitle".localized
                FindPSLocationManager.shared().startLocationUpdates()
                self.isUseCurrentLocationClicked = true
            }
        }
            else {
            let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
            let errorMsg = appName + ", " + "networkconnectionMsg".localized

            let alertView = UIAlertController(title: "networkErrorTitle".localized, message: errorMsg, preferredStyle: UIAlertControllerStyle.alert)

            let action = UIAlertAction(title: "OKButtonLabel".localized, style: .default)
            {
                UIAlertAction in
                if self.isInitialLoading == true
                {
                    self.isInitialLoading = false
                    self.setUpView()
                }
            }
            alertView.addAction(action)
            parentViewController?.present(alertView, animated: true, completion: nil)
        }
    }


    /**
     current location notification method called when notification is received
     */

    func locationFound(notify: NSNotification) {

        FindPSLocationManager.shared().stopLocationUpdates()
        if self.isUseCurrentLocationClicked == true {
            self.isUseCurrentLocationClicked = false
            var isError = false
            if (notify.userInfo != nil) {
                if (notify.userInfo!["GPSError"] != nil)
                {
                    isError = true
                    MBProgressHUD.hideAllHUDs(for: self, animated: true)
                    let error = notify.userInfo!["GPSError"]
                    self.handleGPSError(code: CLError(_nsError: error as! NSError))
                    self.isInitialLoading = false
                    self.selectedLocation = ""
                    self.selectedLocationInfoDict = nil

                }
            }
            if isError == false {
                MBProgressHUD.hideAllHUDs(for: self, animated: true)
                let currentLocation = FindPSLocationManager.shared().currentLocation
                self.selectedLocation = ""
                self.selectedLocationInfoDict = nil
                let position = CLLocationCoordinate2DMake((currentLocation?.coordinate.latitude)!, (currentLocation?.coordinate.longitude)!)
                self.pinLocationType = FindConstants.pinDragDropViewConstants.kCurrentLocationPinType

                self.callForCoOrdinateLocation(location: position)
            }
        }
    }

    //MARK:- Location Manager Delegates
    func locationManagerStatus(status: NSString) {
        print(status)
    }
    func locationManagerReceivedError(error: NSString) {
        print(error)
    }
    func locationFoundGetAsString(latitude: NSString, longitude: NSString) {
        print(latitude)
    }
    func locationFound(latitude: Double, longitude: Double) {
        print(latitude)
    }


    func handleGPSError(code: CLError) {
        switch code {
        case CLError.network: // general, network-related error
            if self.isInitialLoading == false {
                self.displayAlert(title: "gpsErrorTitle".localized, message: "gpsAeroplaneModeMsg".localized)
            }
            break;

        default:
            if(!self.isInitialLoading) {
                self.displayAlert(title: "gpsErrorTitle".localized, message: "gpsErrorMsg".localized)
            }
            break;
        }

        if self.isInitialLoading == true {
            self.isInitialLoading = false
            self.setUpView()
        }


    }

    func setCurrentLocationDetails() {

        if self.currentLocationMarker != nil {
            self.saveValidLocationDetails()
        }
    }

    func saveValidLocationDetails() {

        let userDefault = UserDefaults.standard
        userDefault.set(self.currentLocationMarker.position.latitude, forKey: FindConstants.UniqueKeyConstants.GMSLatitudeKey)
        userDefault.set(self.currentLocationMarker.position.longitude, forKey: FindConstants.UniqueKeyConstants.GMSLongitudeKey)
        userDefault.set(self.selectedLocation, forKey: FindConstants.UniqueKeyConstants.GMSAddressKey)
        userDefault.synchronize()
    }

    //MARK: -  TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let searchText = self.searchTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if((searchText?.characters.count)! > 0) {
            self.searchLocationAddress(address: searchText!)
        }

        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.selectedLocationInfoDict = nil
        return true
    }

    func searchLocationAddress(address: String) {

        if(FindCheckConnectivitySwift.hasConnectivity()) {
            MBProgressHUD.showAdded(to: self, animated: true)
            self.selectedLocation = ""
            self.serviceRequestType = FindConstants.pinDragDropViewConstants.serviceReqTypeGeoAddress
            self.getDisplayLocationInfoForAddress(address: address)
        }
            else {

            let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
            let errorMsg = appName + ", " + "networkconnectionMsg".localized
            self.displayAlert(title: "networkErrorTitle".localized, message: errorMsg)
        }
    }


    // MARK:- Search address
    @IBAction func addressSearchGoButtonClick(sender: AnyObject) {
        if self.infoWindowView != nil && self.infoWindowView.superview != nil {
            self.infoWindowView.removeFromSuperview()
        }

        let searchText = self.searchTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if((searchText?.characters.count)! > 0) {
            self.callForAddressLocation(addressString: self.searchTextField.text!)
        }
            else {
            self.displayAlert(title: "enterLocEmptyMsg".localized, message: "")
        }
    }

    func callForCoOrdinateLocation(location: CLLocationCoordinate2D) {
        if(FindCheckConnectivitySwift.hasConnectivity()) {
            let hud = MBProgressHUD.showAdded(to: self, animated: true)
            hud?.labelText = "gatheringLocInfoHudTitle".localized
            let location = location
            self.selectedLocation = ""
            self.serviceRequestType = FindConstants.pinDragDropViewConstants.serviceReqTypeGeoCordinate
            self.getDisplayLocationInfoForCoOrdinate(Location: location)
        } else {
            let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
            let errorMsg = appName + ", " + "networkconnectionMsg".localized
            let alertView = UIAlertController(title: "networkErrorTitle".localized, message: errorMsg, preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "OKButtonLabel".localized, style: .default) {
                UIAlertAction in
                if self.isInitialLoading == true {
                    self.isInitialLoading = false
                    self.setUpView()
                }
            }
            alertView.addAction(action)
            parentViewController?.present(alertView, animated: true, completion: nil)
        }
    }

    func callForAddressLocation(addressString: String) {

        self.searchTextField.resignFirstResponder()
        if(FindCheckConnectivitySwift.hasConnectivity()) {
            let hud = MBProgressHUD.showAdded(to: self, animated: true)
            hud?.labelText = "gatheringLocInfoHudTitle".localized
            // call GIS service for address
            //let addressString = self.searchTextField.text! as String
            self.selectedLocation = ""
            self.serviceRequestType = FindConstants.pinDragDropViewConstants.serviceReqTypeGeoAddress
            self.getDisplayLocationInfoForAddress(address: addressString)
        }
            else {

            let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
            let errorMsg = appName + " ," + "networkconnectionMsg".localized
            self.displayAlert(title: "networkErrorTitle".localized, message: errorMsg)
        }
    }

    /**
     call GIS service for co-ordinates when user drag drop the pin
     */

    func getDisplayLocationInfoForCoOrdinate(Location: CLLocationCoordinate2D) {
        if FindCheckConnectivitySwift.hasConnectivity() {
            // call coordinate search service
            let coOrdinateRequestObj = GISAddressSearchRequest()
            coOrdinateRequestObj.latitude = Float(Location.latitude)
            coOrdinateRequestObj.longitude = Float(Location.longitude)
            coOrdinateRequestObj.requestType = self.serviceRequestType
            self.getMatchesForCurrentLocation(coOrdinateSearchReq: coOrdinateRequestObj)

        }
            else {
            let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
            let errorMsg = appName + ", " + "networkconnectionMsg".localized

            let alertView = UIAlertController(title: "networkErrorTitle".localized, message: errorMsg, preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "OKButtonLabel".localized, style: .cancel) {
                UIAlertAction in
                if self.isInitialLoading == true
                {
                    self.isInitialLoading = false
                    self.setUpView()
                }
            }

            alertView.addAction(cancelAction)
            parentViewController?.present(alertView, animated: true, completion: nil)
        }
    }

    /**
     call GIS service for address when user enters address in search field
     */
    func getDisplayLocationInfoForAddress(address: String) {
        if FindCheckConnectivitySwift.hasConnectivity() {
            // call coordinate search service
            let addressRequestObj = GISAddressSearchRequest()
            addressRequestObj.address = address
            print(self.serviceRequestType)
            addressRequestObj.requestType = self.serviceRequestType
            self.getMatchesForCurrentLocation(coOrdinateSearchReq: addressRequestObj)

        }
            else {
            let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
            let errorMsg = appName + ", " + "networkconnectionMsg".localized
            self.displayAlert(title: "networkErrorTitle".localized, message: errorMsg)
        }
    }


    // MARK:- Filter Button action
    @IBAction func filtersButton_Clicked() {
        if parentViewController?.menuContainerViewController != nil {
            let frameworkBundleId = "com.kahuna.FindViewControl"
            let bundle = Bundle(identifier: frameworkBundleId)
            let viewController = bundle?.loadNibNamed("FindFilterTableViewController", owner: self, options: nil)![0] as! FindFilterTableViewController
            viewController.selectedFiltersArray = [FilterObject]()
            viewController.selectedFiltersArray.append(contentsOf: selectedFiltersArray)
            viewController.filterArray = [FilterObject]()
            viewController.filterArray.append(contentsOf: filterArray)
            viewController.delegate = self
            let nav = UINavigationController(rootViewController: viewController)
            nav.navigationBar.barStyle = UIBarStyle.black

            parentViewController?.menuContainerViewController.rightMenuViewController = nav
            parentViewController?.menuContainerViewController.toggleRightSideMenuCompletion(nil)
        }


    }

    //MARK:- Filter Delegate
    func filtersTableViewController(selectedFilters: [FilterObject]) {
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud?.labelText = "gatheringLocInfoHudTitle".localized

        markerIndex = 0

        if self.infoWindowView != nil && self.infoWindowView.superview != nil {
            self.infoWindowView.removeFromSuperview()
        }
        self.mapView.clear()
        self.placesArray = [PlacesObject]()
        self.currentLocationMarker.map = self.mapView

        self.selectedFiltersArray.removeAll()
        selectedFiltersArray = [FilterObject]()
        self.selectedFiltersArray.append(contentsOf: selectedFilters)
        if self.selectedFiltersArray.count > 0 {
            if self.useGooglePlaces == true {
                self.queryGooglePlaces(nextPageToken: "")
            }
        }
            else {
            MBProgressHUD.hideAllHUDs(for: self, animated: true)
        }

        self.setMapCenter()

    }

    //MARK:- Set Map Center
    func setMapCenter() {

        let zoomLevel = self.mapView.camera.zoom
        let position = GMSCameraPosition.camera(withLatitude: self.currentLocationMarker.position.latitude, longitude: self.currentLocationMarker.position.longitude, zoom: zoomLevel)
        self.mapView.camera = position

    }

    //MARK:- Call Google Places API
    func queryGooglePlaces (nextPageToken: String) {
        var url = ""
        if nextPageToken == "" {
            var type = ""
            for filterObj in selectedFiltersArray {
                if type == "" {
                    type = filterObj.filterID
                }
                    else
                {
                    type = type + "|" + filterObj.filterID
                }
            }

            url = "\(FindConstants.findConstants.kGooglePlacesUrl)location=\(self.currentLocationMarker.position.latitude),\(self.currentLocationMarker.position.longitude)&radius=\(self.radiusOfEarth)&types=\(type)&sensor=true&key=\(googlePlacesAPIKey!)"

        }
            else {
            url = "\(FindConstants.findConstants.kGooglePlacesUrl)pagetoken=\(nextPageToken)&key=\(googlePlacesAPIKey)"
        }

        let customAllowedSet = NSCharacterSet(charactersIn: "|").inverted
        let escapedString = url.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        print("URL : \(escapedString)")

        if(FindCheckConnectivitySwift.hasConnectivity()) {
            if let googleRequestURL = NSURL(string: escapedString!) {

                if let data = NSData(contentsOf: googleRequestURL as URL) {
                    self.fetchedData(responseData: data)
                }
                    else {
                    self.displayAlert(title: "unableFindPlacesTitle".localized, message: "")
                    MBProgressHUD.hideAllHUDs(for: self, animated: true)
                }
            }
                else {
                self.displayAlert(title: "unableFindPlacesTitle".localized, message: "")
                MBProgressHUD.hideAllHUDs(for: self, animated: true)
            }
        }
            else {
            MBProgressHUD.hideAllHUDs(for: self, animated: true)

            let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
            let errorMsg = appName + ", " + "networkconnectionMsg".localized
            self.displayAlert(title: "networkErrorTitle".localized, message: errorMsg)
        }
    }

    //MARK:- Verify Google Places API Response

    func fetchedData(responseData: NSData) {
        var isQueryComplete = false

        do {
            let jsonResult: NSDictionary! = try JSONSerialization.jsonObject(with: responseData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary

            print("Places Response:- \(jsonResult)")

            if (jsonResult != nil) {

                MBProgressHUD.hideAllHUDs(for: self, animated: true)

                let placesResp = PlacesAPIResponseModel (fromDictionary: jsonResult as NSDictionary)

                isQueryComplete = true
                if placesResp.results != nil && placesResp.results.count > 0 {
                    placesArray.append(contentsOf: placesResp.results)
                }
                    else {
                    self.displayAlert(title: "noPlacesFoundTitle".localized, message: "")
                }

            }
                else {
                if placesArray.count > 0 {
                    isQueryComplete = true
                }
                    else {
                    self.displayAlert(title: "unableFindPlacesTitle".localized, message: "")
                }
                MBProgressHUD.hideAllHUDs(for: self, animated: true)
            }
        }
        catch {
            print("Something went wrong!")

            if(placesArray.count > 0) {
                isQueryComplete = true
            }
                else {
                self.displayAlert(title: "unableFindPlacesTitle".localized, message: "")
            }

            MBProgressHUD.hideAllHUDs(for: self, animated: true)
        }

        if isQueryComplete == true {
            isQueryComplete = false
            if(FindCheckConnectivitySwift.hasConnectivity()) {
                self.addPlacesMarker()
            }
                else {
                MBProgressHUD.hideAllHUDs(for: self, animated: true)

                let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
                let errorMsg = appName + ", " + "networkconnectionMsg".localized
                self.displayAlert(title: "networkErrorTitle".localized, message: errorMsg)
            }
        }
    }

    //MARK:- Add places marker on map
    func addPlacesMarker() {

        markerIndex = 0
        self.mapView.clear()
        self.currentLocationMarker.map = self.mapView
        var bounds = GMSCoordinateBounds()
        self.currentLocationMarker.map = self.mapView
        bounds = bounds.includingCoordinate(self.currentLocationMarker.position)

        for placeObj in placesArray {
            let markerOptions1 = GMSMarker()
            markerOptions1.position = CLLocationCoordinate2DMake(Double(placeObj.geometry.location.lat), Double(placeObj.geometry.location.lng))

            if(placeObj.icon != nil && placeObj.icon.characters.count > 0) {
                let url = NSURL(string: placeObj.icon)
                let data = NSData(contentsOf: url! as URL)
                markerOptions1.icon = UIImage(data: data! as Data, scale: 2.0)
            }

            markerOptions1.infoWindowAnchor = CGPoint(x: 0.5, y: 0.25)
            markerOptions1.groundAnchor = CGPoint(x: 0.5, y: 1.0)

            /*      if placeObj.name != nil {
                var titleStr = placeObj.name.capitalized

                if placeObj.name.characters.count > 20
                {
                    titleStr = (placeObj.name as NSString).substring(to: 20).capitalized
                    titleStr = titleStr.appending("...")
                }

                let charCode = UInt32("000027A1", radix: 16)
                let str: String? = String(describing: UnicodeScalar(charCode!))
                markerOptions1.title = String(format: "%@ \(str!)", titleStr)

            }
                else {
                markerOptions1.title = "N/A"
            } */

            markerOptions1.accessibilityLabel = String(format: "%d", markerIndex)
            markerOptions1.map = self.mapView
            markerIndex = markerIndex + 1
            bounds = bounds.includingCoordinate(markerOptions1.position)
        }
        self.setMapCenter()
        self.mapView.animate(with: GMSCameraUpdate.fit(bounds))
    }

    //MARK:- GMSMapView delegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {

    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.endEditing(true)
        if marker != self.currentLocationMarker {
            if self.placesArray.count > Int(marker.accessibilityLabel!)! {
                if prevSelectedMarker != nil && self.selectedPlace != nil{
                    if(self.selectedPlace.icon != nil && self.selectedPlace.icon.characters.count > 0) {
                        let url = NSURL(string: self.selectedPlace.icon)
                        let data = NSData(contentsOf: url! as URL)
                        prevSelectedMarker.icon = UIImage(data: data! as Data, scale: 2.0)
                    }

                }

                self.selectedPlace = self.placesArray[Int(marker.accessibilityLabel!)!]
                if(self.selectedPlace.icon != nil && self.selectedPlace.icon.characters.count > 0) {
                    let url = NSURL(string: self.selectedPlace.icon)
                    let data = NSData(contentsOf: url! as URL)
                    marker.icon = UIImage(data: data! as Data, scale: 1.0)
                }
                prevSelectedMarker = marker
                if infoWindowView != nil {
                    infoWindowView.removeFromSuperview()
                }
                let frameworkBundleId = "com.kahuna.FindViewControl"
                let bundle = Bundle(identifier: frameworkBundleId)
                infoWindowView = bundle?.loadNibNamed("InfoWindowView", owner: self, options: nil)![0] as? InfoWindowView
                infoWindowView.frame = CGRect(x: 0, y: self.frame.size.height - 100, width: self.frame.size.width, height: 100)
                infoWindowView.nameLabel.text = self.selectedPlace.name
                infoWindowView.addressLabel.text = self.selectedPlace.vicinity
                infoWindowView.getDirectionsButton.addTarget(self, action: #selector(self.onGetDirectionButtonClick(sender:)), for: UIControlEvents.touchUpInside)

                self.setUpInfoView()

            }
                else {
                self.selectedPlace = nil
            }

        }

        return false
    }


    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {

    }


    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if self.infoWindowView != nil {
            self.hideInfoView(value: self.frame.size.height)
        }
    }


    // MARK: - Setup Info window
    func setUpInfoView() {

        UIView.animate(withDuration: 0.0,
                       delay: 0.0,
                       options: .transitionCurlUp,
                       animations: {
            self.infoWindowView.frame = CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 119)
        },
                       completion: { finished in
            self.addSubview(self.infoWindowView)
            UIView.animate(withDuration: 0.3,
                           delay: 0.0,
                           options: .transitionCurlDown,
                           animations: {
                self.infoWindowView.frame = CGRect(x: 0, y: self.frame.size.height - 119, width: self.frame.size.width, height: 119)
            },
                           completion: { finished in
            })
        })
    }

    // MARK: - Inde info window
    func hideInfoView(value: CGFloat) {

        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .transitionCurlUp,
                       animations: {
            self.infoWindowView.frame = CGRect(x: 0, y: value, width: self.frame.size.width, height: 119)
        },
                       completion: { finished in
            if self.infoWindowView != nil {
                self.infoWindowView.removeFromSuperview()
            }
        })
    }

    @IBAction func onGetDirectionButtonClick(sender: AnyObject) {
        let http = "http://maps.apple.com/?saddr=\(self.currentLocationMarker.position.latitude),\(self.currentLocationMarker.position.longitude)&daddr=\(self.selectedPlace.geometry.location.lat!),\(self.self.selectedPlace.geometry.location.lng!)"
        UIApplication.shared.openURL(NSURL(string: http)! as URL)

    }

    //MARK:- Display Alert
    func displayAlert (title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OKButtonLabel".localized, style: .default, handler: nil)
        alertView.addAction(action)
        parentViewController?.present(alertView, animated: true, completion: nil)

    }

    //Mark: fetch address from co-ordinates
    func getMatchesForCurrentLocation(coOrdinateSearchReq: GISAddressSearchRequest) {
        let requestParameters = coOrdinateSearchReq.toDictionary()
        let requestHandler = FindHTTPRequest.sharedInstance
        requestHandler.delegate = self
        requestHandler.sendRequestAtPath(gisURL, withParameters: requestParameters as? [String: AnyObject], timeoutInterval: Constants.TimeOutIntervals.kSRTimeoutInterval)
    }

    // MARK: -  CONFIRMING HTTP REQUEST DELEGATE
    func httpRequest(_ requestHandler: FindHTTPRequest, requestCompletedWithResponseJsonObject jsonObject: AnyObject, forPath path: String) {
        self.handleGISResponse(jsonObject: jsonObject)

    }

    func httpRequest(_ requestHandler: FindHTTPRequest, requestFailedWithError failureError: Error, forPath path: String) {

        MBProgressHUD.hideAllHUDs(for: self, animated: true)
        let intCode = failureError._code
        let errorMessage = String(format: "%@ - %d", failureError._domain, intCode)
        self.selectedLocation = ""
        self.selectedLocationInfoDict = nil
        let alertView = UIAlertController(title: "", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "OKButtonLabel".localized, style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            if self.isInitialLoading == true {
                self.isInitialLoading = false
                self.setUpView()
            }
        }
        alertView.addAction(cancelAction)
        parentViewController?.present(alertView, animated: true, completion: nil)

    }

    func handleGISResponse(jsonObject: AnyObject) {
        MBProgressHUD.hideAllHUDs(for: self, animated: true)
        let gisResponse = FindGISAddressSearchResponse(fromDictionary: jsonObject as! NSDictionary)
        if gisResponse.status == nil {
            MBProgressHUD.hide(for: self, animated: true)
            if self.isInitialLoading == true {
                self.isInitialLoading = false
                self.setUpView()
            }
            return
        }

        if gisResponse.status.code == FindConstants.ServerResponseCodes.successCode {
            print(gisResponse.response.results)
            let resultsArray = gisResponse.response.results
            if((resultsArray?.count)! > 0) {
                self.gisAddressResultArray = NSMutableArray(array: resultsArray!)
                if((resultsArray?.count)! > 1) {
                    let frameworkBundleId = "com.kahuna.FindViewControl"
                    let bundle = Bundle(identifier: frameworkBundleId)
                    let multipleLocationObj = bundle?.loadNibNamed("FindMultipleLocationSelectionViewController", owner: self, options: nil)![0] as! FindMultipleLocationSelectionViewController
                    multipleLocationObj.setLocaArray(locArray: self.gisAddressResultArray)
                    multipleLocationObj.delegate = self
                    multipleLocationObj.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
                    parentViewController?.present(multipleLocationObj, animated: true, completion: nil)
                } else {
                    let dataDict = self.gisAddressResultArray.object(at: 0) as! FindResult
                    self.selectedLocation = dataDict.formattedAddress
                    let tempdict = dataDict.geometry.location
                    let mapLocation = CLLocationCoordinate2D(
                                                             latitude: Double(((tempdict?.lat)! as Float)),
                                                             longitude: Double(((tempdict?.lng)! as Float))
                    )
                    self.searchTextField.text = self.selectedLocation
                    self.selectedLocationInfoDict = dataDict
                    self.pinLocationType = FindConstants.pinDragDropViewConstants.kCurrentLocationPinType
                    self.addMarkerOnMap(location: mapLocation, address: self.selectedLocation)
                    self.setCurrentLocationDetails()
                }
            }
        } else {
            let errorMessage = gisResponse.status.message
            let message = String(format: "%@%d", "errorCodeTitle".localized, gisResponse.status.code)
            let alertView = UIAlertController(title: errorMessage, message: message, preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "OKButtonLabel".localized, style: UIAlertActionStyle.cancel) {
                UIAlertAction in
                if self.isInitialLoading == true
                {
                    self.isInitialLoading = false
                    self.setUpView()
                }
            }
            alertView.addAction(cancelAction)
            parentViewController?.present(alertView, animated: true, completion: nil)
        }
    }

    //MARK: Multiple Location Delegate
    func locationSelectedFromMultipleLocation(selectedLocationAddress selectedLocationAddressDictionary: FindResult) {
        //Call Service to check if the address is inside nagpur
        self.selectedLocationInfoDict = selectedLocationAddressDictionary
        self.selectedLocation = self.selectedLocationInfoDict.formattedAddress
        self.searchTextField.text = self.selectedLocation
        let tempdict = self.selectedLocationInfoDict.geometry.location
        let mapLocation = CLLocationCoordinate2D(
                                                 latitude: Double(((tempdict?.lat)! as Float)),
                                                 longitude: Double(((tempdict?.lng)! as Float))
        )
        self.addMarkerOnMap(location: mapLocation, address: self.selectedLocation)
        self.pinLocationType = FindConstants.pinDragDropViewConstants.kCurrentLocationPinType
        self.setCurrentLocationDetails()
    }



}

extension String {
    var localized: String {
        let frameworkBundleId = "com.kahuna.FindViewControl"
        let bundle = Bundle(identifier: frameworkBundleId)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
