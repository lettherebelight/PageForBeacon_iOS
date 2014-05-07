//
//  HAMDiscoverCollectionViewController_iPhone.h
//  BeaconReceiver
//
//  Created by daiyue on 5/4/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMBeaconManager.h"

@class HAMHomepageData;

@interface HAMDiscoverCollectionViewController_iPhone : UICollectionViewController <HAMBeaconManagerDelegate> {
    UIView *defaultView;
    int defaultViewTag;
}

@property NSArray *stuffsAround;
@property HAMHomepageData *pageForSegue;

@end
