//
//  HAMDetailViewController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 4/27/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMArtDetailViewController_iPhone.h"
#import "HAMHomepageData.h"
#import "HAMDataManager.h"
#import "HAMDiscoverTableViewController_iPhone.h"
#import "HAMTools.h"

@interface HAMArtDetailViewController_iPhone ()

@end

@implementation HAMArtDetailViewController_iPhone

int loadingViewTag = 22;
UIColor *alertTintColor;
HAMHomepageData *newPage;

- (void)displayHomepage:(HAMHomepageData *)homepage {
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
    HAMDiscoverTableViewController_iPhone *discoverViewController = (HAMDiscoverTableViewController_iPhone*)[[discoverNavigation viewControllers] objectAtIndex:0];
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
    
    //initialize
    pageURL = @"http://www.baidu.com";
    pageTitle = @"title";
    switchDetailViewRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchDetailView)];
    newPage = nil;
    
    self.navigationController.navigationBar.barTintColor = nil;
    alertTintColor = [UIColor colorWithRed:237.0f / 255 green:239 / 255 blue:241 / 255 alpha:1];
    if ([self homepage] != nil) {
        pageURL = [self homepage].pageURL;
        pageTitle = [self homepage].pageTitle;
    }
    [HAMBeaconManager beaconManager].detailDelegate = self;
    // Set Navigation Bar
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
    UIBarButtonItem *refreshItem;
    refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(performRefresh)];
    NSArray *barItems = [[NSArray alloc] initWithObjects:favItem, refreshItem, nil];
    self.navigationItem.rightBarButtonItems = barItems;
    self.navigationItem.title = pageTitle;
    
    // Load Website
    if ([HAMTools isWebAvailable]) {
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:pageURL]];
        [self.detailWebView loadRequest:request];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无网络连接" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)performRefresh {
    [self.detailWebView reload];
}

- (void)performFavorite {
    [HAMDataManager addAMarkedRecord:self.homepage];
    UIImage *originImage = [[UIImage imageNamed:@"fav-selected-normal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *image = [HAMTools image:originImage changeToSize:CGSizeMake(22.0f, 22.0f)];
    
    UIBarButtonItem *favItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:self action:@selector(performUnFavorite)];
    self.navigationItem.rightBarButtonItem= favItem;
}

- (void)performUnFavorite {
    [HAMDataManager removeMarkedRecord:self.homepage];
    UIImage *originImage = [[UIImage imageNamed:@"fav-normal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *image = [HAMTools image:originImage changeToSize:CGSizeMake(22.0f, 22.0f)];
    
    UIBarButtonItem *favItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(performFavorite)];
    self.navigationItem.rightBarButtonItem= favItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController popViewControllerAnimated:NO];
    [self.detailWebView stopLoading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - perform UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 874.0f, 768.0f)];
    [view setTag:loadingViewTag];
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:0.5];
    [self.view addSubview:view];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [activityIndicator setCenter:view.center];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [view addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    UIView *view = (UIView*)[self.view viewWithTag:loadingViewTag];
    [view removeFromSuperview];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIView *view = (UIView*)[self.view viewWithTag:loadingViewTag];
    [view removeFromSuperview];
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"加载失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    //[alert show];
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
