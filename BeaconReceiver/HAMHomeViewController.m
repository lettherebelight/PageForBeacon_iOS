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
#import "HAMFavoritesViewController.h"
#import "HAMDataManager.h"
#import "HAMBeaconManager.h"
#import "HAMTourManager.h"

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
    [HAMDataManager clearData];
    [[HAMTourManager tourManager] newVisitor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initLoginInStatus {
    
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
        [contentTabView setSelectedIndex:1];
        contentTabView.tabBar.hidden = YES;
    }
}

#pragma mark - perform delegate

- (void)displayHomepage:(HAMHomepageData*)homepage {
    HAMHomepageData *nearestPage = nil;
    UINavigationController *navigation = (UINavigationController*)[contentTabView.viewControllers objectAtIndex:1];
    HAMThumbnailViewController *thumbnailVC = (HAMThumbnailViewController*)[navigation.viewControllers objectAtIndex:0];
    if (homepage != nil) {
        nearestPage = homepage;
        //[contentTabView setSelectedIndex:1];
        //contentTabView.tabBar.hidden = YES;
        //[navigation popToRootViewControllerAnimated:NO];
        thumbnailVC.homepage = nearestPage;
        [thumbnailVC updateView];
    }
    else {
        
        thumbnailVC.homepage = nil;
        [thumbnailVC updateView];
        
    }
    return;
}

- (Boolean)showHomePage {
    [contentTabView setSelectedIndex:1];
    contentTabView.tabBar.hidden = YES;
    
    UINavigationController *navigation = (UINavigationController*)[contentTabView selectedViewController];
    [navigation popToRootViewControllerAnimated:NO];
    
    HAMThumbnailViewController *thumbnailVC = [[navigation viewControllers] objectAtIndex:0];
    [thumbnailVC updateView];
    return YES;
}

- (Boolean)showFavorites {
    [contentTabView setSelectedIndex:2];
    contentTabView.tabBar.hidden = YES;
    UINavigationController *navigation = (UINavigationController*)[contentTabView selectedViewController];
    [navigation popToRootViewControllerAnimated:NO];
    
    HAMFavoritesViewController *favoritesVC = [[navigation viewControllers] objectAtIndex:0];
    [favoritesVC loadCollections];
    return YES;
}

- (Boolean)resetData {
    [HAMDataManager clearData];
    [[HAMTourManager tourManager] newVisitor];
    UINavigationController *navigation;
    navigation = (UINavigationController*)[[contentTabView viewControllers] objectAtIndex:1];
    HAMThumbnailViewController *thumbnailVC = [[navigation viewControllers] objectAtIndex:0];
    thumbnailVC.homepage = nil;
    [thumbnailVC updateView];
    navigation = (UINavigationController*)[[contentTabView viewControllers] objectAtIndex:2];
    HAMFavoritesViewController *favoritesVC = [[navigation viewControllers] objectAtIndex:0];
    [favoritesVC loadCollections];
    [[HAMBeaconManager beaconManager] startMonitor];
    return YES;
}


@end
