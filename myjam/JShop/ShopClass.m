//
//  ShopClass.m
//  myjam
//
//  Created by M Ridhwan M Sari on 6/11/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "ShopClass.h"

@implementation ShopClass

static ShopClass *_sharedInstance = nil;
+(ShopClass*)sharedInstance{
    if (!_sharedInstance) {
        _sharedInstance = [[ShopClass alloc] init];
    }
    return _sharedInstance;
}

- (UIView*)priceViewFor:(NSString*)normalPrice and:(NSString*)discountPrice {
    
    UIView *priceView = [[UIView alloc] init];
    UIView *discountView = [[UIView alloc] init];
    UIView *normalView = [[UIView alloc] init];
    [priceView setBackgroundColor:[UIColor whiteColor]];
    CGFloat norWidthSize, widthSize=0;
    
    UILabel *normalRmLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 17, 10)];
    [normalRmLabel setText:@"RM"];
    [normalRmLabel setTextColor:[UIColor colorWithHex:@"#D71C43"]];
    [normalRmLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [normalRmLabel setTextAlignment:UITextAlignmentRight];
    norWidthSize = normalRmLabel.frame.size.width;
    
    NSString *prc = [[normalPrice componentsSeparatedByString:@"."] objectAtIndex:0];
    UILabel *normalPrLabel = [[UILabel alloc] initWithFrame:CGRectMake(norWidthSize, 0, 30, 13)];
    CGSize expectedNorSize  = [prc sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(FLT_MAX, normalPrLabel.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
    CGRect newNorFrame = normalPrLabel.frame;
    newNorFrame.size.width = expectedNorSize.width;
    [normalPrLabel setTextColor:[UIColor colorWithHex:@"#D71C43"]];
    [normalPrLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [normalPrLabel setFrame:newNorFrame];
    [normalPrLabel setText:prc];
    norWidthSize += newNorFrame.size.width;
    
    NSString *sen = [NSString stringWithFormat:@".%@",[[normalPrice componentsSeparatedByString:@"."] objectAtIndex:1]];
    UILabel *normalSenLabel = [[UILabel alloc] initWithFrame:CGRectMake(norWidthSize, 0, 17, 10)];
    if (![sen isEqualToString:@".00"]) {
        [normalSenLabel setText:sen];
        [normalSenLabel setTextColor:[UIColor colorWithHex:@"#D71C43"]];
        [normalSenLabel setFont:[UIFont boldSystemFontOfSize:10]];
        norWidthSize += normalSenLabel.frame.size.width;
        [normalView addSubview:normalSenLabel];
    }
    
    if (![discountPrice isEqualToString:normalPrice]) {
        [normalRmLabel setTextColor:[UIColor blackColor]];
        [normalPrLabel setTextColor:[UIColor blackColor]];
        [normalSenLabel setTextColor:[UIColor blackColor]];
    }
    [normalView setFrame:CGRectMake(0, 0, norWidthSize, 20)];
    [normalView addSubview:normalRmLabel];
    [normalView addSubview:normalPrLabel];
    [normalRmLabel release];
    [normalPrLabel release];
    [normalSenLabel release];
    [priceView addSubview:normalView];
    [normalView release];
    
    if (![discountPrice isEqualToString:normalPrice]) {
        
        CGFloat discWidthSize;
        
        UILabel *discountRmLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 17, 10)];
        [discountRmLabel setText:@"RM"];
        [discountRmLabel setTextColor:[UIColor colorWithHex:@"#D71C43"]];
        [discountRmLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [discountRmLabel setTextAlignment:UITextAlignmentRight];
        discWidthSize = discountRmLabel.frame.size.width;
        
        NSString *disc = [[discountPrice componentsSeparatedByString:@"."] objectAtIndex:0];
        UILabel *discountPrLabel = [[UILabel alloc] initWithFrame:CGRectMake(discWidthSize, 0, 30, 13)];
        CGSize expectedLabelSize  = [disc sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(FLT_MAX, discountPrLabel.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
        CGRect newFrame = discountPrLabel.frame;
        newFrame.size.width = expectedLabelSize.width;
        [discountPrLabel setTextColor:[UIColor colorWithHex:@"#D71C43"]];
        [discountPrLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [discountPrLabel setFrame:newFrame];
        [discountPrLabel setText:disc];
        discWidthSize += newFrame.size.width;
        
        NSString *sen = [NSString stringWithFormat:@".%@",[[discountPrice componentsSeparatedByString:@"."] objectAtIndex:1]];
        UILabel *discountSenLabel = [[UILabel alloc] initWithFrame:CGRectMake(discWidthSize, 0, 17, 10)];
        if (![sen isEqualToString:@".00"]) {
            [discountSenLabel setText:sen];
            [discountSenLabel setTextColor:[UIColor colorWithHex:@"#D71C43"]];
            [discountSenLabel setFont:[UIFont boldSystemFontOfSize:10]];
            discWidthSize += discountSenLabel.frame.size.width;
            [discountView addSubview:discountSenLabel];
        }
        widthSize += discWidthSize+3;
        [discountView setFrame:CGRectMake(norWidthSize+3, 0, discWidthSize, 20)];
        [discountView addSubview:discountRmLabel];
        [discountView addSubview:discountPrLabel];
        [discountRmLabel release];
        [discountPrLabel release];
        [discountSenLabel release];
        [priceView addSubview:discountView];
        [discountView release];
        
        UILabel *redLine = [[UILabel alloc] initWithFrame:CGRectMake(1, normalView.frame.size.height/2-4, normalView.frame.size.width-1, 2)];
        [redLine setBackgroundColor:[UIColor colorWithHex:@"#D71C43"]];
        [normalView addSubview:redLine];
        [redLine release];
    }
    widthSize += norWidthSize;
    [priceView setFrame:CGRectMake(0,0, widthSize, 20)];
    return priceView;
}

@end
