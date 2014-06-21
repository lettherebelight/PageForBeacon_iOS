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
@class HAMThing;

@interface HAMCreateThingContentViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate,UITextViewDelegate>
{
}

@property Boolean isNewThing;

@property CLBeacon* beaconToBind;
@property HAMThing* thingToEdit;

@property UITabBar* tabBar;
@property HAMCreateThingViewController* containerViewController;
@end
