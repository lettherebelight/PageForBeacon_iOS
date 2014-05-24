//
//  HAMTourManager.h
//  BeaconReceiver
//
//  Created by daiyue on 4/16/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAMThing;

@class AVObject;

@interface HAMTourManager : NSObject

+ (HAMTourManager*)tourManager;

- (HAMThing*)currentUserThing;
- (void)updateCurrentUserThing:(HAMThing*)thing;
- (void)logout;
- (void)newUserWithThing:(HAMThing*)thing;
- (void)approachThing:(HAMThing*)thing;
- (void)leaveThing:(HAMThing*)thing;
- (void)addFavoriteThing:(HAMThing*)thing;
- (void)removeFavoriteThing:(HAMThing*)thing;
- (void)saveTour;

@property AVObject *tour;

@end
