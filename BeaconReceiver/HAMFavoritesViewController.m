//
//  HAMFavoritesViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-11.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMFavoritesViewController.h"
#import "HAMDetailViewController.h"

@interface HAMFavoritesViewController ()

@end

@implementation HAMFavoritesViewController

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
    UIBarButtonItem *bItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(performShare)];
    self.navigationItem.rightBarButtonItem= bItem;
}

- (void)performShare {
    NSString *message = @"123";
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
    return 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath  {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"thumbnailCell" forIndexPath:indexPath];
    
    UITextField *titleTF = (UITextField*)[cell viewWithTag:1];
    
    titleTF.text = [NSString stringWithFormat:@"Favorite %ld", (long)indexPath.row];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showDetailPage"]) {
        //HAMDetailViewController *detailVC = segue.destinationViewController;
        //detailVC.homepage = self.homepage;
    }
}


@end
