//
//  HAMTourManager.m
//  BeaconReceiver
//
//  Created by daiyue on 4/16/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMTourManager.h"
#import "HAMDataManager.h"
#import "HAMHomepageData.h"
#import "HAMDataManager.h"
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
    visitorID = [tour objectForKey:@"user_id"];
    return visitorID;
}

- (void) newVisitor {
    tour = [AVObject objectWithClassName:@"Tour"];
    [tour setObject:@"534d27dce4b0275ea1a07ff7" forKey:@"user_id"];
    [tour save];
}

- (void)newVisitorWithID:(NSString *)userID {
    tour = [AVObject objectWithClassName:@"Tour"];
    [tour setObject:userID forKey:@"user_id"];
    [tour save];
}

- (void)approachStuff:(HAMHomepageData *)data {
    AVObject *tourEvent = [AVObject objectWithClassName:@"TourEvent"];
    [tourEvent setObject:[self currentVisitor] forKey:@"user_id"];
    [tourEvent setObject:data.dataID forKey:@"beacon_id"];
    [tourEvent setObject:@"approach" forKey:@"event"];
    [tourEvent saveInBackground];
    if (data.historyListRecord == nil) {
        [HAMDataManager addAHistoryRecord:data];
        [tour addObject:data.dataID forKey:@"beacons"];
        [tour save];
    } else {
        [HAMDataManager updateHistoryRecord:data.historyListRecord];
    }
}

- (void)leaveStuff:(HAMHomepageData *)data {
    AVObject *tourEvent = [AVObject objectWithClassName:@"TourEvent"];
    [tourEvent setObject:[self currentVisitor] forKey:@"user_id"];
    [tourEvent setObject:data.dataID forKey:@"beacon_id"];
    [tourEvent setObject:@"leave" forKey:@"event"];
    [tourEvent saveInBackground];
}

- (void)addFavoriteStuff:(HAMHomepageData *)data {
    AVObject *tourEvent = [AVObject objectWithClassName:@"TourEvent"];
    [tourEvent setObject:[self currentVisitor] forKey:@"user_id"];
    [tourEvent setObject:data.dataID forKey:@"beacon_id"];
    [tourEvent setObject:@"favorite" forKey:@"event"];
    [tourEvent saveInBackground];
    [HAMDataManager addAMarkedRecord:data];
    [tour addObject:data.dataID forKey:@"favorites"];
    [tour save];
}

- (void)removeFavoriteStuff:(HAMHomepageData *)data {
    AVObject *tourEvent = [AVObject objectWithClassName:@"TourEvent"];
    [tourEvent setObject:[self currentVisitor] forKey:@"user_id"];
    [tourEvent setObject:data.dataID forKey:@"beacon_id"];
    [tourEvent setObject:@"unfavorite" forKey:@"event"];
    [tourEvent saveInBackground];
    [HAMDataManager removeMarkedRecord:data];
    [tour removeObject:data.dataID forKey:@"favorites"];
    [tour save];
}

- (void)saveTour {
    [tour save];
}

@end
