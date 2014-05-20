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
#import "HAMThing.h"
#import <AVOSCloud/AVOSCloud.h>

@interface HAMFavoritesCollectionViewController_iPhone ()

@end

@implementation HAMFavoritesCollectionViewController_iPhone

- (void)initView {
    thingForSegue = nil;
    thingArray = [HAMDataManager fetchMarkedRecords];
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

- (IBAction)shareButtonClicked:(id)sender {
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
    if (thingArray != nil) {
        return [thingArray count];
    }
    return 0;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"artCell" forIndexPath:indexPath];
    
    //cell
    UIView *view = [cell viewWithTag:1];
    view.layer.cornerRadius = 6.0f;
    [view.layer setMasksToBounds:YES];
    
    //shadow
    UIView *shadowView = [cell viewWithTag:7];
    [shadowView.layer setShadowColor:[UIColor lightGrayColor].CGColor];
    [shadowView.layer setShadowOpacity:0.4f];
    [shadowView.layer setShadowRadius:1.0f];
    [shadowView.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    shadowView.layer.cornerRadius = 6.0f;
    
    HAMThing *thing;
    
    thing = [thingArray objectAtIndex:indexPath.row];
    
    UIImageView *imageView = (UIImageView*)[view viewWithTag:6];
    UIImage *thumbnail = [HAMTools imageFromURL:thing.coverURL];
    UIImage *image = [HAMTools image:thumbnail changeToMaxSize:imageView.frame.size];
    imageView.image = image;
    thumbnail = nil;
    image = nil;
    
    UILabel *titleLabel = (UILabel*)[view viewWithTag:2];
    titleLabel.text = thing.title;
    
    UITextView *contentTV = (UITextView*)[view viewWithTag:5];
    contentTV.text = thing.content;
    
    UIButton *commentButton = (UIButton*)[view viewWithTag:3];
    UIImage *commentImage = [[UIImage imageNamed:@"ios7-chatbubble-outline.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [commentButton setImage:commentImage forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(commentClicked:) forControlEvents:UIControlEventTouchUpInside];
    commentImage = nil;
    
    UIButton *favButton = (UIButton*)[view viewWithTag:4];
    UIImage *favImage = [[UIImage imageNamed:@"ios7-heart.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [favButton setImage:favImage forState:UIControlStateNormal];
    [favButton addTarget:self action:@selector(performUnFavorite:) forControlEvents:UIControlEventTouchUpInside];
    favImage = nil;

    return cell;
}

- (void)commentClicked:(UIButton*)button {
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview.superview;
    long i = [self.collectionView indexPathForCell:cell].row;
    thingForSegue = [thingArray objectAtIndex:i];
    [self performSegueWithIdentifier:@"showArtDetailComment" sender:self];
}

- (void)performUnFavorite:(UIButton*)button {
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview.superview;
    long i = [self.collectionView indexPathForCell:cell].row;
    [[HAMTourManager tourManager] removeFavoriteThing:[thingArray objectAtIndex:i]];
    
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
        detailVC.thing = [thingArray objectAtIndex:index.row];
    } else if ([segue.identifier isEqualToString:@"showArtDetailComment"]) {
        HAMArtDetailTabController_iPhone *detailVC = segue.destinationViewController;
        [detailVC setHidesBottomBarWhenPushed:YES];
        if (thingForSegue != nil) {
            detailVC.thing = thingForSegue;
            thingForSegue = nil;
        }
        [detailVC setSelectedIndex:1];
    }
}

@end
