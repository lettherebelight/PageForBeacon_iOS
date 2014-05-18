//
//  HAMUserCollectionViewController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 5/15/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMUserCollectionViewController_iPhone.h"

@interface HAMUserCollectionViewController_iPhone ()

@end

@implementation HAMUserCollectionViewController_iPhone

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
    
    //navigation bar
//    UIBarButtonItem *customInfoButton = [[UIBarButtonItem alloc] initWithTitle:@"个人信息" style:UIBarButtonItemStylePlain target:self action:@selector(showCustomEditPage)];
//    UIBarButtonItem *bindBeaconButton = [[UIBarButtonItem alloc] initWithTitle:@"绑定beacon" style:UIBarButtonItemStylePlain target:self action:@selector(bindBeacon)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
