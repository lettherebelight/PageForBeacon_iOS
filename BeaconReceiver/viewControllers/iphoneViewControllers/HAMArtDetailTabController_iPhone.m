//
//  HAMArtDetailTabController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 5/4/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMArtDetailTabController_iPhone.h"
#import "HAMHomepageData.h"
#import "HAMTourManager.h"
#import "HAMDiscoverTableViewController_iPhone.h"
#import "HAMDiscoverCollectionViewController_iPhone.h"
#import "HAMTools.h"
#import "SVProgressHUD.h"

@interface HAMArtDetailTabController_iPhone ()

@end

@implementation HAMArtDetailTabController_iPhone

UIColor *alertTintColor;
HAMHomepageData *newPage;

- (void)displayHomepage:(NSArray*)stuffsAround {
    if ([stuffsAround count] == 0) {
        return;
    }
    HAMHomepageData *homepage = [stuffsAround objectAtIndex:0];
    if (homepage != nil) {
        if (homepage == self.homepage) {
            self.navigationItem.title = pageTitle;
            self.navigationController.navigationBar.barTintColor = nil;
            [self.navigationController.navigationBar removeGestureRecognizer:switchDetailViewRecognizer];
        } else {
            newPage = homepage;
            self.navigationItem.title = [NSString stringWithFormat:@"新展品\t\t%@", pageTitle];
            self.navigationController.navigationBar.barTintColor = alertTintColor;
            [self.navigationController.navigationBar addGestureRecognizer:switchDetailViewRecognizer];
        }
    }
}

- (void)switchDetailView {
    [self.navigationController.navigationBar removeGestureRecognizer:switchDetailViewRecognizer];
    UIViewController *parent = [self parentViewController];
    UITabBarController *root = (UITabBarController*)[parent parentViewController];
    [root setSelectedIndex:0];
    UINavigationController *discoverNavigation = (UINavigationController*)[root selectedViewController];
    HAMDiscoverCollectionViewController_iPhone *discoverViewController = (HAMDiscoverCollectionViewController_iPhone*)[[discoverNavigation viewControllers] objectAtIndex:0];
    discoverViewController.pageForSegue = newPage;
    [self.navigationController popViewControllerAnimated:NO];
    [discoverViewController performSegueWithIdentifier:@"showArtDetailPage" sender:discoverViewController];
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
    newPage = nil;
    
    self.navigationController.navigationBar.barTintColor = nil;
    alertTintColor = [UIColor colorWithRed:237.0f / 255 green:239 / 255 blue:241 / 255 alpha:1];
    if ([self homepage] != nil) {
        pageTitle = [self homepage].pageTitle;
    }
    [HAMBeaconManager beaconManager].detailDelegate = self;
    
    // Set Navigation Bar
    self.navigationItem.title = pageTitle;
    UIBarButtonItem *favItem;
    if (self.homepage.markedListRecord == nil) {
        UIImage *originImage = [[UIImage imageNamed:@"fav-normal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *image = [HAMTools image:originImage changeToSize:CGSizeMake(22.0f, 22.0f)];
        
        favItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(performFavorite)];
    } else {
        UIImage *originImage = [[UIImage imageNamed:@"fav-selected-normal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *image = [HAMTools image:originImage changeToSize:CGSizeMake(22.0f, 22.0f)];
        
        favItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:self action:@selector(performUnFavorite)];
    }
    //UIBarButtonItem *refreshItem;
    //refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(performRefresh)];
    //UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    barItems = [NSMutableArray arrayWithObjects:favItem, nil];
    //barItems = [NSMutableArray arrayWithObjects:flexibleSpace, refreshItem, favItem, nil];
    //[self setToolbarItems:barItems];
    self.navigationItem.rightBarButtonItems = barItems;

}

- (void)performFavorite {
    [[HAMTourManager tourManager] addFavoriteStuff:self.homepage];
    UIImage *originImage = [[UIImage imageNamed:@"fav-selected-normal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *image = [HAMTools image:originImage changeToSize:CGSizeMake(22.0f, 22.0f)];
    
    UIBarButtonItem *favItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:self action:@selector(performUnFavorite)];
    self.navigationItem.rightBarButtonItem= favItem;
    //barItems = [NSMutableArray arrayWithObjects:[barItems objectAtIndex:0], [barItems objectAtIndex:1], favItem, nil];
    //[self setToolbarItems:barItems];
    [SVProgressHUD showSuccessWithStatus:@"收藏成功！"];
}

- (void)performUnFavorite {
    [[HAMTourManager tourManager] removeFavoriteStuff:self.homepage];
    UIImage *originImage = [[UIImage imageNamed:@"fav-normal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *image = [HAMTools image:originImage changeToSize:CGSizeMake(22.0f, 22.0f)];
    
    UIBarButtonItem *favItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(performFavorite)];
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
    [self.navigationController popViewControllerAnimated:NO];
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
