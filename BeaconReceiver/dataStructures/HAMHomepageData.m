//
//  HAMHomepageData.m
//  BeaconReceiver
//
//  Created by daiyue on 5/5/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMHomepageData.h"
#import "HAMHistoryHomepage.h"
#import "HAMMarkedHomepage.h"
#import <AVOSCloud/AVOSCloud.h>


@implementation HAMHomepageData

@dynamic backImage;
@dynamic beaconID;
@dynamic beaconMajor;
@dynamic beaconMinor;
//TODO: change to stuff id
@dynamic dataID;
@dynamic pageTitle;
@dynamic pageURL;
@dynamic range;
@dynamic thumbnail;
@dynamic describe;
@dynamic historyListRecord;
@dynamic markedListRecord;

- (void)saveToServerWithTarget:(id)target callback:(SEL)callback{
    AVObject* object = [AVObject objectWithClassName:@"Stuff"];
    [object setObject:self.pageTitle forKey:@"name"];
    [object setObject:self.thumbnail forKey:@"preview_thumbnail"];
    [object setObject:self.pageURL forKey:@"page_url"];
    //type?
    //preview background?
    [object setObject:self.describe forKey:@"description"];
}

@end
