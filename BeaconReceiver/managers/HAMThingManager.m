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
            if (error != nil || objectArray == nil || [objectArray count] == 0) {
                return;
            }
            thingsInWorld = nil;
            thingsInWorld = [NSMutableArray array];
            for (AVObject *thingObject in objectArray) {
                //TODO: Please use [HAMAVOSManager thingWithThingAVObject]
                HAMThing *thing = [[HAMThing alloc] init];
                thing.objectID = thingObject.objectId;
                thing.type = [thingObject objectForKey:@"type"];
                thing.url = [thingObject objectForKey:@"url"];
                thing.title = [thingObject objectForKey:@"title"];
                thing.content = [thingObject objectForKey:@"content"];
                
                AVFile* coverFile = [thingObject objectForKey:@"cover"];
                NSData *coverData = [coverFile getData];
                thing.cover = [UIImage imageWithData:coverData];
                
                thing.coverURL = [thingObject objectForKey:@"coverURL"];
                thing.creator = [thingObject objectForKey:@"creator"];
                [thingsInWorld addObject:thing];
            }
            if (delegate != nil) {
                [delegate updateThings:thingsInWorld];
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
                        AVObject *beaconObject = [objectArray objectAtIndex:0];
                        AVObject *thingObject = [beaconObject objectForKey:@"thing"];
                        if (thingObject == nil) {
                            return;
                        }
                        pageData = [HAMDataManager newPageData];
                        pageData.beaconID = beaconID;
                        pageData.beaconMajor = major;
                        pageData.beaconMinor = minor;
                        pageData.range = (NSNumber*)[beaconObject objectForKey:@"range"];
                        if (pageData.range <= 0) {
                            pageData.range = [NSNumber numberWithFloat:defaultDistanceRangeMin];
                        }
                        
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
