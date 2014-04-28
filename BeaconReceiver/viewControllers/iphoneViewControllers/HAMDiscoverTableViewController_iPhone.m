//
//  HAMDiscoverTableViewController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 4/27/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMDiscoverTableViewController_iPhone.h"
#import "HAMDataManager.h"
#import "HAMHomepageData.h"
#import "HAMTourManager.h"
#import "HAMTools.h"
#import "HAMArtDetailViewController_iPhone.h"

@interface HAMDiscoverTableViewController_iPhone ()

@end

@implementation HAMDiscoverTableViewController_iPhone

@synthesize homepage;

- (void)initView {
    historyPages = [HAMDataManager fetchHistoryRecords];
    self.pageForSegue = nil;
    [self.tableView reloadData];
}

- (void)updateView {
    historyPages = [HAMDataManager fetchHistoryRecords];
    if (homepage == nil || historyPages == nil || [historyPages count] <= 1) {
        [self.tableView reloadData];
    } else {
        /*
         int cellHeight = 150;
        CGPoint center = self.tableView.center;
        self.tableView.center = CGPointMake(center.x, center.y - cellHeight);
        [UIView animateWithDuration:0.75 delay:0.15 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.tableView.center = center;
        } completion:nil];
        */
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    }
}

- (void)displayHomepage:(HAMHomepageData *)curHomepage {
    self.homepage = curHomepage;
    [self updateView];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.navigationController.navigationBar.barTintColor = nil;
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    [HAMBeaconManager beaconManager].delegate = self;
    [HAMDataManager clearData];
    [[HAMBeaconManager beaconManager] startMonitor];
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    long count;
    if (historyPages == nil) {
        count = 0;
    } else {
        count = [historyPages count];
    }
    if (count < 5) {
        return 5;
    }
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    // Configure the cell...
    
    if ((historyPages == nil || [historyPages count] == 0) && indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"loadingCell" forIndexPath:indexPath];
        return cell;
    }
    
    if (historyPages == nil || [historyPages count] <= indexPath.row) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"plainCell" forIndexPath:indexPath];
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"artCell" forIndexPath:indexPath];
    
    HAMHomepageData *pageData;
    
    pageData = [historyPages objectAtIndex:indexPath.row];
    if (homepage != nil && indexPath.row == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    else {
        cell.backgroundColor = [UIColor grayColor];
    }
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
    UIImage *thumbnail = [HAMTools imageFromURL:pageData.thumbnail];
    UIImage *image = [HAMTools image:thumbnail changeToMaxSize:imageView.frame.size];
    imageView.image = image;
    thumbnail = nil;
    image = nil;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showArtDetailPage"]) {
        HAMArtDetailViewController_iPhone *detailVC = segue.destinationViewController;
        if (self.pageForSegue != nil) {
            detailVC.homepage = self.pageForSegue;
            self.pageForSegue = nil;
        }
        else {
            NSIndexPath *index = [self.tableView indexPathForSelectedRow];
            detailVC.homepage = [historyPages objectAtIndex:index.row];
        }
    }
}


@end
