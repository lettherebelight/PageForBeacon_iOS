//
//  HAMDiscoverViewController_iPhone.h
//  BeaconReceiver
//
//  Created by daiyue on 5/21/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMBeaconManager.h"
#import "HAMThingManager.h"

@interface HAMDiscoverViewController_iPhone : UIViewController <HAMBeaconManagerDelegate, HAMThingManagerDelegate>

@end
