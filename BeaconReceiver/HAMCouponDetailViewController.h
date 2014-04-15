//
//  HAMCouponDetailViewController.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-3-10.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class HAMHomepage;

@interface HAMCouponDetailViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *homepageWebView;

@property HAMHomepage *homepage;

@end
