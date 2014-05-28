//
//  HAMCardsListViewController_iPhone.h
//  BeaconReceiver
//
//  Created by daiyue on 5/21/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HAMThing;

@interface HAMCardListViewController_iPhone : UICollectionViewController

@property NSArray *thingArray;
@property HAMThing *thingForSegue;

@property Boolean shouldShowPurchaseItem;

//for analystic events
@property NSString* source;

- (void)updateViewScrollToTop:(BOOL)needScroll;
- (void)updateWithThingArray:(NSArray*)array scrollToTop:(BOOL)needScroll;

- (void)showDetailWithThing:(HAMThing*)thing sender:(id)sender;

@end
