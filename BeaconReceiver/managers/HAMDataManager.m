//
//  HAMDataManager.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-14.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMDataManager.h"
#import "HAMAppDelegate.h"
#import "HAMGlobalData.h"

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

+ (HAMGlobalData*)globalData {
    @synchronized(self) {
        HAMGlobalData *globalData;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *globalDataEntity = [NSEntityDescription entityForName:@"HAMGlobalData" inManagedObjectContext:[self context]];
        [fetchRequest setEntity:globalDataEntity];
        NSError *error1 = nil;
        NSArray *fetchedGlobalObjects = [context executeFetchRequest:fetchRequest error:&error1];
        if (fetchedGlobalObjects == nil || [fetchedGlobalObjects count] == 0) {
            globalData = [NSEntityDescription insertNewObjectForEntityForName:@"HAMGlobalData" inManagedObjectContext:[self context]];
        } else{
            globalData = [fetchedGlobalObjects objectAtIndex:0];
        }
        return globalData;
    }
}

@end
