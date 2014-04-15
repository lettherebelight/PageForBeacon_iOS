//
//  HAMCouponManager.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-20.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

enum HAMSyncError {
    HAMSyncErrorConnectionFailed,
    HAMSyncErrorParseDataFailed,
    HAMSyncErrorDBOperationFailed,
};
typedef enum HAMSyncError HAMSyncError;

@protocol HAMCouponManagerDelegate <NSObject>

- (void)syncSucceeded;
- (void)syncFailed:(HAMSyncError*)error;

@end

@class HAMCoupon;

@interface HAMCouponManager : NSObject

@property id<HAMCouponManagerDelegate> delegate;

+ (HAMCouponManager*)couponManager;

+ (HAMCoupon*)couponWithID:(NSString*)couponID;
+ (HAMCoupon*)couponWithBeaconID:(NSString*)beaconID major:(NSNumber*)major minor:(NSNumber*)minor;

+ (NSArray*)visitedHistory;

+ (void)syncWithServer;
+ (void)syncWithServerWithDelegate: (id<HAMCouponManagerDelegate>)delegate;

@end