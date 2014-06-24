//
//  HAMCreateThingViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-17.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMCreateThingViewController.h"

#import "HAMCreateThingContentViewController.h"

#import "HAMThing.h"

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
    self.contentViewController.isNewThing = self.isNewThing;
    if (!self.isNewThing) {
        self.contentViewController.thingToEdit = self.thingToEdit;
    }
    
    [self.scrollView addSubview:self.contentViewController.view];
    
    //make scrollview all through top bar
    CGRect frame = self.contentViewController.view.frame;
    frame.origin.y = 93.0f;
    self.contentViewController.view.frame = frame;
    //"+ frame.size.height - self.view.frame.size.height" so that it looks right on both 3.5-inch and 4-inch screen
    frame.size.height += 93.0f + frame.size.height - self.view.frame.size.height;
    self.scrollView.contentSize = frame.size;
    
    //hide scrollview's scroll indicator
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    //bar title
    if (self.isNewThing) {
        self.tabBarController.title = @"新的thing";
    } else {
        self.tabBarController.title = @"编辑thing";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
