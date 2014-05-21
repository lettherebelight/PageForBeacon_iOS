//
//  HAMDiscoverViewController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 5/21/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMDiscoverViewController_iPhone.h"
#import "HAMCardListViewController_iPhone.h"
#import "HAMThing.h"
#import "OLImage.h"
#import "OLImageView.h"

@interface HAMDiscoverViewController_iPhone ()

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
    NSArray *thingsInWorld;
}

static NSString *kHAMEmbedSegueId = @"embedSegue";

static int kHAMDefaultViewTag = 22;

#pragma mark - actions

- (IBAction)changStatus:(id)sender {
    if ([self.segmentedControl selectedSegmentIndex] == 0) {
        discoverStatus = AROUND;
        if ([self.view viewWithTag:kHAMDefaultViewTag] == nil && (thingsAround == nil || [thingsAround count] == 0)) {
            [self.view addSubview:defaultView];
        }
        if (listViewController != nil) {
            [listViewController updateWithThingArray:thingsAround scrollToTop:YES];
        }
    } else if ([self.segmentedControl selectedSegmentIndex] == 1) {
        discoverStatus = WORLD;
        if ([self.view viewWithTag:kHAMDefaultViewTag] != nil) {
            [defaultView removeFromSuperview];
        }
        if (listViewController != nil) {
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

- (void)updateThings:(NSArray *)things {
    thingsInWorld = things;
    if (discoverStatus == WORLD) {
        if (listViewController != nil) {
            [listViewController updateWithThingArray:thingsInWorld scrollToTop:NO];
        }
    }
}

- (void)displayThings:(NSArray *)things {
    thingsAround = things;
    if (discoverStatus == AROUND) {
        if ([self.view viewWithTag:kHAMDefaultViewTag] == nil && (thingsAround == nil || [thingsAround count] == 0)) {
            [self.view addSubview:defaultView];
        } else if([self.view viewWithTag:kHAMDefaultViewTag] != nil && thingsAround != nil && [thingsAround count] > 0) {
            [defaultView removeFromSuperview];
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
    // Do any additional setup after loading the view.
    
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
    [[HAMBeaconManager beaconManager] startMonitor];
    [HAMThingManager thingManager].delegate = self;
    
    //set default view
    defaultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    UIImage *eyeGIF = [OLImage imageNamed:@"gif.gif"];
    OLImageView *eyeImageView = [[OLImageView alloc] initWithFrame:CGRectMake(110, 200, 100, 100)];
    eyeImageView.image = eyeGIF;
    eyeImageView.alpha = 0.1;
    UIImage *backJPG = [OLImage imageNamed:@"background_nobeacon.jpg"];
    OLImageView *backImageView = [[OLImageView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    backImageView.image = backJPG;
    [defaultView addSubview:backImageView];
    [defaultView addSubview:eyeImageView];
    [defaultView setTag:kHAMDefaultViewTag];
    [self.view addSubview:defaultView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = nil;
    if (listViewController != nil) {
        [listViewController updateViewScrollToTop:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:kHAMEmbedSegueId]) {
        if ([segue.destinationViewController isKindOfClass:[HAMCardListViewController_iPhone class]]) {
            listViewController = segue.destinationViewController;
        }
    }
}


@end
