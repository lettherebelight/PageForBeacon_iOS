//
//  HAMArtDetailTabController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 5/4/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMArtDetailTabController_iPhone.h"
#import "HAMThing.h"
#import "HAMTourManager.h"
#import "HAMDiscoverViewController_iPhone.h"
#import "HAMTools.h"
#import "SVProgressHUD.h"
#import "HAMAVOSManager.h"

@interface HAMArtDetailTabController_iPhone ()

@end

@implementation HAMArtDetailTabController_iPhone

UIColor *alertTintColor;
HAMThing *newThing;

- (void)displayThings:(NSArray *)things {
    if ([things count] == 0) {
        return;
    }
    HAMThing *thing = [things objectAtIndex:0];
    if (thing != nil) {
        if ([thing isEqualToThing:self.thing]) {
            self.navigationItem.title = pageTitle;
            self.navigationController.navigationBar.barTintColor = nil;
            [self.navigationController.navigationBar removeGestureRecognizer:switchDetailViewRecognizer];
        } else {
            newThing = thing;
            self.navigationItem.title = [NSString stringWithFormat:@"新展品\t\t%@", pageTitle];
            self.navigationController.navigationBar.barTintColor = alertTintColor;
            [self.navigationController.navigationBar addSubview:switchArea];
        }
    }
}

- (void)switchDetailView {
    [switchArea removeFromSuperview];
    UIViewController *parent = [self parentViewController];
    UITabBarController *root = (UITabBarController*)[parent parentViewController];
    [root setSelectedIndex:0];
    UINavigationController *discoverNavigation = (UINavigationController*)[root selectedViewController];
    HAMDiscoverViewController_iPhone *discoverViewController = (HAMDiscoverViewController_iPhone*)[[discoverNavigation viewControllers] objectAtIndex:0];
    [self.navigationController popViewControllerAnimated:NO];
    [discoverViewController showDetailWithThing:newThing sender:self];
}

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
    pageTitle = @"title";
    
    switchDetailViewRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchDetailView)];
    newThing = nil;
    
    self.navigationController.navigationBar.barTintColor = nil;
    alertTintColor = [UIColor colorWithRed:237.0f / 255 green:239 / 255 blue:241 / 255 alpha:1];
    if (self.thing != nil) {
        pageTitle = self.thing.title;
    }
    
    //for new thing
    //[HAMBeaconManager beaconManager].detailDelegate = self;
//    switchArea = [[UIView alloc] initWithFrame:CGRectMake(50, 0, 220, self.navigationController.navigationBar.frame.size.height)];
//    [switchArea addGestureRecognizer:switchDetailViewRecognizer];
    
    
    // Set Navigation Bar
    self.navigationItem.title = pageTitle;
    UIBarButtonItem *favItem;
    if ([HAMAVOSManager isThingFavoriteOfCurrentUser:self.thing]) {
        UIImage *favImage = [[UIImage imageNamed:@"common_icon_liked_selected.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
        favItem = [[UIBarButtonItem alloc] initWithImage:favImage style:UIBarButtonItemStyleBordered target:self action:@selector(performUnFavorite)];
    } else {
        UIImage *favImage = [[UIImage imageNamed:@"ios7-heart-outline.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
        favItem = [[UIBarButtonItem alloc] initWithImage:favImage style:UIBarButtonItemStylePlain target:self action:@selector(performFavorite)];
    }
    barItems = [NSMutableArray arrayWithObjects:favItem, nil];
    
    //UIBarButtonItem *refreshItem;
    //refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(performRefresh)];
    //UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    //barItems = [NSMutableArray arrayWithObjects:flexibleSpace, refreshItem, favItem, nil];
    //[self setToolbarItems:barItems];
    self.navigationItem.rightBarButtonItems = barItems;

}

- (void)performFavorite {
    [[HAMTourManager tourManager] addFavoriteThing:self.thing];
    UIImage *favImage = [[UIImage imageNamed:@"ios7-heart.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    UIBarButtonItem *favItem = [[UIBarButtonItem alloc] initWithImage:favImage style:UIBarButtonItemStyleBordered target:self action:@selector(performUnFavorite)];
    self.navigationItem.rightBarButtonItem= favItem;
    //barItems = [NSMutableArray arrayWithObjects:[barItems objectAtIndex:0], [barItems objectAtIndex:1], favItem, nil];
    //[self setToolbarItems:barItems];
    [SVProgressHUD showSuccessWithStatus:@"收藏成功！"];
}

- (void)performUnFavorite {
    [[HAMTourManager tourManager] removeFavoriteThing:self.thing];
    UIImage *favImage = [[UIImage imageNamed:@"ios7-heart-outline.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    UIBarButtonItem *favItem = [[UIBarButtonItem alloc] initWithImage:favImage style:UIBarButtonItemStylePlain target:self action:@selector(performFavorite)];
    self.navigationItem.rightBarButtonItem= favItem;
    //barItems = [NSMutableArray arrayWithObjects:[barItems objectAtIndex:0], [barItems objectAtIndex:1], favItem, nil];
    //[self setToolbarItems:barItems];
    [SVProgressHUD showSuccessWithStatus:@"取消收藏。"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self.navigationController setToolbarHidden:YES animated:animated];
    //[self.navigationController popViewControllerAnimated:NO];
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
