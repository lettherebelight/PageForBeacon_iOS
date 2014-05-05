//
//  HAMUserViewController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 4/29/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMUserViewController_iPhone.h"

@interface HAMUserViewController_iPhone ()

@end

@implementation HAMUserViewController_iPhone

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
    self.userStatusTV.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.userStatusTV.layer.borderWidth = 1.0f;
    self.userStatusTV.layer.cornerRadius = 5.0f;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setBeacon:(id)sender {
}

- (IBAction)save:(id)sender {
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
