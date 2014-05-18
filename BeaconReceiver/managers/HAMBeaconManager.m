//
//  HAMBeaconManager.m
//  BeaconReceiver
//
//  Created by daiyue on 5/10/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMBeaconManager.h"

#import <AVOSCloud/AVOSCloud.h>

#import "HAMThing.h"

//#import "HAMBeaconDictionary.h"
#import "HAMHomepageData.h"
#import "HAMThingManager.h"
#import "HAMTourManager.h"
#import "HAMAVOSManager.h"

#import "HAMLogTool.h"
#import "HAMTools.h"

@interface HAMBeaconManager(){
    NSMutableDictionary* beaconDictionary;
}

@property NSMutableDictionary* descriptionDictionary;
//@property HAMBeaconDictionary* beaconThingDictionary;

@end

@implementation HAMBeaconManager

@synthesize delegate;
@synthesize detailDelegate;
@synthesize nearestBeacon;
@synthesize debugTextFields;

static HAMBeaconManager* beaconManager = nil;

static float defaultDistanceDelta = 0.5;

CLLocationManager *locationManager;
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
        }
    }
    return beaconManager;
}

-(id)init{
    if (self = [super init]) {
        beaconDictionary = [NSMutableDictionary dictionary];
        
        nearestBeacon = nil;
        beaconsAround = [NSMutableArray array];
        beaconRegions = [NSMutableArray array];
        debugTextFields = [NSMutableDictionary dictionary];
        [self setupLocationManager];
    }
    return self;
}

- (void)setupLocationManager {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
}

+ (void)setBackGroundStatus:(Boolean)status {
    isInBackground = status;
}

- (void)startMonitor {
    if (![HAMTools isWebAvailable]) {
        return;
    }
    AVQuery *query = [AVQuery queryWithClassName:@"BeaconUUID"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *uuidInfoArray, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            return;
        }
        if (uuidInfoArray == nil || uuidInfoArray.count == 0) {
            return;
        }
        
        //                    NSArray *beaconIDArray = [NSArray array];
//                    AVObject *globalObject = [objects objectAtIndex:0];
//                    beaconIDArray = (NSArray*)[globalObject objectForKey:@"proximityUUIDs"];
        
        self.descriptionDictionary = [NSMutableDictionary dictionary];
//        self.beaconThingDictionary = [HAMBeaconDictionary dictionary];
        NSMutableArray* beaconUUIDArray = [NSMutableArray array];
                
        //parse data
        for (int i = 0; i < uuidInfoArray.count; i++) {
            AVObject* beaconObject = uuidInfoArray[i];
            NSString* beaconUUID = [beaconObject objectForKey:@"proximityUUID"];
            [beaconUUIDArray addObject:beaconUUID];
//            NSNumber* major = [beaconObject objectForKey:@"major"];
//            NSNumber* minor = [beaconObject objectForKey:@"minor"];
            
            //save description
            NSString* description = [beaconObject objectForKey:@"description"];
            if (description == nil) {
                description = @"未知iBeacon";
            }
            [self.descriptionDictionary setObject:description forKey:beaconUUID];
            
//            //save thing
//            AVObject* thingObject = [beaconObject objectForKey:@"thing"];
//            HAMThing* thing = [HAMThing thingWithThingObject:thingObject];
//
//            [self.beaconThingDictionary setValue:thing forBeaconUUID:beaconUUID major:major minor:minor];
        }
        
        //start ranging
        for (int i = 0; i < beaconUUIDArray.count; i++)
        {
            NSString* uuidString = beaconUUIDArray[i];
            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
            CLBeaconRegion *region = [[CLBeaconRegion alloc]initWithProximityUUID:uuid identifier:uuidString];
            region.notifyEntryStateOnDisplay = YES;
            if (region != nil) {
                [beaconRegions addObject:region];
            }
        }
        
        for (CLBeaconRegion* beaconRegion in beaconRegions)
        {
                    //[estBeaconManager stopRangingBeaconsInRegion:beaconRegion];
            [locationManager startMonitoringForRegion:beaconRegion];
            [locationManager startRangingBeaconsInRegion:beaconRegion];
        }
    }];
}

- (void)stopMonitor {
    for (CLBeaconRegion* beaconRegion in beaconRegions)
    {
        [locationManager stopRangingBeaconsInRegion:beaconRegion];
        [locationManager stopMonitoringForRegion:beaconRegion];
    }
}

- (Boolean)beacon:(CLBeacon*)beacon1 theSameAsBeacon:(CLBeacon*)beacon2 {
    if (beacon1 == nil || beacon2 == nil) {
        return NO;
    }
    NSString *info1 = [[NSString alloc] initWithFormat:@"%@/%@/%@", beacon1.proximityUUID.UUIDString, beacon1.major, beacon1.minor];
    NSString *info2 = [[NSString alloc] initWithFormat:@"%@/%@/%@", beacon2.proximityUUID.UUIDString, beacon2.major, beacon2.minor];
    return [info1 isEqualToString:info2];
}

- (Boolean)pageData:(HAMHomepageData*)data1 theSameAsPageData:(HAMHomepageData*)data2 {
    if (data1 == nil && data2 == nil) {
        return YES;
    }
    if (data1 == nil || data2 == nil) {
        return NO;
    }
    NSString *info1 = [[NSString alloc] initWithFormat:@"%@/%@/%@", data1.beaconID, data1.beaconMajor, data1.beaconMinor];
    NSString *info2 = [[NSString alloc] initWithFormat:@"%@/%@/%@", data2.beaconID, data2.beaconMajor, data2.beaconMinor];
    return [info1 isEqualToString:info2];
}

- (Boolean)removeBeacon:(CLBeacon*)currentBeacon {
    long i;
    long count = [beaconsAround count];
    for (i = count - 1; i >= 0; i--) {
        CLBeacon *beacon = [beaconsAround objectAtIndex:i];
        if ([self beacon:beacon theSameAsBeacon:currentBeacon]) {
            [beaconsAround removeObjectAtIndex:i];
            return YES;
        }
    }
    return NO;
}
- (void)addBeacon:(CLBeacon*)currentBeacon {
    long i;
    long count = [beaconsAround count];
    for (i = 0; i < count; i++) {
        CLBeacon *beacon = (CLBeacon*)[beaconsAround objectAtIndex:i];
        if (currentBeacon.accuracy < beacon.accuracy) {
            [beaconsAround insertObject:currentBeacon atIndex:i];
            return;
        }
    }
    [beaconsAround addObject:currentBeacon];
}

#pragma mark - LocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    //update beaconDictionary
    CLBeaconRegion* beaconRegion = (CLBeaconRegion*)region;
    NSString* uuid = beaconRegion.proximityUUID.UUIDString;
    [beaconDictionary removeObjectForKey:uuid];
    
    [locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    
    if (state == CLRegionStateInside) {
        
        
        //Start Ranging
        [manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }
    
    else{
        
        //Stop Ranging
        [manager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    //update beaconDictionary
    NSString* uuid = region.proximityUUID.UUIDString;
    [beaconDictionary setObject:beacons forKey:uuid];
    
    for (CLBeacon* beacon in beacons) {
//        [HAMLogTool debug:[NSString stringWithFormat:@"distance:%f", beacon.accuracy]];
        HAMHomepageData *pageData = [HAMThingManager homepageWithBeaconID:beacon.proximityUUID.UUIDString major:beacon.major minor:beacon.minor];
        if (pageData == nil || beacon.accuracy < 0) {
            continue;
        }
        
        UITextField *debugTF = (UITextField*)[debugTextFields objectForKey:[NSString stringWithFormat:@"%@/%@/%@", pageData.beaconID, pageData.beaconMajor, pageData.beaconMinor]];
        if (debugTF != nil) {
            //debugTF.text = [NSString stringWithFormat:@"dis:%f", beacon.accuracy];
            debugTF.text = [NSString stringWithFormat:@"%@/%@  %f", beacon.major, beacon.minor, beacon.accuracy];
        }
        
        if ([self removeBeacon:beacon] == YES && beacon.accuracy <= (pageData.range.floatValue + defaultDistanceDelta)) {
            [self addBeacon:beacon];
        }
        else if (beacon.accuracy <= pageData.range.floatValue) {
            [self addBeacon:beacon];
            if (isInBackground == YES) {
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                NSDate *now = [NSDate date];
                localNotification.fireDate = now;
                if (pageData.pageTitle  == nil) {
                    localNotification.alertBody = @"beacon  found";
                }
                else {
                    localNotification.alertBody = pageData.pageTitle;
                }
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
        }
    }
    [self showHomepages];
}

- (void)showHomepages {
    CLBeacon *currentBeacon;
    HAMHomepageData *currentPageData;
    NSMutableArray *stuffsAround = [NSMutableArray array];
    long i, count = [beaconsAround count];
    for (i = 0; i < count; i++) {
        currentBeacon = [beaconsAround objectAtIndex:i];
        HAMHomepageData *pageData = [HAMThingManager homepageWithBeaconID:currentBeacon.proximityUUID.UUIDString major:currentBeacon.major minor:currentBeacon.minor];
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
        beaconsAroundCount = (int)count;
        if (delegate != nil) {
            [delegate displayHomepage:stuffsAround];
        }
        if (detailDelegate != nil) {
            [detailDelegate displayHomepage:stuffsAround];
        }
    }
}

#pragma mark - BeaconDictionary Methods

-(NSDictionary*)beaconDictionary{
    return [NSDictionary dictionaryWithDictionary:beaconDictionary];
}

- (NSString*)descriptionOfUUID:(NSString*)uuid{
    return [self.descriptionDictionary objectForKey:uuid];
}

//- (HAMThing*)thingOfBeacon:(CLBeacon*)beacon{
//    return [self.beaconThingDictionary objectForBeacon:beacon];
//}

@end
