//
//  HAMAVManager.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-17.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVOSCloud/AVOSCloud.h>
#import <CoreLocation/CoreLocation.h>

#import "HAMBeaconManager.h"

@class HAMThing;

@interface HAMAVOSManager : NSObject{}

#pragma mark - Cache

#pragma mark - Clear Cache

#pragma mark - BeaconUUID

#pragma mark - BeaconUUID Query

+ (NSDictionary*)beaconDescriptionDictionary;

#pragma mark - BeaconUUID Save

+ (void)saveBeaconUUID:(NSString*)uuid description:(NSString*)description withTarget:(id)target callback:(SEL)callback;

#pragma mark - Beacon

#pragma mark - Beacon Conversion

+ (AVObject*)beaconAVObjectWithCLBeacon:(CLBeacon*)beacon;

#pragma mark - Beacon Query

+ (AVObject*)queryBeaconAVObjectWithCLBeacon:(CLBeacon*)beacon;
+ (CLProximity)rangeOfBeacon:(CLBeacon*)beacon;

#pragma mark - Beacon Save

+ (void)saveCLBeacon:(CLBeacon*)beacon;
+ (void)saveCLBeacon:(CLBeacon*)beacon withTarget:(id)target callback:(SEL)callback;

#pragma mark - Thing

#pragma mark - Thing Conversion

+ (HAMThing*)thingWithThingAVObject:(AVObject *)thingObject;
+ (AVObject*)thingAVObjectWithThing:(HAMThing*)thing shouldSaveCover:(Boolean)shouldSaveCover;

#pragma mark - Thing Query

+ (HAMThing*)thingWithObjectID:(NSString*)objectID;
+ (void)thingsInWorldWithSkip:(int)skip limit:(int)limit target:(id)target callback:(SEL)callback;

#pragma mark - Thing Save

+ (void)saveThing:(HAMThing *)thing withTarget:(id)target callback:(SEL)callback;

#pragma mark - Beacon & User

#pragma mark - Beacon & User Query

+ (HAMBeaconState)ownStateOfBeacon:(CLBeacon*)beacon;
+ (HAMBeaconState)ownStateOfBeaconUpdated:(CLBeacon*)beacon;
+ (int)ownBeaconCountOfCurrentUser;

#pragma mark - Thing & Beacon(Bind)

#pragma mark - Thing & Beacon Query

+ (HAMThing*)thingWithBeacon:(CLBeacon*)beacon;
//+ (CLProximity)rangeOfThing:(HAMThing*)thing;
+ (void)isThingBoundToBeaconInBackground:(HAMThing*)thing;
+ (Boolean)isThingBoundToBeacon:(HAMThing*)thing;

#pragma mark - Thing & Beacon Save

//+ (void)unbindThingToBeacon:(CLBeacon*)beacon withTarget:(id)target callback:(SEL)callback;
+ (void)unbindThingWithThingID:(NSString*)thingID withTarget:(id)target callback:(SEL)callback;
+ (void)bindThing:(HAMThing*)thing toBeacon:(CLBeacon*)beacon withTarget:(id)target callback:(SEL)callback;
+(void)updateRangeOfBeaconBoundWithThing:(HAMThing*)thing;

#pragma mark - Thing & User

#pragma mark - Thing & User Query

+ (void)thingsOfCurrentUserWithSkip:(int)skip limit:(int)limit target:(id)target callback:(SEL)callback;

#pragma mark - Thing & User Update

+ (void)updateCurrentUserCardWithThing:(HAMThing*)thing;

#pragma mark - Thing & User Save

+ (void)saveCurrentUserCard:(HAMThing*)thing;

#pragma mark - File

#pragma mark - File Query

+ (UIImage*)imageFromFile:(AVFile*)file;

#pragma mark - File Save

+ (AVFile*)saveImage:(UIImage*)image;

#pragma mark - Favorites

#pragma mark - Favorites Query

//+ (NSArray*)allFavoriteThingsOfCurrentUser;
+ (void)favoriteThingsOfCurrentUserWithSkip:(int)skip limit:(int)limit target:(id)target callback:(SEL)callback;
+ (Boolean)isThingFavoriteOfCurrentUser:(HAMThing*)targetThing;

#pragma mark - Favorites Save

+ (void)saveFavoriteThingForCurrentUser:(HAMThing*)thing;
+ (void)removeFavoriteThingFromCurrentUser:(HAMThing*)thing;

#pragma mark - Comment

#pragma mark - Comment Query

+ (int)numberOfCommentsOfThing:(HAMThing*)thing;

#pragma mark - Analytics

#pragma mark - Analytics Save

+ (void)saveApproachEventWithOldTopThing:(HAMThing*)oldTopThing newTopThing:(HAMThing*)currentTopThing;

+ (void)saveDetailViewEventWithThing:(HAMThing*)thing source:(NSString*)source;

@end
