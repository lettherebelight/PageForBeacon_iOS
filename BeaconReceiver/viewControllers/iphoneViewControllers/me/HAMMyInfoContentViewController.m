//
//  HAMMyInfoContentViewController.m
//  BeaconReceiver
//
//  Created by daiyue on 6/1/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMMyInfoContentViewController.h"

#import "HAMMyInfoViewController.h"
#import "SVProgressHUD.h"

#import "HAMThing.h"

#import "HAMTourManager.h"
#import "HAMAVOSManager.h"

#import "HAMViewTools.h"
#import "HAMTools.h"

@interface HAMMyInfoContentViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *introTextView;

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UITextField *wechatTextField;
@property (weak, nonatomic) IBOutlet UITextField *weiboTextField;
@property (weak, nonatomic) IBOutlet UITextField *qqTextField;

@end

@implementation HAMMyInfoContentViewController

@synthesize containerViewController;

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
    
    //round corner
    self.view.layer.cornerRadius = 6;
    [self.view.layer setMasksToBounds:YES];
    
    //round corner on textView
    [HAMViewTools setTextViewBorder:self.introTextView];
    
    //tap view gesture - resign text fields
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapedView:)];
    [self.view addGestureRecognizer:tapGesture];
    
    //data prepare
    HAMThing* card = [[HAMTourManager tourManager] currentUserThing];
    
    UIImage* avatarImageRaw = [HAMTools imageFromURL:card.coverURL];
    UIImage *avatarImageResized = [HAMTools image:avatarImageRaw staysShapeChangeToSize:self.avatarImageView.frame.size];
    self.avatarImageView.image = avatarImageResized;
    
    self.nameTextField.text = card.title;
    self.introTextView.text = card.content;
    
    self.urlTextField.text = card.url;
    self.wechatTextField.text = card.wechat;
    self.weiboTextField.text = card.weibo;
    self.qqTextField.text = card.qq;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated{
}

#pragma mark - Actions

- (IBAction)saveMyInfoClicked:(id)sender {
    //collapse keyboard, just like when taped view
    [self tapedView:nil];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    HAMThing* thing = [[HAMTourManager tourManager]currentUserThing];
    thing.title = self.nameTextField.text;
    thing.content = self.introTextView.text;
    
    thing.url = self.urlTextField.text;
    thing.wechat = self.wechatTextField.text;
    thing.weibo = self.weiboTextField.text;
    thing.qq = self.qqTextField.text;
    
    [HAMAVOSManager updateCurrentUserCardWithThing:thing];
    
    [SVProgressHUD showSuccessWithStatus:@"我的信息成功更新。"];
}

- (IBAction)logoutClicked:(id)sender {
    [[HAMTourManager tourManager] logout];
    [containerViewController performSegueWithIdentifier:@"backToIndex" sender:self];
}

#pragma mark - UI Delegate

- (void)tapedView:(UITapGestureRecognizer *)gesture{
    [self.nameTextField resignFirstResponder];
    [self.introTextView resignFirstResponder];
    [self.weiboTextField resignFirstResponder];
    [self.qqTextField resignFirstResponder];
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

#pragma mark - textfield delegate
//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    
    UIScrollView *superScrollView = (UIScrollView*)self.view.superview;
    int offset = self.view.frame.origin.y + frame.origin.y + frame.size.height - superScrollView.contentOffset.y + 160.0f - (self.view.frame.size.height - 216.0);//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, self.view.frame.origin.y - offset, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame =CGRectMake(0, 93.0f, self.view.frame.size.width, self.view.frame.size.height);
}


@end
