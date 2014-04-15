//
//  HAMThumbnailViewController.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-11.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HAMHomepageData;

@interface HAMThumbnailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@property HAMHomepageData *homepage;

- (void)updateView;

@end
