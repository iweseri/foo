//
//  SMMessageViewTableCell.m
//  JabberClient
//
//  Created by cesarerocchi on 9/8/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import "SMMessageViewTableCell.h"


@implementation SMMessageViewTableCell

@synthesize senderAndTimeLabel, messageContentView, bgImageView, notifyDesc;

- (void)dealloc {
	
	[senderAndTimeLabel release];
	[messageContentView release];
	[bgImageView release];
    [notifyDesc release];
    [super dealloc];
	
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

//		senderAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 70, 36)];
        senderAndTimeLabel = [[UILabel alloc] init];// initWithFrame:CGRectMake(250, 5, 70, 36)];
		senderAndTimeLabel.font = [UIFont systemFontOfSize:11.0];
		senderAndTimeLabel.textColor = [UIColor darkGrayColor];
        [senderAndTimeLabel setBackgroundColor:[UIColor clearColor]];
        [senderAndTimeLabel setNumberOfLines:2];
		[self.contentView addSubview:senderAndTimeLabel];
		
		bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:bgImageView];
		
		messageContentView = [[UITextView alloc] init];
		messageContentView.backgroundColor = [UIColor clearColor];
		messageContentView.editable = NO;
		messageContentView.scrollEnabled = NO;
		[messageContentView sizeToFit];
		[self.contentView addSubview:messageContentView];
        
        notifyDesc = [[UILabel alloc] init];
		notifyDesc.font = [UIFont systemFontOfSize:11.0];
		notifyDesc.textColor = [UIColor darkGrayColor];
        [notifyDesc setBackgroundColor:[UIColor clearColor]];
        [notifyDesc setNumberOfLines:1];
		[self.contentView addSubview:notifyDesc];
    }
	
    return self;
	
}








@end
