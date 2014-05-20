//
//  HAMDiscoverCollectionViewController_iPhone.h
//  BeaconReceiver
//
//  Created by daiyue on 5/4/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMBeaconManager.h"
#import "HAMThingManager.h"

@class HAMThing;

@interface HAMDiscoverCollectionViewController_iPhone : UICollectionViewController <HAMBeaconManagerDelegate, HAMThingManagerDelegate> {
    UIView *defaultView;
    int defaultViewTag;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property NSArray *thingsAround;
@property NSArray *thingsInWorld;
@property HAMThing *thingForSegue;

@end
