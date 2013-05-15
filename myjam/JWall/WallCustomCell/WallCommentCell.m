//
//  WallCommentCell.m
//  myjam
//
//  Created by Mohd Hafiz on 5/15/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "WallCommentCell.h"

@implementation WallCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_username release];
    [_thumbImageView release];
    [_statusLabel release];
    [_commentLabel release];
    [super dealloc];
}
@end
