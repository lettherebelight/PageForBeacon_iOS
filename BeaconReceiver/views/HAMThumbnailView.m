//
//  HAMThumbnailView.m
//  BeaconReceiver
//
//  Created by daiyue on 4/15/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMThumbnailView.h"
#import "HAMHomepageData.h"
#import "HAMTools.h"

@implementation HAMThumbnailView

@synthesize pageData;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame pageData:(HAMHomepageData *)page {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.pageData = page;
        
        UIImage *background = [HAMTools imageFromURL:page.backImage];
        if (background != nil) {
            UIImage *image = [HAMTools image:background staysShapeChangeToSize:self.frame.size];
            backImageView = [[UIImageView alloc] initWithImage:image];
            [backImageView setCenter:CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f)];
            [self addSubview:backImageView];
            image = nil;
            background = nil;
        }
        
        /*
        UITextField *titleTF = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 50.0f, self.frame.size.width, 100.0f)];
        [titleTF setTextAlignment:NSTextAlignmentCenter];
        [titleTF setEnabled:NO];
        titleTF.text = page.pageTitle;
        [self addSubview:titleTF];
        */
        
        UIImage *thumbnail = [HAMTools imageFromURL:page.thumbnail];
        CGSize maxSize = CGSizeMake(500.0f, 400.0f);
        if (thumbnail != nil) {
            UIImage *image = [HAMTools image:thumbnail changeToMaxSize:maxSize];
            imageView = [[UIImageView alloc] initWithImage:image];
            [imageView setCenter:CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f)];
            [self addSubview:imageView];
            thumbnail = nil;
        }
        
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    backImageView.image = nil;
    backImageView = nil;
    imageView.image = nil;
    imageView = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
