//
//  HAMTourManager.m
//  BeaconReceiver
//
//  Created by daiyue on 4/16/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMTourManager.h"
#import "HAMDataManager.h"
#import "HAMThing.h"
#import "HAMDataManager.h"
#import "HAMGlobalData.h"
#import "HAMAVOSManager.h"
#import <AVOSCloud/AVOSCloud.h>

@implementation HAMTourManager {
    HAMThing *userThing;
    NSString *currentUserId;
}

@synthesize tour;

static HAMTourManager *tourManager;

+ (HAMTourManager*)tourManager {
    @synchronized(self) {
        if (tourManager == nil) {
            tourManager = [[HAMTourManager alloc] init];
        }
    }
    return tourManager;
}

- (id)init {
    if (self = [super init]) {
        userThing = nil;
        currentUserId = nil;
    }
    return self;
}

- (HAMThing*)currentUserThing {
    return userThing;
}

- (void)updateCurrentUserThing:(HAMThing *)thing {
    userThing = thing;
}

- (void)logout {
    [AVUser logOut];
    HAMGlobalData *globalData = [HAMDataManager globalData];
    globalData.lastLogin = nil;
    [HAMDataManager saveData];
}

- (void)newUserWithThing:(HAMThing *)thing {
    userThing = thing;
    currentUserId = [AVUser currentUser].objectId;
    tour = [AVObject objectWithClassName:@"Tour"];
    [tour setObject:currentUserId forKey:@"userID"];
    [tour saveInBackground];
}

- (void)approachThing:(HAMThing*)thing {
    AVObject *tourEvent = [AVObject objectWithClassName:@"TourEvent"];
    [tourEvent setObject:currentUserId forKey:@"userID"];
    [tourEvent setObject:thing.objectID forKey:@"thingID"];
    [tourEvent setObject:@"approach" forKey:@"event"];
    [tourEvent saveInBackground];
    [tour addObject:thing.objectID forKey:@"beacons"];
    [tour saveInBackground];
}

- (void)leaveThing:(HAMThing*)thing {
    AVObject *tourEvent = [AVObject objectWithClassName:@"TourEvent"];
    [tourEvent setObject:currentUserId forKey:@"userID"];
    [tourEvent setObject:thing.objectID forKey:@"thingID"];
    [tourEvent setObject:@"leave" forKey:@"event"];
    [tourEvent saveInBackground];
}

- (void)addFavoriteThing:(HAMThing*)thing {
    [HAMAVOSManager saveFavoriteThingForCurrentUser:thing];
    AVObject *tourEvent = [AVObject objectWithClassName:@"TourEvent"];
    [tourEvent setObject:currentUserId forKey:@"userID"];
    [tourEvent setObject:thing.objectID forKey:@"thingID"];
    [tourEvent setObject:@"favorite" forKey:@"event"];
    [tourEvent saveInBackground];
    [tour addObject:thing.objectID forKey:@"favorites"];
    [tour saveInBackground];
}

- (void)removeFavoriteThing:(HAMThing*)thing {
    [HAMAVOSManager removeFavoriteThingFromCurrentUser:thing];
    AVObject *tourEvent = [AVObject objectWithClassName:@"TourEvent"];
    [tourEvent setObject:currentUserId forKey:@"userID"];
    [tourEvent setObject:thing.objectID forKey:@"thingID"];
    [tourEvent setObject:@"unfavorite" forKey:@"event"];
    [tourEvent saveInBackground];
    [tour removeObject:thing.objectID forKey:@"favorites"];
    [tour saveInBackground];
}

- (void)saveTour {
    [tour saveInBackground];
}

@end
