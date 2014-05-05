//
//  HAMUserManager.h
//  BeaconReceiver
//
//  Created by daiyue on 4/30/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAMUserData;

@interface HAMUserManager : NSObject

@property HAMUserData *currentUser;

+ (HAMUserManager*)userManager;

- (void)newUserWithUserID:(NSString *)userID name:(NSString*)name avatar:(NSString*)avatar description:(NSString*)description;

@end
