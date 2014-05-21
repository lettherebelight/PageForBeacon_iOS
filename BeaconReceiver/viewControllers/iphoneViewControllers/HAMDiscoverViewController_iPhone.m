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
        if (listViewController != nil) {
            [listViewController updateWithThingArray:thingsAround scrollToTop:YES];
        }
    } else if ([self.segmentedControl selectedSegmentIndex] == 1) {
        discoverStatus = WORLD;
        if (listViewController != nil) {
            [listViewController updateWithThingArray:thingsInWorld scrollToTop:YES];
        }
    }
}

#pragma mark - perform delegate methods

- (void)updateThings:(NSArray *)things {
    thingsInWorld = things;
    if (discoverStatus == WORLD) {
        if (listViewController != nil) {
            [listViewController updateWithThingArray:thingsInWorld scrollToTop:YES];
        }
    }
}

- (void)displayThings:(NSArray *)things {
    thingsAround = things;
    if (discoverStatus == AROUND) {
        if (listViewController != nil) {
            [listViewController updateWithThingArray:thingsAround scrollToTop:YES];
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
