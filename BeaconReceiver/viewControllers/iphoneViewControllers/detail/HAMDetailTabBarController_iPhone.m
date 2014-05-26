//
//  HAMDetailTabBarController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 5/24/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMDetailTabBarController_iPhone.h"
#import "HAMThing.h"
#import "HAMTourManager.h"
#import "SVProgressHUD.h"
#import "HAMAVOSManager.h"

@interface HAMDetailTabBarController_iPhone ()

@end

@implementation HAMDetailTabBarController_iPhone {
    UIBarButtonItem *likedBarButtonItem;
    UIBarButtonItem *normalBarButtonItem;
}

@synthesize thing;

#pragma mark - like/unlike actions
- (void)unlikeCurrentThing {
    [[HAMTourManager tourManager] removeFavoriteThing:self.thing];
    [self.navigationItem setRightBarButtonItem:normalBarButtonItem];
    [SVProgressHUD showSuccessWithStatus:@"取消收藏。"];
}

- (void)likeCurrentThing {
    [[HAMTourManager tourManager] addFavoriteThing:self.thing];
    [self.navigationItem setRightBarButtonItem:likedBarButtonItem];
    [SVProgressHUD showSuccessWithStatus:@"收藏成功！"];
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
    if (thing == nil) {
        return;
    }
    
    likedBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_icon_liked_selected.png"] style:UIBarButtonItemStylePlain target:self action:@selector(unlikeCurrentThing)];
    normalBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_icon_like_selected.png"] style:UIBarButtonItemStylePlain target:self action:@selector(likeCurrentThing)];
    
    self.navigationItem.title = thing.title;
    
    if ([HAMAVOSManager isThingFavoriteOfCurrentUser:self.thing]) {
        [self.navigationItem setRightBarButtonItem:likedBarButtonItem];
    } else {
        [self.navigationItem setRightBarButtonItem:normalBarButtonItem];
    }
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
