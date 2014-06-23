//
//  HAMCardsListViewController_iPhone.h
//  BeaconReceiver
//
//  Created by daiyue on 5/21/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HAMThing;

@protocol HAMCardListDelegate <NSObject>

@optional

- (NSArray*)updateThings;
- (void)updateThingsAsync;
- (NSArray*)loadMoreThings;
- (void)loadMoreThingsAsync;
//- (void)cellLongPressed:(HAMThing*)thing;
- (void)cellClicked:(HAMThing*)thing;

@end

@interface HAMCardListViewController_iPhone : UICollectionViewController

@property id<HAMCardListDelegate> delegate;

@property NSArray *thingArray;
@property HAMThing *thingForSegue;

@property Boolean shouldShowPurchaseItem;

//for analystic events
@property NSString* source;

- (void)didUpdateThingsWithThingArray:(NSArray*)updatedThingArray;
- (void)didLoadMoreThingsWithThingArray:(NSArray*)updatedThingArray;

- (void)updateViewScrollToTop:(BOOL)needScroll;
- (void)updateWithThingArray:(NSArray*)array scrollToTop:(BOOL)needScroll;

- (void)showDetailWithThing:(HAMThing*)thing sender:(id)sender;

@end
