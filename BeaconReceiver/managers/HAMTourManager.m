//
//  HAMTourManager.m
//  BeaconReceiver
//
//  Created by daiyue on 4/16/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMTourManager.h"
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

- (void) newVisitor {
    tour = [AVObject objectWithClassName:@"Tour"];
    [tour setObject:@"534d27dce4b0275ea1a07ff7" forKey:@"user_id"];
    [tour saveInBackground];
}

- (void)addHistory:(NSString *)dataID {
    [tour addObject:dataID forKey:@"beacons"];
    [tour saveInBackground];
}

- (void)addFavorite:(NSString *)dataID {
    [tour addObject:dataID forKey:@"favorites"];
    [tour saveInBackground];
}

- (void)deleteFavorite:(NSString *)dataID {
    [tour removeObject:dataID forKey:@"favorites"];
    [tour saveInBackground];
}

- (void)saveTour {
    [tour saveInBackground];
}

@end
