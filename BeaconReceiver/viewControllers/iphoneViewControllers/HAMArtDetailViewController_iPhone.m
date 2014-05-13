//
//  HAMDetailViewController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 4/27/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMArtDetailViewController_iPhone.h"
#import "HAMHomepageData.h"
#import "HAMTourManager.h"
#import "HAMDiscoverCollectionViewController_iPhone.h"
#import "HAMTools.h"
#import "SVProgressHUD.h"
#import "HAMArtDetailTabController_iPhone.h"

@interface HAMArtDetailViewController_iPhone ()

@end

@implementation HAMArtDetailViewController_iPhone

int loadingViewTag = 22;

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
    
    HAMArtDetailTabController_iPhone *detailTabVC = (HAMArtDetailTabController_iPhone*)self.parentViewController;
    self.homepage = detailTabVC.homepage;
    
    if (self.homepage != nil) {
        pageURL = self.homepage.pageURL;
    }
    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self.navigationController setToolbarHidden:YES animated:animated];
    //[self.navigationController popViewControllerAnimated:NO];
    //[self.detailWebView stopLoading];
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
