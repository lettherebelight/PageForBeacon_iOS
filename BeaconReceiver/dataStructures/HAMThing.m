//
//  HAMThing.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-16.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMThing.h"

#import "HAMBeaconManager.h"
#import "HAMAVOSManager.h"

#import "HAMConstants.h"

#import "HAMLogTool.h"

@implementation HAMThing

@synthesize objectID;
@synthesize type;
@synthesize url;
@synthesize title;
@synthesize content;
@synthesize cover;
@synthesize coverFile;
@synthesize coverURL;
@synthesize creator;
@synthesize weibo;
@synthesize wechat;
@synthesize qq;
@synthesize range;

#pragma mark - Equal

- (BOOL)isEqual:(id)object {
    if (object == nil) {
        return NO;
    }
    if ([object isKindOfClass:[HAMThing class]] == NO) {
        return NO;
    }
    HAMThing *thingObj = (HAMThing*)object;
    return [objectID isEqualToString:thingObj.objectID];
}

- (BOOL)isEqualToThing:(HAMThing *)thing {
    if (thing == nil) {
        return NO;
    }
    return [objectID isEqualToString:thing.objectID];
}

#pragma mark - Type

- (HAMThingType)setTypeWithTypeString:(NSString*)typeString{
    if ([typeString isEqualToString:@"art"]) {
        self.type = HAMThingTypeArt;
    }
    else if ([typeString isEqualToString:@"card"]) {
        self.type = HAMThingTypeCard;
    }
    else{
        self.type = HAMThingTypeOther;
    }
    return self.type;
}

- (NSString*)typeString{
    switch (self.type) {
        case HAMThingTypeArt:
            return @"art";
            break;
            
        case HAMThingTypeCard:
            return @"card";
            break;
            
        default:
            return @"other";
            break;
    }
}

#pragma mark - Range

- (CLProximity)setRangeWithRangeString:(NSString*)rangeString{
    range = [HAMThing rangeFromRangeString:rangeString];
    return range;
}

- (NSString*)rangeString{
    return [HAMThing rangeStringFromRange:range];
}

+ (CLProximity)rangeFromRangeString:(NSString*)rangeString{
    if (rangeString == nil || [rangeString isEqualToString:@""]) {
        return CLProximityUnknown;
    }
    if ([rangeString isEqualToString:@"immediate"]) {
        return CLProximityImmediate;
    }
    if ([rangeString isEqualToString:@"near"]) {
        return CLProximityNear;
    }
    if ([rangeString isEqualToString:@"far"]) {
        return CLProximityFar;
    }
    
    [HAMLogTool warn:@"range of thing unknown"];
    return CLProximityUnknown;
}

+ (NSString*)rangeStringFromRange:(CLProximity)range{
    NSString* rangeString;
    switch (range) {
        case CLProximityImmediate:
            rangeString = @"immediate";
            break;
            
        case CLProximityNear:
            rangeString = @"near";
            break;
            
        case CLProximityFar:
            rangeString = @"far";
            break;
            
        default:
            [HAMLogTool warn:@"range of thing unknown"];
            rangeString = @"immediate";
            break;
    }
    return rangeString;
}

#pragma mark - Cover

//- (UIImage*)cover{
//    //lazy loading
//    if (cover != nil) {
//        return cover;
//    }
//    
//    if (self.coverFile != nil) {
//        [self fetchCover];
//    }
//    return cover;
//}

//fetch cover's thumbnail
/*- (void)fetchCover{
//    cover = [HAMAVOSManager imageFromFile:self.coverFile];
    AVFile* file = [AVFile fileWithURL:self.coverURL];
    if (file == nil) {
        [HAMLogTool warn:[NSString stringWithFormat:@"invalid coverURL:%@",self.coverURL]];
        return;
    }
    
    //TODO: change width and height depend on differt card type
    double thumbnailWidth, thumbnailHeight;
    switch (self.type) {
        case HAMThingTypeArt:
            thumbnailWidth = kHAMThingTypeArtThumbnailWidth;
            thumbnailHeight = kHAMThingTypeArtThumbnailHeight;
            break;
            
        case HAMThingTypeCard:
            thumbnailWidth = kHAMThingTypeCardThumbnailWidth;
            thumbnailHeight = kHAMThingTypeCardThumbnailHeight;
            break;
            
        default:
            thumbnailWidth = 0.0f;
            thumbnailHeight = 0.0f;
            break;
    }
    
    [file getThumbnail:YES width:thumbnailWidth height:thumbnailHeight withBlock:^(UIImage * image, NSError *error) {
        if (error != nil) {
            [HAMLogTool warn:@"fetch cover thumbnail failed:"];
            [HAMLogTool warn:error.debugDescription];
            return;
        }
        self.cover = image;
    }];
}*/

@end
