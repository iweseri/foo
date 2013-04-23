//
//  ShopLoadingCell.m
//  myjam
//
//  Created by Mohd Hafiz on 4/23/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "ShopLoadingCell.h"

@implementation ShopLoadingCell

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
    [_label release];
    [_loadingIndicator release];
    [super dealloc];
}
@end
