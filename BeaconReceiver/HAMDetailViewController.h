//
//  HAMDetailViewController.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-11.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMBeaconManager.h"
#import "HAMCommentsManager.h"

@class HAMHomepageData;

@interface HAMDetailViewController : UIViewController <UIWebViewDelegate, HAMBeaconManagerDelegate, UITableViewDataSource, UITableViewDelegate, HAMCommentsManagerDelegate> {
    NSString *pageURL;
    NSString *pageTitle;
    UIGestureRecognizer *backToHomeRecognizer;
    NSArray *comments;
}

@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
@property (weak, nonatomic) IBOutlet UITableView *commentsTable;
@property (weak, nonatomic) IBOutlet UITextView *commentText;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIView *commentView;

@property HAMHomepageData *homepage;

@end
