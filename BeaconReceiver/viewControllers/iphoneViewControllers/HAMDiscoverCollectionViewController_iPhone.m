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
#import "OLImageView.h"
#import "OLImage.h"
#import "HAMThing.h"
#import "HAMAVOSManager.h"

@interface HAMDiscoverCollectionViewController_iPhone ()

@end

@implementation HAMDiscoverCollectionViewController_iPhone

@synthesize thingForSegue;
@synthesize thingsAround;
@synthesize thingsInWorld;

typedef enum discoverType {
    AROUND = 0,
    WORLD
}DiscoverType;

DiscoverType discoverStatus = AROUND;

- (void)initView {
    //stuffsAround = nil;
    thingForSegue = nil;
    [self.collectionView reloadData];
}

- (void)updateView {
    [self.collectionView reloadData];
    if ([self.collectionView numberOfItemsInSection:0] > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
}

- (IBAction)changStatus:(id)sender {
    if ([self.segmentedControl selectedSegmentIndex] == 0) {
        discoverStatus = AROUND;
        [self updateView];
    } else if ([self.segmentedControl selectedSegmentIndex] == 1) {
        discoverStatus = WORLD;
        [self updateView];
    }
}

- (void)updateThings:(NSArray *)things {
    thingsInWorld = things;
    if (discoverStatus == WORLD) {
        [self updateView];
    }
}

- (void)displayThings:(NSArray *)things {
    thingsAround = things;
    if (discoverStatus == AROUND) {
        [self updateView];
    }
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
    
    //navigation bar
    self.navigationController.navigationBar.barTintColor = nil;
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    
    //tab bar
    /*[self.tabBarController.tabBar setBackgroundColor:[UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1.000]];
    self.tabBarController.tabBar.alpha = 0.3;
    self.tabBarController.tabBar.translucent = YES;
    */
     
    //init
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    [HAMBeaconManager beaconManager].delegate = self;
    [HAMDataManager clearData];
    [[HAMBeaconManager beaconManager] startMonitor];
    [HAMThingManager thingManager].delegate = self;
    
    //self.navigationItem.title = @"感应中";
    
    //set default view
    defaultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.collectionView.frame.size.height)];
    UIImage *eyeGIF = [OLImage imageNamed:@"gif.gif"];
    OLImageView *eyeImageView = [[OLImageView alloc] initWithFrame:CGRectMake(110, 200, 100, 100)];
    eyeImageView.image = eyeGIF;
    eyeImageView.alpha = 0.1;
    UIImage *backJPG = [OLImage imageNamed:@"background_nobeacon.jpg"];
    OLImageView *backImageView = [[OLImageView alloc] initWithFrame:CGRectMake(0, 0, 320, self.collectionView.frame.size.height)];
    backImageView.image = backJPG;
    [defaultView addSubview:backImageView];
    [defaultView addSubview:eyeImageView];
    defaultViewTag = 22;
    [defaultView setTag:defaultViewTag];
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = nil;
    [self initView];
    //self.view.layer.shouldRasterize = YES;
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
    if (discoverStatus == AROUND) {
        if (thingsAround != nil && [thingsAround count] > 0) {
            if ([self.view viewWithTag:defaultViewTag] != nil) {
                [[self.view viewWithTag:defaultViewTag] removeFromSuperview];
            }
            return [thingsAround count];
        }
        if ([self.view viewWithTag:defaultViewTag] == nil) {
            [self.view addSubview:defaultView];
        }
        return 0;
    } else if (discoverStatus == WORLD) {
        if ([self.view viewWithTag:defaultViewTag] != nil) {
            [[self.view viewWithTag:defaultViewTag] removeFromSuperview];
        }
        if (thingsInWorld != nil) {
            return [thingsInWorld count];
        }
        return 0;
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
    
    
    //set data
    if (discoverStatus == AROUND) {
        thing = [thingsAround objectAtIndex:indexPath.row];
    } else if (discoverStatus == WORLD) {
        thing = [thingsInWorld objectAtIndex:indexPath.row];
    }
    
    if (thing == nil) {
        return nil;
    }
    
    
    //debug
//    if (pageData.beaconID != nil) {
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        bool debugSetting = [defaults boolForKey:@"debugSetting"];
//        if (debugSetting == YES) {
//            [view viewWithTag:8].hidden = NO;
//            NSString *beaconInfo = [NSString stringWithFormat:@"%@/%@/%@", pageData.beaconID, pageData.beaconMajor, pageData.beaconMinor];
//            [[HAMBeaconManager beaconManager].debugTextFields setValue:[view viewWithTag:8] forKey:beaconInfo];
//        } else {
//            [view viewWithTag:8].hidden = YES;
//        }
//    } else {
//        [view viewWithTag:8].hidden = YES;
//    }
    
    //set view
    UIImageView *imageView = (UIImageView*)[view viewWithTag:6];
    UIImage *thumbnail = [HAMTools imageFromURL:thing.coverURL];
    UIImage *image = [HAMTools image:thumbnail changeToMaxSize:imageView.frame.size];
    imageView.image = image;
    //thumbnail = nil;
    //image = nil;
    
    UILabel *titleLabel = (UILabel*)[view viewWithTag:2];
    titleLabel.text = thing.title;
    
    UITextView *contentTV = (UITextView*)[view viewWithTag:5];
    contentTV.text = thing.content;
    //contentTV.frame = CGRectMake(contentTV.frame.origin.x, contentTV.frame.origin.y, contentTV.frame.size.width, contentTV.contentSize.height);
    //cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height - 100.0f + contentTV.frame.size.height);
    
    UIButton *commentButton = (UIButton*)[view viewWithTag:3];
    UIImage *commentImage = [[UIImage imageNamed:@"ios7-chatbubble-outline.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [commentButton setImage:commentImage forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(commentClicked:) forControlEvents:UIControlEventTouchUpInside];
    commentImage = nil;
    
    UIButton *favButton = (UIButton*)[view viewWithTag:4];
    if ([HAMAVOSManager isThingFavoriteOfCurrentUser:thing]) {
        UIImage *favImage = [[UIImage imageNamed:@"ios7-heart.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
        [favButton setImage:favImage forState:UIControlStateNormal];
        [favButton removeTarget:self action:@selector(performFavorite:) forControlEvents:UIControlEventTouchUpInside];
        [favButton addTarget:self action:@selector(performUnFavorite:) forControlEvents:UIControlEventTouchUpInside];
        favImage = nil;
    }
    else {
        UIImage *favImage = [[UIImage imageNamed:@"ios7-heart-outline.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
        [favButton setImage:favImage forState:UIControlStateNormal];
        [favButton removeTarget:self action:@selector(performUnFavorite:) forControlEvents:UIControlEventTouchUpInside];
        [favButton addTarget:self action:@selector(performFavorite:) forControlEvents:UIControlEventTouchUpInside];
        favImage = nil;
    }
    return cell;
}

- (void)commentClicked:(UIButton*)button {
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview.superview;
    long i = [self.collectionView indexPathForCell:cell].row;
    if (discoverStatus == AROUND) {
        thingForSegue = [self.thingsAround objectAtIndex:i];
    } else {
        thingForSegue = [self.thingsInWorld objectAtIndex:i];
    }
    [self performSegueWithIdentifier:@"showArtDetailComment" sender:self];
}

- (void)performFavorite:(UIButton*)button {
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview.superview;
    long i = [self.collectionView indexPathForCell:cell].row;
    [[HAMTourManager tourManager] addFavoriteThing:[self.thingsAround objectAtIndex:i]];
    UIButton *favButton = (UIButton*)[cell viewWithTag:4];
    UIImage *favImage = [[UIImage imageNamed:@"ios7-heart.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [favButton setImage:favImage forState:UIControlStateNormal];
    [favButton removeTarget:self action:@selector(performFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [favButton addTarget:self action:@selector(performUnFavorite:) forControlEvents:UIControlEventTouchUpInside];
    favImage = nil;

    [SVProgressHUD showSuccessWithStatus:@"收藏成功！"];
}

- (void)performUnFavorite:(UIButton*)button {
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview.superview;
    long i = [self.collectionView indexPathForCell:cell].row;
    [[HAMTourManager tourManager] removeFavoriteThing:[self.thingsAround objectAtIndex:i]];
    
    UIButton *favButton = (UIButton*)[cell viewWithTag:4];
    UIImage *favImage = [[UIImage imageNamed:@"ios7-heart-outline.png.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [favButton setImage:favImage forState:UIControlStateNormal];
    [favButton removeTarget:self action:@selector(performUnFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [favButton addTarget:self action:@selector(performFavorite:) forControlEvents:UIControlEventTouchUpInside];
    favImage = nil;

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
        if (self.thingForSegue != nil) {
            detailVC.thing = self.thingForSegue;
            self.thingForSegue = nil;
        }
        else {
            NSIndexPath *index = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
            detailVC.thing = [thingsAround objectAtIndex:index.row];
        }
    } else if ([segue.identifier isEqualToString:@"showArtDetailComment"]) {
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
