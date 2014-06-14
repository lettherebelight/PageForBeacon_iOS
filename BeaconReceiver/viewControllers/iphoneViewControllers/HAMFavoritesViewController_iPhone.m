//
//  HAMFavoritesViewController.m
//  BeaconReceiver
//
//  Created by daiyue on 5/21/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMFavoritesViewController_iPhone.h"
#import "HAMCardListViewController_iPhone.h"
#import "HAMTourManager.h"
#import "HAMAVOSManager.h"

#import "HAMConstants.h"

@interface HAMFavoritesViewController_iPhone () <HAMCardListDelegate>

@end

@implementation HAMFavoritesViewController_iPhone {
    HAMCardListViewController_iPhone *listViewController;
    NSMutableArray *favoriteThingArray;
}

static NSString *kHAMEmbedSegueId = @"embedSegue";

- (NSArray*)updateThings {
    favoriteThingArray = [NSMutableArray array];
    [favoriteThingArray addObjectsFromArray:[HAMAVOSManager favoriteThingsOfCurrentUserWithSkip:0 limit:kHAMNumberOfThingsInFirstPage]];
    return favoriteThingArray;
}

- (NSArray*)loadMoreThings {
    int count = (int)[favoriteThingArray count];
    NSArray *appendArray = [HAMAVOSManager favoriteThingsOfCurrentUserWithSkip:count limit:kHAMNumberOfTHingsInNextPage];
    [favoriteThingArray addObjectsFromArray:appendArray];
    return favoriteThingArray;
}

- (void)initView {
    self.navigationController.navigationBar.barTintColor = nil;
    favoriteThingArray = [NSMutableArray array];
    [favoriteThingArray addObjectsFromArray:[HAMAVOSManager favoriteThingsOfCurrentUserWithSkip:0 limit:kHAMNumberOfThingsInFirstPage]];
    if (listViewController != nil) {
        listViewController.source = @"Favorites";
        [listViewController updateWithThingArray:favoriteThingArray scrollToTop:NO];
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

    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self refreshView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions

- (IBAction)shareButtonClicked:(id)sender {
    NSString *message = [NSString stringWithFormat:@"http://ghxz.qiniudn.com/tour.html#/%@", [HAMTourManager tourManager].tour.objectId];
    UIImage *image = nil;
    NSArray *arrayOfActivityItems = [NSArray arrayWithObjects:message, image, nil];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:arrayOfActivityItems applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:Nil];
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
