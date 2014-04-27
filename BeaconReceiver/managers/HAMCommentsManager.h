//
//  HAMCommentsManager.h
//  BeaconReceiver
//
//  Created by daiyue on 4/24/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAMCommentData;

@protocol HAMCommentsManagerDelegate <NSObject>

- (void)refresh;

@end

@interface HAMCommentsManager : NSObject

+ (HAMCommentsManager*)commentsManager;

- (NSArray*)commentsWithPageDataID:(NSString*)pageDataID;
- (void)updateComments;
- (void)addComment:(HAMCommentData*)comment;

@property NSTimer *timer;
@property NSMutableArray *comments;
@property id<HAMCommentsManagerDelegate> delegate;

@end
