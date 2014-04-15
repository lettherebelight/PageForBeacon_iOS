//
//  HAMDataManager.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-14.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMDataManager.h"
#import "HAMHomepageData.h"
#import "HAMMarkedHomepage.h"
#import "HAMHistoryHomepage.h"
#import "HAMAppDelegate.h"

@implementation HAMDataManager

static HAMAppDelegate *appDelegate;
static NSManagedObjectContext *context;

+ (HAMAppDelegate*)appDelegate {
    @synchronized(self) {
        if (appDelegate == nil) {
            appDelegate = (HAMAppDelegate*)[[UIApplication sharedApplication] delegate];
        }
    }
    return appDelegate;
}
+ (NSManagedObjectContext*)context {
    @synchronized(self) {
        if (context == nil) {
            context = [[self appDelegate] managedObjectContext];
        }
    }
    return context;
}

+ (void)clearData {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *markedEntity = [NSEntityDescription entityForName:@"HAMMarkedHomepage" inManagedObjectContext:[self context]];
    [fetchRequest setEntity:markedEntity];
    NSError *error1 = nil;
    NSArray *fetchedMarkedObjects = [context executeFetchRequest:fetchRequest error:&error1];
    NSEntityDescription *historyEntity = [NSEntityDescription entityForName:@"HAMHistoryHomepage" inManagedObjectContext:context];
    [fetchRequest setEntity:historyEntity];
    NSError *error2 = nil;
    NSArray *fetchedHistoryObjects = [context executeFetchRequest:fetchRequest error:&error2];
    if (fetchedMarkedObjects == nil || [fetchedMarkedObjects count] == 0) {
    } else {
        for (HAMHistoryHomepage* markedPage in fetchedMarkedObjects) {
            [context delete:markedPage];
        }
    }
    if (fetchedHistoryObjects == nil || [fetchedHistoryObjects count] == 0) {
    } else {
        for (HAMHistoryHomepage* historyPage in fetchedHistoryObjects) {
            [context deleteObject:historyPage];
        }
    }
}

+ (void)addAMarkedRecord:(HAMHomepageData*)home {
    HAMMarkedHomepage *markedPage = [NSEntityDescription insertNewObjectForEntityForName:@"HAMMarkedHomepage" inManagedObjectContext:[self context]];
    markedPage.homepage = home;
    [appDelegate saveContext];
}
+ (void)addAHistoryRecord:(HAMHomepageData*)home {
    HAMHistoryHomepage *historyPage = [NSEntityDescription insertNewObjectForEntityForName:@"HAMHistoryHomepage" inManagedObjectContext:[self context]];
    historyPage.homepage = home;
    [appDelegate saveContext];
}
+ (NSArray*)fetchMarkedRecords {
    NSMutableArray *pages = [NSMutableArray array];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HAMMarkedHomepage" inManagedObjectContext:[self context]];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil || [fetchedObjects count] == 0) {
        return nil;
    } else {
        for (HAMMarkedHomepage* markedPage in fetchedObjects) {
            [pages addObject:markedPage.homepage];
        }
        return pages;
    }
}
+ (NSArray*)fetchHistoryRecords {
    NSMutableArray *pages = [NSMutableArray array];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HAMHistoryHomepage" inManagedObjectContext:[self context]];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil || [fetchedObjects count] == 0) {
        return nil;
    } else {
        for (HAMHistoryHomepage* historyPage in fetchedObjects) {
            [pages addObject:historyPage.homepage];
        }
        return pages;
    }
}

@end
