//
//  HAMUserViewController_iPhone.h
//  BeaconReceiver
//
//  Created by daiyue on 4/29/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HAMUserViewController_iPhone : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *setBeaconButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *userTitleTF;
@property (weak, nonatomic) IBOutlet UITextView *userStatusTV;
@property (weak, nonatomic) IBOutlet UITextField *wechatTF;
@property (weak, nonatomic) IBOutlet UITextField *weiboTF;
@property (weak, nonatomic) IBOutlet UITextField *qqTF;
@property (weak, nonatomic) IBOutlet UITextField *momoTF;
@property (weak, nonatomic) IBOutlet UITextField *doubanTF;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end
