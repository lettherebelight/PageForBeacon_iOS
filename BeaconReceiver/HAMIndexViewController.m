//
//  HAMIndexViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-11.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMIndexViewController.h"
#import "HAMAppDelegate.h"
#import "HAMHomepageData.h"
#import "HAMDataManager.h"

@interface HAMIndexViewController ()

@end

@implementation HAMIndexViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonClicked:(id)sender {
    HAMAppDelegate *appDelegate = (HAMAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    HAMHomepageData *homepage = [NSEntityDescription insertNewObjectForEntityForName:@"HAMHomepageData" inManagedObjectContext:context];
    homepage.pageTitle = self.textField.text;
    [HAMDataManager addAHistoryRecord:homepage];
    [appDelegate saveContext];
}
- (IBAction)loadButtonClicked:(id)sender {
    HAMAppDelegate *appDelegate = (HAMAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HAMHomepageData" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil || [fetchedObjects count] == 0) {
        self.textField.text = @"No Data";
    } else {
        HAMHomepageData *home = (HAMHomepageData*)[fetchedObjects objectAtIndex:0];
        self.textField.text = home.pageTitle;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
