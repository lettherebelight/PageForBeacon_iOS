//
//  HAMHomepageManager.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-3-25.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>
#import <CoreLocation/CoreLocation.h>

#import "HAMThing.h"

#import "HAMThingManager.h"
#import "HAMTools.h"
#import "HAMDataManager.h"
#import "HAMAVOSManager.h"
#import "HAMLogTool.h"

@implementation HAMThingManager

@synthesize delegate;

static HAMThingManager* homepageManager = nil;

//static float defaultDistanceRangeMin = 1;

+ (HAMThingManager*)thingManager {
    @synchronized(self) {
        if (homepageManager == nil) {
            homepageManager = [[HAMThingManager alloc] init];
        }
    }
    return homepageManager;
}

- (id)init {
    if (self = [super init]) {
        thingsInWorld = [NSMutableArray array];
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
        [updateTimer setFireDate:[NSDate date]];
    }
    return self;
}

- (void)startUpdate {
    [updateTimer setFireDate:[NSDate date]];
}

- (void)stopUpdate {
    [updateTimer setFireDate:[NSDate distantFuture]];
}

- (void)handleTimer {
    [self updateThingsInWorld];
}

- (void)updateThingsInWorld {
    @synchronized (self) {
        AVQuery *query = [AVQuery queryWithClassName:@"Thing"];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objectArray, NSError *error) {
            if (error != nil || objectArray == nil || [objectArray count] == 0) {
                return;
            }
            //FIXME: What't this?
            thingsInWorld = nil;
            thingsInWorld = [NSMutableArray array];
            for (AVObject *thingObject in objectArray) {
                HAMThing *thing = [HAMAVOSManager thingWithThingAVObject:thingObject];
                [thingsInWorld addObject:thing];
            }
            if (delegate != nil) {
                [delegate updateThingsInWorld:thingsInWorld];
            }
        }];
    }
}

@end
