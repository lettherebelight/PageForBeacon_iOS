//
//  HAMDiscoverTableViewController_iPhone.h
//  BeaconReceiver
//
//  Created by daiyue on 4/27/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMBeaconManager.h"

@class HAMHomepageData;

@interface HAMDiscoverTableViewController_iPhone : UITableViewController <HAMBeaconManagerDelegate> {
    NSArray *historyPages;
}

@property HAMHomepageData *homepage;
@property HAMHomepageData *pageForSegue;

@end
