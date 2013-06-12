//
//  CheckoutPopupView.m
//  myjam
//
//  Created by M Ridhwan M Sari on 6/6/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "CheckoutPopupView.h"

@implementation CheckoutPopupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithDataList:(NSInteger)data andTag:(NSInteger)tag
{
    self = [super init];
    if (self) {
        NSArray *theView =  [[NSBundle mainBundle] loadNibNamed:@"CheckoutPopupView" owner:self options:nil];
        UIView *nv = [theView objectAtIndex:0];
        [nv setBackgroundColor:[UIColor colorWithHex:@"#f1ebe4"]];
        [self.seedView setBackgroundColor:[UIColor colorWithHex:@"#f1ebe4"]];
        NSString *seedText = [NSString stringWithFormat:@"♦ %d",data];
        [self.seedLabel setText:seedText];
        self.tag = tag;
        NSLog(@"TAGVIEW:%d",self.tag);
        if ((NSNumber*)data == nil) {
            [self.seedView setHidden:YES];
        }
        [self.yesButton setTag:1];
        [self.yesButton addTarget:self action:@selector(chooseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.noButton setTag:2];
        [self.noButton addTarget:self action:@selector(chooseButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self setFrame:CGRectMake(0, 0, nv.frame.size.width, nv.frame.size.height)];
        [self addSubview:nv];       
    }
    return self;
}

-(void)chooseButton:(id)sender {
    [self.delegate popView:self didSelectOptionAtIndex:[sender tag]];
    [self removeFromSuperview];
}

@end
