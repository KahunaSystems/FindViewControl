//
//  LocationManager.m
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

//** static const NSUInteger kDistanceFilter = 5; // the minimum distance (meters) for which we want to receive location updates (see docs for CLLocationManager.distanceFilter)
//** static const NSUInteger kHeadingFilter = 30; // the minimum angular change (degrees) for which we want to receive heading updates (see docs for CLLocationManager.headingFilter)


#import "FindPSLocationManager.h"
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

static const NSUInteger kDistanceAndSpeedCalculationInterval = 3; // the interval (seconds) at which we calculate the user's distance and speed
static const NSUInteger kMinimumLocationUpdateInterval = 3; // the interval (seconds) at which we ping for a new location if we haven't received one yet
static const NSUInteger kNumLocationHistoriesToKeep = 5; // the number of locations to store in history so that we can look back at them and determine which is most accurate
static const NSUInteger kValidLocationHistoryDeltaInterval = 3; // the maximum valid age in seconds of a location stored in the location history
static const NSUInteger kNumSpeedHistoriesToAverage = 3; // the number of speeds to store in history so that we can average them to get the current speed
static const NSUInteger kPrioritizeFasterSpeeds = 1; // if > 0, the currentSpeed and complete speed history will automatically be set to to the new speed if the new speed is faster than the averaged speed
static const NSUInteger kMinLocationsNeededToUpdateDistanceAndSpeed = 3; // the number of locations needed in history before we will even update the current distance and speed
static const CGFloat kRequiredHorizontalAccuracy = 20.0; // the required accuracy in meters for a location.  if we receive anything above this number, the delegate will be informed that the signal is weak

CGFloat kMaximumAcceptableHorizontalAccuracy = 70.0; // the maximum acceptable accuracy in meters for a location.  anything above this number will be completely ignored

int kMaximumWaitTime = 10;


static const NSUInteger kGPSRefinementInterval = 15; // the number of seconds at which we will attempt to achieve kRequiredHorizontalAccuracy before giving up and accepting kMaximumAcceptableHorizontalAccuracy


static const CGFloat kSpeedNotSet = -1.0;

@interface FindPSLocationManager ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *locationPingTimer;
@property (nonatomic) FindPSLocationManagerGPSSignalStrength signalStrength;
@property (nonatomic, strong) CLLocation *lastRecordedLocation;
@property (nonatomic) CLLocationDistance totalDistance;
@property (nonatomic, strong) NSMutableArray *locationHistory;
@property (nonatomic, strong) NSDate *startTimestamp;
@property (nonatomic) double currentSpeed;
@property (nonatomic, strong) NSMutableArray *speedHistory;
@property (nonatomic) NSUInteger lastDistanceAndSpeedCalculation;
@property (nonatomic) BOOL forceDistanceAndSpeedCalculation;
@property (nonatomic) NSTimeInterval pauseDelta;
@property (nonatomic) NSTimeInterval pauseDeltaStart;
@property (nonatomic) BOOL readyToExposeDistanceAndSpeed;
@property (nonatomic) BOOL checkingSignalStrength;
@property (nonatomic) BOOL allowMaximumAcceptableAccuracy;
@property (nonatomic, strong) NSMutableArray *tempStartCoOrdinatesArray;
@property (nonatomic) BOOL getFirstApproxLocation;
@property (nonatomic) BOOL isValidLocFound;

- (void)checkSustainedSignalStrength;
- (void)requestNewLocation;

@end


@implementation FindPSLocationManager

@synthesize delegate = _delegate;

@synthesize locationManager = _locationManager;
@synthesize locationPingTimer = _locationPingTimer;
@synthesize signalStrength = _signalStrength;
@synthesize lastRecordedLocation = _lastRecordedLocation;
@synthesize totalDistance = _totalDistance;
@synthesize locationHistory = _locationHistory;
@synthesize totalSeconds = _totalSeconds;
@synthesize startTimestamp = _startTimestamp;
@synthesize currentSpeed = _currentSpeed;
@synthesize speedHistory = _speedHistory;
@synthesize lastDistanceAndSpeedCalculation = _lastDistanceAndSpeedCalculation;
@synthesize forceDistanceAndSpeedCalculation = _forceDistanceAndSpeedCalculation;
@synthesize pauseDelta = _pauseDelta;
@synthesize pauseDeltaStart = _pauseDeltaStart;
@synthesize readyToExposeDistanceAndSpeed = _readyToExposeDistanceAndSpeed;
@synthesize allowMaximumAcceptableAccuracy = _allowMaximumAcceptableAccuracy;
@synthesize checkingSignalStrength = _checkingSignalStrength;

+ (id)sharedLocationManager {
    static dispatch_once_t pred;
    static FindPSLocationManager *locationManagerSingleton = nil;
    
    dispatch_once(&pred, ^{
        locationManagerSingleton = [[self alloc] init];
    });
    return locationManagerSingleton;
}

- (id)init {
    
    if ((self = [super init])) {
        
        if ([CLLocationManager locationServicesEnabled]) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            self.locationManager.distanceFilter = kCLDistanceFilterNone;
            self.locationManager.headingFilter = kCLHeadingFilterNone;
            
           
            self.locationManager.pausesLocationUpdatesAutomatically = NO;
            
            
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
        }
        
        self.locationHistory = [NSMutableArray arrayWithCapacity:kNumLocationHistoriesToKeep];
        self.speedHistory = [NSMutableArray arrayWithCapacity:kNumSpeedHistoriesToAverage];
        [self resetLocationUpdates];
        
        
        
        //Temp Array for storing locations
        self.tempLocationsArray = [[NSMutableArray alloc] init];
    }
    
    
    return self;
}

- (void)dealloc {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    
    self.lastRecordedLocation = nil;
    self.locationHistory = nil;
    self.speedHistory = nil;
}

- (void)setSignalStrength:(FindPSLocationManagerGPSSignalStrength)signalStrength {
    BOOL needToUpdateDelegate = NO;
    if (_signalStrength != signalStrength) {
        needToUpdateDelegate = YES;
    }
    
    _signalStrength = signalStrength;
    
    if (self.signalStrength == FindPSLocationManagerGPSSignalStrengthStrong) {
        self.allowMaximumAcceptableAccuracy = NO;
    } else if (self.signalStrength == FindPSLocationManagerGPSSignalStrengthWeak) {
        [self checkSustainedSignalStrength];
    }
        
    if (needToUpdateDelegate) {
        if ([self.delegate respondsToSelector:@selector(locationManager:signalStrengthChanged:)]) {
            [self.delegate locationManager:self signalStrengthChanged:self.signalStrength];
        }
    }
}

- (void)setTotalDistance:(CLLocationDistance)totalDistance {
    _totalDistance = totalDistance;
    
    if (self.currentSpeed != kSpeedNotSet) {
        if ([self.delegate respondsToSelector:@selector(locationManager:distanceUpdated:)]) {
            [self.delegate locationManager:self distanceUpdated:self.totalDistance];
        }
    }
}

- (NSTimeInterval)totalSeconds {
    return ([self.startTimestamp timeIntervalSinceNow] * -1) - self.pauseDelta;
}

- (void)checkSustainedSignalStrength {
    if (!self.checkingSignalStrength) {
        self.checkingSignalStrength = YES;
        
        double delayInSeconds = kGPSRefinementInterval;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.checkingSignalStrength = NO;
            if (self.signalStrength == FindPSLocationManagerGPSSignalStrengthWeak) {
                self.allowMaximumAcceptableAccuracy = YES;
                if ([self.delegate respondsToSelector:@selector(locationManagerSignalConsistentlyWeak:)]) {
                    [self.delegate locationManagerSignalConsistentlyWeak:self];
                }
            } else if (self.signalStrength == FindPSLocationManagerGPSSignalStrengthInvalid) {
                self.allowMaximumAcceptableAccuracy = YES;
                self.signalStrength = FindPSLocationManagerGPSSignalStrengthWeak;
                if ([self.delegate respondsToSelector:@selector(locationManagerSignalConsistentlyWeak:)]) {
                    [self.delegate locationManagerSignalConsistentlyWeak:self];
                }
            }
        });
    }
}

- (void)requestNewLocation {
    if(!self.isValidLocFound)
    {
       // [self getBestPossibleAccurateLoc];
    }
    [self.tempLocationsArray removeAllObjects];
    self.isValidLocFound = NO;
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startUpdatingLocation];

}

- (void)getBestPossibleAccurateLoc
{
    CLLocation *location;
    
    if([self.tempLocationsArray count] > 0)
    {
        for(int i=0;i<[self.tempLocationsArray count];i++)
        {
            CLLocation *temp = [self.tempLocationsArray objectAtIndex:i];
            
            if(location == nil){
                location = temp;
            }
            
            else if(temp.horizontalAccuracy>location.horizontalAccuracy){
                location = temp;
            }
            
        }
    }
    if(location!=nil)
    {
        self.currentLocation = location;
        //[self cacheLastKnownValidCurrentLocation:location];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LocationFound" object:nil]];
        [self showLocationAlert];
    }
}

- (BOOL)prepLocationUpdates {
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationHistory removeAllObjects];
        [self.speedHistory removeAllObjects];
        self.lastDistanceAndSpeedCalculation = 0;
        self.currentSpeed = kSpeedNotSet;
        self.readyToExposeDistanceAndSpeed = NO;
        self.signalStrength = FindPSLocationManagerGPSSignalStrengthInvalid;
        self.allowMaximumAcceptableAccuracy = NO;
        
        self.forceDistanceAndSpeedCalculation = YES;
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];
        
        [self checkSustainedSignalStrength];
        
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)startLocationUpdates {
    
    self.isStopUpdating = NO;
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        self.locationPingTimer = [NSTimer timerWithTimeInterval:kMinimumLocationUpdateInterval target:self selector:@selector(requestNewLocation) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.locationPingTimer forMode:NSRunLoopCommonModes];
        
        self.getFirstApproxLocation = YES;
        
        [self performSelector:@selector(confirmLocationAvailable) withObject:nil afterDelay:kMaximumWaitTime];
        
        self.readyToExposeDistanceAndSpeed = YES;
        self.tempStartCoOrdinatesArray = [[NSMutableArray alloc] init];
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];
        
        if (self.pauseDeltaStart > 0) {
            self.pauseDelta += ([NSDate timeIntervalSinceReferenceDate] - self.pauseDeltaStart);
            self.pauseDeltaStart = 0;
        }
        
        return YES;
    } else {
        return NO;
    }
}

#pragma mark -
#pragma mark Check After 10 Secs

- (void)confirmLocationAvailable
{
    if(self.getFirstApproxLocation)
    {
        CLLocation *location;
        
        if([self.locationHistory count] == 0)
        {
            for(int i=0;i<[self.tempStartCoOrdinatesArray count];i++)
            {
                CLLocation *temp = [self.tempStartCoOrdinatesArray objectAtIndex:i];
                
                if(location == nil){
                    location = temp;
                }
                
                else if(temp.horizontalAccuracy>location.horizontalAccuracy){
                    location = temp;
                }
                
            }
        }
        
        if(location!=nil)
        {
            self.currentLocation = location;
            //[self cacheLastKnownValidCurrentLocation:location];
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LocationFound" object:nil]];
            
            [self showLocationAlert];
            
            //****NSLog(@"Location Lat = %f Long = %f Accuracy = %f ", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
        }
        else{
            
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"Internal GPS Error" forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *error = [NSError errorWithDomain:@"GPSError" code:9999 userInfo:details];
            
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LocationFound" object:nil userInfo:[NSDictionary dictionaryWithObject:error forKey:@"GPSError"]]];
            
            //****NSLog(@"No location Found Error");
        }
        
        //[self stopLocationUpdates];
    }
    
    self.getFirstApproxLocation = NO;
}

- (void)stopLocationUpdates {
    
    self.isStopUpdating = YES;
    
    [self.tempStartCoOrdinatesArray removeAllObjects];
    [self.locationPingTimer invalidate];
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopMonitoringSignificantLocationChanges];
    
    self.pauseDeltaStart = [NSDate timeIntervalSinceReferenceDate];
    self.lastRecordedLocation = nil;
    //self.currentLocation = nil;
}

- (void)resetLocationUpdates {
    self.totalDistance = 0;
    self.startTimestamp = [NSDate dateWithTimeIntervalSinceNow:0];
    self.forceDistanceAndSpeedCalculation = NO;
    self.pauseDelta = 0;
    self.pauseDeltaStart = 0;
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // since the oldLocation might be from some previous use of core location, we need to make sure we're getting data from this run
    if (oldLocation == nil || self.isStopUpdating) return;
    
    if([self.locationHistory count] == 0)
    {
        if(self.tempStartCoOrdinatesArray == nil){
            self.tempStartCoOrdinatesArray = [[NSMutableArray alloc] init];
        }
        
        [self.tempStartCoOrdinatesArray addObject:newLocation];
    }
        
    if(self.tempLocationsArray == nil){
        self.tempLocationsArray = [[NSMutableArray alloc] init];
    }
    
    if(!self.isValidLocFound){
        [self.tempLocationsArray addObject:newLocation];  
    }
    
    
    //[self writeToTextFile:[NSString stringWithFormat:@"%f,%f,%f\n",newLocation.coordinate.latitude,newLocation.coordinate.longitude,newLocation.horizontalAccuracy]];
    //old and new locations both are same
    /*if(self.currentLocation.coordinate.latitude == newLocation.coordinate.latitude ||  self.currentLocation.coordinate.longitude == newLocation.coordinate.longitude)
    {
        return;
    }*/
    
    
    BOOL isStaleLocation = ([oldLocation.timestamp compare:self.startTimestamp] == NSOrderedAscending);
    
    //[self.locationPingTimer invalidate];
    
    if (newLocation.horizontalAccuracy <= kRequiredHorizontalAccuracy) {
        self.signalStrength = FindPSLocationManagerGPSSignalStrengthStrong;
    } else {
        self.signalStrength = FindPSLocationManagerGPSSignalStrengthWeak;
    }
    
    double horizontalAccuracy;
    if (self.allowMaximumAcceptableAccuracy) {
        horizontalAccuracy = kMaximumAcceptableHorizontalAccuracy;
    } else {
        horizontalAccuracy = kRequiredHorizontalAccuracy;
    }
    
    if (!isStaleLocation && newLocation.horizontalAccuracy >= 0 && newLocation.horizontalAccuracy <= horizontalAccuracy) {
        
        [self.locationHistory addObject:newLocation];
        
        self.currentLocation = newLocation;
        
        //Cache last location
        //[self cacheLastKnownValidCurrentLocation:newLocation];
        
        //Accurate location found
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LocationFound" object:nil]];
        
        //No need to get approximate location
        self.getFirstApproxLocation = NO;
        
        [self showLocationAlert];
        
        if ([self.locationHistory count] > kNumLocationHistoriesToKeep) {
            [self.locationHistory removeObjectAtIndex:0];
        }
        
        BOOL canUpdateDistanceAndSpeed = NO;
        if ([self.locationHistory count] >= kMinLocationsNeededToUpdateDistanceAndSpeed) {
            canUpdateDistanceAndSpeed = YES && self.readyToExposeDistanceAndSpeed;
        }
        
        if (self.forceDistanceAndSpeedCalculation || [NSDate timeIntervalSinceReferenceDate] - self.lastDistanceAndSpeedCalculation > kDistanceAndSpeedCalculationInterval) {
            self.forceDistanceAndSpeedCalculation = NO;
            self.lastDistanceAndSpeedCalculation = [NSDate timeIntervalSinceReferenceDate];
            
            CLLocation *lastLocation = (self.lastRecordedLocation != nil) ? self.lastRecordedLocation : oldLocation;
            
            CLLocation *bestLocation = nil;
            CGFloat bestAccuracy = kRequiredHorizontalAccuracy;
            for (CLLocation *location in self.locationHistory) {
                if ([NSDate timeIntervalSinceReferenceDate] - [location.timestamp timeIntervalSinceReferenceDate] <= kValidLocationHistoryDeltaInterval) {
                    if (location.horizontalAccuracy < bestAccuracy && location != lastLocation) {
                        bestAccuracy = location.horizontalAccuracy;
                        bestLocation = location;
                        
                        self.isValidLocFound = YES;
                        [self.tempLocationsArray removeAllObjects];
                    }
                }
            }
            if (bestLocation == nil) bestLocation = newLocation;
            
            CLLocationDistance distance = [bestLocation distanceFromLocation:lastLocation];
            if (canUpdateDistanceAndSpeed) self.totalDistance += distance;
            self.lastRecordedLocation = bestLocation;
            
            NSTimeInterval timeSinceLastLocation = [bestLocation.timestamp timeIntervalSinceDate:lastLocation.timestamp];
            if (timeSinceLastLocation > 0) {
                CGFloat speed = distance / timeSinceLastLocation;
                if (speed <= 0 && [self.speedHistory count] == 0) {
                    // don't add a speed of 0 as the first item, since it just means we're not moving yet
                } else {
                    [self.speedHistory addObject:[NSNumber numberWithDouble:speed]];
                }
                if ([self.speedHistory count] > kNumSpeedHistoriesToAverage) {
                    [self.speedHistory removeObjectAtIndex:0];
                }
                if ([self.speedHistory count] > 1) {
                    double totalSpeed = 0;
                    for (NSNumber *speedNumber in self.speedHistory) {
                        totalSpeed += [speedNumber doubleValue];
                    }
                    if (canUpdateDistanceAndSpeed) {
                        double newSpeed = totalSpeed / (double)[self.speedHistory count];
                        if (kPrioritizeFasterSpeeds > 0 && speed > newSpeed) {
                            newSpeed = speed;
                            [self.speedHistory removeAllObjects];
                            for (int i=0; i<kNumSpeedHistoriesToAverage; i++) {
                                [self.speedHistory addObject:[NSNumber numberWithDouble:newSpeed]];
                            }
                        }
                        self.currentSpeed = newSpeed;
                    }
                }
            }
            
            if ([self.delegate respondsToSelector:@selector(locationManager:waypoint:calculatedSpeed:)]) {
                [self.delegate locationManager:self waypoint:self.lastRecordedLocation calculatedSpeed:self.currentSpeed];
            }
        }
    }
    
    // this will be invalidated above if a new location is received before it fires
    //self.locationPingTimer = [NSTimer timerWithTimeInterval:kMinimumLocationUpdateInterval target:self selector:@selector(requestNewLocation) userInfo:nil repeats:NO];
    //[[NSRunLoop mainRunLoop] addTimer:self.locationPingTimer forMode:NSRunLoopCommonModes];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    // we don't really care about the new heading.  all we care about is calculating the current distance from the previous distance early if the user changed directions
    self.forceDistanceAndSpeedCalculation = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        if ([self.delegate respondsToSelector:@selector(locationManager:error:)]) {
            [self.delegate locationManager:self error:error];
        }
        //****[self stopLocationUpdates];
    }
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LocationFound" object:nil userInfo:[NSDictionary dictionaryWithObject:error forKey:@"GPSError"]]];
}

-(void) writeToTextFile:(NSString *)savedString{
    
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileHandle *file;
    NSString *fileName = [NSString stringWithFormat:@"%@/AllLocation.txt",
                          documentsDirectory];
    
    file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    
    if (file == nil)
        //****NSLog(@"Failed to open file");
    
    [file seekToEndOfFile];
    [file writeData:[savedString dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
    
    
}

- (void)showLocationAlert{
    
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Current Location Details" message:[NSString stringWithFormat:@"Latitude = %f, Longitude = %f, Accuracy = %f",self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude, self.currentLocation.horizontalAccuracy] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];*/
}

- (CLLocation*)lastKnownLocation{
    
    if(self.locationManager.location!=nil){
        return self.locationManager.location;
    }
    
    return nil;
}
@end
