//
//  PostTaggedCell.m
//  myjam
//
//  Created by Mohd Hafiz on 5/23/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "PostTaggedCell.h"

@implementation PostTaggedCell

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

- (void)dealloc {
    [_taggedLabel release];
    [super dealloc];
}
@end
