//
//  HAMBeaconListViewController.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-15.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HAMThing;

@interface HAMBeaconListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{}

@property HAMThing* thingToBind;

@end
