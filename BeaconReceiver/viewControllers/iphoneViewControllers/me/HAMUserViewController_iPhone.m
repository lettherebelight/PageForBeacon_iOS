//
//  HAMUserViewController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 5/21/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMUserViewController_iPhone.h"
#import "HAMCardListViewController_iPhone.h"
#import "HAMAVOSManager.h"

#import "HAMConstants.h"

@interface HAMUserViewController_iPhone () <HAMCardListDelegate>

@end

@implementation HAMUserViewController_iPhone {
    HAMCardListViewController_iPhone *listViewController;
    NSMutableArray* thingArray;
}

static NSString *kHAMEmbedSegueId = @"embedSegue";

- (NSArray*)updateThings {
    thingArray = [NSMutableArray array];
    [thingArray addObjectsFromArray:[HAMAVOSManager thingsOfCurrentUserWithSkip:0 limit:kHAMNumberOfThingsInFirstPage]];
    return thingArray;
}

- (NSArray*)loadMoreThings {
    int count = (int)[thingArray count];
    [thingArray addObjectsFromArray:[HAMAVOSManager thingsOfCurrentUserWithSkip:count limit:kHAMNumberOfTHingsInNextPage]];
    return thingArray;
}

- (void)refreshView {
    self.navigationController.navigationBar.barTintColor = nil;
    thingArray = [NSMutableArray array];
    [thingArray addObjectsFromArray:[HAMAVOSManager thingsOfCurrentUserWithSkip:0 limit:kHAMNumberOfThingsInFirstPage]];
    if (listViewController != nil) {
        listViewController.shouldShowPurchaseItem = YES;
        [listViewController updateWithThingArray:thingArray scrollToTop:NO];
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
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    [self refreshView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshView];
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
            listViewController.delegate = self;
        }
    }
}

@end
