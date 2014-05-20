//
//  HAMThing.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-16.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

@interface HAMThing : NSObject

@property NSString* type;

@property NSString* url;
@property NSString* title;
@property NSString* content;
@property UIImage* cover;
@property NSString* coverURL;

@property AVUser* creator;

@end
