//
//  HAMBeaconListViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-15.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMBeaconListViewController.h"

#import "HAMCreateThingViewController.h"

#import <CoreLocation/CoreLocation.h>
#import "SVProgressHUD.h"

#import "HAMThing.h"

#import "HAMAVOSManager.h"
#import "HAMBeaconManager.h"
#import "HAMThingManager.h"

#import "HAMTools.h"

@interface HAMBeaconListViewController ()

@property NSDictionary* beaconDictionary;
@property NSTimer* refreshTimer;

@property (weak, nonatomic) IBOutlet UITableView *beaconTableView;

@property CLBeacon* beaconSelected;
@end

static const double kRefreshTimeInterval = 1.0f;

@implementation HAMBeaconListViewController

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
}

- (void)viewWillAppear:(BOOL)animated{
    [self refreshTableView];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshTimeInterval target:self selector:@selector(refreshTableView) userInfo:nil repeats:YES];
    [self.refreshTimer setFireDate:[NSDate date]];

}

- (void)viewWillDisappear:(BOOL)animated{
    [self.refreshTimer setFireDate:[NSDate distantFuture]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Assist Methods

- (void)refreshTableView{
    HAMBeaconManager* beaconManager = [HAMBeaconManager beaconManager];
    self.beaconDictionary = [beaconManager beaconDictionary];
    [self.beaconTableView reloadData];
}

- (NSString*)uuidAtIndex:(NSInteger)index{
    NSArray* uuidArray = [self.beaconDictionary allKeys];
    if (index < uuidArray.count) {
        return uuidArray[index];
    }
    return nil;
}

- (NSArray*)beaconArrayAtIndex:(NSInteger)index{
    NSString* uuid = [self uuidAtIndex:index];
    return [self.beaconDictionary objectForKey:uuid];
}

- (CLBeacon*)beaconAtIndexPath:(NSIndexPath*)indexPath{
    long section = indexPath.section;
    NSArray* beaconArray = [self beaconArrayAtIndex:section];
    if (beaconArray == nil) {
        return nil;
    }
    
    long row = indexPath.row;
    if (row < beaconArray.count) {
        return beaconArray[row];
    }
    return nil;
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.beaconDictionary.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString* uuid = [self uuidAtIndex:section];
    if (uuid == nil) {
        return @"";
    }
    
    HAMBeaconManager* beaconManager = [HAMBeaconManager beaconManager];
    NSString* description = [beaconManager descriptionOfUUID:uuid];
    return [NSString stringWithFormat:@"%@ : %@",description,uuid];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray* beaconArray = [self beaconArrayAtIndex:section];
    return beaconArray.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* CellIdentifier = [NSString stringWithFormat:@"BeaconCell"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    CLBeacon* beacon = [self beaconAtIndexPath:indexPath];
    
    if (beacon == nil) {
        cell.textLabel.text = @"?(?)";
        cell.detailTextLabel.text = @"Major: ?, Minor: ?";
        return cell;
    }
    
    NSString* uuid = [beacon.proximityUUID UUIDString];
    HAMBeaconManager* beaconManager = [HAMBeaconManager beaconManager];
    NSString* description = [beaconManager descriptionOfUUID:uuid];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%.2lf)",description,beacon.accuracy];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Major: %@, Minor: %@",beacon.major,beacon.minor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![HAMTools isWebAvailable]) {
        [SVProgressHUD showErrorWithStatus:@"网络已断开，无法绑定Beacon"];
        return;
    }
    
    CLBeacon* beacon = [self beaconAtIndexPath:indexPath];
    self.beaconSelected = beacon;
    if (beacon == nil) {
//        [HAMTools showAlert:@"选择的Beacon已离开范围。" title:@"抱歉……"];
        [SVProgressHUD showErrorWithStatus:@"选择的Beacon已离开范围"];
        return;
    }
    
    HAMBeaconState ownState = [HAMAVOSManager ownStateOfBeacon:beacon];
    
    if (ownState == HAMBeaconStateFree) {
        [self performSegueWithIdentifier:@"FromBeaconListToCreateThing" sender:nil];
        
    } else if (ownState == HAMBeaconStateOwnedByMe){
        //show actionsheet
        UIActionSheet* actionSheet = [[UIActionSheet alloc]
            initWithTitle:@"已绑定我的Thing"
            delegate:self
            cancelButtonTitle:@"取消"
            destructiveButtonTitle:@"解除绑定"
            otherButtonTitles:@"绑定新的thing",nil];
        [actionSheet showInView:self.view];
    } else {
        //own by others
        return;
    }
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self unbindBeacon:self.beaconSelected];
            break;
            
        case 1:
            [self performSegueWithIdentifier:@"FromBeaconListToCreateThing" sender:nil];
            break;
            
        default:
            //cancel
            break;
    }
}

#pragma mark - Prepare for Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"FromBeaconListToCreateThing"]) {
        HAMCreateThingViewController* createThingViewController = segue.destinationViewController;
        createThingViewController.beaconToBind = self.beaconSelected;
    }
}

#pragma mark - Bind Beacon

- (void)unbindBeacon:(CLBeacon*)beaconSelected{
    if (![HAMTools isWebAvailable]) {
        [SVProgressHUD showErrorWithStatus:@"网络不通"];
        
        return;
    }
    [HAMAVOSManager unbindThingToBeacon:self.beaconSelected withTarget:self callback:@selector(didUnbindBeacon)];
}

- (void)didUnbindBeacon{
    [SVProgressHUD showSuccessWithStatus:@"解除绑定成功"];
}

@end
