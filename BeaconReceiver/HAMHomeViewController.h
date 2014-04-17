//
//  HAMHomeViewController.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-11.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMSideBarViewController.h"
#import "HAMBeaconManager.h"

@interface HAMHomeViewController : UIViewController <HAMSideBarDelegate, HAMBeaconManagerDelegate> {
    UITabBarController *contentTabView;
}

@end
