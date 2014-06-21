//
//  HAMCreateThingViewController.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-17.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class HAMThing;

@interface HAMCreateThingViewController : UIViewController 
{}

@property Boolean isNewThing;

@property CLBeacon* beaconToBind;
@property HAMThing* thingToEdit;

@end
