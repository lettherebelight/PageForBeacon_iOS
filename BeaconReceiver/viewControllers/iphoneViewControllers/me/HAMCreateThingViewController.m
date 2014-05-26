//
//  HAMCreateThingViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-17.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMCreateThingViewController.h"

#import "HAMCreateThingContentViewController.h"

@interface HAMCreateThingViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic) HAMCreateThingContentViewController* contentViewController;

@end

@implementation HAMCreateThingViewController

@synthesize beaconToBind;

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
    
    //add subview to scrollview
    self.contentViewController = [[HAMCreateThingContentViewController alloc] initWithNibName:@"CreateThing_iPhone" bundle:nil];
    self.contentViewController.tabBar = self.tabBarController.tabBar;
    self.contentViewController.containerViewController = self;
    self.contentViewController.beaconToBind = self.beaconToBind;

    [self.scrollView addSubview:self.contentViewController.view];
    
    CGRect frame = self.contentViewController.view.frame;
    frame.origin.y = 93.0f;
    self.contentViewController.view.frame = frame;
    frame.size.height += 93.0f;
    self.scrollView.contentSize = frame.size;
    
    //hide scrollview's scroll indicator
    self.scrollView.showsVerticalScrollIndicator = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
