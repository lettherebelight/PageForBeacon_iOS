//
//  HAMCardDetailViewController.m
//  BeaconReceiver
//
//  Created by daiyue on 5/25/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMCardDetailViewController_iPhone.h"

#import "HAMDetailTabBarController_iPhone.h"

#import "HAMThing.h"

#import "HAMTools.h"

@interface HAMCardDetailViewController_iPhone ()

@end

@implementation HAMCardDetailViewController_iPhone

@synthesize thing;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    HAMDetailTabBarController_iPhone *detailTabVC = (HAMDetailTabBarController_iPhone*)self.parentViewController;
    thing = detailTabVC.thing;
    
    [self.backView.layer setCornerRadius:6.0f];
    [self.backView.layer setMasksToBounds:YES];
    
    UIImage *thumbnail;
    thumbnail = [HAMTools imageFromURL:thing.coverURL];
    UIImage *image = [HAMTools image:thumbnail staysShapeChangeToSize:self.avatarImageView.frame.size];
    self.avatarImageView.image = image;

    self.nameLabel.text = thing.title;
    self.contentLabel.text = thing.content;
    
    self.webLabel.text = thing.url;
    self.wechatLabel.text = thing.wechat;
    self.weiboLabel.text = thing.weibo;
    self.qqLabel.text = thing.qq;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
