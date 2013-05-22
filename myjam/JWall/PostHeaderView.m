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
        
        [self.optionButton addTarget:self action:@selector(onClickOptionButton:) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

- (void)onClickOptionButton:(UIButton *)sender
{
    [self.delegate tableHeaderView:self didClickOptionButton:sender];
}

-(void)setBoldText:(NSString *)prefix withFullText:(NSString *)text andTime:(NSString *)timeText{
    
    CGSize  textSize = {self.textPostView.frame.size.width, self.textPostView.frame.size.height };
    CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:16]
                   constrainedToSize:textSize
                       lineBreakMode:UILineBreakModeWordWrap];
    
    CATextLayer *_textLayer = [[CATextLayer alloc] init];
    //_textLayer.font = [UIFont boldSystemFontOfSize:13].fontName; // not needed since `string` property will be an NSAttributedString
    _textLayer.backgroundColor = [UIColor clearColor].CGColor;
    _textLayer.wrapped = NO;

    CALayer *layer = self.textPostView.layer; //self is a view controller contained by a uiview
    _textLayer.frame = CGRectMake(0, 0, size.width, size.height);
    _textLayer.contentsScale = [[UIScreen mainScreen] scale]; // looks nice in retina displays too :)
    _textLayer.alignmentMode = kCAAlignmentLeft;
//    _textLayer.truncationMode = kCATruncationEnd;
    _textLayer.wrapped = YES;
//    _textLayer.backgroundColor = [[UIColor yellowColor] CGColor];
    [layer addSublayer:_textLayer];
//    }
    
    /* Create the attributes (for the attributed string) */
    CGFloat fontSize = 16;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    CTFontRef ctBoldFont = CTFontCreateWithName((CFStringRef)boldFont.fontName, boldFont.pointSize, NULL);
    UIFont *font = [UIFont systemFontOfSize:14];
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    CGColorRef cgColor = [UIColor blackColor].CGColor;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (id)ctBoldFont, (id)kCTFontAttributeName,
                                cgColor, (id)kCTForegroundColorAttributeName, nil];
    CFRelease(ctBoldFont);
    NSDictionary *subAttributes = [NSDictionary dictionaryWithObjectsAndKeys:(id)ctFont, (id)kCTFontAttributeName, nil];
    CFRelease(ctFont);
    
    /* Create the attributed string (text + attributes) */
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    [attrStr addAttributes:subAttributes range:NSMakeRange(prefix.length, text.length-prefix.length)];
    
    /* Set the attributes string in the text layer :) */
    _textLayer.string = attrStr;
    [attrStr release];
    
    _textLayer.opacity = 1.0;
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.textPostView.bounds.origin.x, self.textPostView.bounds.origin.y+size.height+2, self.textPostView.frame.size.width, 20)];
    [timeLabel setTextColor:[UIColor darkGrayColor]];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [self.textPostView addSubview:timeLabel];
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
    [super dealloc];
}
@end
