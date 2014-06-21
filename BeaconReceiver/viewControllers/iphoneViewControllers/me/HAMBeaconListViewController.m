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

- (IBAction)addUUIDClicked:(id)sender;

@end

static const double kRefreshTimeInterval = 3.0f;
Boolean foo = false;

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
    UIImageView *backImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"common_bg.jpg"]];
    backImageView.frame = self.beaconTableView.bounds;
    backImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.beaconTableView setBackgroundView:backImageView];
}

- (void)viewWillAppear:(BOOL)animated{
    [self refreshTableView];
    [self deselectSelectedRow];

    if (self.refreshTimer == nil) {
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshTimeInterval target:self selector:@selector(refreshTableView) userInfo:nil repeats:YES];
    }
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
    if (uuid != nil) {
        return [self.beaconDictionary objectForKey:uuid];
    }
    return nil;
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


#pragma mark - UITableView Delegate

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
    NSString* CellIdentifier;
    CLBeacon* beacon = [self beaconAtIndexPath:indexPath];
    if (beacon == nil) {
        CellIdentifier = [NSString stringWithFormat:@"BeaconTableViewCell"];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.text = @"?(?)";
        cell.detailTextLabel.text = @"Major: ?, Minor: ?";
        return cell;
    }
    
    HAMBeaconState ownState = [HAMAVOSManager ownStateOfBeacon:beacon];
    switch (ownState) {
        case HAMBeaconStateFree:
            CellIdentifier = [NSString stringWithFormat:@"BeaconTableViewUnbindedCell"];
            break;
        case HAMBeaconStateOwnedByOthers:
            CellIdentifier = [NSString stringWithFormat:@"BeaconTableViewbindedCell"];
            break;
        case HAMBeaconStateOwnedByMe:
            CellIdentifier = [NSString stringWithFormat:@"BeaconTableViewMineCell"];
            break;
        default:
            return nil;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSString* uuid = [beacon.proximityUUID UUIDString];
    HAMBeaconManager* beaconManager = [HAMBeaconManager beaconManager];
    NSString* description = [beaconManager descriptionOfUUID:uuid];
    
    UILabel *textLabel = (UILabel*)[cell viewWithTag:1];
    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:2];
    textLabel.text = [NSString stringWithFormat:@"%@(%.2lf)",description,beacon.accuracy];
    detailTextLabel.text = [NSString stringWithFormat:@"Major: %@, Minor: %@",beacon.major,beacon.minor];
    
    if (self.beaconSelected) {
        if ([HAMBeaconManager isBeacon:beacon sameToBeacon:self.beaconSelected]) {
            [self.beaconTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
    
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

#pragma mark - UITableView Operation

- (void)deselectSelectedRow{
    NSIndexPath* indexPath = [self.beaconTableView indexPathForSelectedRow];
    [self.beaconTableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            //unbind beacon
            [self unbindBeacon:self.beaconSelected];
            self.beaconSelected = nil;
            [self.beaconTableView reloadData];
            break;
            
        case 1:
            //create thing
            [self performSegueWithIdentifier:@"FromBeaconListToCreateThing" sender:nil];
            break;
            
        default:
            //cancel
            [self deselectSelectedRow];
            self.beaconSelected = nil;
            break;
    }
}

#pragma mark - Prepare for Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"FromBeaconListToCreateThing"]) {
        if ([segue.destinationViewController isKindOfClass:[HAMCreateThingViewController class]]) {
            HAMCreateThingViewController* createThingViewController = segue.destinationViewController;
            createThingViewController.isNewThing = YES;
            [createThingViewController setBeaconToBind:self.beaconSelected];
        }
    }
}

#pragma mark - Bind Beacon

- (void)unbindBeacon:(CLBeacon*)beaconSelected{
    if (![HAMTools isWebAvailable]) {
        [SVProgressHUD showErrorWithStatus:@"网络不通"];
        return;
    }
    
    if ([HAMAVOSManager ownStateOfBeaconUpdated:beaconSelected] != HAMBeaconStateOwnedByMe) {
        [SVProgressHUD showErrorWithStatus:@"Beacon状态错误。"];
        return;
    }
    
    [HAMAVOSManager unbindThingToBeacon:self.beaconSelected withTarget:self callback:@selector(didUnbindBeacon)];
}

- (void)didUnbindBeacon{
    [SVProgressHUD showSuccessWithStatus:@"解除绑定成功"];
}

#pragma mark - Add UUID

- (IBAction)addUUIDClicked:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"添加UUID"
                                                        message:@"如果您的UUID不在列表中，请在此添加："
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"添加", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString* uuidString;
    NSUUID* uuid;
    
    switch (buttonIndex) {
        case 1:
            //add
            uuidString = [[alertView textFieldAtIndex:0] text];
            uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
            if (uuid == nil) {
                [SVProgressHUD showErrorWithStatus:@"输入的UUID不合法。"];
                return;
            }
            
            [SVProgressHUD show];
            [HAMAVOSManager saveBeaconUUID:uuidString description:@"未知iBeacon" withTarget:self callback:@selector(didAddUUIDWithResult:error:)];
        default:
            //cancel
            break;
    }
}
             
- (void)didAddUUIDWithResult:(NSNumber*)result error:(NSError*)error{
    if (error != nil){
        [SVProgressHUD showErrorWithStatus:@"添加UUID失败。"];
        return;
    }
    
    HAMBeaconManager* beaconManager = [HAMBeaconManager beaconManager];
    [beaconManager restartMonitor];
    [SVProgressHUD showSuccessWithStatus:@"添加UUID成功。"];
}

@end
