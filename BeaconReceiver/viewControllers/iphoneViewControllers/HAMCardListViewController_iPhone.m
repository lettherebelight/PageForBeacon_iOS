//
//  HAMCardsListViewController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 5/21/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMCardListViewController_iPhone.h"

#import "HAMThing.h"

#import "HAMTourManager.h"
#import "HAMAVOSManager.h"

#import "HAMDetailTabBarController_iPhone.h"
#import "SVProgressHUD.h"
#import "MJRefresh.h"

#import "HAMTools.h"
#import "HAMLogTool.h"

@interface HAMCardListViewController_iPhone () <MJRefreshBaseViewDelegate> {
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
}

@end

@implementation HAMCardListViewController_iPhone

@synthesize delegate;

@synthesize thingArray;
@synthesize thingForSegue;

@synthesize shouldShowPurchaseItem;

@synthesize source;

static NSString *kHAMArtCellId = @"artCell";
static NSString *kHAMCardCellId = @"cardCell";
static NSString *kHAMPurchaseCellId = @"purchaseCell";
static NSString *kHAMNilCellId = @"nilCell";

static NSString *kHAMShowArtDetailSegueId = @"showArtDetailPage";
static NSString *kHAMShowArtCommentSegueId = @"showArtDetailComment";
static NSString *kHAMShowCardDetailSegueId = @"showCardDetailPage";
static NSString *kHAMShowCardCommentSegueId = @"showCardDetailComment";

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

- (void)dealloc
{
    [_header free];
    [_footer free];
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
    
    //下拉刷新
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = self.collectionView;
    header.delegate = self;
    // 自动刷新
    //[header beginRefreshing];
    _header = header;
    
    //上拉加载更多
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.collectionView;
    footer.delegate = self;
    _footer = footer;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    
    // 刷新表格
    
    // 1.更新数据
    
    if ([refreshView isKindOfClass:[MJRefreshHeaderView class]]) {
        if (delegate) {
            thingArray = [delegate updateThings];
        }
    } else {
        if (delegate) {
            thingArray = [delegate loadMoreThings];
        }
    }
    
    [self.collectionView reloadData];
    
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
}

#pragma mark - 刷新控件的代理方法
#pragma mark 开始进入刷新状态
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    NSLog(@"%@----开始进入刷新状态", refreshView.class);
    
    // 2.2秒后刷新表格UI
    [self performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:2.0f];
}

#pragma mark 刷新完毕
- (void)refreshViewEndRefreshing:(MJRefreshBaseView *)refreshView
{
    //NSLog(@"%@----刷新完毕", refreshView.class);
}

#pragma mark 监听刷新状态的改变
- (void)refreshView:(MJRefreshBaseView *)refreshView stateChange:(MJRefreshState)state
{
    switch (state) {
        case MJRefreshStateNormal:
            NSLog(@"%@----切换到：普通状态", refreshView.class);
            break;
            
        case MJRefreshStatePulling:
            NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
            break;
            
        case MJRefreshStateRefreshing:
            NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
            break;
        default:
            break;
    }
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
    if (thing == nil) {
        return;
    }
    if (thing.type == HAMThingTypeCard) {
        [self performSegueWithIdentifier:kHAMShowCardDetailSegueId sender:sender];
    } else if (thing.type == HAMThingTypeArt) {
        if (thing.url == nil) {
            return;
        }
        [self performSegueWithIdentifier:kHAMShowArtDetailSegueId sender:sender];
    } else {
        return;
    }
}

- (void)showCommentWithThing:(HAMThing*)thing sender:(id)sender {
    thingForSegue = thing;
    if (thing == nil) {
        return;
    }
    if (thing.type == HAMThingTypeCard) {
        [self performSegueWithIdentifier:kHAMShowCardCommentSegueId sender:sender];
    } else if (thing.type == HAMThingTypeArt) {
        [self performSegueWithIdentifier:kHAMShowArtCommentSegueId sender:sender];
    } else {
        return;
    }
}

#pragma mark - Show Taobao Item

- (void)showItemInTaobaoWithItemId:(NSString*)itemId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"taobao://item.taobao.com/item.htm?id=%@", itemId]];
    if ([[UIApplication sharedApplication] canOpenURL:url] == NO) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://item.taobao.com/item.htm?id=%@", itemId]];
    }
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - CollectionView delegate methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isPurchaseCellForItemAtIndexPath:indexPath]) {
        //[[UIApplication sharedApplication ] openURL: [NSURL URLWithString:kHAMPurchaseURL]];
        [self showItemInTaobaoWithItemId:@"38865233450"];
        return;
    }
    
    if (indexPath.row >= [thingArray count]) {
        return;
    }

    [self showDetailWithThing:[thingArray objectAtIndex:indexPath.row] sender:self];
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
    
    if (indexPath.row >= [thingArray count]) {
        [HAMLogTool debug:@"index row out of bound"];
        return [self collectionView:collectionView nilCellForItemAtIndexPath:indexPath];
    }
    
    //set data
    HAMThing *thing = [thingArray objectAtIndex:indexPath.row];
    if (thing == nil) {
        [HAMLogTool debug:@"thing is nil"];
        return [self collectionView:collectionView nilCellForItemAtIndexPath:indexPath];
    }
    
    //art cell
    if (thing.type == HAMThingTypeArt) {
        return [self collectionView:collectionView artCellForItemAtIndexPath:indexPath withThing:thing];
    } else if (thing.type == HAMThingTypeCard) {
        return [self collectionView:collectionView cardCellForItemAtIndexPath:indexPath withThing:thing];
    } else{
        [HAMLogTool warn:@"unknown card type"];
        //TODO: changed the following line!
//        return [self collectionView:collectionView nilCellForItemAtIndexPath:indexPath];
        return [self collectionView:collectionView nilCellForItemAtIndexPath:0];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize nilCellSize = CGSizeMake(320.0f, 10.0f);
    CGSize artCellSize = CGSizeMake(320.0f, 255.0f);
    CGSize cardCellSize = CGSizeMake(320.0f, 141.0f);
    CGSize purchaseCellSize = CGSizeMake(320.0f, 150.0f);
    if ([self isPurchaseCellForItemAtIndexPath:indexPath]) {
        return purchaseCellSize;
    }
    if (indexPath.row >= [thingArray count]) {
        return nilCellSize;
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
-(UICollectionViewCell*)collectionView:(UICollectionView*)collectionView nilCellForItemAtIndexPath:(NSIndexPath*)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:kHAMNilCellId forIndexPath:indexPath];
}

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
    //int commentsCount = [HAMAVOSManager numberOfCommentsOfThing:thing];
    //[commentButton setTitle:[NSString stringWithFormat:@"  %d", commentsCount] forState:UIControlStateNormal];
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
    //int commentsCount = [HAMAVOSManager numberOfCommentsOfThing:thing];
    //[commentButton setTitle:[NSString stringWithFormat:@"  %d", commentsCount] forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(commentClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //favorite
    UIButton *favButton = (UIButton*)[view viewWithTag:kHAMCellFavButtonTag];
    if ([HAMAVOSManager isThingFavoriteOfCurrentUser:thing]) {
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
    if (i >= [thingArray count]) {
        return;
    }
    [self showCommentWithThing:[self.thingArray objectAtIndex:i] sender:self];
}

- (void)performFavorite:(UIButton*)button {
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview.superview;
    long i = [self.collectionView indexPathForCell:cell].row;
    
    if (i >= [thingArray count]) {
        return;
    }
    
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
    
    if (i >= [thingArray count]) {
        return;
    }
    
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
    
    //show detail
    if ([segue.identifier isEqualToString:kHAMShowArtDetailSegueId] || [segue.identifier isEqualToString:kHAMShowCardDetailSegueId]) {
        //save analystic event
        [HAMAVOSManager saveDetailViewEventWithThing:self.thingForSegue source:source];
        
        HAMDetailTabBarController_iPhone *detailVC = segue.destinationViewController;
        [detailVC setHidesBottomBarWhenPushed:YES];
        if (self.thingForSegue != nil) {
            detailVC.thing = self.thingForSegue;
            self.thingForSegue = nil;
        }
    }
    
    //show comment
    else if ([segue.identifier isEqualToString:kHAMShowArtCommentSegueId] || [segue.identifier isEqualToString:kHAMShowCardCommentSegueId]) {
        HAMDetailTabBarController_iPhone *detailVC = segue.destinationViewController;
        [detailVC setHidesBottomBarWhenPushed:YES];
        if (self.thingForSegue != nil) {
            detailVC.thing = self.thingForSegue;
            self.thingForSegue = nil;
        }
        [detailVC setSelectedIndex:1];
    }
}


@end
