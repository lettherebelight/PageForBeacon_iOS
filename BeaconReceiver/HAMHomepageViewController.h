//
//  HAMHomepageViewController.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-3-26.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMBeaconManager.h"

@interface HAMHomepageViewController : UIViewController <HAMBeaconManagerDelegate, UIWebViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIWebView *homepageWebView;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIButton *drawerButton;
@property (weak, nonatomic) IBOutlet UICollectionView *historyCollectionView;

@end
