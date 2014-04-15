//
//  HAMSideBarViewController.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-11.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HAMSideBarDelegate <NSObject>

- (Boolean)showHomePage;
- (Boolean)showFavorites;
- (Boolean)resetData;

@end

@interface HAMSideBarViewController : UIViewController

@property (nonatomic, retain) id<HAMSideBarDelegate> delegate;

@end
