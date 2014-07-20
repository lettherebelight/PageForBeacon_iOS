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
#import "SVProgressHUD.h"

#import "HAMGlobalData.h"
#import "HAMThing.h"


#import "HAMBeaconManager.h"
#import "HAMTourManager.h"
#import "HAMDataManager.h"
#import "HAMAVOSManager.h"

#import "HAMTools.h"
#import "HAMViewTools.h"
#import "HAMLogTool.h"

@interface HAMIndexViewController_iPhone ()

@end

@implementation HAMIndexViewController_iPhone

typedef enum loginType {
    CHOOSE = 0,
    WEIBO,
    QQ
}LoginType;

LoginType loginSetting;

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
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    if ([self checkWebStatus] == NO)
        return;
    
    //FIXME: login twice here!
    if ([AVUser currentUser] != nil) {
        AVObject *card = [[AVUser currentUser] objectForKey:@"card"];
        if (card != nil) {
            [card fetchIfNeeded];
            HAMThing *selfCard = [HAMAVOSManager thingWithThingAVObject:card];
            [[HAMTourManager tourManager] newUserWithThing:selfCard];
        }
        [self login];
        return;
    }
    [self getSettings];
    if (loginSetting == WEIBO) {
        [self loginFromWeibo];
    } else if (loginSetting == QQ) {
        [self loginFromQQ];
    }
}

//- (IBAction)defaultLogIn:(id)sender {
//    [[HAMTourManager tourManager] newVisitor];
//    [[HAMUserManager userManager] newUserWithUserID:[HAMTourManager tourManager].currentVisitor name:@"匿名用户" avatar:nil description:nil];
//    [self performSegueWithIdentifier:@"finishLogIn" sender:self];
//}

- (Boolean)checkWebStatus{
    if ([HAMTools isWebAvailable] == NO) {
        [HAMViewTools showAlert:@"请检查您的网络是否通畅。" title:@"无法登录!" delegate:self];
        return NO;
    }
    return YES;
}

- (IBAction)logInFromWeibo:(id)sender {
    if ([self checkWebStatus] == NO) {
        return;
    }
    
    [self loginFromWeibo];
    
}

- (IBAction)logInFromQQ:(id)sender {
    if ([self checkWebStatus] == NO) {
        return;
    }
    
    [self loginFromQQ];
}

- (void)getSettings {
    HAMGlobalData *globalData = [HAMDataManager globalData];
    if ([globalData.lastLogin isEqualToString:@"WEIBO"]) {
        loginSetting = WEIBO;
    } else if ([globalData.lastLogin isEqualToString:@"QQ"]) {
        loginSetting = QQ;
    } else {
        loginSetting = CHOOSE;
    }
}

- (void)loginFromWeibo {
    
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo withAppKey:@"464699941" andAppSecret:@"768924e9a4ef519a95809253ebc886ea" andRedirectURI:nil];
    
    [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
        [SVProgressHUD showWithStatus:@"微博登录中" maskType:SVProgressHUDMaskTypeClear];
        
        if (error) {
            NSLog(@"%@",error);
            [SVProgressHUD dismiss];
            return;
        }
        
        [AVUser loginWithAuthData:object block:^(AVUser *user, NSError *error) {
            if (error) {
                NSLog(@"%@",error);
                [SVProgressHUD dismiss];
                return ;
            }
            
            [HAMDataManager globalData].lastLogin = @"WEIBO";
            [HAMDataManager saveData];
            
            AVObject *card = [user objectForKey:@"card"];
            HAMThing *selfCard;
            if (card == nil) {
                NSDictionary *userDict = object;
                NSString *name = [userDict objectForKey:@"username"];
                NSString *avatar = [userDict objectForKey:@"avatar"];
                NSDictionary *userRawData = [userDict objectForKey:@"raw-user"];
                NSString *description = [userRawData objectForKey:@"description"];
                
                user.username = name;
                [user save];
                
                selfCard = [[HAMThing alloc] init];
                selfCard.type = HAMThingTypeCard;
                selfCard.title = name;
                selfCard.content = description;
                selfCard.coverURL = avatar;
                [HAMAVOSManager saveCurrentUserCard:selfCard];
            } else {
                [card fetchIfNeeded];
                selfCard = [HAMAVOSManager thingWithThingAVObject:card];
            }
            [[HAMTourManager tourManager] newUserWithThing:selfCard];
        
            [self login];
        }];
    } toPlatform:AVOSCloudSNSSinaWeibo];
}

- (void)loginFromQQ {
    
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSQQ withAppKey:@"1101349087" andAppSecret:@"BAj9jn2xOw9eM7c2" andRedirectURI:nil];
    
    [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
        [SVProgressHUD showWithStatus:@"QQ登录中" maskType:SVProgressHUDMaskTypeClear];

        if (error) {
            NSLog(@"QQ Login Error:%@",error);
            [SVProgressHUD dismiss];
            return;
        }
        
        [AVUser loginWithAuthData:object block:^(AVUser *user, NSError *error) {
            if (error) {
                NSLog(@"QQ LoginWithAuthData error:%@",error);
                [SVProgressHUD dismiss];
                return;
            }
            
            [HAMDataManager globalData].lastLogin = @"QQ";
            [HAMDataManager saveData];
            
            AVObject *card = [user objectForKey:@"card"];
            HAMThing *selfCard;
            if (card == nil) {
                NSDictionary *userDict = object;
                NSString *name = [userDict objectForKey:@"username"];
                NSString *avatar = [userDict objectForKey:@"avatar"];
                
                user.username = name;
                [user save];
                
                selfCard = [[HAMThing alloc] init];
                selfCard.type = HAMThingTypeCard;
                selfCard.title = name;
                selfCard.coverURL = avatar;
                [HAMAVOSManager saveCurrentUserCard:selfCard];
            } else {
                [card fetchIfNeeded];
                selfCard = [HAMAVOSManager thingWithThingAVObject:card];
            }
            [[HAMTourManager tourManager] newUserWithThing:selfCard];
           
            [self login];
        }];
    } toPlatform:AVOSCloudSNSQQ];
}

- (void)login {
    [SVProgressHUD dismiss];
    [self performSegueWithIdentifier:@"finishLogIn" sender:self];
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
