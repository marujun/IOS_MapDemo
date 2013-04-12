//
//  MapDemoViewController.h
//  MapDemo
//
//  Created by marujun on 13-4-11.
//  Copyright (c) 2013年 马汝军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MASearch.h"

@interface MapDemoViewController : UIViewController <CLLocationManagerDelegate,MASearchDelegate> {
    __weak IBOutlet UITextField *wgsText;
    __weak IBOutlet UITextField *gaodeText;
    __weak IBOutlet UITextField *privateModule;
    CLLocationManager *locationManager;
}

@property (nonatomic, retain) CLLocationManager *locationManager;

@end
