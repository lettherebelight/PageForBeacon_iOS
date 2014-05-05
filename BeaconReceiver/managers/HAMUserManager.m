//
//  HAMUserManager.m
//  BeaconReceiver
//
//  Created by daiyue on 4/30/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMUserManager.h"
#import "HAMUserData.h"

@implementation HAMUserManager

@synthesize currentUser;

static HAMUserManager* userManager;

+ (HAMUserManager*)userManager {
    @synchronized(self) {
        if (userManager == nil) {
            userManager = [[HAMUserManager alloc] init];
        }
    }
    return userManager;
}

- (void)newUserWithUserID:(NSString *)userID name:(NSString *)name avatar:(NSString *)avatar description:(NSString *)description {
    if (currentUser == nil) {
        currentUser = [[HAMUserData alloc] init];
    }
    currentUser.userID = userID;
    currentUser.name = name;
    currentUser.avatar = avatar;
    currentUser.description = description;
}

@end
