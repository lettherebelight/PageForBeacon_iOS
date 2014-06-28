//
//  HAMViewTools.h
//  BeaconReceiver
//
//  Created by daiyue on 6/15/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HAMViewTools : NSObject
{}

+ (void)setTextViewBorder:(UITextView*)textView;

+(void)showAlert:(NSString*)text title:(NSString*)title delegate:(id)target;

@end
