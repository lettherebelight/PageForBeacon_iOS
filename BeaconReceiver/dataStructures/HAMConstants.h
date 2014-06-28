//
//  HAMConstants.h
//  BeaconReceiver
//
//  Created by daiyue on 6/15/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#pragma mark - Defaults

//use when creating thing of user card
static CLProximity kHAMDefaultRange = CLProximityImmediate;

#pragma mark - Cache

static float kHAMMaxCacheAge = 600.0f;

#pragma mark - User Constraints

static int kHAMMaxOwnBeaconCount = 5;

#pragma mark - UI

static int kHAMNumberOfThingsInFirstPage = 5;
static int kHAMNumberOfTHingsInNextPage = 3;

static double kHAMThingTypeArtThumbnailHeight = 283.0f;
static double kHAMThingTypeArtThumbnailWidth = 160.0f;
static double kHAMThingTypeCardThumbnailHeight = 0.0f;
static double kHAMThingTypeCardThumbnailWidth = 0.0f;

#pragma mark - Notification

static float kHAMNotificationMinTimeInteval = 3600.0f;

@interface HAMConstants : NSObject

@end
