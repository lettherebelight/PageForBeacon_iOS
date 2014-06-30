//
//  HAMCardDetailViewController.h
//  BeaconReceiver
//
//  Created by daiyue on 5/25/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HAMThing;

@interface HAMCardDetailViewController_iPhone : UIViewController

@property HAMThing *thing;

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end
