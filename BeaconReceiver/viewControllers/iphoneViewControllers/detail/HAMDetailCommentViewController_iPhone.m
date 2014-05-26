//
//  HAMArtDetailCommentViewController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 5/5/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMDetailCommentViewController_iPhone.h"
#import "HAMCommentData.h"
#import "HAMTourManager.h"
#import "HAMDetailTabBarController_iPhone.h"
#import "HAMThing.h"

@interface HAMDetailCommentViewController_iPhone ()

@end

@implementation HAMDetailCommentViewController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self.commentsTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    HAMDetailTabBarController_iPhone *detailTabVC = (HAMDetailTabBarController_iPhone*)self.parentViewController;
    self.thing = detailTabVC.thing;
    
    [self.commentText.layer setCornerRadius:10.0f];
    [self.commentText.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.commentText.layer setBorderWidth:0.5f];
    comments = [[HAMCommentsManager commentsManager] commentsWithPageDataID:self.thing.objectID];
    [HAMCommentsManager commentsManager].delegate = self;
    [[HAMCommentsManager commentsManager] updateComments];
    
    //set comment table
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [self.commentsTable setTableFooterView:view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - performUITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (comments == nil) {
        return 0;
    } else {
        return [comments count];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentHistory"];
    HAMCommentData *data = [comments objectAtIndex:indexPath.row];
    if (data != nil) {
        UILabel *label = (UILabel*)[cell viewWithTag:1];
        label.text = data.userName;
        UITextView *textView = (UITextView*)[cell viewWithTag:2];
        textView.text = data.content;
    }
    return cell;
    
}

#pragma mark - perform textview delegate
//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    CGRect frame = textView.frame;
    int offset = frame.origin.y + frame.size.height + 38.0 - (self.view.frame.size.height - 216.0);//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textViewShouldReturn:(UITextView *)textView
{
    [textView resignFirstResponder];
    return YES;
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textViewDidEndEditing:(UITextView *)textView
{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - comment
- (IBAction)commentButtonClicked:(id)sender {
    comments = [[HAMCommentsManager commentsManager] commentsWithPageDataID:self.thing.objectID];
    [[self commentsTable] reloadData];
    HAMCommentData *data = [[HAMCommentData alloc] init];
    if(self.thing != nil) {
        data.userName = [[HAMTourManager tourManager] currentUserThing].title;
        data.pageDataID = self.thing.objectID;
        data.userID = [AVUser currentUser].objectId;
        data.content = [self commentText].text;
        [[HAMCommentsManager commentsManager] addComment:data];
    }
    [self.commentText resignFirstResponder];
    self.commentText.text = nil;
}

- (void)refresh {
    comments = [[HAMCommentsManager commentsManager] commentsWithPageDataID:self.thing.objectID];
    [[self commentsTable] reloadData];
    if (comments == nil || [comments count] < 1) {
        return;
    }
    [self.commentsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[comments count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
