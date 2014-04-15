//
//  HAMTools.m
//  iosapp
//
//  Created by daiyue on 13-7-30.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMTools.h"
#import "HAMLogTool.h"
#import "Reachability.h"

#define COMMON_DATEFORMAT @"yyyy-MM-dd HH:mm:ss zzz"
#define JSON_DATEFORMAT @""

@implementation HAMTools

#pragma mark - Json Data Methods

+(void)setObject:(id)object toMutableArray:(NSMutableArray*)array atIndex:(int)pos
{
    long i;
    for (i = [array count]; i < pos; i++)
        [array addObject:[NSNull null]];
    [array setObject:object atIndexedSubscript:pos];
}

+(NSDictionary*)dictionaryFromJsonData:(NSData*)data
{
    NSError* error;
    NSDictionary* dic = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    
    if (error)
        [HAMLogTool error:[NSString stringWithFormat:@"Json parse failed : %@", error]];
    
    return dic;
}

+(NSArray*)arrayFromJsonData:(NSData*)data
{
    NSError* error;
    NSArray* array = [NSJSONSerialization
                         JSONObjectWithData:data
                         options:kNilOptions
                         error:&error];
    
    if (error)
        [HAMLogTool error:[NSString stringWithFormat:@"Json parse failed : %@", error]];
    
    return array;
}

+(NSNumber*)intNumberFromString:(NSString*)string{
    return [NSNumber numberWithInt:[string intValue]];
};

# pragma mark - NSDate Methods

+(NSString*)stringFromDate:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:COMMON_DATEFORMAT];
    
    return [dateFormatter stringFromDate:date];
}

+(NSDate*)dateFromString:(NSString*)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:COMMON_DATEFORMAT];
    
    return [dateFormatter dateFromString:dateString];
}

+(NSDate*)dateFromLongLong:(long long)msSince1970{
    return [NSDate dateWithTimeIntervalSince1970:msSince1970 / 1000];
}

+(long long)longLongFromDate:(NSDate*)date{
    return [date timeIntervalSince1970] * 1000;
}

+(Boolean)ifDateIsToday:(NSDate*)date{
    if (date == nil) {
        return false;
    }
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    return [today isEqualToDate:otherDate];
}

#pragma mark - other Methods

+(Boolean) isWebAvailable {
    return ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] != NotReachable);
}

@end