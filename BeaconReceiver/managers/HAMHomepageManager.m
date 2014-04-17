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

+ (NSMutableArray*) homepageVisited {
    @synchronized(self) {
        if (homepageVisited == nil) {
            homepageVisited = [NSMutableArray array];
        }
    }
    return homepageVisited;
}

+ (NSMutableDictionary*) homepageDict {
    @synchronized(self) {
        if (homepageDict == nil) {
            homepageDict = [NSMutableDictionary dictionary];
        }
    }
    return homepageDict;
}

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

/*
+ (HAMHomepageData*)homepageWithBeaconID:(NSString*)beaconID major:(NSNumber*)major minor:(NSNumber*)minor {
    HAMHomepageData *homepage = [[HAMHomepageManager homepageDict] objectForKey:[NSString stringWithFormat:@"%@%@%@", beaconID, major, minor]];
    
    if (homepage == nil) {
        if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] != NotReachable) {
            homepage = [[HAMHomepageData alloc] init];
            
            homepage.beaconID = beaconID;
            homepage.beaconMajor = major;
            homepage.beaconMinor = minor;
            
            NSString *hostURL = @"http://115.28.129.14";
            NSString *beaconurlStr = [NSString stringWithFormat:@"%@/1/beacons?proximity_uuid=%@&major=%@&minor=%@", hostURL, beaconID, major, minor];
            NSURL *beaconUrl = [NSURL URLWithString:beaconurlStr];
            NSURLRequest *beaconRequest = [[NSURLRequest alloc]initWithURL:beaconUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
            NSData *beaconReceived = [NSURLConnection sendSynchronousRequest:beaconRequest returningResponse:nil error:nil];
            NSLog(@"%@",[[NSString alloc] initWithData:beaconReceived encoding:NSUTF8StringEncoding]);
            
            if (beaconReceived != nil) {
                NSArray *beaconInfoArray = [HAMTools arrayFromJsonData:beaconReceived];
                if ([beaconInfoArray count] != 0) {
                    NSDictionary* beaconInfo = [beaconInfoArray objectAtIndex:0];
                    NSString *pageID = [beaconInfo objectForKey:@"page_id"];
                    if (pageID != nil) {
                        NSString *url = [NSString stringWithFormat:@"%@/pageview/%@", hostURL, pageID];
                        homepage.pageURL = url;
                        //homepage.pageID = pageID;
                        NSString *pageurlStr = [NSString stringWithFormat:@"%@/1/pages/%@", hostURL, pageID];
                        NSURL *pageUrl = [NSURL URLWithString:pageurlStr];
                        NSURLRequest *pageRequest = [[NSURLRequest alloc]initWithURL:pageUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
                        NSData *pageReceived = [NSURLConnection sendSynchronousRequest:pageRequest returningResponse:nil error:nil];
                        if (pageReceived != nil) {
                            NSDictionary *pageInfo = [HAMTools dictionaryFromJsonData:pageReceived];
                            NSString *pageTitle = [pageInfo objectForKey:@"title"];
                            if (pageTitle != nil) {
                                homepage.pageTitle = pageTitle;
                            }
                        }
                    }
                }

            }
            
            
            [[HAMHomepageManager homepageDict] setObject:homepage forKey:[NSString stringWithFormat:@"%@%@%@", beaconID, major, minor]];
        }
        
    }
    return homepage;
}
 */

@end
