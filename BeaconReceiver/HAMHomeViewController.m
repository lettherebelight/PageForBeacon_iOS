//
//  HAMHomeViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-11.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMHomeViewController.h"
#import "HAMHomepageData.h"
#import "HAMThumbnailViewController.h"
#import "HAMDataManager.h"

@interface HAMHomeViewController ()

@end

@implementation HAMHomeViewController

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
    [[HAMBeaconManager beaconManager] startMonitor];
    [HAMBeaconManager beaconManager].delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showSideBar"]) {
        HAMSideBarViewController *sideBar = [segue destinationViewController];
        sideBar.delegate = self;
    } else if ([segue.identifier isEqualToString:@"showContentView"]) {
        contentTabView = [segue destinationViewController];
        contentTabView.tabBar.hidden = YES;
    }
}

#pragma mark - perform delegate

- (void)displayHomepage:(NSArray *)homepageArray {
    if ([homepageArray count] > 0) {
        HAMHomepageData *nearestPage = [homepageArray objectAtIndex:0];
        NSString *info = [NSString stringWithFormat:@"%@%@%@", nearestPage.beaconID, nearestPage.beaconMajor, nearestPage.beaconMinor];
        if (homepageInfo != nil && [homepageInfo isEqualToString:info]) {
            return;
        } else {
            homepageInfo = info;
            [contentTabView setSelectedIndex:1];
            contentTabView.tabBar.hidden = YES;
            
            UINavigationController *navigation = (UINavigationController*)[contentTabView selectedViewController];
            [navigation popToRootViewControllerAnimated:NO];
            
            HAMThumbnailViewController *thumbnailVC = (HAMThumbnailViewController*)[navigation.viewControllers objectAtIndex:0];
            thumbnailVC.homepage = nearestPage;
            [thumbnailVC updateView];
        }
    }
    else {
        homepageInfo = nil;
    }
    return;
}

- (Boolean)showHomePage {
    if (homepageInfo == nil) {
        [contentTabView setSelectedIndex:0];
    }
    else {
        [contentTabView setSelectedIndex:1];
    }
    contentTabView.tabBar.hidden = YES;
    return YES;
}

- (Boolean)showFavorites {
    [contentTabView setSelectedIndex:2];
    contentTabView.tabBar.hidden = YES;
    UINavigationController *navigation = (UINavigationController*)[contentTabView selectedViewController];
    [navigation popToRootViewControllerAnimated:NO];
    return YES;
}

- (Boolean)resetData {
    [HAMDataManager clearData];
    return YES;
}


@end
