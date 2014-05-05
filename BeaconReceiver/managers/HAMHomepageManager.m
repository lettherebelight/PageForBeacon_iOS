//
//  HAMHomepageManager.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-3-25.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>
#import "HAMHomepageManager.h"
#import "HAMHomepageData.h"
#import "HAMTools.h"
#import "HAMDataManager.h"
#import "HAMLogTool.h"

@implementation HAMHomepageManager

static float defaultDistanceRangeMin = 1;

+ (void)homepageFromWebWithBeaconID:(NSString *)beaconID major:(NSNumber *)major minor:(NSNumber *)minor {
    @synchronized (self) {
        HAMHomepageData *pageData = [HAMDataManager pageDataWithBID:beaconID major:major minor:minor];
        if (pageData == nil && [HAMTools isWebAvailable]) {
            AVQuery *query = [AVQuery queryWithClassName:@"Beacon"];
            [query includeKey:@"stuff"];
            [query whereKey:@"proximity_uuid" equalTo:beaconID];
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
                        AVObject *stuffObject = [beaconObject objectForKey:@"stuff"];
                        pageData.backImage = (NSString*)[stuffObject objectForKey:@"preview_background"];
                        pageData.thumbnail = (NSString*)[stuffObject objectForKey:@"preview_thumbnail"];
                        pageData.pageURL = (NSString*)[stuffObject objectForKey:@"page_url"];
                        pageData.pageTitle = (NSString*)[stuffObject objectForKey:@"name"];
                        pageData.describe = (NSString*)[stuffObject objectForKey:@"description"];
                        pageData.dataID = beaconObject.objectId;
                        [HAMDataManager saveData];
                    }
                }
            }];
        }
    }
}

+ (HAMHomepageData*)homepageWithBeaconID:(NSString *)beaconID major:(NSNumber *)major minor:(NSNumber *)minor {
    HAMHomepageData *pageData = [HAMDataManager pageDataWithBID:beaconID major:major minor:minor];
    if (pageData != nil) {
        return pageData;
    }
    else {
        [HAMHomepageManager homepageFromWebWithBeaconID:beaconID major:major minor:minor];
        return nil;
    }
}

@end
