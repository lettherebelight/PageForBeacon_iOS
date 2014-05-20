//
//  HAMCreateThingViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-17.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMCreateThingViewController.h"

#import <MobileCoreServices/UTCoreTypes.h>

#import "HAMThing.h"

#import "HAMAVOSManager.h"

#import "SVProgressHUD.h"
#import "HAMLogTool.h"

@interface HAMCreateThingViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rangeSegmentedControl;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property UIImage* coverImage;

- (IBAction)confirmButtonClicked:(id)sender;

@end

static NSString* const kHAMDefaultThingType = @"art";

@implementation HAMCreateThingViewController

@synthesize beaconToBind;

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
    
    //tap view gesture - resign text fields
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapedView:)];
    [self.view addGestureRecognizer:tapGesture];
    
    //tap view gesture - change cover
    UITapGestureRecognizer* imageViewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapedImageView:)];
    [self.coverImageView addGestureRecognizer:imageViewTapGesture];
    
    self.coverImage = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Bind

- (IBAction)confirmButtonClicked:(id)sender {
    if (self.beaconToBind == nil) {
        [SVProgressHUD showErrorWithStatus:@"需要绑定的Beacon出错了。"];
    }
    
    NSString* title = self.titleTextField.text;
    if (title.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"标题不能为空。"];
        return;
    }
    NSString* content = self.contentTextView.text;
    if (content.length == 0) {
        content = nil;
    }
    NSString* url = self.urlTextField.text;
    if (url.length == 0) {
        url = nil;
    }
    NSInteger rangeIndex = [self.rangeSegmentedControl selectedSegmentIndex];
    NSInteger range;
    switch (rangeIndex) {
        case 0:
            range = CLProximityImmediate;
            break;
            
        case 1:
            range = CLProximityNear;
            break;
            
        case 2:
            range = CLProximityFar;
            break;

        default:
            [HAMLogTool error:@"Error range type"];
            range = CLProximityUnknown;
            break;
    }
    
    HAMThing* thing = [[HAMThing alloc] init];
    
    thing.type = kHAMDefaultThingType;
    
    thing.url = url;
    thing.title = title;
    thing.content = content;
    thing.cover = self.coverImage;
    
    thing.creator = [AVUser currentUser];
    
    [HAMAVOSManager bindThing:thing range:range toBeacon:beaconToBind withTarget:self callback:@selector(didBindThing:error:)];
    //TODO: add something indicate uploading here
}

- (void)didBindThing:(NSNumber *)result error:(NSError *)error {
    if (error != nil) {
        [HAMLogTool error:[NSString stringWithFormat:@"Error when bind thing to beacon: %@",error.userInfo]];
        [SVProgressHUD showErrorWithStatus:@"绑定thing至Beacon出错。"];
        return;
    }
    
    [SVProgressHUD showSuccessWithStatus:@"已创建Thing，并成功绑定Beacon。"];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Select Cover

- (void)tapedImageView:(UITapGestureRecognizer*)gesture{
//    + (NSArray *)availableMediaTypesForSourceType:(UIImagePickerControllerSourceType)sourceType;
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"设置封面图片"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"拍照",@"从相册中选取",nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    switch (buttonIndex) {
        case 0:
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
            
        case 1:
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
            
        default:
            //cancel
            break;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if (![[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
        //selected a video or something else
        return;
    }
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.coverImageView.image = image;
    self.coverImage = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UI Delegate

- (void)tapedView:(UITapGestureRecognizer *)gesture{
    [self.titleTextField resignFirstResponder];
    [self.contentTextView resignFirstResponder];
    [self.urlTextField resignFirstResponder];
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
