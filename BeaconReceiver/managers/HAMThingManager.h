//
//  HAMHomepageManager.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-3-25.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAMHomepageData;
@class HAMThing;

@protocol HAMThingManagerDelegate <NSObject>

- (void)updateThingsInWorld:(NSArray*)thingsInWorld;

@end

@interface HAMThingManager : NSObject {
    NSTimer *updateTimer;
    NSMutableArray *thingsInWorld;
}

@property (nonatomic, retain) id<HAMThingManagerDelegate> delegate;

+ (HAMThingManager*)thingManager;

- (void)startUpdate;

@end
