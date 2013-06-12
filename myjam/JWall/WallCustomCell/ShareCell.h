//
//  ShareCell.h
//  myjam
//
//  Created by Mohd Hafiz on 6/7/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ShareCell : UITableViewCell
{
    TTTAttributedLabel *postLabel;
    UILabel *timeLabel;
    UILabel *postTextLabel;
    IBOutlet UIImageView *avatar;
    IBOutlet UIView *innerView;
    IBOutlet UIImageView *postImageView;
}

//@property (nonatomic, retain) TTTAttributedLabel *postLabel;

- (void)setupCell:(NSDictionary *)data;
- (void)setBoldText:(NSString *)prefix withFullText:(NSString *)text boldPostfix:(NSString *)postfix andTime:(NSString *)timeText;
@end
