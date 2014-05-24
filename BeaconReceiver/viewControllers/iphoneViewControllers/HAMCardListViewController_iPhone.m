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

@synthesize shouldShowPurchaseItem;

static NSString *kHAMPurchaseURL = @"http://item.taobao.com/item.htm?id=38865233450";

static NSString *kHAMArtCellId = @"artCell";
static NSString *kHAMCardCellId = @"cardCell";
static NSString *kHAMPurchaseCellId = @"purchaseCell";
static NSString *kHAMShowDetailSegueId = @"showDetailPage";
static NSString *kHAMShowCommentSegueId = @"showDetailComment";

static int kHAMArtCellCoverViewTag = 1;
static int kHAMArtCellImageViewTag = 2;
static int kHAMArtCellTitleViewTag = 3;
static int kHAMArtCellContentViewTag = 4;
static int kHAMArtCellCommentButtonTag = 5;

static int kHAMCardCellCoverViewTag = 1;
static int kHAMCardCellImageViewTag = 2;
static int kHAMCardCellTitleViewTag = 3;
static int kHAMCardCellContentViewTag = 4;
static int kHAMCardCellCommentButtonTag = 5;

static int kHAMCellFavButtonTag = 6;

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
    //back ground
    UIImageView *backImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"common_bg.jpg"]];
    backImageView.frame = self.collectionView.bounds;
    backImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.collectionView setBackgroundView:backImageView];
    thingArray = nil;
    thingForSegue = nil;
    shouldShowPurchaseItem = NO;
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

#pragma mark - CollectionView delegate methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isPurchaseCellForItemAtIndexPath:indexPath]) {
        [[UIApplication sharedApplication ] openURL: [NSURL URLWithString:kHAMPurchaseURL]];
        return;
    }
    
    HAMThing *thing = [thingArray objectAtIndex:indexPath.row];
    if (thing == nil || thing.url == nil) {
        return;
    }
    thingForSegue = thing;
    [self performSegueWithIdentifier:kHAMShowDetailSegueId sender:self];
}

#pragma mark - CollectionView data source methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (shouldShowPurchaseItem) {
        if (thingArray == nil) {
            return 1;
        }
        return [thingArray count] + 1;
    }
    if (thingArray == nil) {
        return 0;
    }
    return [thingArray count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //purchase cell
    
    if ([self isPurchaseCellForItemAtIndexPath:indexPath]) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:kHAMPurchaseCellId forIndexPath:indexPath];
    }
    
    //set data
    HAMThing *thing = [thingArray objectAtIndex:indexPath.row];
    if (thing == nil) {
        return nil;
    }
    
    //art cell
    if (thing.type == HAMThingTypeArt) {
        return [self collectionView:collectionView artCellForItemAtIndexPath:indexPath withThing:thing];
    } else if (thing.type == HAMThingTypeCard) {
        return [self collectionView:collectionView cardCellForItemAtIndexPath:indexPath withThing:thing];
    }
    
    return nil;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize nilCellSize = CGSizeMake(0.0f, 0.0f);
    CGSize artCellSize = CGSizeMake(320.0f, 255.0f);
    CGSize cardCellSize = CGSizeMake(320.0f, 141.0f);
    CGSize purchaseCellSize = CGSizeMake(320.0f, 150.0f);
    if ([self isPurchaseCellForItemAtIndexPath:indexPath]) {
        return purchaseCellSize;
    }
    HAMThing *thing = [thingArray objectAtIndex:indexPath.row];
    if (thing == nil) {
        return nilCellSize;
    } else if (thing.type == HAMThingTypeArt) {
        return artCellSize;
    } else if (thing.type == HAMThingTypeCard) {
        return cardCellSize;
    }
    return nilCellSize;
}

- (BOOL)isPurchaseCellForItemAtIndexPath:(NSIndexPath*)indexPath {
    return shouldShowPurchaseItem && (thingArray == nil || indexPath.row >= [thingArray count]);
}

#pragma mark - fill cell methods
-(UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cardCellForItemAtIndexPath:(NSIndexPath*)indexPath withThing:(HAMThing*)thing {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHAMCardCellId forIndexPath:indexPath];
    
    UIView *view = [cell viewWithTag:kHAMCardCellCoverViewTag];
    view.layer.cornerRadius = 6.0f;
    [view.layer setMasksToBounds:YES];
    
    //image
    UIImageView *imageView = (UIImageView*)[view viewWithTag:kHAMCardCellImageViewTag];
    UIImage *thumbnail;
    thumbnail = [HAMTools imageFromURL:thing.coverURL];
    UIImage *image = [HAMTools image:thumbnail staysShapeChangeToSize:imageView.frame.size];
    imageView.image = image;
    
    //title
    UILabel *titleLabel = (UILabel*)[view viewWithTag:kHAMCardCellTitleViewTag];
    titleLabel.text = thing.title;
    
    //content
    UITextView *contentTV = (UITextView*)[view viewWithTag:kHAMCardCellContentViewTag];
    contentTV.text = thing.content;
    
    //comment
    UIButton *commentButton = (UIButton*)[view viewWithTag:kHAMCardCellCommentButtonTag];
    //UIImage *commentImage = [[UIImage imageNamed:@"ios7-chatbubble-outline.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    //[commentButton setImage:commentImage forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(commentClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //favorite
    UIButton *favButton = (UIButton*)[view viewWithTag:kHAMCellFavButtonTag];
    //UIImage *favImage = [[UIImage imageNamed:@"ios7-heart-outline.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    //[favButton setImage:favImage forState:UIControlStateNormal];
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

-(UICollectionViewCell*)collectionView:(UICollectionView*)collectionView artCellForItemAtIndexPath:(NSIndexPath*)indexPath withThing:(HAMThing*)thing {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHAMArtCellId forIndexPath:indexPath];
    
    UIView *view = [cell viewWithTag:kHAMArtCellCoverViewTag];
    view.layer.cornerRadius = 6.0f;
    [view.layer setMasksToBounds:YES];
    
    //image
    UIImageView *imageView = (UIImageView*)[view viewWithTag:kHAMArtCellImageViewTag];
    UIImage *thumbnail;
    thumbnail = [HAMTools imageFromURL:thing.coverURL];
    UIImage *image = [HAMTools image:thumbnail staysShapeChangeToSize:imageView.frame.size];
    imageView.image = image;
    
    //title
    UILabel *titleLabel = (UILabel*)[view viewWithTag:kHAMArtCellTitleViewTag];
    titleLabel.text = thing.title;
    
    //content
    UITextView *contentTV = (UITextView*)[view viewWithTag:kHAMArtCellContentViewTag];
    contentTV.text = thing.content;
    
    //comment
    UIButton *commentButton = (UIButton*)[view viewWithTag:kHAMArtCellCommentButtonTag];
    //UIImage *commentImage = [[UIImage imageNamed:@"ios7-chatbubble-outline.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    //[commentButton setImage:commentImage forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(commentClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //favorite
    UIButton *favButton = (UIButton*)[view viewWithTag:kHAMCellFavButtonTag];
    //UIImage *favImage = [[UIImage imageNamed:@"ios7-heart-outline.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    //[favButton setImage:favImage forState:UIControlStateNormal];
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
    UIButton *favButton = (UIButton*)[cell viewWithTag:kHAMCellFavButtonTag];
    [favButton setSelected:YES];
    [favButton removeTarget:self action:@selector(performFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [favButton addTarget:self action:@selector(performUnFavorite:) forControlEvents:UIControlEventTouchUpInside];
    
    [SVProgressHUD showSuccessWithStatus:@"收藏成功！"];
}

- (void)performUnFavorite:(UIButton*)button {
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview.superview;
    long i = [self.collectionView indexPathForCell:cell].row;
    [[HAMTourManager tourManager] removeFavoriteThing:[self.thingArray objectAtIndex:i]];
    
    UIButton *favButton = (UIButton*)[cell viewWithTag:kHAMCellFavButtonTag];
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
