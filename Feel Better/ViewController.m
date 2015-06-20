//
//  ViewController.m
//  TESTEAD3
//
//  Created by Lucas Yamashita on 6/17/15.
//  Copyright (c) 2015 YUKIOSOFTWARE. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>


const NSString *kWundergroundKey = @"b12402b27720feed";

@interface ViewController () <CLLocationManagerDelegate, UITextFieldDelegate>
{
    BOOL _bannerIsVisible;
    ADBannerView *_adBanner;
    CLLocationManager *locationManager;
    UIActivityIndicatorView *activityIndicator;
}
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    //    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    [self checkLocationManager];
    [self.locationManager startUpdatingLocation];
    self.statusLabel.text = @"Determining location";
}

-(BOOL) checkLocationManager
{
    if(![CLLocationManager locationServicesEnabled])
    {
        NSLog(@"You need to enable Location Services");
        return  FALSE;
    }
    if(![CLLocationManager isMonitoringAvailableForClass:self.class])
    {
        NSLog(@"Region monitoring is not available for this Class");
        return  FALSE;
    }
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted  )
    {
        NSLog(@"You need to authorize Location Services for the APP");
        return  FALSE;
    }
    return TRUE;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 50)];
    _adBanner.delegate = self;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!_bannerIsVisible)
    {
        // If banner isn't part of view hierarchy, add it
        if (_adBanner.superview == nil)
        {
            [self.view addSubview:_adBanner];
        }
        
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        
        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        
        [UIView commitAnimations];
        
        _bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to retrieve ad");
    
    if (_bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        
        [UIView commitAnimations];
        
        _bannerIsVisible = NO;
    }
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    
    [self retrieveWeatherForLocation:location orZipCode:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
    // handle location errors here, such as case where user doesn't let app use iphone's location
    

}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{

}

#pragma mark - Methods for retrieving weather from Wunderground

- (void)retrieveWeatherForLocation:(CLLocation *)location orZipCode:(NSString *)zipCode
{
    NSString *urlString;
    
    // get URL for current conditions
    
    if (location)
    {
        // based upon longitude and latitude returned by CLLocationManager
        
        urlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/%@/conditions/q/%+f,%+f.json",
                     kWundergroundKey,
                     location.coordinate.latitude,
                     location.coordinate.longitude];
    }
    else if ([zipCode length] == 5)
    {
        // based upon the zip code
        
        urlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/%@/conditions/q/%@.json",
                     kWundergroundKey,
                     zipCode];
        
    }
    else
    {
        NSAssert(NO, @"You must provide a CLLocation object or five digit zip code");
    }
    
    // Log it so you can see what the URL was for diagnostic purposes.
    // It's often useful to pull this up in a web browser like FireFox
    // so you can diagnose what's going on.
    
    NSURL *url          = [NSURL URLWithString:urlString];
    
    NSData *weatherData = [NSData dataWithContentsOfURL:url];
    
    // make sure we were able to get some response from the URL; if not
    // maybe your internet connection is not operational, or something
    // like that.
    
    if (weatherData == nil)
    {
    
        return;
    }
    
    // parse the JSON results
    
    NSError *error;
    id weatherResults = [NSJSONSerialization JSONObjectWithData:weatherData options:0 error:&error];
    
    // if there was an error, report this
    
    if (error != nil)
    {
    
        return;
    }
    
    // otherwise, let's make sure we got a NSDictionary like we expected
    
    else if (![weatherResults isKindOfClass:[NSDictionary class]])
    {
    
        return;
    }
    
    // if we've gotten here, that means that we've parsed the JSON feed from Wunderground,
    // so now let's see if we got the expected response
    
    NSDictionary *response = weatherResults[@"response"];
    if (response == nil || ![response isKindOfClass:[NSDictionary class]])
    {
    
        return;
    }
    
    // now, let's see if that response reported any particular error
    
    NSDictionary *errorDictionary = response[@"error"];
    if (errorDictionary != nil)
    {
        NSString *message = @"Error reported by weather service";
        
        if (errorDictionary[@"description"])
            message = [NSString stringWithFormat:@"%@: %@", message, errorDictionary[@"description"]];
        
        
        if ([errorDictionary[@"type"] isEqualToString:@"keynotfound"])
        {
            NSLog(@"%s You must get a key for your app from http://www.wunderground.com/weather/api/", __FUNCTION__);
        }
        return;
    }
    
    // if no errors thus far, then we can now inspect the current_observation
    
    NSDictionary *currentObservation = weatherResults[@"current_observation"];
    
    if (currentObservation == nil)
    {
        // if not found, let's tell the user
        
       
        return;
    }
    
    // otherwise, let's look up the barometer information
    
    NSString *statusMessage;
    NSString *pressureMb = currentObservation[@"pressure_mb"];
    
    if (pressureMb)
    {
        statusMessage = @"Retrieved barometric pressure";
        self.pressureMbLabel.text = pressureMb;
    }
    else
    {
        statusMessage = @"No barometric information found";
    }
    
    NSNumber *tempC      = currentObservation[@"temp_c"];
    
    if (tempC)
    {
        statusMessage = @"Retrieved temperature";
        self.tempCLabel.text = [tempC stringValue];
    }
    else
    {
        statusMessage = @"No temperature information found";
    }
    
    // update the user interface status message
    
    [self updateStatusMessage:statusMessage stopActivityIndicator:YES stopLocationServices:YES logMessage:weatherResults];
}

- (void)updateStatusMessage:(NSString *)userInterfaceMessage
      stopActivityIndicator:(BOOL)stopActivityIndicator
       stopLocationServices:(BOOL)stopLocationServices
                 logMessage:(id)systemLogInformation
{
    self.statusLabel.text = userInterfaceMessage;
    
    
    // note, we should only use NSLog during diagnostic phase of development;
    // in production app, we should comment out the following NSLog!
    
    if (systemLogInformation)
        NSLog(@"%s %@", __FUNCTION__, @[userInterfaceMessage, systemLogInformation]);
}
@end
