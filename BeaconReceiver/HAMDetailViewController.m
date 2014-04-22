//
//  HAMDetailViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-11.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMDetailViewController.h"
#import "HAMTools.h"
#import "HAMHomepageData.h"
#import "HAMDataManager.h"
#import "HAMThumbnailViewController.h"

@interface HAMDetailViewController ()

@end

@implementation HAMDetailViewController

static int loadingViewTag = 22;
UIColor *alertTintColor;

- (void)displayHomepage:(HAMHomepageData *)homepage {
    if (homepage != nil) {
        if (homepage == self.homepage) {
            self.navigationItem.title = pageTitle;
            self.navigationController.navigationBar.barTintColor = nil;
            [self.navigationController.navigationBar removeGestureRecognizer:backToHomeRecognizer];
        } else {
            self.navigationItem.title = [NSString stringWithFormat:@"新展品\t\t%@", pageTitle];
            self.navigationController.navigationBar.barTintColor = alertTintColor;
            [self.navigationController.navigationBar addGestureRecognizer:backToHomeRecognizer];
        }
    }
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
    backToHomeRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToHome)];
    
    self.navigationController.navigationBar.barTintColor = nil;
    alertTintColor = [UIColor colorWithRed:237.0f / 255 green:239 / 255 blue:241 / 255 alpha:1];
    if ([self homepage] != nil) {
        pageURL = [self homepage].pageURL;
        pageTitle = [self homepage].pageTitle;
    }
    [HAMBeaconManager beaconManager].detailDelegate = self;
    // Set Navigation Bar
    //self.navigationController.navigationBar.barTintColor = normalTintColor;
    //self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:@"UITextAttributeTextColor"];
    UIBarButtonItem *favItem;
    if (self.homepage.markedListRecord == nil) {
        //favItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(performFavorite)];
        //favItem = [[UIBarButtonItem alloc] initWithTitle:@"MARK" style:UIBarButtonItemStylePlain target:self action:@selector(performFavorite)];
        UIImage *originImage = [[UIImage imageNamed:@"fav-normal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *image = [HAMTools image:originImage changeToSize:CGSizeMake(22.0f, 22.0f)];
        
        favItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(performFavorite)];
    } else {
        //favItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(performUnFavorite)];
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

- (void)backToHome {
    [self.navigationController.navigationBar removeGestureRecognizer:backToHomeRecognizer];
    HAMThumbnailViewController *parentView = [self.navigationController.viewControllers objectAtIndex:0];
    [self.navigationController popViewControllerAnimated:NO];
    [parentView performSegueWithIdentifier:@"showDetailPage" sender:parentView];
    //[self removeFromParentViewController];
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

- (void)viewWillDisappear:(BOOL)animated {
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
