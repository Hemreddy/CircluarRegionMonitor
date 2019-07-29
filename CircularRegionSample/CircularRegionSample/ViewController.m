//
//  ViewController.m
//  CircularRegionSample
//
//  Created by Hemareddy Halli on 3/9/15.
//  Copyright (c) 2015 Hemareddy Halli. All rights reserved.
//

#import "ViewController.h"

#ifdef DEBUG
#define DEBUGLOG NSLog
#else
#define DEBUGLOG(x,...)
#endif

#define RADIUS_CONSTANT  100.0f
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIButton *theAgreeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [theAgreeButton setTitle:@"Set Region" forState:UIControlStateNormal];
    [theAgreeButton setFrame:CGRectMake(50, 100, 220, 30)];
    [theAgreeButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [theAgreeButton addTarget:self action:@selector(monitorRegions:) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:theAgreeButton];

}

-(IBAction)monitorRegions:(id)sender
{
    
    if ([CLLocationManager locationServicesEnabled])
    {
        if (nil == locationManager)
        {
            locationManager = [[CLLocationManager alloc] init];
            
            
            if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [locationManager requestAlwaysAuthorization]; //or requestWhenInUseAuthorization //requestAlwaysAuthorization
            }
            locationManager.pausesLocationUpdatesAutomatically = YES;
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // kCLLocationAccuracyHundredMeters;
            
            locationManager.distanceFilter = kCLDistanceFilterNone;
            //            [locationManager startUpdatingLocation];
        }
        else
        {
            //[locationManager startUpdatingLocation];
        }
        
    }
    
    [self registerForNotification];
    [self setUpRegions];
}

-(void)setUpRegions
{
    NSString *filePath =[[NSBundle mainBundle] pathForResource:@"RegionPropertyList" ofType:@"plist"];
    NSArray *mTruckStopPromosList = [[NSArray alloc] initWithArray:[NSArray arrayWithContentsOfFile:filePath]];
    for (int index = 0;  index < [mTruckStopPromosList count]; index++)
    {
        NSDictionary *theDict = [mTruckStopPromosList objectAtIndex:index];
        float theLat = [[theDict objectForKey:@"Latit"] floatValue];
        float theLong = [[theDict objectForKey:@"Longi"] floatValue];
        switch (index)
        {
            case 0:
            {
                theLat = 32.735772f;
                theLong = -97.419968f;
            }
                break;
            case 1:
            {
                theLat = 32.735463f;
                theLong = -97.416297f;
            }
                break;
            case 2:
            {
                theLat = 32.736825f;
                theLong = -97.433088f;
            }
                break;
                
            default:
                break;
        }
        NSString *theName = [theDict objectForKey:@"Name"];
        NSString *teRegionIdentifier = [NSString stringWithFormat:@"Region name :%@ \nLatitude : %f && Longitude  : %f",theName, theLat,theLong];
        CLLocationCoordinate2D theLocationCenter = CLLocationCoordinate2DMake(theLat,theLong);
        CLCircularRegion *theRegion = [[CLCircularRegion alloc] initWithCenter:theLocationCenter radius:RADIUS_CONSTANT identifier:teRegionIdentifier];
        theRegion.notifyOnExit = NO;
        theRegion.notifyOnEntry = YES;
        //theRegion.notifyEntryStateOnDisplay = YES;

        
        //        NSString *theCurLoc = [NSString stringWithFormat:@"Region id :%@\nLat : %f\nLong  :%f",theRegion.identifier,locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude];
        //        [self showLocalNotif:theCurLoc];

        [locationManager startMonitoringForRegion:theRegion];
        [locationManager performSelector:@selector(requestStateForRegion:) withObject:theRegion afterDelay:3];

        //[locationManager requestStateForRegion:theRegion];

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    DEBUGLOG(@"didFailWithError: %@", error);
    //    UIAlertView *errorAlert = [[UIAlertView alloc]
    //                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    DEBUGLOG(@"didUpdateToLocation: %@", newLocation);

}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSString *theMessage = [NSString stringWithFormat:@"Entered region : %@",region.identifier];

    if (state ==CLRegionStateInside)
    {
        theMessage = [NSString stringWithFormat:@"didDetermineState (inside) : %@",region.identifier];
    }
    else
        theMessage = [NSString stringWithFormat:@"didDetermineState (outside) : %@",region.identifier];

    
    [self SetLocalNotifciation:theMessage];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSString *theMessage = [NSString stringWithFormat:@"Entered region : %@",region.identifier];
//    UIAlertView *theAlertView = [[UIAlertView alloc] initWithTitle:@"didEnterRegion" message:theMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//    [theAlertView show];
    [self SetLocalNotifciation:theMessage];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSString *theMessage = [NSString stringWithFormat:@"Exited region : %@",region.identifier];
//    UIAlertView *theAlertView = [[UIAlertView alloc] initWithTitle:@"didEnterRegion" message:theMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//    [theAlertView show];
    [self SetLocalNotifciation:theMessage];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    //[locationManager stopMonitoringForRegion:region];
    DEBUGLOG(@"monitoringDidFailForRegion :%@\n Region Id :%@",error,[region identifier]);
    DEBUGLOG(@"theRegion  :%@",region);
    
    DEBUGLOG(@"Monitored region count  :%d",(int)[manager monitoredRegions].count);
    NSString *theError = [NSString stringWithFormat:@"Error :%@", [error description]];
    [self SetLocalNotifciation:theError];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSString *theMessage = [NSString stringWithFormat:@"Start monitoring region : %@",region.identifier];
    //    UIAlertView *theAlertView = [[UIAlertView alloc] initWithTitle:@"didEnterRegion" message:theMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    //    [theAlertView show];
    [self SetLocalNotifciation:theMessage];
}

#pragma mark ends

-(void)SetLocalNotifciation:(NSString*)inString
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:25];
    notification.alertBody = inString;
    
    notification.hasAction = YES;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

-(void)registerForNotification
{
    
    /*
     // Register for Push Notitications
     #ifdef __IPHONE_8_0
     if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
     UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert) categories:nil];
     [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
     }
     #else
     //register to receive notifications
     UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
     #endif
     
     if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
     UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert) categories:nil];
     [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
     }
     else{
     UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
     }
     */
    
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert) categories:nil];
//    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
}

@end
