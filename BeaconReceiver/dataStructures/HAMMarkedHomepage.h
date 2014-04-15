//
//  HAMMarkedHomepage.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-14.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HAMHomepageData;

@interface HAMMarkedHomepage : NSManagedObject

@property (nonatomic, retain) HAMHomepageData *homepage;

@end
