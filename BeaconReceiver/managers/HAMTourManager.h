//
//  HAMTourManager.h
//  BeaconReceiver
//
//  Created by daiyue on 4/16/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAMHomepageData;

@class AVObject;

@interface HAMTourManager : NSObject

+ (HAMTourManager*)tourManager;

- (NSString*)currentVisitor;
- (void)newVisitorWithID:(NSString*)userID;
- (void)newVisitor;
- (void)approachStuff:(HAMHomepageData*)data;
- (void)leaveStuff:(HAMHomepageData*)data;
- (void)addFavoriteStuff:(HAMHomepageData*)data;
- (void)removeFavoriteStuff:(HAMHomepageData*)data;
- (void)saveTour;

@property AVObject *tour;

@end
