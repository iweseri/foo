//
//  SMMessageViewTableCell.h
//  JabberClient
//
//  Created by cesarerocchi on 9/8/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SMMessageViewTableCell : UITableViewCell {

	UILabel	*senderAndTimeLabel;
	UITextView *messageContentView;
	UIImageView *bgImageView;
	UILabel *notifyDesc;
    UILabel *dateDesc;
}

@property (nonatomic,assign) UILabel *senderAndTimeLabel;
@property (nonatomic,assign) UILabel *notifyDesc;
@property (nonatomic,assign) UILabel *dateDesc;
@property (nonatomic,assign) UITextView *messageContentView;
@property (nonatomic,assign) UIImageView *bgImageView;

@end
