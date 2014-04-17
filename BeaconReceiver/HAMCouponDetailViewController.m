//
//  HAMCouponDetailViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-3-10.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HAMCouponDetailViewController.h"
#import "Reachability.h"
//#import "HAMHomepage.h"

@interface HAMCouponDetailViewController ()

@end

@implementation HAMCouponDetailViewController

@synthesize homepage;

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
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] != NotReachable) {
        self.homepageWebView.delegate = self;
        //NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:homepage.homepageURL]];
        //[self.homepageWebView loadRequest:request];
    }

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
