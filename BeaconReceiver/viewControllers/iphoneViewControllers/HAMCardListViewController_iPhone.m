//
//  HAMCardsListViewController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 5/21/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMCardListViewController_iPhone.h"
#import "HAMThing.h"
#import "HAMTools.h"
#import "HAMTourManager.h"
#import "HAMAVOSManager.h"
#import "HAMArtDetailTabController_iPhone.h"
#import "SVProgressHUD.h"

@interface HAMCardListViewController_iPhone ()

@end

@implementation HAMCardListViewController_iPhone

@synthesize thingArray;
@synthesize thingForSegue;

static NSString *kHAMArtCellId = @"artCell";
static NSString *kHAMCardCellId = @"cardCell";
static NSString *kHAMShowDetailSegueId = @"showDetailPage";
static NSString *kHAMShowCommentSegueId = @"showDetailComment";

static int kHAMArtCellShadowViewTag = 1;
static int kHAMArtCellCoverViewTag = 2;
static int kHAMArtCellImageViewTag = 3;
static int kHAMArtCellTitleViewTag = 4;
static int kHAMArtCellContentViewTag = 5;
static int kHAMArtCellCommentButtonTag = 6;
static int kHAMArtCellFavButtonTag = 7;

#pragma mark - UIView methods

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
    thingArray = nil;
    thingForSegue = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - change collection view

- (void)scrollToTop {
    if ([self.collectionView numberOfItemsInSection:0] <= 0) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
}

- (void)updateViewScrollToTop:(BOOL)needScroll {
    [self.collectionView reloadData];
    if (needScroll == YES) {
        [self scrollToTop];
    }
}

- (void)updateWithThingArray:(NSArray*)array scrollToTop:(BOOL)needScroll {
    thingArray = array;
    [self.collectionView reloadData];
    if (needScroll == YES) {
        [self scrollToTop];
    }
}

#pragma mark - show detail method

- (void)showDetailWithThing:(HAMThing*)thing sender:(id)sender {
    thingForSegue = thing;
    [self performSegueWithIdentifier:kHAMShowDetailSegueId sender:sender];
}

#pragma mark - CollectionView data source methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (thingArray == nil) {
        return 0;
    }
    return [thingArray count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //set data
    HAMThing *thing = [thingArray objectAtIndex:indexPath.row];
    if (thing == nil) {
        return nil;
    }
    
    //art cell
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"artCell" forIndexPath:indexPath];
    
    return [self makeArtCell:cell withThing:thing];
}

#pragma mark - make cell methods

- (UICollectionViewCell*)makeArtCell:(UICollectionViewCell*)cell withThing:(HAMThing*)thing {
    UIView *view = [cell viewWithTag:kHAMArtCellCoverViewTag];
    view.layer.cornerRadius = 6.0f;
    [view.layer setMasksToBounds:YES];
    
    //shadow
    UIView *shadowView = [cell viewWithTag:kHAMArtCellShadowViewTag];
    [shadowView.layer setShadowColor:[UIColor lightGrayColor].CGColor];
    [shadowView.layer setShadowOpacity:0.4f];
    [shadowView.layer setShadowRadius:1.0f];
    [shadowView.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    shadowView.layer.cornerRadius = 6.0f;
    
    //image
    UIImageView *imageView = (UIImageView*)[view viewWithTag:kHAMArtCellImageViewTag];
    UIImage *thumbnail;
    thumbnail = [HAMTools imageFromURL:thing.coverURL];
    UIImage *image = [HAMTools image:thumbnail changeToMaxSize:imageView.frame.size];
    imageView.image = image;
    
    //title
    UILabel *titleLabel = (UILabel*)[view viewWithTag:kHAMArtCellTitleViewTag];
    titleLabel.text = thing.title;
    
    //content
    UITextView *contentTV = (UITextView*)[view viewWithTag:kHAMArtCellContentViewTag];
    contentTV.text = thing.content;
    
    //comment
    UIButton *commentButton = (UIButton*)[view viewWithTag:kHAMArtCellCommentButtonTag];
    UIImage *commentImage = [[UIImage imageNamed:@"ios7-chatbubble-outline.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [commentButton setImage:commentImage forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(commentClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //favorite
    UIButton *favButton = (UIButton*)[view viewWithTag:kHAMArtCellFavButtonTag];
    UIImage *favImage = [[UIImage imageNamed:@"ios7-heart-outline.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [favButton setImage:favImage forState:UIControlStateNormal];
    if ([HAMAVOSManager isThingFavoriteOfCurrentUser:thing]) {
        //UIImage *favImage = [[UIImage imageNamed:@"ios7-heart.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
        //[favButton setImage:favImage forState:UIControlStateNormal];
        [favButton setSelected:YES];
        [favButton removeTarget:self action:@selector(performFavorite:) forControlEvents:UIControlEventTouchUpInside];
        [favButton addTarget:self action:@selector(performUnFavorite:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [favButton setSelected:NO];
        [favButton removeTarget:self action:@selector(performUnFavorite:) forControlEvents:UIControlEventTouchUpInside];
        [favButton addTarget:self action:@selector(performFavorite:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

#pragma mark - button in card clicked actions

- (void)commentClicked:(UIButton*)button {
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview.superview;
    long i = [self.collectionView indexPathForCell:cell].row;
    thingForSegue = [self.thingArray objectAtIndex:i];
    [self performSegueWithIdentifier:kHAMShowCommentSegueId sender:self];
}

- (void)performFavorite:(UIButton*)button {
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview.superview;
    long i = [self.collectionView indexPathForCell:cell].row;
    [[HAMTourManager tourManager] addFavoriteThing:[self.thingArray objectAtIndex:i]];
    UIButton *favButton = (UIButton*)[cell viewWithTag:kHAMArtCellFavButtonTag];
    [favButton setSelected:YES];
    [favButton removeTarget:self action:@selector(performFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [favButton addTarget:self action:@selector(performUnFavorite:) forControlEvents:UIControlEventTouchUpInside];
    
    [SVProgressHUD showSuccessWithStatus:@"收藏成功！"];
}

- (void)performUnFavorite:(UIButton*)button {
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview.superview;
    long i = [self.collectionView indexPathForCell:cell].row;
    [[HAMTourManager tourManager] removeFavoriteThing:[self.thingArray objectAtIndex:i]];
    
    UIButton *favButton = (UIButton*)[cell viewWithTag:kHAMArtCellFavButtonTag];
    [favButton setSelected:NO];
    [favButton removeTarget:self action:@selector(performUnFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [favButton addTarget:self action:@selector(performFavorite:) forControlEvents:UIControlEventTouchUpInside];
    
    [SVProgressHUD showSuccessWithStatus:@"取消收藏。"];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:kHAMShowDetailSegueId]) {
        HAMArtDetailTabController_iPhone *detailVC = segue.destinationViewController;
        [detailVC setHidesBottomBarWhenPushed:YES];
        if (self.thingForSegue != nil) {
            detailVC.thing = self.thingForSegue;
            self.thingForSegue = nil;
        }
        else {
            NSIndexPath *index = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
            detailVC.thing = [thingArray objectAtIndex:index.row];
        }
    } else if ([segue.identifier isEqualToString:kHAMShowCommentSegueId]) {
        HAMArtDetailTabController_iPhone *detailVC = segue.destinationViewController;
        [detailVC setHidesBottomBarWhenPushed:YES];
        if (self.thingForSegue != nil) {
            detailVC.thing = self.thingForSegue;
            self.thingForSegue = nil;
        }
        [detailVC setSelectedIndex:1];
    }
}


@end
