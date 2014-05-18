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
#import "HAMHomepageData.h"
#import "HAMTools.h"
#import "HAMDataManager.h"
#import "HAMLogTool.h"

@implementation HAMThingManager

@synthesize delegate;

static HAMThingManager* homepageManager = nil;

static float defaultDistanceRangeMin = 1;

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

- (void)handleTimer {
    [self updateThingsInWorld];
}

- (void)updateThingsInWorld {
    @synchronized (self) {
        AVQuery *query = [AVQuery queryWithClassName:@"Thing"];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objectArray, NSError *error) {
            if (error == nil && objectArray != nil && [objectArray count] > 0) {
                thingsInWorld = nil;
                thingsInWorld = [NSMutableArray array];
                for (AVObject *thingObj in objectArray) {
                    HAMHomepageData *pageData = [HAMDataManager pageDataWithThingID:thingObj.objectId];
                    if (pageData == nil) {
                        pageData = [HAMDataManager newPageData];
                        pageData.beaconID = nil;
                        pageData.beaconMajor = nil;
                        pageData.beaconMinor = nil;
                        pageData.range = nil;
                        pageData.thumbnail = (NSString*)[thingObj objectForKey:@"coverURL"];
                        pageData.pageURL = (NSString*)[thingObj objectForKey:@"url"];
                        pageData.pageTitle = (NSString*)[thingObj objectForKey:@"title"];
                        pageData.describe = (NSString*)[thingObj objectForKey:@"content"];
                        pageData.dataID = thingObj.objectId;
                    }
                    [thingsInWorld addObject:pageData];
                }
                if (delegate != nil) {
                    [delegate updateThings:thingsInWorld];
                }
            }
        }];
    }
}

+ (void)homepageFromWebWithBeaconID:(NSString *)beaconID major:(NSNumber *)major minor:(NSNumber *)minor {
    @synchronized (self) {
        HAMHomepageData *pageData = [HAMDataManager pageDataWithBID:beaconID major:major minor:minor];
        if (pageData == nil && [HAMTools isWebAvailable]) {
            AVQuery *query = [AVQuery queryWithClassName:@"Beacon"];
            [query includeKey:@"thing"];
            [query whereKey:@"proximityUUID" equalTo:beaconID];
            [query whereKey:@"major" equalTo:major];
            [query whereKey:@"minor" equalTo:minor];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objectArray, NSError *error) {
                @synchronized (self) {
                    HAMHomepageData *pageData = [HAMDataManager pageDataWithBID:beaconID major:major minor:minor];
                    if (pageData == nil && error == nil && objectArray != nil && [objectArray count] > 0) {
                        pageData = [HAMDataManager newPageData];
                        AVObject *beaconObject = [objectArray objectAtIndex:0];
                        pageData.beaconID = beaconID;
                        pageData.beaconMajor = major;
                        pageData.beaconMinor = minor;
                        pageData.range = (NSNumber*)[beaconObject objectForKey:@"range"];
                        if (pageData.range <= 0) {
                            pageData.range = [NSNumber numberWithFloat:defaultDistanceRangeMin];
                        }
                        AVObject *thingObject = [beaconObject objectForKey:@"thing"];
                        //pageData.backImage = (NSString*)[thingObject objectForKey:@"preview_background"];
                        pageData.thumbnail = (NSString*)[thingObject objectForKey:@"coverURL"];
                        pageData.pageURL = (NSString*)[thingObject objectForKey:@"url"];
                        pageData.pageTitle = (NSString*)[thingObject objectForKey:@"title"];
                        pageData.describe = (NSString*)[thingObject objectForKey:@"content"];
                        pageData.dataID = thingObject.objectId;
                        [HAMDataManager saveData];
                    }
                }
            }];
        }
    }
}

+ (HAMHomepageData*)homepageWithBeaconID:(NSString*)beaconID major:(NSNumber*)major minor:(NSNumber*)minor{
    HAMHomepageData *pageData = [HAMDataManager pageDataWithBID:beaconID major:major minor:minor];
     if (pageData != nil) {
     return pageData;
     }
     else {
     [HAMThingManager homepageFromWebWithBeaconID:beaconID major:major minor:minor];
     return nil;
    }
}

@end
