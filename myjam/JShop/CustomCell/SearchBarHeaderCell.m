//
//  SearchBarHeaderCell.m
//  myjam
//
//  Created by M Ridhwan M Sari on 5/26/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "SearchBarHeaderCell.h"

@implementation SearchBarHeaderCell

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

    // Configure the view for the selected state
}

- (void)dealloc
{
    [_titleLabel release];
    [super dealloc];
}

@end
