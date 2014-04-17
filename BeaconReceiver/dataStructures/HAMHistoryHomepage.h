//
//  HAMHistoryHomepage.h
//  BeaconReceiver
//
//  Created by daiyue on 4/16/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HAMHomepageData;

@interface HAMHistoryHomepage : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) HAMHomepageData *homepage;

@end
