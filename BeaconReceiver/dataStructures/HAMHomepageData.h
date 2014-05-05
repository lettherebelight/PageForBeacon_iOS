//
//  HAMHomepageData.h
//  BeaconReceiver
//
//  Created by daiyue on 5/5/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HAMHistoryHomepage, HAMMarkedHomepage;

@interface HAMHomepageData : NSManagedObject

@property (nonatomic, retain) NSString * backImage;
@property (nonatomic, retain) NSString * beaconID;
@property (nonatomic, retain) NSNumber * beaconMajor;
@property (nonatomic, retain) NSNumber * beaconMinor;
@property (nonatomic, retain) NSString * dataID;
@property (nonatomic, retain) NSString * pageTitle;
@property (nonatomic, retain) NSString * pageURL;
@property (nonatomic, retain) NSNumber * range;
@property (nonatomic, retain) NSString * thumbnail;
@property (nonatomic, retain) NSString * describe;
@property (nonatomic, retain) HAMHistoryHomepage *historyListRecord;
@property (nonatomic, retain) HAMMarkedHomepage *markedListRecord;

@end
