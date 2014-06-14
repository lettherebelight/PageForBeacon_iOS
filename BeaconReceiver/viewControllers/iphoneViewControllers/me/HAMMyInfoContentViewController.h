//
//  HAMMyInfoContentViewController.h
//  BeaconReceiver
//
//  Created by daiyue on 6/1/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HAMMyInfoViewController;

@interface HAMMyInfoContentViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic) HAMMyInfoViewController* containerViewController;

@end
