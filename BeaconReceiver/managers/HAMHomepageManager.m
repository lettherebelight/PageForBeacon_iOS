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

static NSMutableDictionary *homepageDict = nil;
static NSMutableArray *homepageVisited = nil;


+ (HAMHomepageData*)homepageWithBeaconID:(NSString *)beaconID major:(NSNumber *)major minor:(NSNumber *)minor {
    HAMHomepageData *pageData = [HAMDataManager pageDataWithBID:beaconID major:major minor:minor];
    if (pageData == nil && [HAMTools isWebAvailable]) {
        AVQuery *query = [AVQuery queryWithClassName:@"Beacon"];
        [query whereKey:@"proximity_uuid" equalTo:beaconID];
        [query whereKey:@"major" equalTo:major];
        [query whereKey:@"minor" equalTo:minor];
        NSArray *objectArray = [query findObjects];
        if (objectArray != nil && [objectArray count] > 0) {
            pageData = [HAMDataManager newPageData];
            AVObject *beaconObject = [objectArray objectAtIndex:0];
            pageData.beaconID = beaconID;
            pageData.beaconMajor = major;
            pageData.beaconMinor = minor;
            pageData.range = (NSNumber*)[beaconObject objectForKey:@"range"];
            pageData.backImage = (NSString*)[beaconObject objectForKey:@"preview_background"];
            pageData.thumbnail = (NSString*)[beaconObject objectForKey:@"preview_thumbnail"];
            pageData.pageURL = (NSString*)[beaconObject objectForKey:@"page_url"];
            pageData.pageTitle = (NSString*)[beaconObject objectForKey:@"page_title"];
            pageData.dataID = beaconObject.objectId;
            [HAMDataManager saveData];
        }
    }
    return pageData;
}

@end
