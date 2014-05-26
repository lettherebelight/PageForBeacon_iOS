//
//  HAMArtDetailCommentViewController_iPhone.h
//  BeaconReceiver
//
//  Created by daiyue on 5/5/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMCommentsManager.h"

@class HAMThing;

@interface HAMDetailCommentViewController_iPhone : UIViewController <UITableViewDataSource, UITextViewDelegate, HAMCommentsManagerDelegate> {
    NSArray *comments;
}

@property HAMThing *thing;
@property (weak, nonatomic) IBOutlet UITableView *commentsTable;
@property (weak, nonatomic) IBOutlet UITextView *commentText;

@end
