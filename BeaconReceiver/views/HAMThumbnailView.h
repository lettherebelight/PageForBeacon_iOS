//
//  HAMThumbnailView.h
//  BeaconReceiver
//
//  Created by daiyue on 4/15/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HAMHomepageData;

@interface HAMThumbnailView : UIView {
    UIImageView *backImageView;
    UIImageView *imageView;
}

@property HAMHomepageData* pageData;

- (id)initWithFrame:(CGRect)frame pageData:(HAMHomepageData*)page;

- (void)removeFromSuperview;

@end
