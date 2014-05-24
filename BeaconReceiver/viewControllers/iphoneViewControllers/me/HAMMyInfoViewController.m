//
//  HAMMeInfoViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-21.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMMyInfoViewController.h"

#import "HAMThing.h"

#import "HAMAVOSManager.h"
#import "HAMTourManager.h"
#import "HAMTools.h"

#import "SVProgressHUD.h"

@interface HAMMyInfoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextView *nameTextView;
@property (weak, nonatomic) IBOutlet UITextView *introTextView;

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UITextField *wechatTextField;


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
    
    //tap view gesture - resign text fields
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapedView:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated{
    HAMThing* card = [[HAMTourManager tourManager] currentUserThing];
    
    UIImage* avatarImageRaw = [HAMTools imageFromURL:card.coverURL];
    UIImage *avatarImageResized = [HAMTools image:avatarImageRaw staysShapeChangeToSize:self.avatarImageView.frame.size];
    self.avatarImageView.image = avatarImageResized;
    
    self.nameTextView.text = card.title;
    self.introTextView.text = card.content;
    
    self.urlTextField.text = card.url;
    self.wechatTextField.text = card.wechat;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)saveMyInfoClicked:(id)sender {
    HAMThing* thing = [[HAMTourManager tourManager]currentUserThing];
    thing.title = self.nameTextView.text;
    thing.content = self.introTextView.text;
    thing.url = self.urlTextField.text;
    
    thing.wechat = self.wechatTextField.text;
    
    [SVProgressHUD show];
    [HAMAVOSManager updateCurrentUserCardWithThing:thing];
    [SVProgressHUD dismiss];
    
    [SVProgressHUD showSuccessWithStatus:@"我的信息成功更新。"];
}

- (IBAction)logoutClicked:(id)sender {
    [[HAMTourManager tourManager] logout];
}

#pragma mark - UI Delegate

- (void)tapedView:(UITapGestureRecognizer *)gesture{
    [self.nameTextView resignFirstResponder];
    [self.introTextView resignFirstResponder];
    [self.urlTextField resignFirstResponder];
    [self.wechatTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    return YES;
}

@end
