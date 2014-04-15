//
//  HAMSideBarViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-11.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMSideBarViewController.h"

@interface HAMSideBarViewController ()

@end

@implementation HAMSideBarViewController

@synthesize delegate;

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

- (IBAction)homeButtonClicked:(id)sender {
    if (self.delegate != nil ) {
        [self.delegate showHomePage];
    }
}

- (IBAction)favoritesButtonClicked:(id)sender {
    if (self.delegate != nil ) {
        [self.delegate showFavorites];
    }
}

- (IBAction)resetButtonClicked:(id)sender {
    if (self.delegate != nil ) {
        [self.delegate resetData];
    }
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
