# FindViewControl

![LogCamp](http://www.kahuna-mobihub.com/templates/ja_puresite/images/logo-trans.png)

FindViewControl is written in Swift

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. 

```ruby
pod 'FindViewControl', :git => 'https://github.com/Kruks/FindViewControl.git', :tag => '1.0.10'
```

## Add FindViewControl To Project

### Swift Code:

```swift
(Add this code in viewdidload for viewcontroller)
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

\\ Init Find Control

 _ =  FindControl.init(viewController: self,googleAPIKey: "AIzXXXXXXXXXXXXXXXXXX8sk",useGooglePlaces: true, filterArray: pickerArray, gisURL: "GIS validation URl", googlePlacesKey: "AIzaXXXXXXXXXXXXXXXXXXFFMc", defaultLattitude: 34.052235, defaultLongitude: -118.243683, defaultAddress: "test")
 
```

