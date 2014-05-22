//
//  HAMMeInfoViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-21.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMMyInfoViewController.h"

#import "HAMAVOSManager.h"

#import "SVProgressHUD.h"

@interface HAMMyInfoViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *introTextView;

- (IBAction)saveMyInfoClicked:(id)sender;

@end

@implementation HAMMyInfoViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveMyInfoClicked:(id)sender {
    [HAMAVOSManager updateCurrentUserCardWithName:self.nameTextField.text intro:self.introTextView.text];
    [SVProgressHUD showSuccessWithStatus:@"我的信息成功更新。"];
}
@end
