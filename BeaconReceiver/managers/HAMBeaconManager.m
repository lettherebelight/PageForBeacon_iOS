//
//  HAMBeaconManager.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-26.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>
#import "HAMBeaconManager.h"
#import "HAMLogTool.h"
#import "HAMTools.h"
#import "HAMHomepageData.h"
#import "HAMHomepageManager.h"
#import "HAMDataManager.h"

@implementation HAMBeaconManager
@synthesize delegate;
@synthesize detailDelegate;

static HAMBeaconManager* beaconManager = nil;
static NSArray* beaconIDArray;

static float distanceRangeMin = 1;
static float distanceRangeMax = 1.8;

NSMutableArray *beaconRegions;
CLLocationManager *locationManager;
CLBeacon *nearestBeacon;
NSMutableArray *beaconsAround = nil;
bool allowNotify = YES;
bool isInBackground = NO;

+ (HAMBeaconManager*)beaconManager{
    @synchronized(self) {
        if (beaconManager == nil) {
            beaconManager = [[HAMBeaconManager alloc] init];
        }
    }
    return beaconManager;
}

+ (void)setNotifyStatus:(Boolean)status {
    allowNotify = status;
}

+ (void)setBackGroundStatus:(Boolean)status {
    isInBackground = status;
}

+ (NSArray*)beaconIDArray{
    //NSMutableArray *beaconIDArray = [NSMutableArray arrayWithObjects:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D", @"F62D3F65-2FCB-AB76-00AB-68186B10300D", nil];
    if ([HAMTools isWebAvailable]) {
        AVQuery *query = [AVQuery queryWithClassName:@"Global"];
        NSArray *objectArray = [query findObjects];
        if (objectArray != nil) {
            AVObject *globalObject = [objectArray objectAtIndex:0];
            beaconIDArray = (NSArray*)[globalObject objectForKey:@"proximityUUIDs"];
        }
    }
    return beaconIDArray;
}


- (void)startMonitor {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = [HAMBeaconManager beaconManager];
    nearestBeacon = nil;
    beaconsAround = [NSMutableArray array];
    beaconRegions = [NSMutableArray array];
    
    
    
    NSEnumerator *enumerator = [locationManager.monitoredRegions objectEnumerator];
    for (CLBeaconRegion *region in enumerator) {
        [locationManager stopMonitoringForRegion:region];
    }
    
    
    NSArray *idArray = [HAMBeaconManager beaconIDArray];
    
    for (NSString* BId in idArray)
    {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:BId];
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:BId];
        region.notifyEntryStateOnDisplay = YES;
        if (region != nil) {
            [beaconRegions addObject:region];
        }
    }
    
    for (CLBeaconRegion* beaconRegion in beaconRegions)
    {
        [locationManager startMonitoringForRegion:beaconRegion];
        [locationManager startRangingBeaconsInRegion:beaconRegion];
    }
}

- (void)stopMonitor {
    NSArray *idArray = [HAMBeaconManager beaconIDArray];
    
    for (NSString* BId in idArray)
    {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:BId];
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:BId];
        region.notifyEntryStateOnDisplay = YES;
        if (region != nil) {
            [beaconRegions addObject:region];
        }
    }
    
    for (CLBeaconRegion* beaconRegion in beaconRegions)
    {
        [locationManager stopMonitoringForRegion:beaconRegion];
    }
}

- (Boolean)beacon:(CLBeacon*)beacon1 theSameAsBeacon:(CLBeacon*)beacon2 {
    if (beacon1 == nil || beacon2 == nil) {
        return NO;
    }
    NSString *info1 = [[NSString alloc] initWithFormat:@"%@%@%@", beacon1.proximityUUID.UUIDString, beacon1.major, beacon1.minor];
    NSString *info2 = [[NSString alloc] initWithFormat:@"%@%@%@", beacon2.proximityUUID.UUIDString, beacon2.major, beacon2.minor];
    return [info1 isEqualToString:info2];
}

- (void)getAndDisplayHomepagesAround {
    /*if (delegate) {
        NSMutableArray *objectsAround;
        objectsAround = [NSMutableArray array];
        for (CLBeacon* beacon in beaconsAround) {
            HAMHomepageData *homepage = [HAMHomepageManager homepageWithBeaconID:beacon.proximityUUID.UUIDString major:beacon.major minor:beacon.minor];
            if (homepage) {
                [objectsAround addObject:homepage];
            }
        }
        [delegate displayHomepage:objectsAround];
    }*/
    HAMHomepageData *homepage = nil;
    if (beaconsAround != nil && [beaconsAround count] > 0) {
        CLBeacon *beacon = [beaconsAround objectAtIndex:0];
        if (beacon.accuracy > distanceRangeMin || [self beacon:beacon theSameAsBeacon:nearestBeacon]) {
            return;
        } else {
            nearestBeacon = beacon;
            homepage = [HAMHomepageManager homepageWithBeaconID:beacon.proximityUUID.UUIDString major:beacon.major minor:beacon.minor];
            if (homepage != nil && homepage.historyListRecord == nil) {
                [HAMDataManager addAHistoryRecord:homepage];
            } else if (homepage != nil) {
                [HAMDataManager updateHistoryRecord:homepage.historyListRecord];
            }
        }
    }
    else if (nearestBeacon == nil){
        return;
    } else {
        nearestBeacon = nil;
    }
    if (delegate != nil) {
        [delegate displayHomepage:homepage];
    }
    if (detailDelegate != nil) {
        [detailDelegate displayHomepage:homepage];
    }
}

- (NSArray*)removeBeaconByUUID:(NSString*)uuid {
    NSMutableArray *removedBeaconInfo;
    removedBeaconInfo = [NSMutableArray array];
    long i;
    for (i = [beaconsAround count] - 1; i >= 0; i--) {
        CLBeacon *beacon = [beaconsAround objectAtIndex:i];
        if ([beacon.proximityUUID.UUIDString isEqualToString:uuid]) {
            NSString *info = [NSString stringWithFormat:@"%@%@", beacon.major, beacon.minor];
            [removedBeaconInfo addObject:info];
            [beaconsAround removeObjectAtIndex:i];
        }
    }
    return removedBeaconInfo;
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [HAMLogTool debug:[NSString stringWithFormat:@"enter region: %@", region.identifier]];
    [locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    //[HAMLogTool debug:[NSString stringWithFormat:@"exit region: %@", region.identifier]];
    [locationManager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
    [self removeBeaconByUUID:region.identifier];
    [self getAndDisplayHomepagesAround];
}

- (BOOL)beacon:(CLBeacon *)beacon1 isCloserToBeacon:(CLBeacon *)beacon2 {
    if (beacon2 == nil)
    {
        return true;
    }
    else if (beacon1.proximity == CLProximityUnknown)
    {
        return false;
    }
    else if (beacon2.proximity == CLProximityUnknown)
    {
        return true;
    }
    else if (beacon1.proximity > beacon2.proximity)
    {
        return false;
    }
    else if (beacon1.proximity < beacon2.proximity)
    {
        return true;
    }
    else if (beacon1.accuracy < beacon2.accuracy)
    {
        return true;
    }
    else
    {
        return false;
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    bool needToNotificate = YES;
    
    //beaconsAround = [NSMutableArray array];
    
    NSArray *removedBeaconInfo = [self removeBeaconByUUID:region.identifier];
    
    for (CLBeacon* beacon in beacons) {
        [HAMLogTool debug:[NSString stringWithFormat:@"accuracy:%f", beacon.accuracy]];
        if (beacon == nil || beacon.accuracy > distanceRangeMax || beacon.accuracy < 0) {
            continue;
        }
        NSString *currentBInfo = [NSString stringWithFormat:@"%@%@", beacon.major, beacon.minor];
        for (NSString *bInfo in removedBeaconInfo) {
            if ([currentBInfo isEqualToString:bInfo]) {
                needToNotificate = NO;
                break;
            }
        }
        long i;
        for (i = 0; i < [beaconsAround count]; i++) {
            if ([self beacon:beacon isCloserToBeacon:[beaconsAround objectAtIndex:i]]) {
                [beaconsAround insertObject:beacon atIndex:i];
                break;
            }
        }
        if (i == [beaconsAround count]) {
            [beaconsAround addObject:beacon];
        }
        if (allowNotify == YES && needToNotificate == YES && isInBackground == YES) {
            HAMHomepageData *homepage = [HAMHomepageManager homepageWithBeaconID:beacon.proximityUUID.UUIDString major:beacon.major minor:beacon.minor];
            if (homepage != nil) {
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                NSDate *now = [NSDate date];
                localNotification.fireDate = now;
                if (homepage.pageTitle  == nil) {
                    localNotification.alertBody = @"beacon  found";
                }
                else {
                    localNotification.alertBody = homepage.pageTitle;
                }
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
        }
    }
    
    [self getAndDisplayHomepagesAround];
}

@end
