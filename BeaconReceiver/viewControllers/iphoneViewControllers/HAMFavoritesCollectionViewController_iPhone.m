//
//  HAMFavoritesCollectionViewController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 5/5/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMFavoritesCollectionViewController_iPhone.h"
#import "SVProgressHUD.h"
#import "HAMTourManager.h"
#import "HAMDataManager.h"
#import "HAMTools.h"
#import "HAMHomepageData.h"
#import "HAMArtDetailTabController_iPhone.h"
#import <AVOSCloud/AVOSCloud.h>

@interface HAMFavoritesCollectionViewController_iPhone ()

@end

@implementation HAMFavoritesCollectionViewController_iPhone

HAMHomepageData *pageForSegue;

- (void)initView {
    pageForSegue = nil;
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
    self.navigationController.navigationBar.barTintColor = nil;
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    UIBarButtonItem *bItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(performShare)];
    self.navigationItem.rightBarButtonItem= bItem;
    
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = nil;
    [self initView];
}

- (void)performShare {
    NSString *message = [NSString stringWithFormat:@"http://ghxz.qiniudn.com/tour.html#/%@", [HAMTourManager tourManager].tour.objectId];
    UIImage *image = nil;//[UIImage imageNamed:nil];
    NSArray *arrayOfActivityItems = [NSArray arrayWithObjects:message, image, nil];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:arrayOfActivityItems applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:Nil];
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (pageArray != nil) {
        return [pageArray count];
    }
    return 0;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"artCell" forIndexPath:indexPath];
    
    cell.layer.cornerRadius = 10.0f;
    
    HAMHomepageData *pageData;
    
    pageData = [pageArray objectAtIndex:indexPath.row];
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
    UIImage *thumbnail = [HAMTools imageFromURL:pageData.thumbnail];
    UIImage *image = [HAMTools image:thumbnail changeToMaxSize:imageView.frame.size];
    imageView.image = image;
    thumbnail = nil;
    image = nil;
    
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:2];
    titleLabel.text = pageData.pageTitle;
    
    UITextView *contentTV = (UITextView*)[cell viewWithTag:5];
    contentTV.text = pageData.describe;
    
    UIButton *commentButton = (UIButton*)[cell viewWithTag:3];
    [commentButton addTarget:self action:@selector(commentClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *favButton = (UIButton*)[cell viewWithTag:4];
    UIImage *originImage = [[UIImage imageNamed:@"fav-selected-normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *btnImage = [HAMTools image:originImage changeToSize:CGSizeMake(22.0f, 22.0f)];
    [favButton setImage:btnImage forState:UIControlStateNormal];
    [favButton addTarget:self action:@selector(performUnFavorite:) forControlEvents:UIControlEventTouchUpInside];
    originImage = nil;
    btnImage = nil;

    return cell;
}

- (void)commentClicked:(UIButton*)button {
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview;
    int i = [self.collectionView indexPathForCell:cell].row;
    pageForSegue = [pageArray objectAtIndex:i];
    [self performSegueWithIdentifier:@"showArtDetailComment" sender:self];
}

- (void)performUnFavorite:(UIButton*)button {
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview;
    long i = [self.collectionView indexPathForCell:cell].row;
    [[HAMTourManager tourManager] removeFavoriteStuff:[pageArray objectAtIndex:i]];
    
    [self initView];
    
    [SVProgressHUD showSuccessWithStatus:@"取消收藏。"];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showArtDetailPage"]) {
        HAMArtDetailTabController_iPhone *detailVC = segue.destinationViewController;
        [detailVC setHidesBottomBarWhenPushed:YES];
        NSIndexPath *index = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        detailVC.homepage = [pageArray objectAtIndex:index.row];
    } else if ([segue.identifier isEqualToString:@"showArtDetailComment"]) {
        HAMArtDetailTabController_iPhone *detailVC = segue.destinationViewController;
        [detailVC setHidesBottomBarWhenPushed:YES];
        if (pageForSegue != nil) {
            detailVC.homepage = pageForSegue;
            pageForSegue = nil;
        }
        [detailVC setSelectedIndex:1];
    }
}

@end
