//
//  LocationManager.h
//  Faster
//
//  Created by Daniel Isenhower on 1/6/12.
//  daniel@perspecdev.com
//  Copyright (c) 2012 PerspecDev Solutions LLC. All rights reserved.
//
//  For more details, check out the blog post about this here:
//  http://perspecdev.com/blog/2012/02/22/using-corelocation-on-ios-to-track-a-users-distance-and-speed/
//
//  Want to use this code in your app?  Feel free!  I would love it if you would send me a quick email
//  about your project.
//
//
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish, distribute,
//  sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all copies or
//  substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
//  NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class FindPSLocationManager;

typedef enum {
    FindPSLocationManagerGPSSignalStrengthInvalid = 0
    , FindPSLocationManagerGPSSignalStrengthWeak
    , FindPSLocationManagerGPSSignalStrengthStrong
} FindPSLocationManagerGPSSignalStrength;

@protocol FindPSLocationManagerDelegate <NSObject>

@optional
- (void)locationManager:(FindPSLocationManager *)locationManager signalStrengthChanged:(FindPSLocationManagerGPSSignalStrength)signalStrength;
- (void)locationManagerSignalConsistentlyWeak:(FindPSLocationManager *)locationManager;
- (void)locationManager:(FindPSLocationManager *)locationManager distanceUpdated:(CLLocationDistance)distance;
- (void)locationManager:(FindPSLocationManager *)locationManager waypoint:(CLLocation *)waypoint calculatedSpeed:(double)calculatedSpeed;
- (void)locationManager:(FindPSLocationManager *)locationManager error:(NSError *)error;
- (void)locationManager:(FindPSLocationManager *)locationManager debugText:(NSString *)text;

@end

@interface FindPSLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id<FindPSLocationManagerDelegate> delegate;
@property (nonatomic, readonly) FindPSLocationManagerGPSSignalStrength signalStrength;
@property (nonatomic, readonly) CLLocationDistance totalDistance;
@property (nonatomic, readonly) NSTimeInterval totalSeconds;
@property (nonatomic, readonly) double currentSpeed;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSMutableArray *tempLocationsArray;
@property (nonatomic) BOOL isStopUpdating;


+ (FindPSLocationManager *)sharedLocationManager;

- (BOOL)prepLocationUpdates; // this must be called before startLocationUpdates (best to call it early so we can get an early lock on location)
- (BOOL)startLocationUpdates;
- (void)stopLocationUpdates;
- (void)resetLocationUpdates;
- (CLLocation*)lastKnownLocation;

@end
