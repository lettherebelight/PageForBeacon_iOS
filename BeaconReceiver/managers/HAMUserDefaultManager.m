//
//  HAMUserDefaultManager.m
//  BeaconReceiver
//
//  Created by daiyue on 6/24/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMUserDefaultManager.h"

#import "HAMThing.h"
#import "HAMConstants.h"

#import "HAMLogTool.h"

@implementation HAMUserDefaultManager

static NSString* const kHAMUserDefaultKeyThingNotificationDate = @"thingNotificationDate";

static HAMUserDefaultManager* userDefaultManager = nil;

+ (HAMUserDefaultManager*)userDefaultManager{
    @synchronized(self) {
        if (userDefaultManager == nil) {
            userDefaultManager = [[HAMUserDefaultManager alloc] init];
        }
    }
    return userDefaultManager;
}

+ (void)recordThingNotificated:(HAMThing*)thing {
    if (thing.objectID == nil) {
        [HAMLogTool warn:@"trying to record notificated thing with objectID == nil"];
        return;
    }
    
    NSDictionary* oldDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kHAMUserDefaultKeyThingNotificationDate];
    NSMutableDictionary* updatedDictionary;
    
    if (oldDictionary == nil) {
        updatedDictionary = [NSMutableDictionary dictionary];
    } else {
        updatedDictionary = [NSMutableDictionary dictionaryWithDictionary:oldDictionary];
    }
    
    [updatedDictionary setObject:[NSDate date] forKey:thing.objectID];
    [[NSUserDefaults standardUserDefaults] setObject:updatedDictionary forKey:kHAMUserDefaultKeyThingNotificationDate];
}

+ (Boolean)isThingNotificatedRecently:(HAMThing*)thing {
    if (thing.objectID == nil) {
        return NO;
    }
    
    NSDictionary* dictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kHAMUserDefaultKeyThingNotificationDate];
    
    NSDate* lastNotificationDate = [dictionary objectForKey:thing.objectID];
    if (lastNotificationDate == nil) {
        return NO;
    }
    
    if ([[NSDate date] timeIntervalSinceDate:lastNotificationDate] < kHAMNotificationMinTimeInteval) {
        return YES;
    }
    return NO;
}

@end
