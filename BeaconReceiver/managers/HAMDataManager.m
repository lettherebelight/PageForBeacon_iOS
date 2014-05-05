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
#import "HAMTourManager.h"

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

+ (void)saveData {
    [appDelegate saveContext];
}

+ (void)deleteRecord:(NSManagedObject*)object {
    if (object != nil) {
        [[self context] deleteObject:object];
    }
    [appDelegate saveContext];
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
    NSEntityDescription *pageDataEntity = [NSEntityDescription entityForName:@"HAMHomepageData" inManagedObjectContext:context];
    [fetchRequest setEntity:pageDataEntity];
    NSError *error3 = nil;
    NSArray *fetchedpageDataObjects = [context executeFetchRequest:fetchRequest error:&error3];
    if (fetchedMarkedObjects == nil || [fetchedMarkedObjects count] == 0) {
    } else {
        for (HAMHistoryHomepage* markedPage in fetchedMarkedObjects) {
            [context deleteObject:markedPage];
        }
    }
    if (fetchedHistoryObjects == nil || [fetchedHistoryObjects count] == 0) {
    } else {
        for (HAMHistoryHomepage* historyPage in fetchedHistoryObjects) {
            [context deleteObject:historyPage];
        }
    }
    if (fetchedpageDataObjects == nil || [fetchedpageDataObjects count] == 0) {
    } else {
        for (HAMHomepageData* pageData in fetchedpageDataObjects) {
            [context deleteObject:pageData];
        }
    }
    [appDelegate saveContext];
}

+ (HAMHomepageData*)newPageData {
    HAMHomepageData *pageData = [NSEntityDescription insertNewObjectForEntityForName:@"HAMHomepageData" inManagedObjectContext:[self context]];
    return pageData;
}

+ (HAMHomepageData*)pageDataWithBID:(NSString *)beaconID major:(NSNumber *)major minor:(NSNumber *)minor {
    NSPredicate *query = [NSPredicate predicateWithFormat:@"beaconID = %@ AND beaconMajor = %@ AND beaconMinor = %@", beaconID, major, minor];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HAMHomepageData" inManagedObjectContext:[self context]];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:query];
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil || [fetchedObjects count] == 0) {
        return nil;
    } else {
        return [fetchedObjects objectAtIndex:0];
    }
}

+ (void)addAMarkedRecord:(HAMHomepageData*)home {
    if (home == nil) {
        return;
    }
    HAMMarkedHomepage *markedPage = [NSEntityDescription insertNewObjectForEntityForName:@"HAMMarkedHomepage" inManagedObjectContext:[self context]];
    markedPage.date = [NSDate date];
    markedPage.homepage = home;
    home.markedListRecord = markedPage;
    [appDelegate saveContext];
}
+ (void)removeMarkedRecord:(HAMHomepageData *)home {
    if (home == nil) {
        return;
    }
    [[self context] deleteObject:home.markedListRecord];
    [appDelegate saveContext];
}
+ (void)addAHistoryRecord:(HAMHomepageData*)home {
    if (home == nil) {
        return;
    }
    HAMHistoryHomepage *historyPage = [NSEntityDescription insertNewObjectForEntityForName:@"HAMHistoryHomepage" inManagedObjectContext:[self context]];
    historyPage.date = [NSDate date];
    historyPage.homepage = home;
    home.historyListRecord = historyPage;
    [appDelegate saveContext];
}
+ (NSArray*)fetchMarkedRecords {
    NSMutableArray *pages = [NSMutableArray array];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HAMMarkedHomepage" inManagedObjectContext:[self context]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                         initWithKey:@"date" ascending:NO];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:sortDescriptor, nil]];
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"date" ascending:NO];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:sortDescriptor, nil]];
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
+ (void)updateHistoryRecord:(HAMHistoryHomepage *)history {
    if (history == nil) {
        return;
    }
    history.date = [NSDate date];
    [appDelegate saveContext];
}

@end
