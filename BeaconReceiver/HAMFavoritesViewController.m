//
//  HAMFavoritesViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-11.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMFavoritesViewController.h"
#import "HAMDetailViewController.h"
#import "HAMDataManager.h"
#import "HAMHomepageData.h"
#import "HAMTools.h"
#import "HAMTourManager.h"
#import <AVOSCloud/AVOSCloud.h>

@interface HAMFavoritesViewController ()

@end

@implementation HAMFavoritesViewController

- (void)loadCollections {
    pageArray = [HAMDataManager fetchMarkedRecords];
    [self.collectionView reloadData];
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
    self.hidesBottomBarWhenPushed = YES;
    //set navigation bar
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    UIBarButtonItem *bItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(performShare)];
    self.navigationItem.rightBarButtonItem= bItem;
    
    //load home data
    [self loadCollections];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadCollections];
    CATransition *transition = [CATransition animation];
    [transition setDuration:0.3];
    [transition setType:kCATransitionMoveIn];
    [transition setSubtype:kCATransitionFromLeft];
    [self.tabBarController.view.layer addAnimation:transition forKey:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    CATransition *transition = [CATransition animation];
    [transition setDuration:0.3];
    [transition setType:kCATransitionReveal];
    [transition setSubtype:kCATransitionFromRight];
    [self.tabBarController.view.layer addAnimation:transition forKey:nil];
}

- (void)performShare {
    NSString *message = [NSString stringWithFormat:@"http://ghxz.qiniudn.com/tour.html#/%@", [HAMTourManager tourManager].tour.objectId];
    UIImage *image = nil;//[UIImage imageNamed:nil];
    NSArray *arrayOfActivityItems = [NSArray arrayWithObjects:message, image, nil];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:arrayOfActivityItems applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:Nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [pageArray count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath  {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"thumbnailCell" forIndexPath:indexPath];
    
    HAMHomepageData *curHome = (HAMHomepageData*)[pageArray objectAtIndex:indexPath.row];
    UIImage *thumbnail = [HAMTools imageFromURL:curHome.thumbnail];
    
    if (thumbnail == nil) {
        UITextField *titleTF = (UITextField*)[cell viewWithTag:1];
        titleTF.text = curHome.pageTitle;
    } else {
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
        [imageView setImage:[HAMTools image:thumbnail changeToMaxSize:imageView.frame.size]];
    }
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showDetailPage"]) {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        HAMDetailViewController *detailVC = segue.destinationViewController;
        detailVC.homepage = [pageArray objectAtIndex:indexPath.row];
    }
}


@end
