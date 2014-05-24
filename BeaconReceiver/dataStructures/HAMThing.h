//
//  HAMThing.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-16.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

enum HAMThingType : NSInteger {
    HAMThingTypeArt,
    HAMThingTypeCard,
    HAMThingTypeOther
};
typedef enum HAMThingType HAMThingType;

@interface HAMThing : NSObject

@property (nonatomic) NSString* objectID;

@property (nonatomic) HAMThingType type;

@property (nonatomic) NSString* url;
@property (nonatomic) NSString* title;
@property (nonatomic) NSString* content;
@property (nonatomic) UIImage* cover;
@property (nonatomic) AVFile* coverFile;
@property (nonatomic) NSString* coverURL;

@property (nonatomic) AVUser* creator;

@property (nonatomic) NSString* weibo;
@property (nonatomic) NSString* wechat;
@property (nonatomic) NSString* qq;


- (BOOL)isEqualToThing:(HAMThing*)thing;

- (HAMThingType)setTypeWithTypeString:(NSString*)typeString;
- (NSString*)typeString;

@end
