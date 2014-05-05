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
#import "HAMTourManager.h"
#import "HAMThumbnailViewController.h"
#import "HAMCommentsManager.h"
#import "HAMCommentData.h"
#import "HAMTourManager.h"

@interface HAMDetailViewController ()

@end

@implementation HAMDetailViewController

@synthesize commentView;

typedef enum commentState {
    UPSTATE = 0,
    DOWNSTATE
}CommentState;

CommentState state = DOWNSTATE;

static int loadingViewTag = 22;
UIColor *alertTintColor;

- (void)displayHomepage:(NSArray*)stuffsAround {
    if ([stuffsAround count] == 0) {
        return;
    }
    HAMHomepageData *homepage = [stuffsAround objectAtIndex:0];
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
    
    //set comment part
    [self.commentText.layer setCornerRadius:10.0f];
    comments = [[HAMCommentsManager commentsManager] commentsWithPageDataID:self.homepage.dataID];
    [HAMCommentsManager commentsManager].delegate = self;
    [[HAMCommentsManager commentsManager] updateComments];
}

#pragma mark - navigation bar selectors

- (void)backToHome {
    [self.navigationController.navigationBar removeGestureRecognizer:backToHomeRecognizer];
    UIViewController *view = [self parentViewController];
    UITabBarController *root = (UITabBarController*)[view parentViewController];
    [root setSelectedIndex:1];
    UINavigationController *thumbnailNavigation = (UINavigationController*)[root selectedViewController];
    HAMThumbnailViewController *thumbnailView = [thumbnailNavigation.viewControllers objectAtIndex:0];
    [self.navigationController popViewControllerAnimated:NO];
    [thumbnailView performSegueWithIdentifier:@"showDetailPage" sender:thumbnailView];
    /*
    HAMThumbnailViewController *parentView = [self.navigationController.viewControllers objectAtIndex:0];
    [self.navigationController popViewControllerAnimated:NO];
    [parentView performSegueWithIdentifier:@"showDetailPage" sender:parentView];
     */
    //[self removeFromParentViewController];
}

- (void)performRefresh {
    [self.detailWebView reload];
}

- (void)performFavorite {
    [[HAMTourManager tourManager] addFavoriteStuff:self.homepage];
    UIImage *originImage = [[UIImage imageNamed:@"fav-selected-normal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *image = [HAMTools image:originImage changeToSize:CGSizeMake(22.0f, 22.0f)];
    
    UIBarButtonItem *favItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:self action:@selector(performUnFavorite)];
    self.navigationItem.rightBarButtonItem= favItem;
}

- (void)performUnFavorite {
    [[HAMTourManager tourManager] removeFavoriteStuff:self.homepage];
    UIImage *originImage = [[UIImage imageNamed:@"fav-normal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *image = [HAMTools image:originImage changeToSize:CGSizeMake(22.0f, 22.0f)];
    
    UIBarButtonItem *favItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(performFavorite)];
    self.navigationItem.rightBarButtonItem= favItem;
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

#pragma mark - perform UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        if (commentView.frame.origin.y > 700) {
            //pull comment up
            [UIView animateWithDuration:0.75 delay:0.15 options:UIViewAnimationOptionCurveEaseOut animations:^{
                
                CGRect frame = commentView.frame;
                frame.origin.y = 200;
                commentView.frame = frame;
                
            } completion:nil];
        }
        else{
            [UIView animateWithDuration:0.75 delay:0.15 options:UIViewAnimationOptionCurveEaseOut animations:^{
                
                CGRect frame = commentView.frame;
                frame.origin.y = 710;
                commentView.frame = frame;
                
            } completion:nil];
        }
        
    }
}

#pragma mark - performUITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (comments == nil) {
        return 1;
    } else {
        return [comments count] + 1;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentTitle"];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentHistory"];
        HAMCommentData *data = [comments objectAtIndex:indexPath.row - 1];
        if (data != nil) {
            UITextField *textField = (UITextField*)[cell viewWithTag:1];
            textField.text = data.content;
        }
        return cell;
    }
    
}

#pragma mark - comment
- (IBAction)commentButtonClicked:(id)sender {
    comments = [[HAMCommentsManager commentsManager] commentsWithPageDataID:self.homepage.dataID];
    [[self commentsTable] reloadData];
    HAMCommentData *data = [[HAMCommentData alloc] init];
    if([self homepage] != nil) {
        data.pageDataID = [self homepage].dataID;
        data.userID = [[HAMTourManager tourManager] currentVisitor];
        data.content = [self commentText].text;
        [[HAMCommentsManager commentsManager] addComment:data];
    }
    [[HAMCommentsManager commentsManager] updateComments];
}

- (void)refresh {
    comments = [[HAMCommentsManager commentsManager] commentsWithPageDataID:self.homepage.dataID];
    [[self commentsTable] reloadData];
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
