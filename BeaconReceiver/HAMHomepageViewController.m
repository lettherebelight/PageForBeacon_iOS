//
//  HAMHomepageViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-3-26.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMHomepageViewController.h"
#import "HAMHomepage.h"
#import "HAMHomepageManager.h"
#import "Reachability.h"
#import "HAMCouponDetailViewController.h"

@interface HAMHomepageViewController ()

@end

@implementation HAMHomepageViewController
@synthesize homepageWebView;

typedef enum {
    DrawerStateUp = 0,
    DrawerStateDown
}DrawerState;

typedef enum {
    PageNotLoaded = 0,
    PageLoadSuccessfully,
    PageLoadFailed
}PageLoadState;

HAMHomepage *homepage = nil;
PageLoadState pageLoadState = PageNotLoaded;
DrawerState drawerState = DrawerStateDown;

- (void)displayHomepage:(NSArray *)homepageArray {
    if ([homepageArray count] != 0) {
        /*HAMHomepage *nearestHome = [homepageArray objectAtIndex:0];
        if (nearestHome.homepageURL == nil) return;
        if (homepage == nil || [homepage.homepageURL isEqualToString:nearestHome.homepageURL] == NO) {
            homepage = nearestHome;
            pageLoadState = PageNotLoaded;
            [[HAMHomepageManager homepageVisited] addObject:homepage];
            UIView *view = (UIView*)[self.view viewWithTag:21];
            if (view != nil) {
                [view removeFromSuperview];
            }
            if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] != NotReachable) {
                self.homepageWebView.delegate = self;
                NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:homepage.homepageURL]];
                [self.homepageWebView loadRequest:request];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无网络连接" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        }*/
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
    [[HAMBeaconManager beaconManager] startMonitor];
    
    [HAMBeaconManager beaconManager].delegate = self;
    
    pageLoadState = PageNotLoaded;
    
    if (homepage == nil) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 100)];
        [view setBackgroundColor:[UIColor whiteColor]];
        [view setTag:21];
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 32.0f)];
        [textField setCenter:view.center];
        textField.text = @"no beacon around.";
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField setEnabled:NO];
        [view addSubview:textField];
        [self.view addSubview:view];
    }
    else {
        if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] != NotReachable) {
            self.homepageWebView.delegate = self;
            //NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:homepage.homepageURL]];
            //[self.homepageWebView loadRequest:request];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无网络连接" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    // Do any additional setup after loading the view.
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(30, 105, 260, 350)];
    [view setTag:22];
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
    UIView *view = (UIView*)[self.view viewWithTag:22];
    [view removeFromSuperview];
    pageLoadState = PageLoadSuccessfully;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIView *view = (UIView*)[self.view viewWithTag:22];
    [view removeFromSuperview];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"加载失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    pageLoadState = PageLoadFailed;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)drawerClicked:(id)sender {
    [UIView animateWithDuration:0.75 delay:0.15 options:UIViewAnimationOptionTransitionCurlUp animations:^{
        if (drawerState == DrawerStateDown) {
            self.historyCollectionView.center = CGPointMake(self.historyCollectionView.center.x, self.historyCollectionView.center.y - 350);
            self.drawerButton.center = CGPointMake(self.drawerButton.center.x, self.drawerButton.center.y - 350);
            drawerState = DrawerStateUp;
        }
        else {
            self.historyCollectionView.center = CGPointMake(self.historyCollectionView.center.x, self.historyCollectionView.center.y + 350);
            self.drawerButton.center = CGPointMake(self.drawerButton.center.x, self.drawerButton.center.y + 350);
            drawerState = DrawerStateDown;
        }
    } completion:nil];
}

- (IBAction)pageClicked:(id)sender {
    //if (pageLoadState == PageLoadSuccessfully) {
        [self performSegueWithIdentifier:@"showDetailPage" sender:self];
    //}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDetailPage"]) {
        HAMCouponDetailViewController *destVC = segue.destinationViewController;
        if ([destVC respondsToSelector:@selector(setHomepage:)]) {
            if (homepage) {
                [destVC setValue:homepage forKey:@"homepage"];
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"showDetailPageFromHistory"]) {
        HAMCouponDetailViewController *destVC = segue.destinationViewController;
        if ([destVC respondsToSelector:@selector(setHomepage:)]) {
            if (homepage) {
                [destVC setValue:homepage forKey:@"homepage"];
            }
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"infoCell" forIndexPath:indexPath];
    
    UITextField *titleTF = (UITextField*)[cell viewWithTag:1];
    
    titleTF.text = [NSString stringWithFormat:@"History %ld", (long)indexPath.row];
    
    return cell;
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
