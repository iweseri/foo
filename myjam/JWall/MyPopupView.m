//
//  MyPopupView.m
//  myjam
//
//  Created by Mohd Hafiz on 5/13/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "MyPopupView.h"

@implementation MyPopupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithDataList:(NSArray *)list andTag:(NSInteger)tag
{
    self = [super init];
    if (self) {
        
        self.tag = tag;
        
        CGFloat currHeight = 10;
        CGFloat padding = 30;
        CGFloat labelHeight = 40;
        CGFloat labelWidth = 160;
    
        for (int i = 0; i < [list count]; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(padding, currHeight, labelWidth, labelHeight)];
            [label setText:[list objectAtIndex:i]];
            [self addSubview:label];
            [label release];
            
            currHeight += labelHeight;
            label.tag = i;
            label.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLabelTap:)];
            [label addGestureRecognizer:tapGesture];
            [tapGesture release];
        }
        
        self.frame = CGRectMake(0, 0, labelWidth+padding*2, currHeight+10);
        [self setBackgroundColor:[UIColor whiteColor]];
        
    }
    return self;
}

- (void)handleLabelTap:(UITapGestureRecognizer *)sender
{
    [self.delegate popView:self didSelectOptionAtIndex:sender.view.tag];
    [self removeFromSuperview];
}


@end
