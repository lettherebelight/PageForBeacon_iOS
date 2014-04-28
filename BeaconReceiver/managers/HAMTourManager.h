//
//  HAMTourManager.h
//  BeaconReceiver
//
//  Created by daiyue on 4/16/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVObject;

@interface HAMTourManager : NSObject

+ (HAMTourManager*)tourManager;

- (NSString*)currentVisitor;
- (void)newVisitorWithID:(NSString*)userID;
- (void)newVisitor;
- (void)addHistory:(NSString*)dataID;
- (void)addFavorite:(NSString*)dataID;
- (void)deleteFavorite:(NSString*)dataID;
- (void)saveTour;

@property AVObject *tour;

@end
