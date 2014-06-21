//
//  HAMAVManager.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-17.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMAVOSManager.h"

#import "HAMThing.h"

#import "HAMTourManager.h"

#import "HAMTools.h"
#import "HAMLogTool.h"

@implementation HAMAVOSManager

#pragma mark - Cache

#pragma mark - Query Methods

+ (void)setCachePolicyOfQuery:(AVQuery*)query{
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 600;
}

#pragma mark - Clear Cache

+ (void)clearCache{
    [AVQuery clearAllCachedResults];
}

#pragma mark - BeaconUUID

#pragma mark - BeaconUUID Query

+ (NSDictionary*)beaconDescriptionDictionary{
    AVQuery *query = [AVQuery queryWithClassName:@"BeaconUUID"];
//    [self setCachePolicyOfQuery:query];
    
    NSArray* uuidObjectsArray = [query findObjects];
//    NSLog(@"%@",uuidObjectsArray);
    if (uuidObjectsArray == nil) {
        return nil;
    }
    
    NSMutableDictionary* beaconDescriptionDictionary = [NSMutableDictionary dictionary];
    for (int i = 0; i < uuidObjectsArray.count; i++) {
        AVObject* uuidObject = uuidObjectsArray[i];
        NSString* description = [uuidObject objectForKey:@"description"];
        NSString* uuid = [uuidObject objectForKey:@"proximityUUID"];
        if (uuid == nil) {
            continue;
        }
        if (description == nil) {
            description = @"未知iBeacon";
        }
        [beaconDescriptionDictionary setObject:description forKey:uuid];
    }
    return [NSDictionary dictionaryWithDictionary:beaconDescriptionDictionary];
}

#pragma mark - BeaconUUID Save

+ (void)saveBeaconUUID:(NSString*)uuid description:(NSString*)description withTarget:(id)target callback:(SEL)callback{
    NSUUID* uuidCheck = [[NSUUID alloc] initWithUUIDString:uuid];
    if (uuidCheck == nil) {
        [HAMLogTool warn:@"illegal uuid"];
        return;
    }

    AVObject* uuidObject = [AVObject objectWithClassName:@"BeaconUUID"];
    [uuidObject setObject:[uuidCheck UUIDString] forKey:@"proximityUUID"];
    [uuidObject setObject:description forKey:@"description"];
    
    [self clearCache];
    [uuidObject save];
    
    //perform callback
    if (target == nil) {
        return;
    }
    
    [HAMTools performSelector:callback byTarget:target];
//    [uuidObject saveInBackgroundWithTarget:target selector:callback];
}

#pragma mark - Beacon

#pragma mark - Beacon Conversion

+ (AVObject*)beaconAVObjectWithCLBeacon:(CLBeacon*)beacon{
    if (beacon == nil) {
        return nil;
    }
    
    AVObject* beaconObject = [AVObject objectWithClassName:@"Beacon"];
    [beaconObject setObject:beacon.proximityUUID.UUIDString forKey:@"proximityUUID"];
    [beaconObject setObject:beacon.major forKey:@"major"];
    [beaconObject setObject:beacon.minor forKey:@"minor"];
    return beaconObject;
}

#pragma mark - Beacon Query

+ (AVObject*)queryBeaconAVObjectWithCLBeacon:(CLBeacon*)beacon{
    if (beacon == nil) {
        return nil;
    }
    
    AVQuery *query = [AVQuery queryWithClassName:@"Beacon"];
    [self setCachePolicyOfQuery:query];
    
    [query whereKey:@"proximityUUID" equalTo:beacon.proximityUUID.UUIDString];
    [query whereKey:@"major" equalTo:beacon.major];
    [query whereKey:@"minor" equalTo:beacon.minor];
    
    AVObject* beaconObject = [query getFirstObject];
    return beaconObject;
}

+ (CLProximity)rangeOfBeacon:(CLBeacon*)beacon{
    if (beacon == nil) {
        [HAMLogTool warn:@"query range of beacon nil"];
        return CLProximityUnknown;
    }
    
    AVObject* beaconObject = [self queryBeaconAVObjectWithCLBeacon:beacon];
    NSString* rangeString = [beaconObject objectForKey:@"range"];
    return [self proximityFromRangeString:rangeString];
}

+ (AVObject*)queryBeaconAVObjectWithThingID:(NSString*)thingID{
    if (thingID == nil) {
        return nil;
    }
    
    AVQuery* query = [AVQuery queryWithClassName:@"Beacon"];
    [self setCachePolicyOfQuery:query];
    
    [query whereKey:@"thing" equalTo:[AVObject objectWithoutDataWithClassName:@"Thing" objectId:thingID]];
    //not a must, but for safety reason
    [query whereKey:@"occupier" equalTo:[AVUser currentUser]];
    
    return [query getFirstObject];
}

#pragma mark - Beacon Save

+ (void)saveCLBeacon:(CLBeacon*)beacon{
    if (beacon == nil) {
        [HAMLogTool warn:@"trying to save beacon nil"];
        return;
    }
    
    AVObject* beaconObject = [self beaconAVObjectWithCLBeacon:beacon];
    [beaconObject save];
    [self clearCache];
}

+ (void)saveCLBeacon:(CLBeacon*)beacon withTarget:(id)target callback:(SEL)callback{
    if (beacon == nil) {
        [HAMLogTool warn:@"trying to save beacon nil"];
        return;
    }
    
    AVObject* beaconObject = [self beaconAVObjectWithCLBeacon:beacon];
    [beaconObject saveInBackgroundWithTarget:target selector:callback];
    [self clearCache];
}

#pragma mark - Thing

#pragma mark - Thing Conversion

+ (HAMThing*)thingWithThingAVObject:(AVObject *)thingObject{
    if (thingObject == nil) {
        return nil;
    }
    
    HAMThing* thing = [[HAMThing alloc] init];
    
    thing.objectID = thingObject.objectId;
    
    NSString* typeString = [thingObject objectForKey:@"type"];
    [thing setTypeWithTypeString:typeString];
    thing.url = [thingObject objectForKey:@"url"];
    thing.title = [thingObject objectForKey:@"title"];
    thing.content = [thingObject objectForKey:@"content"];
    thing.coverFile = [thingObject objectForKey:@"cover"];
    thing.cover = nil;
    thing.coverURL = [thingObject objectForKey:@"coverURL"];
    thing.creator = [thingObject objectForKey:@"creator"];
    thing.weibo = [thingObject objectForKey:@"weibo"];
    thing.wechat = [thingObject objectForKey:@"wechat"];
    thing.qq = [thingObject objectForKey:@"qq"];
    
    return thing;
}

+ (AVObject*)thingAVObjectWithThing:(HAMThing*)thing shouldSaveCover:(Boolean)shouldSaveCover{
    if (thing == nil) {
        return nil;
    }
    
    AVObject* thingObject = [AVObject objectWithClassName:@"Thing"];
    
    if (thing.objectID != nil) {
        thingObject.objectId = thing.objectID;
    }
    
    NSString* typeString = [thing typeString];
    [thingObject setObject:typeString forKey:@"type"];
    [thingObject setObject:thing.url forKey:@"url"];
    [thingObject setObject:thing.title forKey:@"title"];
    [thingObject setObject:thing.content forKey:@"content"];
    
    if (shouldSaveCover) {
        AVFile* coverFile = [self saveImage:thing.cover];
        if (coverFile != nil) {
            [thingObject setObject:coverFile forKey:@"cover"];
            [thingObject setObject:coverFile.url forKey:@"coverURL"];
        }
    } else {
        [thingObject setObject:thing.coverFile forKey:@"cover"];
        [thingObject setObject:thing.coverURL forKey:@"coverURL"];
    }
    
    [thingObject setObject:thing.creator forKey:@"creator"];
    
    [thingObject setObject:thing.weibo forKey:@"weibo"];
    [thingObject setObject:thing.wechat forKey:@"wechat"];
    [thingObject setObject:thing.qq forKey:@"qq"];

    return thingObject;
}

+ (NSArray*)thingsArrayWithThingObjectArray:(NSArray*)thingObjectArray{
    NSMutableArray* thingArray = [NSMutableArray array];
    for (int i = 0; i < thingObjectArray.count; i++) {
        AVObject* thingObject = thingObjectArray[i];
        HAMThing* thing = [self thingWithThingAVObject:thingObject];
        if (thing == nil) {
            [HAMLogTool error:@"failed to convert from thingObject to thing"];
            continue;
        }
        
        [thingArray addObject:thing];
    }
    return thingArray;
}

#pragma mark - Thing Query

+ (AVObject*)thingAVObjectWithObjectID:(NSString*)objectID{
    if (objectID == nil) {
        [HAMLogTool warn:@"query thing with objectID nil"];
        return nil;
    }
    
    AVQuery* query = [AVQuery queryWithClassName:@"Thing"];
    [self setCachePolicyOfQuery:query];

    return [query getObjectWithId:objectID];
}

+ (HAMThing*)thingWithObjectID:(NSString*)objectID{
    AVObject* thingObject = [self thingAVObjectWithObjectID:objectID];
    if (!thingObject) {
        [HAMLogTool warn:@"thing with ObjectID not found"];
        return nil;
    }
    
    return [self thingWithThingAVObject:thingObject];
}

+ (NSArray*)thingsInWorldWithSkip:(int)skip limit:(int)limit{
    AVQuery* query = [AVQuery queryWithClassName:@"Thing"];
    [query orderByDescending:@"updatedAt"];
    [self setCachePolicyOfQuery:query];
    query.skip = skip;
    query.limit = limit;
    
    NSArray* thingObjectArray = [query findObjects];
    
    if (thingObjectArray == nil || thingObjectArray.count == 0) {
        return @[];
    }
    
    return [self thingsArrayWithThingObjectArray:thingObjectArray];
}

#pragma mark - Thing Save

//return nil on fail
+ (AVObject*)saveThing:(HAMThing*)thing{
    if (thing == nil) {
        [HAMLogTool warn:@"trying to save thing nil"];
        return nil;
    }
    
    thing.creator = [AVUser currentUser];
    
    Boolean shouldSaveCover = YES;
    if (thing.cover == nil) {
        //update thing without changing cover
        shouldSaveCover = NO;
    }
    AVObject* thingObject = [self thingAVObjectWithThing:thing shouldSaveCover:shouldSaveCover];
    
    [self clearCache];
    if (![thingObject save]) {
        return nil;
    }
    
    return thingObject;
}

+ (void)saveThing:(HAMThing *)thing withTarget:(id)target callback:(SEL)callback{
    if (thing == nil || target == nil || callback == nil) {
        //FIXME: callback with error
        return;
    }
    
    NSArray* params = [NSArray arrayWithObjects:thing, target, NSStringFromSelector(callback), nil];
    [NSThread detachNewThreadSelector:@selector(saveThingSyncWithParams:) toTarget:self withObject:params];
}

+ (void)saveThingSyncWithParams:(NSArray*)params{
    HAMThing* thing = params[0];
    id target = params[1];
    SEL callback = NSSelectorFromString(params[2]);
    
    AVObject* result = [self saveThing:thing];
    if ([target respondsToSelector:callback]){
        if(result == nil) {
            //FIXME: return with error
            [target performSelector:callback withObject:@0 withObject:nil];
        } else {
            [target performSelector:callback withObject:@1 withObject:nil];
        }
    }
}

#pragma mark - Beacon & User

#pragma mark - Beacon & User Query

+ (HAMBeaconState)ownStateOfBeacon:(CLBeacon*)beacon{
    if (beacon == nil) {
        [HAMLogTool warn:@"query own state of beacon nil"];
        return HAMBeaconStateOwnedByOthers;
    }
    
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

+ (HAMBeaconState)ownStateOfBeaconUpdated:(CLBeacon*)beacon{
    [self clearCache];
    return [self ownStateOfBeacon:beacon];
}

+ (int)ownBeaconCountOfCurrentUser{
    AVQuery* query = [AVQuery queryWithClassName:@"Beacon"];
    AVUser* currentUser = [AVUser currentUser];
    [query whereKey:@"occupier" equalTo:currentUser];
    return (int)[query countObjects];
}

#pragma mark - Thing & Beacon (Bind)

#pragma mark - Thing & Beacon Query

+ (HAMThing*)thingWithBeacon:(CLBeacon*)beacon{
    if (beacon == nil) {
        return nil;
    }
    
    NSString* uuid = beacon.proximityUUID.UUIDString;
    NSNumber* major = beacon.major;
    NSNumber* minor = beacon.minor;
    
    return [self thingWithBeaconID:uuid major:major minor:minor];
}

+ (HAMThing*)thingWithBeaconID:(NSString *)beaconID major:(NSNumber *)major minor:(NSNumber *)minor{
    AVQuery *query = [AVQuery queryWithClassName:@"Beacon"];
    [self setCachePolicyOfQuery:query];
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

+ (CLProximity)rangeOfThing:(HAMThing*)thing{
    if (thing.objectID == nil) {
        return CLProximityUnknown;
    }
    AVObject* beaconObject = [self queryBeaconAVObjectWithThingID:thing.objectID];
    NSString* rangeString = [beaconObject objectForKey:@"range"];
    return [self proximityFromRangeString:rangeString];
}

+ (Boolean)isThingBoundToBeacon:(NSString*)thingID{
    if (thingID == nil) {
        return false;
    }
    
    AVObject* beaconObject = [self queryBeaconAVObjectWithThingID:thingID];
    return beaconObject == nil ? NO : YES;
}

#pragma mark - Thing & Beacon Save

+ (void)unbindThingToBeaconAVObject:(AVObject*)beaconObject withTarget:(id)target callback:(SEL)callback{
    [beaconObject setObject:nil forKey:@"thing"];
    [beaconObject setObject:nil forKey:@"occupier"];
    [self clearCache];
    [beaconObject saveInBackgroundWithTarget:target selector:callback];
}

+ (void)unbindThingToBeacon:(CLBeacon*)beacon withTarget:(id)target callback:(SEL)callback{
    if (beacon == nil) {
        return;
    }
    
    AVObject* beaconObject = [self queryBeaconAVObjectWithCLBeacon:beacon];
    if (beaconObject == nil) {
        //unbind thing from unrecorded beacon, normally won't happen
        [HAMLogTool warn:@"unbind thing from unrecorded beacon."];
        return;
    }
    
    [self unbindThingToBeaconAVObject:beaconObject withTarget:target callback:callback];
}

+ (void)unbindThingWithThingID:(NSString*)thingID withTarget:(id)target callback:(SEL)callback{
    if (thingID == nil) {
        //FIXME: callback with error
        return;
    }
    
    AVObject* beaconObject = [self queryBeaconAVObjectWithThingID:thingID];
    if (beaconObject == nil) {
        //not bound to beacon. no need to unbind
        //FIXME: callback with error
        [HAMTools performSelector:callback byTarget:target];
        return;
    }
    
    [self unbindThingToBeaconAVObject:beaconObject withTarget:target callback:callback];
}

+ (void)bindThing:(HAMThing *)thing range:(CLProximity)range toBeacon:(CLBeacon *)beacon withTarget:(id)target callback:(SEL)callback{
    NSArray* params = [NSArray arrayWithObjects:thing, [NSNumber numberWithInt:range], beacon, target, NSStringFromSelector(callback), nil];
    [NSThread detachNewThreadSelector:@selector(bindThingSyncWithParams:) toTarget:self withObject:params];
}

+ (void)bindThingSyncWithParams:(NSArray*)params{
    
    HAMThing* thing = params[0];
    CLProximity range = [params[1] intValue];
    CLBeacon* beacon = params[2];
    id target = params[3];
    SEL callback = NSSelectorFromString(params[4]);
    
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
    
    NSString* rangeString = [self rangeStringFromRange:range];
    [beaconObject setObject:rangeString forKey:@"range"];
    [beaconObject setObject:thingObject forKey:@"thing"];
    AVUser* user = [AVUser currentUser];
    [beaconObject setObject:user forKey:@"occupier"];
    
    [self clearCache];
    [beaconObject saveInBackgroundWithTarget:target selector:callback];
}

+(void)updateRange:(CLProximity)range ofThing:(HAMThing*)thing{
    NSString* rangeString = [self rangeStringFromRange:range];
    
    AVObject* beaconObject = [self queryBeaconAVObjectWithThingID:thing.objectID];
    if (beaconObject == nil) {
        [HAMLogTool warn:@"update range of thing which is currently not bound to beacon."];
        return;
    }
    [beaconObject setObject:rangeString forKey:@"range"];
    [self clearCache];
    [beaconObject save];
}

#pragma mark - Thing & User

#pragma mark - Thing & User Query

+ (NSArray*)thingsOfCurrentUserWithSkip:(int)skip limit:(int)limit{
    AVUser* user = [AVUser currentUser];
    if (user == nil) {
        return @[];
    }
    
    AVQuery* query = [AVQuery queryWithClassName:@"Thing"];
    [query orderByDescending:@"updatedAt"];
    [self setCachePolicyOfQuery:query];
    query.skip = skip;
    query.limit = limit;
    
    [query whereKey:@"creator" equalTo:user];
    NSArray* thingObjectArray = [query findObjects];
    
    if (thingObjectArray == nil || thingObjectArray.count == 0) {
        return @[];
    }
    
    return [self thingsArrayWithThingObjectArray:thingObjectArray];
}

#pragma mark - Thing & User Update

+ (void)updateCurrentUserCardWithThing:(HAMThing*)thing{
    AVUser* user = [AVUser currentUser];
    
    AVObject* oldThingObject = [user objectForKey:@"card"];
    if (oldThingObject == nil) {
        [HAMLogTool warn:@"Card not exists for current user"];
        return;
    }
    
    AVObject* thingObject = [self thingAVObjectWithThing:thing shouldSaveCover:NO];
    thingObject.objectId = oldThingObject.objectId;
    [thingObject save];
    [self clearCache];
    
    HAMTourManager* tourManager = [HAMTourManager tourManager];
    [tourManager updateCurrentUserThing:thing];
}

#pragma mark - Thing & User Save

+ (void)saveCurrentUserCard:(HAMThing*)thing{
    if (thing == nil) {
        [HAMLogTool warn:@"save nil card to Current user"];
        return;
    }
    
    thing.type = HAMThingTypeCard;
    thing.creator = [AVUser currentUser];
    
    AVObject* thingObject = [self thingAVObjectWithThing:thing shouldSaveCover:NO];
    [thingObject save];
    [self clearCache];
    
    AVUser* user = [AVUser currentUser];
    [user setObject:thingObject forKey:@"card"];
    [user save];
}

#pragma mark - File

#pragma mark - File Query

+ (UIImage*)imageFromFile:(AVFile*)file{
    if (file == nil) {
        return nil;
    }
    
    NSData *coverData = [file getData];
    if (coverData == nil) {
        return nil;
    }
    
    return [UIImage imageWithData:coverData];
}

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

#pragma mark - Favorites

#pragma mark - Favorites Query

+ (NSArray*)favoriteThingsOfCurrentUserWithSkip:(int)skip limit:(int)limit{
    if (limit <= 0) {
        return @[];
    }
    
    AVUser* user = [AVUser currentUser];
    //TODO: change to Relation someday!
    NSArray* favoritesObjectArray = [user objectForKey:@"favorites"];
    if (favoritesObjectArray == nil || favoritesObjectArray.count == 0) {
        //no favorites
        return [NSArray array];
    }
    
    if (skip >= favoritesObjectArray.count)
        return @[];
    
    NSMutableArray* favoritesArray = [NSMutableArray array];
//    for (int i = skip; i < favoritesObjectArray.count && i < skip + limit; i++) {
    for (long i = MIN(skip + limit - 1, favoritesObjectArray.count - 1); i >= 0 && i >= skip; i--) {
        AVObject* thingObject = favoritesObjectArray[i];
        [thingObject fetchIfNeeded];
        
        HAMThing* thing = [self thingWithThingAVObject:thingObject];
        [favoritesArray addObject:thing];
    }
    
    return [NSArray arrayWithArray:favoritesArray];
}

+ (Boolean)isThingFavoriteOfCurrentUser:(HAMThing*)targetThing{
    if (targetThing == nil || targetThing.objectID == nil) {
        return false;
    }
    
    AVUser* user = [AVUser currentUser];
    NSArray* favoritesObjectArray = [user objectForKey:@"favorites"];
    if (favoritesObjectArray == nil || favoritesObjectArray.count == 0) {
        //no favorites
        return NO;
    }
    
    for (int i = 0; i < favoritesObjectArray.count; i++) {
        AVObject* thingObject = favoritesObjectArray[i];
        if ([thingObject.objectId isEqualToString:targetThing.objectID]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Favorites Save

+ (void)saveFavoriteThingForCurrentUser:(HAMThing*)thing{
    if (thing == nil) {
        [HAMLogTool warn:@"save nil favorite thing for current user"];
        return;
    }
    
    AVUser* user = [AVUser currentUser];
    AVObject* thingObject = [self thingAVObjectWithThing:thing shouldSaveCover:NO];
    //The favorite array's is ordered by adding consequence. So didn't use addUniqueObject here. Please don't add favorite things that are already favorite, so that there would be no duplicate things in the favorite array.
    [user addObject:thingObject forKey:@"favorites"];
    [user save];
    [self clearCache];
}

+ (void)removeFavoriteThingFromCurrentUser:(HAMThing*)thing{
    if (thing == nil) {
        [HAMLogTool warn:@"remove nil favorite thing for current user"];
        return;
    }
    
    AVUser* user = [AVUser currentUser];
    AVObject* thingObject = [self thingAVObjectWithThing:thing shouldSaveCover:NO];
    [user removeObject:thingObject forKey:@"favorites"];
    [user save];
    [self clearCache];
}

#pragma mark - Comment

#pragma mark - Comment Query

+ (int)numberOfCommentsOfThing:(HAMThing*)thing {
    if (thing == nil) {
        [HAMLogTool warn:@"query comments of nil thing"];
        return -1;
    }
    
    AVQuery *query = [AVQuery queryWithClassName:@"Comment"];
    //[self setCachePolicyOfQuery:query];

    [query whereKey:@"thingID" equalTo:thing.objectID];
    int count = (int)[query countObjects];
    return count;
}

#pragma mark - Analytics

#pragma mark - Analytics Save

+ (void)saveApproachEventWithOldTopThing:(HAMThing*)oldTopThing newTopThing:(HAMThing*)currentTopThing{
    AVObject* eventObject = [AVObject objectWithClassName:@"ApproachEvent"];
    
    [eventObject setObject:oldTopThing.objectID forKey:@"oldTopThing"];
    [eventObject setObject:currentTopThing.objectID forKey:@"newTopThing"];
    [eventObject setObject:[NSDate date] forKey:@"timeStamp"];
    
    [eventObject saveEventually];
}

+ (void)saveDetailViewEventWithThing:(HAMThing *)thing source:(NSString *)source{
    AVObject* eventObject = [AVObject objectWithClassName:@"DetailViewEvent"];
    
    [eventObject setObject:thing.objectID forKey:@"thing"];
    [eventObject setObject:source forKey:@"source"];
    [eventObject setObject:[NSDate date] forKey:@"timeStamp"];
    
    [eventObject saveEventually];
}

#pragma mark - Utils

+ (CLProximity)proximityFromRangeString:(NSString*)rangeString{
    if (rangeString == nil) {
        return CLProximityImmediate;
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
    
    [HAMLogTool warn:@"range of beacon unknown"];
    return CLProximityUnknown;
}

//FIXME: move this method, paired with the reverse process, into another class somday
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
            rangeString = @"immediate";
            break;
    }
    return rangeString;
}

@end
