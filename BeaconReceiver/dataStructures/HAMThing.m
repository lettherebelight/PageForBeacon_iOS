//
//  HAMThing.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-16.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMThing.h"

#import "HAMBeaconManager.h"

@implementation HAMThing

@synthesize objectID;
@synthesize type;
@synthesize url;
@synthesize title;
@synthesize content;
@synthesize cover;
@synthesize coverURL;
@synthesize creator;

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[HAMThing class]] == NO) {
        return NO;
    }
    HAMThing *thingObj = (HAMThing*)object;
    return [objectID isEqualToString:thingObj.objectID];
}

- (BOOL)isEqualToThing:(HAMThing *)thing {
    return [objectID isEqualToString:thing.objectID];
}

@end
