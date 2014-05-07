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
#import "HAMTourManager.h"

@implementation HAMBeaconManager

@synthesize delegate;
@synthesize detailDelegate;
@synthesize nearestBeacon;

static HAMBeaconManager* beaconManager = nil;

static float defaultDistanceDelta = 0.5;

ESTBeaconManager *estBeaconManager;
NSMutableArray *beaconRegions;
NSMutableArray *beaconsAround = nil;
bool isInBackground = NO;

HAMHomepageData *lastPageData = nil;
HAMHomepageData *nearestPageData = nil;
int nearestTime = 0;
int beaconsAroundCount = 0;

+ (HAMBeaconManager*)beaconManager{
    @synchronized(self) {
        if (beaconManager == nil) {
            beaconManager = [[HAMBeaconManager alloc] init];
            [beaconManager setupESTBeaconManager];
        }
    }
    return beaconManager;
}

- (void)setupESTBeaconManager {
    estBeaconManager = [[ESTBeaconManager alloc] init];
    estBeaconManager.delegate = self;
    estBeaconManager.avoidUnknownStateBeacons = YES;
}

+ (void)setBackGroundStatus:(Boolean)status {
    isInBackground = status;
}

+ (NSArray*)beaconIDArray{
    //NSMutableArray *beaconIDArray = [NSMutableArray arrayWithObjects:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D", @"F62D3F65-2FCB-AB76-00AB-68186B10300D", nil];
    NSArray *beaconIDArray = nil;
    if ([HAMTools isWebAvailable]) {
        AVQuery *query = [AVQuery queryWithClassName:@"Global"];
        NSArray *objectArray = [query findObjects];
        //NSArray *objectArray = nil;
        beaconIDArray = [NSArray array];
        if (objectArray != nil) {
            AVObject *globalObject = [objectArray objectAtIndex:0];
            beaconIDArray = (NSArray*)[globalObject objectForKey:@"proximityUUIDs"];
        }
    }
    return beaconIDArray;
}


- (void)startMonitor {
    nearestBeacon = nil;
    beaconsAround = [NSMutableArray array];
    beaconRegions = [NSMutableArray array];
    
    if ([HAMTools isWebAvailable]) {
        AVQuery *query = [AVQuery queryWithClassName:@"Global"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                if (objects != nil && [objects count] > 0) {
                    NSArray *beaconIDArray = [NSArray array];
                    AVObject *globalObject = [objects objectAtIndex:0];
                    beaconIDArray = (NSArray*)[globalObject objectForKey:@"proximityUUIDs"];
                    for (NSString* BId in beaconIDArray)
                    {
                        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:BId];
                        ESTBeaconRegion *region = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid identifier:BId];
                        region.notifyEntryStateOnDisplay = YES;
                        if (region != nil) {
                            [beaconRegions addObject:region];
                        }
                    }
                    
                    for (ESTBeaconRegion* beaconRegion in beaconRegions)
                    {
                        //[estBeaconManager stopRangingBeaconsInRegion:beaconRegion];
                        [estBeaconManager startRangingBeaconsInRegion:beaconRegion];
                    }
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    
}

- (void)stopMonitor {
    for (ESTBeaconRegion* beaconRegion in beaconRegions)
    {
        [estBeaconManager stopRangingBeaconsInRegion:beaconRegion];
    }
}

- (Boolean)beacon:(ESTBeacon*)beacon1 theSameAsBeacon:(ESTBeacon*)beacon2 {
    if (beacon1 == nil || beacon2 == nil) {
        return NO;
    }
    NSString *info1 = [[NSString alloc] initWithFormat:@"%@%@%@", beacon1.proximityUUID.UUIDString, beacon1.major, beacon1.minor];
    NSString *info2 = [[NSString alloc] initWithFormat:@"%@%@%@", beacon2.proximityUUID.UUIDString, beacon2.major, beacon2.minor];
    return [info1 isEqualToString:info2];
}

- (Boolean)pageData:(HAMHomepageData*)data1 theSameAsPageData:(HAMHomepageData*)data2 {
    if (data1 == nil && data2 == nil) {
        return YES;
    }
    if (data1 == nil || data2 == nil) {
        return NO;
    }
    NSString *info1 = [[NSString alloc] initWithFormat:@"%@%@%@", data1.beaconID, data1.beaconMajor, data1.beaconMinor];
    NSString *info2 = [[NSString alloc] initWithFormat:@"%@%@%@", data2.beaconID, data2.beaconMajor, data2.beaconMinor];
    return [info1 isEqualToString:info2];
}

- (Boolean)removeBeacon:(ESTBeacon*)currentBeacon {
    long i;
    long count = [beaconsAround count];
    for (i = count - 1; i >= 0; i--) {
        ESTBeacon *beacon = [beaconsAround objectAtIndex:i];
        if ([self beacon:beacon theSameAsBeacon:currentBeacon]) {
            [beaconsAround removeObjectAtIndex:i];
            return YES;
        }
    }
    return NO;
}
- (void)addBeacon:(ESTBeacon*)currentBeacon {
    long i;
    long count = [beaconsAround count];
    for (i = 0; i < count; i++) {
        ESTBeacon *beacon = (ESTBeacon*)[beaconsAround objectAtIndex:i];
        if (currentBeacon.distance.floatValue < beacon.distance.floatValue) {
            [beaconsAround insertObject:currentBeacon atIndex:i];
            return;
        }
    }
    [beaconsAround addObject:currentBeacon];
}
- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region {
    for (ESTBeacon* beacon in beacons) {
        [HAMLogTool debug:[NSString stringWithFormat:@"distance:%@", beacon.distance]];
        HAMHomepageData *pageData = [HAMHomepageManager homepageWithBeaconID:beacon.proximityUUID.UUIDString major:beacon.major minor:beacon.minor];
        if (pageData == nil) {
            continue;
        }
        if ([self removeBeacon:beacon] == YES && beacon.distance.floatValue <= (pageData.range.floatValue + defaultDistanceDelta)) {
            [self addBeacon:beacon];
        }
        else if (beacon.distance.floatValue <= pageData.range.floatValue) {
            [self addBeacon:beacon];
        }
    }
    [self showHomepages];
}

- (void)showHomepages {
    ESTBeacon *currentBeacon;
    HAMHomepageData *currentPageData;
    NSMutableArray *stuffsAround = [NSMutableArray array];
    long i, count = [beaconsAround count];
    for (i = 0; i < count; i++) {
        currentBeacon = [beaconsAround objectAtIndex:i];
        HAMHomepageData *pageData = [HAMHomepageManager homepageWithBeaconID:currentBeacon.proximityUUID.UUIDString major:currentBeacon.major minor:currentBeacon.minor];
        if (pageData != nil) {
            [stuffsAround addObject:pageData];
        }
    }
    
    if (count == 0) {
        currentPageData = nil;
    } else {
        currentPageData = [stuffsAround objectAtIndex:0];
    }
    
    if ([self pageData:currentPageData theSameAsPageData:nearestPageData]) {
        nearestTime ++;
    } else {
        nearestTime = 0;
        lastPageData = nearestPageData;
        nearestPageData = currentPageData;
    }
    
    if (nearestTime == 3) {
        if (lastPageData != nil) {
            [[HAMTourManager tourManager] leaveStuff:lastPageData];
        }
        if (currentPageData != nil) {
            [[HAMTourManager tourManager] approachStuff:currentPageData];
        }
    }
    
    if (count != beaconsAroundCount || nearestTime == 3) {
        beaconsAroundCount = count;
        if (delegate != nil) {
            [delegate displayHomepage:stuffsAround];
        }
        if (detailDelegate != nil) {
            [detailDelegate displayHomepage:stuffsAround];
        }
    }
    
    /*
    if (count == 0) {
        currentBeacon = nil;
        if (nearestBeacon == nil) {
            return;
        }
    }
    else {
        currentBeacon = [beaconsAround objectAtIndex:0];
    }
    if ([self beacon:currentBeacon theSameAsBeacon:nearestBeacon] == NO) {
        if (nearestBeacon != nil) {
            HAMHomepageData* pageData = [HAMHomepageManager homepageWithBeaconID:nearestBeacon.proximityUUID.UUIDString major:nearestBeacon.major minor:nearestBeacon.minor];
            [[HAMTourManager tourManager] leaveStuff:pageData];
        }
        nearestBeacon = currentBeacon;
        HAMHomepageData* pageData;
        if (currentBeacon == nil) {
            pageData = nil;
        } else {
            pageData = [HAMHomepageManager homepageWithBeaconID:currentBeacon.proximityUUID.UUIDString major:currentBeacon.major minor:currentBeacon.minor];
            if (pageData != nil) {
                [[HAMTourManager tourManager] approachStuff:pageData];
            }
        }
        if (delegate != nil) {
            [delegate displayHomepage:stuffsAround];
        }
        if (detailDelegate != nil) {
            [detailDelegate displayHomepage:stuffsAround];
        }
    }
     */
}

/*
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
 */

/*
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
        if (isInBackground == YES) {
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
*/
/*
- (void)DisplayHomepagesAround {
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
}*/

@end
