//
//  HAMArtDetailCommentViewController_iPhone.h
//  BeaconReceiver
//
//  Created by daiyue on 5/5/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMCommentsManager.h"

@class HAMHomepageData;

@interface HAMArtDetailCommentViewController_iPhone : UIViewController <UITableViewDataSource, UITextViewDelegate, HAMCommentsManagerDelegate> {
    NSArray *comments;
}

@property HAMHomepageData *homepage;
@property (weak, nonatomic) IBOutlet UITableView *commentsTable;
@property (weak, nonatomic) IBOutlet UITextView *commentText;

@end
