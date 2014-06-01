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
+ (HAMBeaconState)ownStateOfBeacon:(CLBeacon*)beacon;
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
+ (NSArray*)thingsOfCurrentUser;

#pragma mark - Thing Save

+ (AVObject*)saveThing:(HAMThing*)thing;

#pragma mark - Thing & Beacon

#pragma mark - Thing & Beacon Query

+ (HAMThing*)thingWithBeacon:(CLBeacon*)beacon;
+ (HAMThing*)thingWithBeaconID:(NSString *)beaconID major:(NSNumber *)major minor:(NSNumber *)minor;

#pragma mark - Thing & Beacon Save

+ (void)unbindThingToBeacon:(CLBeacon*)beacon withTarget:(id)target callback:(SEL)callback;
+ (void)bindThing:(HAMThing*)thing range:(CLProximity)range toBeacon:(CLBeacon*)beacon withTarget:(id)target callback:(SEL)callback;

#pragma mark - Thing & User

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

+ (NSArray*)allFavoriteThingsOfCurrentUser;
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
