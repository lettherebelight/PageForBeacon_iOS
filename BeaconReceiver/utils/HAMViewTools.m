//
//  HAMViewTools.m
//  BeaconReceiver
//
//  Created by daiyue on 6/15/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMViewTools.h"

@implementation HAMViewTools

+ (void)setTextViewBorder:(UITextView *)textView{
    CALayer* layer = textView.layer;
    layer.borderColor = [[UIColor colorWithRed:215.0 / 255.0 green:215.0 / 255.0 blue:215.0 / 255.0 alpha:1] CGColor];
    layer.borderWidth = 0.6f;
    layer.cornerRadius = 6.0f;
}

+(void)showAlert:(NSString*)text title:(NSString*)title delegate:(id)target{
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:text
                          delegate:target
                          cancelButtonTitle:@"返回"
                          otherButtonTitles:nil];
    [alert show];
}

@end
