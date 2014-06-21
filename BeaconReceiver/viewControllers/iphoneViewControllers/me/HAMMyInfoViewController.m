//
//  HAMMeInfoViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-21.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMMyInfoViewController.h"

#import "HAMMyInfoContentViewController.h"

@interface HAMMyInfoViewController ()

@property (nonatomic) HAMMyInfoContentViewController* contentViewController;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation HAMMyInfoViewController

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
    
//    //tap view gesture - resign text fields
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapedView:)];
//    [self.view addGestureRecognizer:tapGesture];
    [super viewDidLoad];
    
    //add subview to scrollview
    self.contentViewController = [[HAMMyInfoContentViewController alloc] initWithNibName:@"MyInfo_iPhone" bundle:nil];
    self.contentViewController.containerViewController = self;
    
    [self.scrollView addSubview:self.contentViewController.view];
    
    //make scrollview all through top bar
    CGRect frame = self.contentViewController.view.frame;
    frame.origin.y = 93.0f;
    self.contentViewController.view.frame = frame;
    frame.size.height += 93.0f;
    self.scrollView.contentSize = frame.size;
    
    //hide scrollview's scroll indicator
    self.scrollView.showsVerticalScrollIndicator = NO;
}

@end
