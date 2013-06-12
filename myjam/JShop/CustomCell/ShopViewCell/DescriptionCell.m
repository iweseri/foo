//
//  DescriptionCell.m
//  myjam
//
//  Created by M Ridhwan M Sari on 5/29/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "DescriptionCell.h"

@implementation DescriptionCell

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
    //infoCell
    [_descLabel release];
    [_shopLabel release];
    [_catLabel release];
    [_shopLogo release];
    //readmoreCell
    [_readMoreLabel release];
    //headerrowCell
    [_headerRowLabel release];
    [_colorHeaderRow release];
    //rowCell
    [_rowInfoTextView release];
    //promotionCell
    [_colorLabel1 release];
    [_colorLabel2 release];
    [_shopPLabel1 release];
    [_shopPLabel2 release];
    [_titlePLabel1 release];
    [_titlePLabel2 release];
    [_datePLabel1 release];
    [_datePLabel2 release];
    [_descPLabel1 release];
    [_descPLabel2 release];
    [_catPLabel1 release];
    [_catPLabel2 release];
    [_pImage1 release];
    [_pImage2 release];
    //productCell
    [_productImage1 release];
    [_productImage2 release];
    [_shopLabel1 release];
    [_shopLabel2 release];
    [_proLabel1 release];
    [_proLabel2 release];
    [_visitShopButton release];
    //shareCell
    [_shareEmailButton release];
    [_shareFBButton release];
    [_shareTwitterButton release];
    [super dealloc];
}

@end
