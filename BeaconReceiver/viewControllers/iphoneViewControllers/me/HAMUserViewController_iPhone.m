//
//  HAMUserViewController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 5/21/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMUserViewController_iPhone.h"

#import "HAMCardListViewController_iPhone.h"
#import "HAMCreateThingViewController.h"
#import "HAMBeaconListViewController.h"

#import "SVProgressHUD.h"

#import "HAMThing.h"

#import "HAMAVOSManager.h"

#import "HAMConstants.h"
#import "HAMTools.h"
#import "HAMLogTool.h"

@interface HAMUserViewController_iPhone () <HAMCardListDelegate>
{
}

//@property (nonatomic) HAMThing* selectedThing;
@property (nonatomic) NSIndexPath* selectedIndexPath;

@property (nonatomic) Boolean updateThingsFirstTime;

@end

static NSString *kHAMEmbedSegueId = @"embedSegue";

@implementation HAMUserViewController_iPhone {
    HAMCardListViewController_iPhone *listViewController;
    NSMutableArray* thingArray;
}

#pragma mark - Cardlist Delegate

- (void)updateThingsAsync {
    [HAMAVOSManager thingsOfCurrentUserWithSkip:0 limit:kHAMNumberOfThingsInFirstPage target:self callback:@selector(didUpdateThingsWithResult:error:)];
}

- (void)didUpdateThingsWithResult:(NSArray*)resultArray error:(NSError*)error{
    if (error != nil) {
        [HAMLogTool error:[NSString stringWithFormat:@"error when update things: %@",error.localizedDescription]];
        [SVProgressHUD showErrorWithStatus:@"刷新thing列表出错。"];
        return;
    }
    
    if (self.updateThingsFirstTime == YES) {
        self.updateThingsFirstTime = NO;
        [SVProgressHUD dismiss];
    }
    
    thingArray = [NSMutableArray arrayWithArray:resultArray];
    
    //preload for cache result
    for (int i = 0; i < thingArray.count; i++) {
        [HAMAVOSManager isThingBoundToBeaconInBackground:thingArray[i]];
    }

    [listViewController didUpdateThingsWithThingArray:thingArray];
}

- (void)loadMoreThingsAsync {
    int count = (int)[thingArray count];
    [HAMAVOSManager thingsOfCurrentUserWithSkip:count limit:kHAMNumberOfTHingsInNextPage target:self callback:@selector(didLoadMoreThingsWithResult:error:)];
}

- (void)didLoadMoreThingsWithResult:(NSArray*)resultArray error:(NSError*)error{
    if (error != nil) {
        [HAMLogTool error:[NSString stringWithFormat:@"error when load more things: %@",error.localizedDescription]];
        [SVProgressHUD showErrorWithStatus:@"加载更多thing出错。"];
        return;
    }
    
    [thingArray addObjectsFromArray:resultArray];
    
    //preload for cache result
    for (int i = 0; i < resultArray.count; i++) {
        [HAMAVOSManager isThingBoundToBeaconInBackground:resultArray[i]];
    }
    
    [listViewController didLoadMoreThingsWithThingArray:thingArray];
}

- (void)refreshView {
    //FIXME:are you sure the following line should be here?
    self.navigationController.navigationBar.barTintColor = nil;
    if (self.updateThingsFirstTime) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    }
    
    thingArray = [NSMutableArray array];
    [self updateThingsAsync];
    
    if (listViewController != nil) {
        listViewController.shouldShowPurchaseItem = YES;
        [listViewController updateWithThingArray:thingArray scrollToTop:NO];
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
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    self.updateThingsFirstTime = YES;
    
//    [self refreshView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Unbind/Edit menu

//get selected Thing from self.selectedIndexPath
- (HAMThing*)selectedThing{
    if (self.selectedIndexPath == nil) {
        return nil;
    }
    
    int index = self.selectedIndexPath.row;
    if (index >= listViewController.thingArray.count) {
        return nil;
    }
    
    return listViewController.thingArray[index];
}

- (void)cellClicked:(NSIndexPath*)indexPath{
    self.selectedIndexPath = indexPath;
    HAMThing* thing = [self selectedThing];
    
    NSString* destructiveButtonTitle = nil;
    if ([HAMAVOSManager isThingBoundToBeacon:thing]) {
        destructiveButtonTitle = @"解除绑定";
    } else {
        destructiveButtonTitle = @"绑定";
    }

    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"我的thing"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:destructiveButtonTitle
                                  otherButtonTitles:@"详情",@"编辑",nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            //bind/unbind beacon
            if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"解除绑定"]) {
                [self unbindThing:self.selectedThing];
            }
            else {
                [self bindThing:self.selectedThing];
            }
            return;
            
        case 1:
            //show detail
            [listViewController showDetailWithThing:self.selectedThing sender:listViewController];
            return;
            
        case 2:
            //edit thing
            [self performSegueWithIdentifier:@"FromMyThingListToEditThing" sender:self.selectedThing];
            return;
            
        default:
            //cancel
            self.selectedIndexPath = nil;
            break;
    }
}

- (void)bindThing:(HAMThing*)thing{
    if (thing.objectID == nil) {
        return;
    }
    
    if (![HAMTools isWebAvailable]) {
        [SVProgressHUD showErrorWithStatus:@"网络不通"];
        return;
    }
    
    if ([HAMAVOSManager ownBeaconCountOfCurrentUser] >= kHAMMaxOwnBeaconCount) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"最多只能绑定%d个Beacon。",kHAMMaxOwnBeaconCount]];
        return;
    }
    
    [self performSegueWithIdentifier:@"FromMyThingListToBeaconList" sender:thing];
}

- (void)unbindThing:(HAMThing*)thing{
    if (thing.objectID == nil) {
        return;
    }
    
    if (![HAMTools isWebAvailable]) {
        [SVProgressHUD showErrorWithStatus:@"网络不通"];
        return;
    }
    
    [HAMAVOSManager unbindThingWithThingID:thing.objectID withTarget:self callback:@selector(didUnbindThing)];
}

//FIXME: add error param
- (void)didUnbindThing{
    [listViewController refreshCellAtIndexPath:self.selectedIndexPath];
    [SVProgressHUD showSuccessWithStatus:@"解除绑定成功"];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kHAMEmbedSegueId]) {
        if ([segue.destinationViewController isKindOfClass:[HAMCardListViewController_iPhone class]]) {
            listViewController = segue.destinationViewController;
            listViewController.delegate = self;
        }
    } else if ([segue.identifier isEqualToString:@"FromMyThingListToEditThing"]){
        //edit thing
        if ([segue.destinationViewController isKindOfClass:[HAMCreateThingViewController class]]) {
            HAMCreateThingViewController* createThingViewController = segue.destinationViewController;
            createThingViewController.isNewThing = NO;
            createThingViewController.thingToEdit = sender;
        }
    } else if ([segue.identifier isEqualToString:@"FromMyThingListToCreateThing"]){
        //create thing
        if ([segue.destinationViewController isKindOfClass:[HAMCreateThingViewController class]]) {
            HAMCreateThingViewController* createThingViewController = segue.destinationViewController;
            createThingViewController.isNewThing = YES;
        }
    } else if ([segue.identifier isEqualToString:@"FromMyThingListToBeaconList"]){
        if ([segue.destinationViewController isKindOfClass:[HAMBeaconListViewController class]]) {
            HAMBeaconListViewController* beaconListViewController = segue.destinationViewController;
            beaconListViewController.thingToBind = sender;
        }
    }
}

@end
