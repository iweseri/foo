//
//  PostFooterView.m
//  myjam
//
//  Created by Mohd Hafiz on 5/9/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "PostFooterView.h"

@implementation PostFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *nibs =  [[NSBundle mainBundle] loadNibNamed:@"PostFooterView" owner:self options:nil];
        
        self = (PostFooterView *)[nibs objectAtIndex:0];
    }
    return self;
}

- (void)setupWithFav:(NSString *)fav andComment:(NSString *)comment
{
    // Initialization code
    
    CGFloat totalWidth = 0;
    
    CGFloat favLabelWidth = [fav sizeWithFont:[UIFont boldSystemFontOfSize:14 ]].width;
    self.favouriteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, favLabelWidth, self.countingHolderView.frame.size.height)];
    [self.favouriteLabel setBackgroundColor:[UIColor clearColor]];
    [self.favouriteLabel setTextColor:[UIColor colorWithHex:@"#D22042"]];
    [self.favouriteLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [self.favouriteLabel setText:fav];
    [self.countingHolderView addSubview:self.favouriteLabel];
    [self.favouriteLabel release];
    
    totalWidth += self.favouriteLabel.frame.size.width + 10;
    
    UILabel *dotLabel = [[UILabel alloc] initWithFrame:CGRectMake(totalWidth, -6, 14, self.countingHolderView.frame.size.height)];
    [dotLabel setBackgroundColor:[UIColor clearColor]];
    [dotLabel setTextColor:[UIColor blackColor]];
    [dotLabel setFont:[UIFont boldSystemFontOfSize:30]];
    [dotLabel setText:@"."];
    [dotLabel setTextAlignment:NSTextAlignmentCenter];
    [self.countingHolderView addSubview:dotLabel];
    [dotLabel release];
    
    totalWidth += dotLabel.frame.size.width + 10;
    
    CGFloat commentLabelWidth = [comment sizeWithFont:[UIFont boldSystemFontOfSize:14 ]].width;
    self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(totalWidth, 0, commentLabelWidth, self.countingHolderView.frame.size.height)];
    [self.commentLabel setBackgroundColor:[UIColor clearColor]];
    [self.commentLabel setTextColor:[UIColor colorWithHex:@"#D22042"]];
    [self.commentLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [self.commentLabel setText:comment];
    [self.countingHolderView addSubview:self.commentLabel];
    [self.commentLabel release];
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
    [_countingHolderView release];
    [_favoriteButton release];
    [_commentButton release];
    [super dealloc];
}
@end
