//
//  HAMThumbnailViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-11.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMThumbnailViewController.h"
#import "HAMDetailViewController.h"
#import "HAMDataManager.h"
#import "HAMHomepageData.h"
#import "HAMThumbnailView.h"
#import "HAMTools.h"
#import <MediaPlayer/MediaPlayer.h>

@interface HAMThumbnailViewController ()

@end

@implementation HAMThumbnailViewController

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
    // Do any additional setup after loading the view.
    //set navigation bar
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    self.hidesBottomBarWhenPushed = YES;
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearViews {
    long count = [[self.listScrollView subviews] count];
    long i;
    for (i = count - 1; i >= 0; i--) {
        HAMThumbnailView *view = [[self.listScrollView subviews] objectAtIndex:i];
        [view removeFromSuperview];
        view = nil;
    }
}

- (void)initView {
    [self clearViews];
    float viewHeight = [self listScrollView].frame.size.height;
    float marginUp = 0.0f;
    CGPoint scrollOffset = CGPointMake(0.0f, 0.0f);
    NSArray *historyPages = [HAMDataManager fetchHistoryRecords];
    long historyCount;
    int i;
    if (homepage == nil) {
        i = 1;
        historyCount = [historyPages count];
    } else {
        i = 0;
        historyCount = [historyPages count] - 1;
    }
    //for (UIView* view in [[self listScrollView] subviews]) {
    //    [view removeFromSuperview];
    //}
    [self listScrollView].contentSize = CGSizeMake([self listScrollView].frame.size.width, (historyCount+1) * viewHeight + 2.0f * marginUp);
    [self listScrollView].contentOffset = scrollOffset;
    for (HAMHomepageData* pageData in historyPages) {
        if (i == 0) {
            i++;
            continue;
        }
        HAMThumbnailView *view = [[HAMThumbnailView alloc] initWithFrame:CGRectMake(0.0f, marginUp + viewHeight * i, [self listScrollView].frame.size.width,viewHeight) pageData:pageData];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickViewWithRecognizer:)];
        [view addGestureRecognizer:tapGesture];
        
        [[self listScrollView] addSubview:view];
        i++;
    }
    
    if (homepage != nil) {
        HAMThumbnailView *view = [[HAMThumbnailView alloc] initWithFrame:CGRectMake(0.0f, marginUp, [self listScrollView].frame.size.width,viewHeight) pageData:homepage];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickViewWithRecognizer:)];
        [view addGestureRecognizer:tapGesture];
        
        [[self listScrollView] addSubview:view];
    }
    else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [self listScrollView].frame.size.width,viewHeight)];
        UITextField *titleTF = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 50.0f, [self listScrollView].frame.size.width, 100.0f)];
        [titleTF setTextAlignment:NSTextAlignmentCenter];
        [titleTF setEnabled:NO];
        titleTF.text = @"sensing the world.";
        [view addSubview:titleTF];
        [view setBackgroundColor:[UIColor whiteColor]];
        [[self listScrollView] addSubview:view];
        /*if ([HAMTools isWebAvailable] == YES) {
         MPMoviePlayerViewController *playerVC;
         NSString *urlString = @"http://artbeacon.qiniudn.com/background.mp4";
         NSURL *url = [NSURL URLWithString:urlString];
         playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
         [self presentMoviePlayerViewControllerAnimated:playerVC];
         [playerVC.moviePlayer play];
         
         }
         */
    }
}

- (void)updateView {
    [self clearViews];
    selPage = homepage;
    selPage = homepage;
    float viewHeight = [self listScrollView].frame.size.height;
    float marginUp = 0.0f;
    CGPoint scrollOffset = CGPointMake(0.0f, viewHeight);
    NSArray *historyPages = [HAMDataManager fetchHistoryRecords];
    long historyCount;
    int i;
    if (homepage == nil) {
        i = 1;
        historyCount = [historyPages count];
    } else {
        i = 0;
        historyCount = [historyPages count] - 1;
    }
    //for (UIView* view in [[self listScrollView] subviews]) {
    //    [view removeFromSuperview];
    //}
    [self listScrollView].contentSize = CGSizeMake([self listScrollView].frame.size.width, (historyCount+1) * viewHeight + 2.0f * marginUp);
    [self listScrollView].contentOffset = scrollOffset;
    for (HAMHomepageData* pageData in historyPages) {
        if (i == 0) {
            i++;
            continue;
        }
        HAMThumbnailView *view = [[HAMThumbnailView alloc] initWithFrame:CGRectMake(0.0f, marginUp + viewHeight * i, [self listScrollView].frame.size.width,viewHeight) pageData:pageData];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickViewWithRecognizer:)];
        [view addGestureRecognizer:tapGesture];
        
        [[self listScrollView] addSubview:view];
        i++;
    }
    
    if (homepage != nil) {
        HAMThumbnailView *view = [[HAMThumbnailView alloc] initWithFrame:CGRectMake(0.0f, marginUp, [self listScrollView].frame.size.width,viewHeight) pageData:homepage];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickViewWithRecognizer:)];
        [view addGestureRecognizer:tapGesture];
        
        [[self listScrollView] addSubview:view];
    }
    else {
         UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [self listScrollView].frame.size.width,viewHeight)];
        UITextField *titleTF = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 50.0f, [self listScrollView].frame.size.width, 100.0f)];
        [titleTF setTextAlignment:NSTextAlignmentCenter];
        [titleTF setEnabled:NO];
        titleTF.text = @"sensing the world.";
        [view addSubview:titleTF];
        [view setBackgroundColor:[UIColor whiteColor]];
        [[self listScrollView] addSubview:view];
        /*if ([HAMTools isWebAvailable] == YES) {
            MPMoviePlayerViewController *playerVC;
            NSString *urlString = @"http://artbeacon.qiniudn.com/background.mp4";
            NSURL *url = [NSURL URLWithString:urlString];
            playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
            [self presentMoviePlayerViewControllerAnimated:playerVC];
            [playerVC.moviePlayer play];
            
        }
         */
    }
    [[self listScrollView] setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)onClickViewWithRecognizer:(UITapGestureRecognizer*) recognizer {
    HAMThumbnailView *view = (HAMThumbnailView*)[recognizer view];
    selPage = view.pageData;
    [self performSegueWithIdentifier:@"showDetailPage" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showDetailPage"]) {
        HAMDetailViewController *detailVC = segue.destinationViewController;
        detailVC.homepage = selPage;
    }
}

@end
