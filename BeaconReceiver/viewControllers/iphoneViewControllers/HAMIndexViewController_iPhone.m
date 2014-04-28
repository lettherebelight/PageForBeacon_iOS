//
//  HAMIndexViewController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 4/27/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMIndexViewController_iPhone.h"
#import <AVOSCloudSNS/AVOSCloudSNS.h>
#import <AVOSCloudSNS/AVUser+SNS.h>
#import "HAMLogTool.h"
#import "HAMBeaconManager.h"
#import "HAMTourManager.h"

@interface HAMIndexViewController_iPhone ()

@end

@implementation HAMIndexViewController_iPhone

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

- (IBAction)logInFromWeibo:(id)sender {
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo withAppKey:@"464699941" andAppSecret:@"768924e9a4ef519a95809253ebc886ea" andRedirectURI:@"http://www.weibo.com"];
    
    [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
        //you code here
        if (!error) {
            [AVUser loginWithAuthData:object block:^(AVUser *user, NSError *error) {
                if (!error) {
                    [self logInWithUser:user];
                }
                else {
                    NSLog(@"%@",error);
                }
            }];
        }
        else {
            NSLog(@"%@",error);
        }
    } toPlatform:AVOSCloudSNSSinaWeibo];
    
}

- (void)logInWithUser:(AVUser*)user {
    [[HAMTourManager tourManager]newVisitorWithID:user.objectId];
    [self performSegueWithIdentifier:@"finishLogIn" sender:self];
}

- (IBAction)logInFromQQ:(id)sender {
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSQQ withAppKey:@"1101349087" andAppSecret:@"BAj9jn2xOw9eM7c2" andRedirectURI:@"http://www.weibo.com"];
    
    [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
        //you code here
        if (!error) {
            [AVUser loginWithAuthData:object block:^(AVUser *user, NSError *error) {
                if (!error) {
                    [self logInWithUser:user];
                }
                else {
                    NSLog(@"%@",error);
                }
            }];
        }
        else {
            NSLog(@"%@",error);
        }
    } toPlatform:AVOSCloudSNSQQ];
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
