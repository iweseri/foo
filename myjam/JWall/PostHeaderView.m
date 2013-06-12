//
//  PostHeaderView.m
//  myjam
//
//  Created by Mohd Hafiz on 5/9/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "PostHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>


@implementation PostHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"PostHeaderView" owner:self options:nil];
        self = [nibs objectAtIndex:0];
        
        CGRect labelFrame = CGRectMake(0, 0, self.textPostView.frame.size.width-10, self.textPostView.frame.size.height-25);
        
        postLabel = [[TTTAttributedLabel alloc] initWithFrame:labelFrame];
        postLabel.font = [UIFont systemFontOfSize:14];
        postLabel.backgroundColor = [UIColor clearColor];
        postLabel.numberOfLines = 3;
        [self.textPostView addSubview:postLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.textPostView addSubview:timeLabel];
        [self.optionButton addTarget:self action:@selector(onClickOptionButton:) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

- (void)onClickOptionButton:(UIButton *)sender
{
    [self.delegate tableHeaderView:self didClickOptionButton:sender];
}

-(void)setBoldText:(NSString *)prefix withFullText:(NSString *)text boldPostfix:(NSString *)postfix andTime:(NSString *)timeText{
    
//    prefix = [NSString stringWithFormat:@"%@ ", prefix];
    
    [postLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:prefix options:NSCaseInsensitiveSearch];
        
        NSRange boldRange2;
        if ([postfix length]) {
//            boldRange2 = [[mutableAttributedString string] rangeOfString:postfix options:NSCaseInsensitiveSearch];
            boldRange2 = [[mutableAttributedString string] rangeOfString:postfix options:NSCaseInsensitiveSearch range:NSMakeRange([prefix length], [text length]-[prefix length])];
        }
        
        
        UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:14];
        CTFontRef font = CTFontCreateWithName((CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)font range:boldRange];
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor colorWithHex:@"#D22042"].CGColor range:boldRange];
            
            if ([postfix length]) {
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)font range:boldRange2];
                [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor colorWithHex:@"#D22042"].CGColor range:boldRange2];
            }

            CFRelease(font);
        }
        
        return mutableAttributedString;
    }];
    
    
    [postLabel sizeToFit];
    
    timeLabel.frame = CGRectMake(0, postLabel.frame.size.height+2, self.textPostView.frame.size.width-10, 21);

    [timeLabel setTextColor:[UIColor darkGrayColor]];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setFont:[UIFont systemFontOfSize:11]];
    [timeLabel setText:timeText];
    [timeLabel release];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_optionButton release];
    [_qrcodeImageView release];
    [super dealloc];
}
@end
