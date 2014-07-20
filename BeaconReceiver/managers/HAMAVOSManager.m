//
//  HAMAVManager.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-17.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMAVOSManager.h"

#import "HAMThing.h"
#import "HAMConstants.h"

#import "HAMTourManager.h"
#import "HAMUserDefaultManager.h"

#import "HAMTools.h"
#import "HAMLogTool.h"

@implementation HAMAVOSManager

#pragma mark - Common

#pragma mark - Cache

+ (void)setCachePolicyOfQuery:(AVQuery*)query{
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = kHAMMaxCacheAge;
}

+ (void)clearCache{
    [AVQuery clearAllCachedResults];
}

#pragma mark - ACL

+ (AVACL*)aclWithPublicReadPrivateWrite{
    AVACL *acl = [AVACL ACL];
    [acl setPublicReadAccess:YES];
    [acl setWriteAccess:YES forUser:[AVUser currentUser]];
    return acl;
}

+ (AVACL*)aclWithPublicReadWrite{
    AVACL *acl = [AVACL ACL];
    [acl setPublicReadAccess:YES];
    [acl setPublicWriteAccess:YES];
    return acl;
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
    return [HAMThing rangeFromRangeString:rangeString];
}

+ (AVObject*)queryBeaconAVObjectWithThingID:(NSString*)thingID{
    if (thingID == nil) {
        return nil;
    }
    
    AVQuery* query = [AVQuery queryWithClassName:@"Beacon"];
    //FIXME: cache would cause a bug here. So I removed cache. All the functions that calls this function are save methods, except for isThingBoundToBeacon, which use UserDefaults as cache.
//    [self setCachePolicyOfQuery:query];
    
    [query whereKey:@"thing" equalTo:[AVObject objectWithoutDataWithClassName:@"Thing" objectId:thingID]];
    //not a must, but for safety reason
    [query whereKey:@"occupier" equalTo:[AVUser currentUser]];
    
    AVObject* object =  [query getFirstObject];
    return object;
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
    thing.range = [thing setRangeWithRangeString:[thingObject objectForKey:@"range"]];
    
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
        //TODO:
        thing.cover = [HAMTools image:thing.cover changeToMinSize:CGSizeMake(kHAMThingTypeArtThumbnailWidth, kHAMThingTypeArtThumbnailHeight)];
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
    
    [thingObject setObject:[thing rangeString] forKey:@"range"];

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

+ (void)thingsInWorldWithSkip:(int)skip limit:(int)limit target:(id)target callback:(SEL)callback{
    if (target == nil || callback == nil) {
        return;
    }
    NSArray* params = [NSArray arrayWithObjects:[NSNumber numberWithInt:skip], [NSNumber numberWithInt:limit], target, NSStringFromSelector(callback), nil];
    [NSThread detachNewThreadSelector:@selector(thingsInWorldSyncWithParams:) toTarget:self withObject:params];
}

+ (void)thingsInWorldSyncWithParams:(NSArray*)params{
    int skip = [params[0] intValue];
    int limit = [params[1] intValue];
    id target = params[2];
    SEL callback = NSSelectorFromString(params[3]);
    
    AVQuery* query = [AVQuery queryWithClassName:@"Thing"];
    [query orderByDescending:@"updatedAt"];
    [self setCachePolicyOfQuery:query];
    query.skip = skip;
    query.limit = limit;
    
    NSArray* thingObjectArray = [query findObjects];
    
    if (thingObjectArray == nil || thingObjectArray.count == 0) {
        if ([target respondsToSelector:callback]) {
            [target performSelector:callback withObject:@[] withObject:nil];
            return;
        }
    }
    
    NSArray* resultArray = [self thingsArrayWithThingObjectArray:thingObjectArray];
    if ([target respondsToSelector:callback]) {
        [target performSelector:callback withObject:resultArray withObject:nil];
        return;
    }
}

#pragma mark - Thing Save

//return nil on fail
+ (AVObject*)saveThing:(HAMThing*)thing{
    if (thing == nil) {
        [HAMLogTool warn:@"trying to save thing nil"];
        return nil;
    }
    
    //creator
    thing.creator = [AVUser currentUser];
    
    //cover
    Boolean shouldSaveCover = YES;
    if (thing.cover == nil) {
        //update thing without changing cover
        shouldSaveCover = NO;
    }
    
    AVObject* thingObject = [self thingAVObjectWithThing:thing shouldSaveCover:shouldSaveCover];
    
    //ACL
    thingObject.ACL = [self aclWithPublicReadPrivateWrite];
    
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
    
    [self updateRangeOfBeaconBoundWithThing:thing];
    
    AVObject* result = [self saveThing:thing];
    if ([target respondsToSelector:callback]){
        if(result == nil) {
            //FIXME: return with error
            [target performSelector:callback withObject:@0 withObject:[NSError errorWithDomain:@"error" code:0 userInfo:nil]];
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

//+ (CLProximity)rangeOfThing:(HAMThing*)thing{
//    /*if (thing.objectID == nil) {
//        return CLProximityUnknown;
//    }
//    AVObject* beaconObject = [self queryBeaconAVObjectWithThingID:thing.objectID];
//    NSString* rangeString = [beaconObject objectForKey:@"range"];
//    return [self proximityFromRangeString:rangeString];*/
//}
+ (void)isThingBoundToBeaconInBackground:(HAMThing*)thing{
    [NSThread detachNewThreadSelector:@selector(isThingBoundToBeacon:) toTarget:self withObject:thing];
}

+ (Boolean)isThingBoundToBeacon:(HAMThing*)thing{
    if (thing == nil || thing.objectID == nil) {
        return false;
    }
    
    NSString* cacheResult = [HAMUserDefaultManager isThingBoundToBeaconInCache:thing];
    if (cacheResult != nil) {
        return [HAMTools booleanFromString:cacheResult];
    }
    
    AVObject* beaconObject = [self queryBeaconAVObjectWithThingID:thing.objectID];
    Boolean result = beaconObject == nil ? NO : YES;
    
    [HAMUserDefaultManager recordThing:thing isBoundToBeacon:[HAMTools stringFromBoolean:result]];
    
    return result;
}

#pragma mark - Thing & Beacon Save

+ (void)unbindThingToBeaconAVObject:(AVObject*)beaconObject withTarget:(id)target callback:(SEL)callback{
    AVObject* thingObject = [beaconObject objectForKey:@"thing"];
    HAMThing* thing = nil;
    if (thingObject != nil) {
        thing = [[HAMThing alloc] init];
        thing.objectID = thingObject.objectId;
    }
    
    [beaconObject setObject:nil forKey:@"thing"];
    [beaconObject setObject:nil forKey:@"occupier"];
    [beaconObject setObject:nil forKey:@"range"];
    
    beaconObject.ACL = [self aclWithPublicReadWrite];
    
    [self clearCache];
    if (thing != nil) {
        [HAMUserDefaultManager recordThing:thing isBoundToBeacon:@"NO"];
    }
    
    [beaconObject saveInBackgroundWithTarget:target selector:callback];
}

//+ (void)unbindThingToBeacon:(CLBeacon*)beacon withTarget:(id)target callback:(SEL)callback{
//    if (beacon == nil) {
//        return;
//    }
//    
//    AVObject* beaconObject = [self queryBeaconAVObjectWithCLBeacon:beacon];
//    if (beaconObject == nil) {
//        //unbind thing from unrecorded beacon, normally won't happen
//        [HAMLogTool warn:@"unbind thing from unrecorded beacon."];
//        return;
//    }
//    
//    [self unbindThingToBeaconAVObject:beaconObject withTarget:target callback:callback];
//}

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
    
    AVUser* occupier = [beaconObject objectForKey:@"occupier"];
    if (![occupier.objectId isEqualToString:[AVUser currentUser].objectId]) {
        //try to unbind thing that is not occupied by the current user. normally impossible.
        //FIXME: callback with error
        [HAMTools performSelector:callback byTarget:target];
        return;
    }
    
    [self unbindThingToBeaconAVObject:beaconObject withTarget:target callback:callback];
}

+ (void)bindThing:(HAMThing *)thing toBeacon:(CLBeacon *)beacon withTarget:(id)target callback:(SEL)callback{
    NSArray* params = [NSArray arrayWithObjects:thing, beacon, target, NSStringFromSelector(callback), nil];
    [NSThread detachNewThreadSelector:@selector(bindThingSyncWithParams:) toTarget:self withObject:params];
}

+ (void)bindThingSyncWithParams:(NSArray*)params{
    
    HAMThing* thing = params[0];
    CLBeacon* beacon = params[1];
    id target = params[2];
    SEL callback = NSSelectorFromString(params[3]);
    
    if (thing == nil || thing.objectID == nil) {
        [HAMLogTool warn:@"binding nil thing to Beacon"];
        return;
    }
    
    AVObject* beaconObject = [self queryBeaconAVObjectWithCLBeacon:beacon];
    
    if (beaconObject == nil) {
        //beacon not recorded. save beacon first.
        beaconObject = [self beaconAVObjectWithCLBeacon:beacon];
    }
    
    //save thing
    AVObject* thingObject = [self thingAVObjectWithThing:thing shouldSaveCover:NO];
    
    NSString* rangeString = [thing rangeString];
    [beaconObject setObject:rangeString forKey:@"range"];
    [beaconObject setObject:thingObject forKey:@"thing"];
    AVUser* user = [AVUser currentUser];
    [beaconObject setObject:user forKey:@"occupier"];
    
    beaconObject.ACL = [self aclWithPublicReadPrivateWrite];
    
    if (thing != nil) {
        [HAMUserDefaultManager recordThing:thing isBoundToBeacon:@"YES"];
    }
    [self clearCache];
    
    [beaconObject saveInBackgroundWithTarget:target selector:callback];
}

+(void)updateRangeOfBeaconBoundWithThing:(HAMThing *)thing{
    if (thing.objectID == nil) {
        return;
    }
    
    AVObject* beaconObject = [self queryBeaconAVObjectWithThingID:thing.objectID];
    if (beaconObject == nil) {
        //thing is currently not bound to beacon
        return;
    }
    
    NSString* rangeString = [thing rangeString];
    [beaconObject setObject:rangeString forKey:@"range"];
    [self clearCache];
    [beaconObject save];
}

#pragma mark - Thing & User

#pragma mark - Thing & User Query

+ (void)thingsOfCurrentUserWithSkip:(int)skip limit:(int)limit target:(id)target callback:(SEL)callback{
    if (target == nil || callback == nil) {
        return;
    }
    
    NSArray* params = [NSArray arrayWithObjects:[NSNumber numberWithInt:skip], [NSNumber numberWithInt:limit], target, NSStringFromSelector(callback), nil];
    [NSThread detachNewThreadSelector:@selector(thingsOfCurrentUserSyncWithParams:) toTarget:self withObject:params];
}

+ (void)thingsOfCurrentUserSyncWithParams:(NSArray*)params{
    //TODO: handle error
    int skip = [params[0] intValue];
    int limit = [params[1] intValue];
    id target = params[2];
    SEL callback = NSSelectorFromString(params[3]);
    
    AVUser* user = [AVUser currentUser];
    if (user == nil) {
        if ([target respondsToSelector:callback]) {
            [target performSelector:callback withObject:@[] withObject:nil];
            return;
        }
    }
    
    AVQuery* query = [AVQuery queryWithClassName:@"Thing"];
    [query orderByDescending:@"updatedAt"];
    [self setCachePolicyOfQuery:query];
    query.skip = skip;
    query.limit = limit;
    
    [query whereKey:@"creator" equalTo:user];
    NSArray* thingObjectArray = [query findObjects];
    
    if (thingObjectArray == nil || thingObjectArray.count == 0) {
        if ([target respondsToSelector:callback]) {
            [target performSelector:callback withObject:@[] withObject:nil];
            return;
        }
    }
    
    NSArray* resultArray = [self thingsArrayWithThingObjectArray:thingObjectArray];
    if ([target respondsToSelector:callback]) {
        [target performSelector:callback withObject:resultArray withObject:nil];
    }
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
    thing.range = kHAMDefaultRange;
    
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
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    AVFile *file = [AVFile fileWithData:imageData];
    if ([file save] == NO) {
        [HAMLogTool error:@"save image file failed."];
        return nil;
    };
    return file;
}

#pragma mark - Favorites

#pragma mark - Favorites Query

+ (void)favoriteThingsOfCurrentUserWithSkip:(int)skip limit:(int)limit target:(id)target callback:(SEL)callback{
    if (target == nil || callback == nil) {
        return;
    }
    NSArray* params = [NSArray arrayWithObjects:[NSNumber numberWithInt:skip], [NSNumber numberWithInt:limit], target, NSStringFromSelector(callback), nil];
    [NSThread detachNewThreadSelector:@selector(favoriteThingsOfCurrentUserSyncWithParams:) toTarget:self withObject:params];
}

+ (void)favoriteThingsOfCurrentUserSyncWithParams:(NSArray*)params{
    int skip = [params[0] intValue];
    int limit = [params[1] intValue];
    id target = params[2];
    SEL callback = NSSelectorFromString(params[3]);
    
    if (limit <= 0) {
//        return @[];
        if ([target respondsToSelector:callback]) {
            [target performSelector:callback withObject:@[] withObject:nil];
            return;
        }
    }
    
    AVUser* user = [AVUser currentUser];
    //TODO: change to Relation someday!
    NSArray* favoritesObjectArray = [user objectForKey:@"favorites"];
    if (favoritesObjectArray == nil || favoritesObjectArray.count == 0) {
        //no favorites
//        return [NSArray array];
        if ([target respondsToSelector:callback]) {
            [target performSelector:callback withObject:@[] withObject:nil];
            return;
        }
    }
    
    if (skip >= favoritesObjectArray.count){
//        return @[];
        if ([target respondsToSelector:callback]) {
            [target performSelector:callback withObject:@[] withObject:nil];
            return;
        }
    }
    
    NSMutableArray* favoritesArray = [NSMutableArray array];
    for (long i = MIN(skip + limit - 1, favoritesObjectArray.count - 1); i >= 0 && i >= skip; i--) {
        AVObject* thingObject = favoritesObjectArray[i];
        //TODO: handle error
        [thingObject fetchIfNeeded];
        
        HAMThing* thing = [self thingWithThingAVObject:thingObject];
        [favoritesArray addObject:thing];
    }
    
//    return [NSArray arrayWithArray:favoritesArray];
    if ([target respondsToSelector:callback]) {
        [target performSelector:callback withObject:favoritesArray withObject:nil];
    }
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
    [self setCachePolicyOfQuery:query];

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

@end
