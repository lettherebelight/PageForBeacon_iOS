//
//  HAMDiscoverCollectionViewController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 5/4/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMDiscoverCollectionViewController_iPhone.h"
#import "SVProgressHUD.h"
#import "HAMDataManager.h"
#import "HAMHomepageData.h"
#import "HAMTourManager.h"
#import "HAMTools.h"
#import "HAMArtDetailTabController_iPhone.h"

@interface HAMDiscoverCollectionViewController_iPhone ()

@end

@implementation HAMDiscoverCollectionViewController_iPhone

@synthesize pageForSegue;
@synthesize stuffsAround;

- (void)initView {
    //stuffsAround = nil;
    pageForSegue = nil;
    [self.collectionView reloadData];
}

- (void)updateView {
    if (stuffsAround == nil || [stuffsAround count] < 1) {
        [self.collectionView reloadData];
        self.navigationItem.title = @"感应中";
    } else {
        /*
         int cellHeight = 150;
         CGPoint center = self.tableView.center;
         self.tableView.center = CGPointMake(center.x, center.y - cellHeight);
         [UIView animateWithDuration:0.75 delay:0.15 options:UIViewAnimationOptionCurveEaseOut animations:^{
         self.tableView.center = center;
         } completion:nil];
         */
        self.navigationItem.title = [NSString stringWithFormat:@"周围有%d个展品", [stuffsAround count]];
        [self.collectionView reloadData];
        //[self.collectionView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    }
}

- (void)displayHomepage:(NSArray*)curStuffsAround {
    stuffsAround = curStuffsAround;
    [self updateView];
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
    [HAMBeaconManager beaconManager].delegate = self;
    [HAMDataManager clearData];
    [[HAMBeaconManager beaconManager] startMonitor];
    
    self.navigationItem.title = @"感应中";
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = nil;
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (stuffsAround != nil) {
        return [stuffsAround count];
    }
    return 0;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"artCell" forIndexPath:indexPath];
    
    cell.layer.cornerRadius = 10.0f;
    
    HAMHomepageData *pageData;
    
    pageData = [stuffsAround objectAtIndex:indexPath.row];

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
    //contentTV.frame = CGRectMake(contentTV.frame.origin.x, contentTV.frame.origin.y, contentTV.frame.size.width, contentTV.contentSize.height);
    //cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height - 100.0f + contentTV.frame.size.height);
    
    UIButton *commentButton = (UIButton*)[cell viewWithTag:3];
    [commentButton addTarget:self action:@selector(commentClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *favButton = (UIButton*)[cell viewWithTag:4];
    if (pageData.markedListRecord == nil) {
        UIImage *originImage = [[UIImage imageNamed:@"fav-normal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *image = [HAMTools image:originImage changeToSize:CGSizeMake(22.0f, 22.0f)];
        [favButton setImage:image forState:UIControlStateNormal];
        [favButton removeTarget:self action:@selector(performUnFavorite:) forControlEvents:UIControlEventTouchUpInside];
        [favButton addTarget:self action:@selector(performFavorite:) forControlEvents:UIControlEventTouchUpInside];
        originImage = nil;
        image = nil;
    }
    else {
        UIImage *originImage = [[UIImage imageNamed:@"fav-selected-normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *image = [HAMTools image:originImage changeToSize:CGSizeMake(22.0f, 22.0f)];
        [favButton setImage:image forState:UIControlStateNormal];
        [favButton removeTarget:self action:@selector(performFavorite:) forControlEvents:UIControlEventTouchUpInside];
        [favButton addTarget:self action:@selector(performUnFavorite:) forControlEvents:UIControlEventTouchUpInside];
        originImage = nil;
        image = nil;
    }
    return cell;
}

- (void)commentClicked:(UIButton*)button {
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview;
    int i = [self.collectionView indexPathForCell:cell].row;
    pageForSegue = [self.stuffsAround objectAtIndex:i];
    [self performSegueWithIdentifier:@"showArtDetailComment" sender:self];
}

- (void)performFavorite:(UIButton*)button {
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview;
    int i = [self.collectionView indexPathForCell:cell].row;
    [[HAMTourManager tourManager] addFavoriteStuff:[self.stuffsAround objectAtIndex:i]];
    
    UIButton *favButton = (UIButton*)[cell viewWithTag:4];
    UIImage *originImage = [[UIImage imageNamed:@"fav-selected-normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *image = [HAMTools image:originImage changeToSize:CGSizeMake(22.0f, 22.0f)];
    [favButton setImage:image forState:UIControlStateNormal];
    [favButton removeTarget:self action:@selector(performFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [favButton addTarget:self action:@selector(performUnFavorite:) forControlEvents:UIControlEventTouchUpInside];
    originImage = nil;
    image = nil;

    [SVProgressHUD showSuccessWithStatus:@"收藏成功！"];
}

- (void)performUnFavorite:(UIButton*)button {
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview;
    int i = [self.collectionView indexPathForCell:cell].row;
    [[HAMTourManager tourManager] removeFavoriteStuff:[self.stuffsAround objectAtIndex:i]];
    
    UIButton *favButton = (UIButton*)[cell viewWithTag:4];
    UIImage *originImage = [[UIImage imageNamed:@"fav-normal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *image = [HAMTools image:originImage changeToSize:CGSizeMake(22.0f, 22.0f)];
    [favButton setImage:image forState:UIControlStateNormal];
    [favButton removeTarget:self action:@selector(performUnFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [favButton addTarget:self action:@selector(performFavorite:) forControlEvents:UIControlEventTouchUpInside];
    originImage = nil;
    image = nil;

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
        if (self.pageForSegue != nil) {
            detailVC.homepage = self.pageForSegue;
            self.pageForSegue = nil;
        }
        else {
            NSIndexPath *index = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
            detailVC.homepage = [stuffsAround objectAtIndex:index.row];
        }
    } else if ([segue.identifier isEqualToString:@"showArtDetailComment"]) {
        HAMArtDetailTabController_iPhone *detailVC = segue.destinationViewController;
        [detailVC setHidesBottomBarWhenPushed:YES];
        if (self.pageForSegue != nil) {
            detailVC.homepage = self.pageForSegue;
            self.pageForSegue = nil;
        }
        [detailVC setSelectedIndex:1];
    }
}


@end
