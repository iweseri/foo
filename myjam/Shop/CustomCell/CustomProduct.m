//
//  CustomProduct.m
//  myjam
//
//  Created by ME-Tech Mac User 2 on 2/20/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "CustomProduct.h"

@implementation CustomProduct

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil)
    {
        NSArray *theView =  [[NSBundle mainBundle] loadNibNamed:@"CustomProduct" owner:self options:nil];
        UIView *nv = [theView objectAtIndex:0];
        
        [self addSubview:nv];
    }
    return self;
}

@end
