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

#import "HAMTools.h"
#import "HAMLogTool.h"

@implementation HAMUserDefaultManager


//thingNotificationDate:
//key   - (NSString*) thing.objectID
//value - (NSDate*)   notificationDate
static NSString* const kHAMUserDefaultKeyThingNotificationDate = @"thingNotificationDate";


//thingBoundToBeacon
//key   - (NSString*)     thing.objectID
//value - (NSDictionary*) boundData
//        key   - (NSString*) @"result"
//        value - (NSString*) @"YES" or @"NO"
//        key   - (NSString*) @"cacheDate"
//        value - (NSDate*)   cacheDate
static NSString* const kHAMUserDefaultKeyThingBoundToBeacon = @"thingBoundToBeacon";
static NSString* const kHAMUserDefaultKeyThingBoundToBeaconDate = @"cacheDate";
static NSString* const kHAMUserDefaultKeyThingBoundToBeaconResult = @"result";

//Settings.bundle
static NSString* const kHAMUserDefaultKeySettingsDebugMode = @"debugSetting";

static HAMUserDefaultManager* userDefaultManager = nil;

+ (HAMUserDefaultManager*)userDefaultManager{
    @synchronized(self) {
        if (userDefaultManager == nil) {
            userDefaultManager = [[HAMUserDefaultManager alloc] init];
        }
    }
    return userDefaultManager;
}

#pragma mark - ThingNotificateDate

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

#pragma mark - ThingBoundToBeacon

+ (void)recordThing:(HAMThing*)thing isBoundToBeacon:(NSString*)isBoundToBeacon {
    if (thing.objectID == nil || isBoundToBeacon == nil) {
        return;
    }
    
    NSDictionary* oldDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kHAMUserDefaultKeyThingBoundToBeacon];
    NSMutableDictionary* updatedDictionary;
    
    if (oldDictionary == nil) {
        updatedDictionary = [NSMutableDictionary dictionary];
    } else {
        updatedDictionary = [NSMutableDictionary dictionaryWithDictionary:oldDictionary];
    }
    
    NSDictionary* boundData = [NSDictionary dictionaryWithObjectsAndKeys:
                               isBoundToBeacon,
                               kHAMUserDefaultKeyThingBoundToBeaconResult,
                               [NSDate date],
                               kHAMUserDefaultKeyThingBoundToBeaconDate, nil];
    
    [updatedDictionary setObject:boundData forKey:thing.objectID];
    [[NSUserDefaults standardUserDefaults] setObject:updatedDictionary forKey:kHAMUserDefaultKeyThingBoundToBeacon];
}

+ (NSString*)isThingBoundToBeaconInCache:(HAMThing*)thing{
    if (thing.objectID == nil) {
        [HAMLogTool warn:@"query isThingBoundToBeacon from cache where thing.objectID == nil"];
        return @"NO";
    }
    
    NSDictionary* dictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kHAMUserDefaultKeyThingBoundToBeacon];
    
    NSDictionary* boundData = [dictionary objectForKey:thing.objectID];
    if (boundData == nil) {
        return NO;
    }
    
    NSDate* cacheDate = boundData[kHAMUserDefaultKeyThingBoundToBeaconDate];
    
    if ([[NSDate date] timeIntervalSinceDate:cacheDate] < kHAMMaxCacheAge) {
        return boundData[kHAMUserDefaultKeyThingBoundToBeaconResult];
    }
    
    return nil;
}

#pragma mark - Debug Mode

+ (Boolean)isDebugMode{
    NSString* debugModeString = [[NSUserDefaults standardUserDefaults] stringForKey:kHAMUserDefaultKeySettingsDebugMode];
    
    if (debugModeString == nil || [debugModeString isEqualToString:@"0"]) {
        return NO;
    } else if ([debugModeString isEqualToString:@"1"]) {
        return YES;
    }
    
    [HAMLogTool error:[NSString stringWithFormat:@"error isDebugMode data in userDefaults:%@",debugModeString]];
    return NO;
}

@end
