//
//  ViewController.h
//  CircularRegionSample
//
//  Created by Hemareddy Halli on 3/9/15.
//  Copyright (c) 2015 Hemareddy Halli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@interface ViewController : UIViewController<CLLocationManagerDelegate>
{
    CLLocationManager   *locationManager;
}

@end

