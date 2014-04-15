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

@interface HAMDetailViewController ()

@end

@implementation HAMDetailViewController

static int loadingViewTag = 22;

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
    // Set Navigation Bar
    UIBarButtonItem *bItem;
    if ([self.homepage.marked  isEqual: @NO]) {
        bItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(performFavorite)];
    } else {
        bItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(performUnFavorite)];
    }
    self.navigationItem.rightBarButtonItem= bItem;
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

- (void)performFavorite {
    self.homepage.marked = @YES;
}

- (void)performUnFavorite {
    self.homepage.marked = @NO;
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"加载失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
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
