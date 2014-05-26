//
//  HAMCreateThingScrollContentViewController.h
//  BeaconReceiver
//
//  Created by daiyue on 5/25/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class HAMCreateThingViewController;

@interface HAMCreateThingContentViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate,UITextViewDelegate>
{
}

@property CLBeacon* beaconToBind;

@property UITabBar* tabBar;
@property HAMCreateThingViewController* containerViewController;
@end
