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
        
        // load nib
        self = (PostFooterView *)[nibs objectAtIndex:0];
        [self.favoriteButton addTarget:self action:@selector(onClickFavouriteButton) forControlEvents:UIControlEventTouchDown];
        [self.commentButton addTarget:self action:@selector(onClickCommentButton) forControlEvents:UIControlEventTouchDown];
        [self.bottomLineView setBackgroundColor:[UIColor colorWithHex:@"#c8c8c8"]];
        
        // add fav label
        self.favouriteLabel = [[UILabel alloc] init];
        [self.countingHolderView addSubview:self.favouriteLabel];
        [self.favouriteLabel setBackgroundColor:[UIColor clearColor]];
        [self.favouriteLabel setTextColor:[UIColor colorWithHex:@"#D22042"]];
        [self.favouriteLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [self.favouriteLabel setTag:0];
        
        // add dot label
        dotLabel = [[UILabel alloc] init];
        [dotLabel setBackgroundColor:[UIColor clearColor]];
        [dotLabel setTextColor:[UIColor blackColor]];
        [dotLabel setFont:[UIFont boldSystemFontOfSize:30]];
        [dotLabel setText:@"."];
        [dotLabel setTextAlignment:NSTextAlignmentCenter];
        [self.countingHolderView addSubview:dotLabel];
        [dotLabel release];
        
        // add comment label
        self.commentLabel = [[UILabel alloc] init];
        [self.commentLabel setBackgroundColor:[UIColor clearColor]];
        [self.commentLabel setTextColor:[UIColor colorWithHex:@"#D22042"]];
        [self.commentLabel setFont:[UIFont boldSystemFontOfSize:14]];        [self.commentLabel setTag:1];
        [self.countingHolderView addSubview:self.commentLabel];
        
        self.commentLabel.userInteractionEnabled = YES;
        self.favouriteLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openDetailsPost:)];
        [self.favouriteLabel addGestureRecognizer:tapGesture];
        [tapGesture release];
        
        UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openDetailsPost:)];
        [self.commentLabel addGestureRecognizer:tapGesture2];
        [tapGesture2 release];
        
        
        [self.favouriteLabel release];
        [self.commentLabel release];
    }
    return self;
}

- (void)setupWithFav:(NSString *)fav andComment:(NSString *)comment
{
    // Initialization code
    if ([fav length] > 0 && [comment length] > 0) {
        aFav = fav;
        aComment = comment;
    }else if ([fav length] == 0){
        fav = aFav;
    }else if ([comment length] == 0){
        comment = aComment;
    }
    
    CGFloat totalWidth = 0;
    
    CGFloat favLabelWidth = [fav sizeWithFont:[UIFont boldSystemFontOfSize:14 ]].width;
    self.favouriteLabel.frame = CGRectMake(0, 0, favLabelWidth, self.countingHolderView.frame.size.height);
    [self.favouriteLabel setText:fav];
    
    totalWidth += self.favouriteLabel.frame.size.width + 10;
    
    dotLabel.frame = CGRectMake(totalWidth, -6, 14, self.countingHolderView.frame.size.height);
    
    totalWidth += dotLabel.frame.size.width + 10;
    
    CGFloat commentLabelWidth = [comment sizeWithFont:[UIFont boldSystemFontOfSize:14 ]].width;
    self.commentLabel.frame = CGRectMake(totalWidth, 0, commentLabelWidth, self.countingHolderView.frame.size.height);
    [self.commentLabel setText:comment];

}

- (void)onClickFavouriteButton
{
    [self.delegate tableFooter:self didClickedFavouriteAtIndex:self.tag];
}

- (void)onClickCommentButton
{
    [self.delegate tableFooter:self didClickedCommentAtIndex:self.tag];
}
- (void)openDetailsPost:(UITapGestureRecognizer *)sender
{
    if (sender.view.tag == 1) {
        [self.delegate tableFooter:self didClickedCommentLinkAtIndex:self.tag];
    }else{
        [self.delegate tableFooter:self didClickedFavouriteLinkAtIndex:self.tag];
    }
}

- (void)dealloc {
    [_countingHolderView release];
    [_favoriteButton release];
    [_commentButton release];
    [_bottomLineView release];
    [_loadingIndicator release];
    [_deleteButton release];
    [super dealloc];
}
@end
