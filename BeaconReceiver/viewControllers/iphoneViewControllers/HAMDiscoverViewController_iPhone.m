//
//  HAMDiscoverViewController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 5/21/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMDiscoverViewController_iPhone.h"

#import "HAMCardListViewController_iPhone.h"
#import "OLImage.h"
#import "OLImageView.h"
#import "SVProgressHUD.h"

#import "HAMThing.h"
#import "HAMConstants.h"

#import "HAMAVOSManager.h"

#import "HAMLogTool.h"


@interface HAMDiscoverViewController_iPhone ()

@property HAMThing* oldTopThing;

@property Boolean updateThingsFirstTime;

@end

typedef enum discoverType {
    AROUND = 0,
    WORLD
}DiscoverType;

@implementation HAMDiscoverViewController_iPhone {
    HAMCardListViewController_iPhone *listViewController;
    
    UIView *defaultView;
    
    DiscoverType discoverStatus;
    
    NSArray *thingsAround;
    NSMutableArray *thingsInWorld;
}

static NSString *kHAMEmbedSegueId = @"embedSegue";

static int kHAMDefaultViewTag = 22;

#pragma mark - Cardlist Delegate
- (void)updateThingsAsync {
    if (discoverStatus == WORLD) {
        [HAMAVOSManager thingsInWorldWithSkip:0 limit:kHAMNumberOfThingsInFirstPage target:self callback:@selector(didUpdateThingsWithResult:error:)];
    } else {
        //FIXME: turn flush into fetch someday
        [listViewController didUpdateThingsWithThingArray:thingsAround];
    }
    
    //statistics
    [AVAnalytics event:@"pull&refresh" label:@"discover"];
}

- (void)didUpdateThingsWithResult:(NSArray*)resultArray error:(NSError*)error{
    if (discoverStatus != WORLD) {
        return;
    }
    
    if (error != nil) {
        [HAMLogTool error:[NSString stringWithFormat:@"error when update things: %@",error.localizedDescription]];
        [SVProgressHUD showErrorWithStatus:@"刷新thing列表出错。"];
        return;
    }
    
    if (self.updateThingsFirstTime == YES) {
        self.updateThingsFirstTime = NO;
        [SVProgressHUD dismiss];
    }
    
    thingsInWorld = [NSMutableArray arrayWithArray:resultArray];
    [listViewController didUpdateThingsWithThingArray:thingsInWorld];
}

- (void)loadMoreThingsAsync {
    if (discoverStatus == WORLD) {
        int count = (int)[thingsInWorld count];
        [HAMAVOSManager thingsInWorldWithSkip:count limit:kHAMNumberOfTHingsInNextPage target:self callback:@selector(didLoadMoreThingsWithResult:error:)];
    } else {
        [listViewController didLoadMoreThingsWithThingArray:thingsAround];
    }
}

- (void)didLoadMoreThingsWithResult:(NSArray*)resultArray error:(NSError*)error{
    
    if (error != nil) {
        [HAMLogTool error:[NSString stringWithFormat:@"error when load more things: %@",error.localizedDescription]];
        [SVProgressHUD showErrorWithStatus:@"加载更多thing出错。"];
        return;
    }
    
    [thingsInWorld addObjectsFromArray:resultArray];
    [listViewController didLoadMoreThingsWithThingArray:thingsInWorld];
}

#pragma mark - actions

- (IBAction)changStatus:(id)sender {
    if ([self.segmentedControl selectedSegmentIndex] == 0) {
        discoverStatus = AROUND;
        if ([self.view viewWithTag:kHAMDefaultViewTag] == nil && (thingsAround == nil || [thingsAround count] == 0)) {
            [self.view addSubview:defaultView];
        }
        if (listViewController != nil) {
            listViewController.source = @"Around";
            [listViewController updateWithThingArray:thingsAround scrollToTop:YES];
        }
    } else if ([self.segmentedControl selectedSegmentIndex] == 1) {
        discoverStatus = WORLD;
        if ([self.view viewWithTag:kHAMDefaultViewTag] != nil) {
            [defaultView removeFromSuperview];
        }
        if (listViewController != nil) {
            listViewController.source = @"World";
            
            //for first time loading
            if (self.updateThingsFirstTime) {
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                thingsInWorld = [NSMutableArray array];
                [self updateThingsAsync];
            }
            
            [listViewController updateWithThingArray:thingsInWorld scrollToTop:YES];
        }
    }
}

- (void)showDetailWithThing:(HAMThing*)thing sender:(id)sender {
    if (listViewController == nil) {
        return;
    }
    [listViewController showDetailWithThing:thing sender:sender];
}

#pragma mark - perform delegate methods

- (void)displayThings:(NSArray *)things {
    thingsAround = things;
    if (discoverStatus == AROUND) {
        //ApproachEvent
        HAMThing* topThing;
        if (things.count > 0) {
            topThing = things[0];
        } else {
            topThing = nil;
        }
        
        if ((self.oldTopThing == nil && topThing != nil) || (self.oldTopThing != nil && topThing == nil) || ([topThing isEqualToThing:self.oldTopThing] == NO)) {
            [HAMAVOSManager saveApproachEventWithOldTopThing:self.oldTopThing newTopThing:topThing];
            self.oldTopThing = topThing;
        }
        
        //eye
        if ([self.view viewWithTag:kHAMDefaultViewTag] == nil && (thingsAround == nil || [thingsAround count] == 0)) {
            [self.view addSubview:defaultView];
        } else if([self.view viewWithTag:kHAMDefaultViewTag] != nil && thingsAround != nil && [thingsAround count] > 0) {
            [defaultView removeFromSuperview];
        }
        
        if (thingsAround == nil || [thingsAround count] == 0) {
            [self.segmentedControl setTitle:@"附近" forSegmentAtIndex:0];
        } else {
            [self.segmentedControl setTitle:[NSString stringWithFormat:@"附近(%lu)", (unsigned long)[thingsAround count]] forSegmentAtIndex:0];
        }
        if (listViewController != nil) {
            [listViewController updateWithThingArray:thingsAround scrollToTop:NO];
        }
    }
}

#pragma mark - UIView methods

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
    
    self.updateThingsFirstTime = YES;
    
    defaultView = nil;
    discoverStatus = AROUND;
    thingsInWorld = nil;
    thingsAround = nil;
    self.navigationController.navigationBar.barTintColor = nil;
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
    //init
    [HAMBeaconManager beaconManager].delegate = self;
    [[HAMBeaconManager beaconManager] stopMonitor];
    [[HAMBeaconManager beaconManager] startMonitor];
    
    
    //set default view
    defaultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    UIImage *eyeGIF = [OLImage imageNamed:@"around_eye.gif"];
    OLImageView *eyeImageView = [[OLImageView alloc] initWithFrame:CGRectMake(110, 200, 100, 100)];
    eyeImageView.image = eyeGIF;
    eyeImageView.alpha = 0.1;
    [defaultView addSubview:eyeImageView];
    [defaultView setTag:kHAMDefaultViewTag];
    [self.view addSubview:defaultView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (thingsAround == nil || [thingsAround count] == 0) {
        [self.segmentedControl setTitle:@"附近" forSegmentAtIndex:0];
    } else {
        [self.segmentedControl setTitle:[NSString stringWithFormat:@"附近(%lu)", (unsigned long)[thingsAround count]] forSegmentAtIndex:0];
    }
    self.navigationController.navigationBar.barTintColor = nil;
    if (listViewController != nil) {
        if (discoverStatus == AROUND) {
            listViewController.source = @"Around";
        }
        else
            listViewController.source = @"World";
        
        [listViewController updateViewScrollToTop:NO];
    }
    
    self.oldTopThing = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kHAMEmbedSegueId]) {
        if ([segue.destinationViewController isKindOfClass:[HAMCardListViewController_iPhone class]]) {
            listViewController = segue.destinationViewController;
            listViewController.delegate = self;
        }
    }
}


@end
