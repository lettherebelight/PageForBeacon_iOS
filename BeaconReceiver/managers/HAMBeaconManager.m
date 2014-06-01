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

#import "HAMThingManager.h"
#import "HAMTourManager.h"
#import "HAMAVOSManager.h"

#import "HAMLogTool.h"
#import "HAMTools.h"

@interface HAMBeaconManager(){
    NSMutableDictionary* beaconDictionary;
    CLLocationManager *locationManager;
    
    bool isInBackground;
    
    NSMutableArray *previousThings;
    
    NSTimer *flushTimer;
    
    HAMThing* lastNotificatedThing;
    NSDate* lastNotificationDate;
}

@property (nonatomic) NSDictionary* descriptionDictionary;
@property (nonatomic) NSMutableArray* beaconRegions;

@end

@implementation HAMBeaconManager

@synthesize delegate;
@synthesize detailDelegate;
@synthesize nearestBeacon;
@synthesize debugTextFields;

static HAMBeaconManager* beaconManager = nil;

static double kHAMRefreshBeaconDictionaryTimeInteval = 1.0f;
//static float defaultDistanceDelta = 0.5;

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
        debugTextFields = [NSMutableDictionary dictionary];
        
        isInBackground = NO;
        
        previousThings = [NSMutableArray array];
        
        [self setupLocationManager];
    }
    return self;
}

- (void)setupLocationManager {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
}

- (void)setBackGroundStatus:(Boolean)status {
    isInBackground = status;
}

- (BOOL)beacon:(CLBeacon*)beacon1 theSameAsBeacon:(CLBeacon*)beacon2 {
    if (beacon1 == nil || beacon2 == nil) {
        return NO;
    }
    NSString *info1 = [[NSString alloc] initWithFormat:@"%@/%@/%@", beacon1.proximityUUID.UUIDString, beacon1.major, beacon1.minor];
    NSString *info2 = [[NSString alloc] initWithFormat:@"%@/%@/%@", beacon2.proximityUUID.UUIDString, beacon2.major, beacon2.minor];
    return [info1 isEqualToString:info2];
}

#pragma mark - Start/Stop Monitor

- (void)startMonitor {
    if (![HAMTools isWebAvailable]) {
        [HAMLogTool error:@"currently offline."];
        return;
    }

    /*AVQuery *query = [AVQuery queryWithClassName:@"BeaconUUID"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *uuidInfoArray, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            return;
        }
        if (uuidInfoArray == nil || uuidInfoArray.count == 0) {
            return;
        }

        self.descriptionDictionary = [NSMutableDictionary dictionary];
//        self.beaconThingDictionary = [HAMBeaconDictionary dictionary];
        NSMutableArray* beaconUUIDArray = [NSMutableArray array];
                
        //parse data
        for (int i = 0; i < uuidInfoArray.count; i++) {
            AVObject* beaconObject = uuidInfoArray[i];
            NSString* beaconUUID = [beaconObject objectForKey:@"proximityUUID"];
            [beaconUUIDArray addObject:beaconUUID];
            
            //save description
            NSString* description = [beaconObject objectForKey:@"description"];
            if (description == nil) {
                description = @"未知iBeacon";
            }
            [self.descriptionDictionary setObject:description forKey:beaconUUID];
        }
        */
    self.descriptionDictionary = [HAMAVOSManager beaconDescriptionDictionary];
    if (self.descriptionDictionary == nil) {
        [HAMLogTool error:@"failed to fetch BeaconUUID dictionary"];
        return;
    }
    
    NSArray* beaconUUIDArray = [self.descriptionDictionary allKeys];
    self.beaconRegions = [NSMutableArray array];
    for (int i = 0; i < beaconUUIDArray.count; i++)
    {
        NSString* uuidString = beaconUUIDArray[i];
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
        if (uuid == nil) {
            [HAMLogTool warn:[NSString stringWithFormat:@"invalid UUID: %@",uuidString]];
            continue;
        }
        
        CLBeaconRegion *region = [[CLBeaconRegion alloc]initWithProximityUUID:uuid identifier:uuidString];
        region.notifyEntryStateOnDisplay = YES;
        if (region != nil) {
            [self.beaconRegions addObject:region];
        }
    }
    
    for (CLBeaconRegion* beaconRegion in self.beaconRegions)
    {
        [locationManager startMonitoringForRegion:beaconRegion];
        [locationManager startRangingBeaconsInRegion:beaconRegion];
    }
    
    flushTimer = [NSTimer scheduledTimerWithTimeInterval:kHAMRefreshBeaconDictionaryTimeInteval target:self selector:@selector(flushBeaconDictionary) userInfo:nil repeats:YES];
}

- (void)stopMonitor {
    if (self.beaconRegions == nil) {
        return;
    }
    
    for (CLBeaconRegion* beaconRegion in self.beaconRegions){
        [locationManager stopRangingBeaconsInRegion:beaconRegion];
        [locationManager stopMonitoringForRegion:beaconRegion];
    }
    self.beaconRegions = nil;
}

- (void)restartMonitor {
    [self stopMonitor];
    [self startMonitor];
}

/*
- (BOOL)removeBeacon:(CLBeacon*)currentBeacon {
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
            if (currentBeacon == nil) {
                return;
            }
            [beaconsAround insertObject:currentBeacon atIndex:i];
            return;
        }
    }
    [beaconsAround addObject:currentBeacon];
}*/

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

- (void)notificateWithThing:(HAMThing*)thing {
    if (thing == nil) {
        return;
    }
    
    if ([lastNotificatedThing.objectID isEqualToString: thing.objectID])
    {
        NSDate* date = [NSDate date];
        long long lastTime = [HAMTools longLongFromDate:lastNotificationDate];
        long long currentTime = [HAMTools longLongFromDate:date];
        if (currentTime - lastTime <= 10000) {
            return;
        }
    }
    
    lastNotificatedThing = thing;
    lastNotificationDate = [NSDate date];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    if (thing.title  == nil) {
        localNotification.alertBody = @"Something found!";
    }
    else {
        localNotification.alertBody = thing.title;
    }
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

- (void)flushBeaconDictionary {
    /*NSArray *keyArray = [beaconDictionary allKeys];
    for (id key in keyArray) {
        NSArray *beacons = [beaconDictionary objectForKey:key];
        for (CLBeacon *beacon in beacons) {
            if (beacon.accuracy < 0 || beacon.proximity == CLProximityUnknown || beacon.proximity > [HAMAVOSManager rangeOfBeacon:beacon]) {
                [self removeBeacon:beacon];
                continue;
            }
            if ([self removeBeacon:beacon] == NO && isInBackground == YES) {
                HAMThing *thing = [HAMAVOSManager thingWithBeacon:beacon];
                if (thing != nil) {
                    [self notificateWithThing:thing];
                }
            }
            [self addBeacon:beacon];
        }
    }
    [self showThings];*/
    NSMutableArray* beaconArray = [NSMutableArray array];
    
    //add all valid beacons to array
    NSArray* keyArray = [beaconDictionary allKeys];
    for (int i = 0; i < keyArray.count; i++) {
        NSString* key = keyArray[i];
        NSArray* beacons = [beaconDictionary objectForKey:key];
        for (int j = 0; j < beacons.count; j++) {
            CLBeacon* beacon = beacons[j];
            if (beacon == nil || beacon.accuracy < 0 || beacon.proximity == CLProximityUnknown) {
                continue;
            }
            if (beacon.proximity <= [HAMAVOSManager rangeOfBeacon:beacon]) {
                [beaconArray addObject:beacon];
            }
        }
    }
    
    //sort beacons by accuracy
    NSArray *sortedBeaconArray = [beaconArray sortedArrayUsingComparator:^NSComparisonResult(CLBeacon* beacon1, CLBeacon* beacon2) {
        
        if (beacon1.accuracy < beacon2.accuracy) {
            return NSOrderedAscending;
        }
        
        return NSOrderedDescending;
    }];
//    for (int i = 0; i < 1 && i < sortedBeaconArray.count; i ++) {
//        CLBeacon* beacon = sortedBeaconArray[i];
//        NSLog(@"beacon %@ #%d:%lf", beacon.major, i, [sortedBeaconArray[i] accuracy]);
//    }
    [self showThingsWithBeaconArray:[NSArray arrayWithArray:sortedBeaconArray]];
}

- (void)showThingsWithBeaconArray:(NSArray*)beaconArray {
    NSMutableArray *thingsAround = [NSMutableArray array];
    long i;
    for (i = 0; i < beaconArray.count; i++) {
        CLBeacon *beacon = beaconArray[i];
        HAMThing *thing = [HAMAVOSManager thingWithBeacon:beacon];
        if (thing != nil && thing.objectID != nil) {
            [thingsAround addObject:thing];
        }
    }
    
    if ([previousThings isEqual:thingsAround]) {
        return;
    }
    
    if (delegate != nil) {
        [delegate displayThings:thingsAround];
    }
    
    if (detailDelegate != nil) {
        [detailDelegate displayThings:thingsAround];
    }
    
    previousThings = thingsAround;
    
    //notification
//    HAMThing *previousNearestThing = nil;
    HAMThing *nearestThing = nil;
//    if (previousThings != nil && [previousThings count] > 0) {
//        previousNearestThing = [previousThings objectAtIndex:0];
//    }
    if (thingsAround != nil && [thingsAround count] > 0) {
        nearestThing = thingsAround[0];
    }
    if (/*isInBackground == NO || */nearestThing == nil) {
        return;
    }
//    if ([nearestThing isEqualToThing:previousNearestThing] == NO) {
        [self notificateWithThing:nearestThing];
//    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)rawBeaconArray inRegion:(CLBeaconRegion *)region {
    
    if (rawBeaconArray == nil) {
        return;
    }
    
    //rotate beacons array, remove "-1" beacons from top and insert into end
    //remove "-1" beacons from top
    int i;
    for (i = 0; i < rawBeaconArray.count; i++) {
        CLBeacon* beacon = rawBeaconArray[i];
        if (beacon.accuracy > 0) {
            //no more "-1"
            break;
        }
    }
    
    NSArray* beaconArray;
    if(i < rawBeaconArray.count){
        beaconArray = [rawBeaconArray subarrayWithRange:NSMakeRange(i, rawBeaconArray.count - i)];
    } else {
        beaconArray = [NSArray array];
    }
    
    //notification
    if (isInBackground && beaconArray.count > 0) {
        CLBeacon* firstBeacon = beaconArray[0];
        HAMThing* thing = [HAMAVOSManager thingWithBeacon:firstBeacon];
        [self notificateWithThing:thing];
    }
    
    //update beaconDictionary
    NSString* uuid = region.proximityUUID.UUIDString;
    [beaconDictionary setObject:beaconArray forKey:uuid];
}

#pragma mark - BeaconDictionary Methods

-(NSDictionary*)beaconDictionary{
    return [NSDictionary dictionaryWithDictionary:beaconDictionary];
}

- (NSString*)descriptionOfUUID:(NSString*)uuid{
    return [self.descriptionDictionary objectForKey:uuid];
}

#pragma mark - Utils

+ (Boolean)isBeacon:(CLBeacon*)beacon1 sameToBeacon:(CLBeacon*)beacon2{
    if (beacon1 == nil && beacon2 == nil) {
        return YES;
    }
    
    if (beacon1 == nil || beacon2 == nil) {
        return NO;
    }
    
    NSString* uuid1 = [beacon1.proximityUUID UUIDString];
    NSString* uuid2 = [beacon2.proximityUUID UUIDString];
    if (![uuid1 isEqualToString:uuid2]) {
        return NO;
    }
    
    if (![beacon1.major isEqualToNumber:beacon2.major]) {
        return NO;
    }
    
    if (![beacon1.minor isEqualToNumber:beacon2.minor]) {
        return NO;
    }
    
    return YES;
}

@end
