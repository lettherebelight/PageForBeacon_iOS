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
#import "HAMAVOSManager.h"
#import <AVOSCloud/AVOSCloud.h>

@implementation HAMTourManager

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

- (NSString*)currentVisitor {
    NSString *visitorID;
    visitorID = [tour objectForKey:@"userID"];
    return visitorID;
}

- (void) newVisitor {
    tour = [AVObject objectWithClassName:@"Tour"];
    [tour setObject:@"534d27dce4b0275ea1a07ff7" forKey:@"userID"];
    [tour save];
}

- (void)newVisitorWithID:(NSString *)userID {
    tour = [AVObject objectWithClassName:@"Tour"];
    [tour setObject:userID forKey:@"userID"];
    [tour save];
}

- (void)approachThing:(HAMThing*)thing {
    AVObject *tourEvent = [AVObject objectWithClassName:@"TourEvent"];
    [tourEvent setObject:[self currentVisitor] forKey:@"userID"];
    [tourEvent setObject:thing.objectID forKey:@"thingID"];
    [tourEvent setObject:@"approach" forKey:@"event"];
    [tourEvent saveInBackground];
    [tour addObject:thing.objectID forKey:@"beacons"];
    [tour saveInBackground];
}

- (void)leaveThing:(HAMThing*)thing {
    AVObject *tourEvent = [AVObject objectWithClassName:@"TourEvent"];
    [tourEvent setObject:[self currentVisitor] forKey:@"userID"];
    [tourEvent setObject:thing.objectID forKey:@"thingID"];
    [tourEvent setObject:@"leave" forKey:@"event"];
    [tourEvent saveInBackground];
}

- (void)addFavoriteThing:(HAMThing*)thing {
    [HAMAVOSManager saveFavoriteThingForCurrentUser:thing];
    AVObject *tourEvent = [AVObject objectWithClassName:@"TourEvent"];
    [tourEvent setObject:[self currentVisitor] forKey:@"userID"];
    [tourEvent setObject:thing.objectID forKey:@"thingID"];
    [tourEvent setObject:@"favorite" forKey:@"event"];
    [tourEvent saveInBackground];
    [tour addObject:thing.objectID forKey:@"favorites"];
    [tour saveInBackground];
}

- (void)removeFavoriteThing:(HAMThing*)thing {
    [HAMAVOSManager removeFavoriteThingFromCurrentUser:thing];
    AVObject *tourEvent = [AVObject objectWithClassName:@"TourEvent"];
    [tourEvent setObject:[self currentVisitor] forKey:@"userID"];
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
