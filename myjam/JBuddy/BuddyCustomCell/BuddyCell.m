//
//  BuddyCell.m
//  myjam
//
//  Created by Mohd Hafiz on 3/29/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "BuddyCell.h"

@implementation BuddyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
    [_userImageView release];
    [_usernameLabel release];
    [_statusLabel release];
    [_timeLabel release];
    [_dateLabel release];
    [_approveButtonsView release];
    [_noButton release];
    [_yesButton release];
    [_loadingIndicator release];
    [_addButtton release];
    [super dealloc];
}
@end
