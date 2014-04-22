//
//  HAMThumbnailViewController.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-11.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HAMHomepageData;

@interface HAMThumbnailViewController : UIViewController {
    HAMHomepageData *selPage;
}

@property (weak, nonatomic) IBOutlet UIScrollView *listScrollView;

@property HAMHomepageData *homepage;

- (void)initView;
- (void)updateView;

@end
