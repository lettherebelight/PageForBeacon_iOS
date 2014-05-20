//
//  HAMAVManager.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-17.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMAVOSManager.h"

#import "HAMThing.h"

#import "HAMLogTool.h"

@implementation HAMAVOSManager

#pragma mark - Beacon

#pragma mark - Beacon Conversion

+ (AVObject*)beaconAVObjectWithCLBeacon:(CLBeacon*)beacon{
    AVObject* beaconObject = [AVObject objectWithClassName:@"Beacon"];
    [beaconObject setObject:beacon.proximityUUID.UUIDString forKey:@"proximityUUID"];
    [beaconObject setObject:beacon.major forKey:@"major"];
    [beaconObject setObject:beacon.minor forKey:@"minor"];
    return beaconObject;
}

#pragma mark - Beacon Query

+ (AVObject*)queryBeaconAVObjectWithCLBeacon:(CLBeacon*)beacon{
    AVQuery *query = [AVQuery queryWithClassName:@"Beacon"];
    [query whereKey:@"proximityUUID" equalTo:beacon.proximityUUID.UUIDString];
    [query whereKey:@"major" equalTo:beacon.major];
    [query whereKey:@"minor" equalTo:beacon.minor];
    
    NSArray* beaconArray = [query findObjects];
    if (beaconArray == nil || beaconArray.count == 0) {
        return nil;
    }
    return beaconArray[0];
}

+ (HAMBeaconState)ownStateOfBeacon:(CLBeacon*)beacon{
    HAMThing* thing = [self thingWithBeacon:beacon];
    
    if (thing.creator == nil) {
        return HAMBeaconStateFree;
    }
    
    AVUser* owner = thing.creator;
    AVUser* currentUser = [AVUser currentUser];
    if ([owner.objectId isEqualToString:currentUser.objectId]) {
        return HAMBeaconStateOwnedByMe;
    }
    return HAMBeaconStateOwnedByOthers;
}

#pragma mark - Beacon Save

+ (void)saveCLBeacon:(CLBeacon*)beacon{
    AVObject* beaconObject = [self beaconAVObjectWithCLBeacon:beacon];
    [beaconObject save];
}

+ (void)saveCLBeacon:(CLBeacon*)beacon withTarget:(id)target callback:(SEL)callback{
    AVObject* beaconObject = [self beaconAVObjectWithCLBeacon:beacon];
    [beaconObject saveInBackgroundWithTarget:target selector:callback];
}

#pragma mark - Thing

#pragma mark - Thing Conversion

+ (HAMThing*)thingWithThingAVObject:(AVObject *)thingObject{
    HAMThing* thing = [[HAMThing alloc] init];
    
    thing.objectID = thingObject.objectId;
    thing.type = [thingObject objectForKey:@"type"];
    thing.url = [thingObject objectForKey:@"url"];
    thing.title = [thingObject objectForKey:@"title"];
    thing.content = [thingObject objectForKey:@"content"];
    
    AVFile* coverFile = [thingObject objectForKey:@"cover"];
    NSData *coverData = [coverFile getData];
    thing.cover = [UIImage imageWithData:coverData];
    
    thing.coverURL = [thingObject objectForKey:@"coverURL"];
    thing.creator = [thingObject objectForKey:@"creator"];
    
    return thing;
}

+ (AVObject*)thingAVObjectWithThing:(HAMThing*)thing{
    AVObject* thingObject = [AVObject objectWithClassName:@"Thing"];
    
    [thingObject setObject:thing.type forKey:@"type"];
    [thingObject setObject:thing.url forKey:@"url"];
    [thingObject setObject:thing.title forKey:@"title"];
    [thingObject setObject:thing.content forKey:@"content"];
    
    AVFile* coverFile = [self saveImage:thing.cover];
    if (coverFile != nil) {
        [thingObject setObject:coverFile forKey:@"cover"];
        [thingObject setObject:coverFile.url forKey:@"coverURL"];
    }
    
    [thingObject setObject:thing.creator forKey:@"creator"];

    return thingObject;
}

#pragma mark - Thing Query

#pragma mark - Thing Save

+ (AVObject*)saveThing:(HAMThing*)thing{
    AVObject* thingObject = [self thingAVObjectWithThing:thing];
    [thingObject save];
    return thingObject;
}

#pragma mark - Thing & Beacon

#pragma mark - Thing & Beacon Query

+ (HAMThing*)thingWithBeacon:(CLBeacon*)beacon{
    NSString* uuid = beacon.proximityUUID.UUIDString;
    NSNumber* major = beacon.major;
    NSNumber* minor = beacon.minor;
    
    return [self thingWithBeaconID:uuid major:major minor:minor];
}

+ (HAMThing*)thingWithBeaconID:(NSString *)beaconID major:(NSNumber *)major minor:(NSNumber *)minor{
    AVQuery *query = [AVQuery queryWithClassName:@"Beacon"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query includeKey:@"thing"];
    
    [query whereKey:@"proximityUUID" equalTo:beaconID];
    [query whereKey:@"major" equalTo:major];
    [query whereKey:@"minor" equalTo:minor];
    
    AVObject* beaconObject = [query getFirstObject];
    
    if (beaconObject == nil) {
        return nil;
    }
    
    AVObject *thingObject = [beaconObject objectForKey:@"thing"];
    
    return [self thingWithThingAVObject:thingObject];
}

#pragma mark - Thing & Beacon Save

+ (void)unbindThingToBeacon:(CLBeacon*)beacon withTarget:(id)target callback:(SEL)callback{
    AVObject* beaconObject = [self queryBeaconAVObjectWithCLBeacon:beacon];
    if (beaconObject == nil) {
        //unbind thing from unrecorded beacon, normally won't happen
        [HAMLogTool warn:@"unbind thing from unrecorded beacon."];
        return;
    }
    
    [beaconObject setObject:nil forKey:@"thing"];
    [beaconObject saveInBackgroundWithTarget:target selector:callback];
}

+ (void)bindThing:(HAMThing*)thing range:(CLProximity)range toBeacon:(CLBeacon*)beacon withTarget:(id)target callback:(SEL)callback{
    //    if (![HAMTools isWebAvailable]) {
    //        return;
    //    }
    
    if (thing == nil) {
        [HAMLogTool warn:@"binding nil thing to Beacon"];
        [self unbindThingToBeacon:beacon withTarget:target callback:callback];
        return;
    }
    
    AVObject* beaconObject = [self queryBeaconAVObjectWithCLBeacon:beacon];
    
    if (beaconObject == nil) {
        //beacon not recorded. save beacon first.
        beaconObject = [self beaconAVObjectWithCLBeacon:beacon];
    }
    
    //save thing
    AVObject* thingObject = [self saveThing:thing];
    
    //TODO: must change here!
    [beaconObject setObject:[NSNumber numberWithInteger:range] forKey:@"range"];
    [beaconObject setObject:thingObject forKey:@"thing"];
    [beaconObject saveInBackgroundWithTarget:target selector:callback];
}

#pragma mark - File

#pragma mark - File Save

+ (AVFile*)saveImage:(UIImage*)image{
    if (image == nil) {
        return nil;
    }
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
    AVFile *file = [AVFile fileWithData:imageData];
    if ([file save] == NO) {
        [HAMLogTool error:@"save image file failed."];
        return nil;
    };
    return file;
}

@end
