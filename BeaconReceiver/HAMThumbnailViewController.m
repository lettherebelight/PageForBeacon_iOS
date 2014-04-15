//
//  HAMThumbnailViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-11.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMThumbnailViewController.h"
#import "HAMDetailViewController.h"

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
    self.hidesBottomBarWhenPushed = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateView {
    if (homepage != nil) {
        self.thumbnailImage.image = nil;
        self.backgroundImage.image = nil;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showDetailPage"]) {
        HAMDetailViewController *detailVC = segue.destinationViewController;
        detailVC.homepage = self.homepage;
    }
}

@end
