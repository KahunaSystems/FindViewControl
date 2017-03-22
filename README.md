# FindViewControl

![LogCamp](http://www.kahuna-mobihub.com/templates/ja_puresite/images/logo-trans.png)

FindViewControl is written in Swift

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. 

```ruby
pod 'FindViewControl', :git => 'https://github.com/Kruks/FindViewControl.git', :tag => '1.0.12'
```
Also, add below code at the end of the pod file.
```ruby
pre_install do |installer|
    def installer.verify_no_static_framework_transitive_dependencies; end
end
```
## Add FindViewControl To Project

### Initial Setup:
You need to add GoogleMaps framework manually, for that go to "Pods" project, select target "FindViewControl" goto Build Phases in "Link Binary With Libraries" add GoogleMaps.framework from project. Also in Build Settings in "Framework Search Paths", please verify the below two paths are added for both debug & release(If not, add it manually):-
```ruby
"${PODS_ROOT}/GoogleMaps/Base/Frameworks"
"${PODS_ROOT}/GoogleMaps/Maps/Frameworks"
```

### Swift Code to plot places From Places API:

```swift
(Add this code in viewdidload of viewcontroller)
// Initialize Picker for filter

      let pickerArray = [FilterObject]()
        
        let fobj = FilterObject()
        fobj.filterID = "fire_station"
        fobj.filterValue = "FireStation"
        pickerArray.append(fobj)
        
        let fobj1 = FilterObject()
        fobj1.filterID = "gas_station"
        fobj1.filterValue = "gas_station"
        pickerArray.append(fobj1)

// Init Find Control

 _ =  FindControl.init(viewController: self,googleAPIKey: "AIzXXXXXXXXXXXXXXXXXX8sk",useGooglePlaces: true, filterArray: pickerArray, gisURL: "GIS validation URl", googlePlacesKey: "AIzaXXXXXXXXXXXXXXXXXXFFMc", defaultLattitude: 34.052235, defaultLongitude: -118.243683, defaultAddress: "test", individualMarkersCount: 4)
 
```

### Swift Code to plot places From DB:
Add DB with name "NearBy.sqlite" that contains places list. Also, add markers with names of filter(Ex:- Parking Lots.png)for normal icon & for selected icon add "Selected" title with filter name (Ex:- Parking LotsSelected.png).


```swift
(Add this code in viewdidload of viewcontroller)
// Init Find Control

 _ =  FindControl.init(viewController: self, googleAPIKey: "AIzXXXXXXXXXXXXXXXXXX8sk", useGooglePlaces: flase, filterArray: [FilterObject](), gisURL: "GIS validation URl", googlePlacesKey: "", defaultLattitude: 34.052235, defaultLongitude: -118.243683, defaultAddress: "test", individualMarkersCount: 4)
 
```

