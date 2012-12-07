//
//  ImageView.m
//  FrameCamera
//
//  Created by Nagino Yuki on 2012/12/06.
//  Copyright (c) 2012年 RaD Inc. All rights reserved.
//

#import "ImageView.h"

@implementation ImageView

@synthesize imageList_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGPoint p = CGPointZero;
    for (UIImage *img in self.imageList_) {
        [img drawAtPoint:p];
        p.x += img.size.width;
    }
}

@end
