//
//  HAMHomepageData.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-14.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HAMHomepageData : NSManagedObject

@property (nonatomic, retain) NSString * beaconID;
@property (nonatomic, retain) NSNumber * beaconMajor;
@property (nonatomic, retain) NSNumber * beaconMinor;
@property (nonatomic, retain) NSString * pageTitle;
@property (nonatomic, retain) NSString * pageID;
@property (nonatomic, retain) NSString * pageURL;
@property (nonatomic, retain) NSNumber * marked;

@end
