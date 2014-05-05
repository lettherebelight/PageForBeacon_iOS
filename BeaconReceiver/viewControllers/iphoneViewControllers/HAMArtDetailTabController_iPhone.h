//
//  HAMArtDetailTabController_iPhone.h
//  BeaconReceiver
//
//  Created by daiyue on 5/4/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMBeaconManager.h"

@interface HAMArtDetailTabController_iPhone : UITabBarController <HAMBeaconManagerDelegate> {
    NSString *pageTitle;
    NSMutableArray *barItems;
    UIGestureRecognizer *switchDetailViewRecognizer;
}

@property HAMHomepageData *homepage;

@end
