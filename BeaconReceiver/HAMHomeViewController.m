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
    timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(handleTimer) userInfo:nil repeats:NO];
    [timer setFireDate:[NSDate distantFuture]];
    [HAMBeaconManager beaconManager].delegate = self;
    [HAMDataManager clearData];
    [[HAMTourManager tourManager] newVisitor];
    [[HAMBeaconManager beaconManager] startMonitor];
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

- (void)displayHomepage:(NSArray*)stuffsAround {
    HAMHomepageData *nearestPage = nil;
    UINavigationController *navigation = (UINavigationController*)[contentTabView.viewControllers objectAtIndex:1];
    HAMThumbnailViewController *thumbnailVC = (HAMThumbnailViewController*)[navigation.viewControllers objectAtIndex:0];
    if ([stuffsAround count] == 0) {
        nearestPageIsNil = YES;
        if (canShowNilPage == YES) {
            thumbnailVC.homepage = nil;
            [thumbnailVC updateView];
        }
        return;
    }
    HAMHomepageData *homepage = [stuffsAround objectAtIndex:0];
    if (homepage != nil) {
        nearestPage = homepage;
        //[contentTabView setSelectedIndex:1];
        //contentTabView.tabBar.hidden = YES;
        //[navigation popToRootViewControllerAnimated:NO];
        nearestPageIsNil = NO;
        canShowNilPage = NO;
        thumbnailVC.homepage = nearestPage;
        
        [timer setFireDate:[NSDate date]];
        
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [thumbnailVC updateView];
    }
    else {
        nearestPageIsNil = YES;
        if (canShowNilPage == YES) {
            thumbnailVC.homepage = nil;
            [thumbnailVC updateView];
        }
    }
    return;
}

- (void)handleTimer {
    canShowNilPage = YES;
    if (nearestPageIsNil == YES) {
        UINavigationController *navigation = (UINavigationController*)[contentTabView.viewControllers objectAtIndex:1];
        HAMThumbnailViewController *thumbnailVC = (HAMThumbnailViewController*)[navigation.viewControllers objectAtIndex:0];
        thumbnailVC.homepage = nil;
        [thumbnailVC updateView];
    }
}

- (Boolean)showHomePage {
    if (contentTabView.selectedIndex == 2) {
        CATransition *transition = [CATransition animation];
        [transition setDuration:0.3];
        [transition setType:kCATransitionReveal];
        [transition setSubtype:kCATransitionFromRight];
        [contentTabView.view.layer addAnimation:transition forKey:nil];
    }
    [contentTabView setSelectedIndex:1];
    contentTabView.tabBar.hidden = YES;
    
    UINavigationController *navigation = (UINavigationController*)[contentTabView selectedViewController];
    [navigation popToRootViewControllerAnimated:NO];
    
    HAMThumbnailViewController *thumbnailVC = [[navigation viewControllers] objectAtIndex:0];
    [thumbnailVC initView];
    return YES;
}

- (Boolean)showFavorites {
    if (contentTabView.selectedIndex == 1) {
        CATransition *transition = [CATransition animation];
        [transition setDuration:0.3];
        [transition setType:kCATransitionMoveIn];
        [transition setSubtype:kCATransitionFromLeft];
        [contentTabView.view.layer addAnimation:transition forKey:nil];

    }
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
