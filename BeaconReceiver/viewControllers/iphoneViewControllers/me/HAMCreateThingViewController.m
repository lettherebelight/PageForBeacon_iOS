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
@property UIImagePickerController* imagePicker;

- (IBAction)confirmButtonClicked:(id)sender;

@end

static HAMThingType kHAMDefaultThingType = HAMThingTypeArt;

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
    [SVProgressHUD show];
}

- (void)didBindThing:(NSNumber *)result error:(NSError *)error {
    if (error != nil) {
        [HAMLogTool error:[NSString stringWithFormat:@"Error when bind thing to beacon: %@",error.userInfo]];
        [SVProgressHUD showErrorWithStatus:@"绑定thing至Beacon出错。"];
        return;
    }
    
    [SVProgressHUD dismiss];
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
                                  otherButtonTitles:nil];

    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        NSArray* availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        for (NSString* mediaType in availableMediaTypes) {
            if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
                //support taking picture
                [actionSheet addButtonWithTitle:@"拍照"];
                break;
            }
        }
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        NSArray* availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        for (NSString* mediaType in availableMediaTypes) {
            if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
                //support choosing picture
                [actionSheet addButtonWithTitle:@"从照片库选取"];
                break;
            }
        }
    }
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (self.imagePicker == nil) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = YES;
        self.imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString*)kUTTypeImage,nil];
    }
    
    switch (buttonIndex) {
        case 1:
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
            
        case 2:
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
            
        default:
            //cancel
            break;
    }
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if (![[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
        [SVProgressHUD showErrorWithStatus:@"这不是合法的封面类型。"];
        return;
    }
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
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
