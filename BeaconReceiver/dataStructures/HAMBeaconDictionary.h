//
//  HAMBeaconDictionary.h
//  BeaconReceiverTest
//
//  Created by Dai Yue on 14-5-11.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface HAMBeaconDictionary : NSObject
{}

+(id)dictionary;

-(void)setValue:(id)value forBeacon:(CLBeacon *)beacon;
- (void)setValue:(id)value forBeaconUUID:(NSString*)uuid major:(NSNumber*)major minor:(NSNumber*)minor;

-(id)objectForBeacon:(CLBeacon*)beacon;

@end
