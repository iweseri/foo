//
//  BuddyGroupCell.h
//  myjam
//
//  Created by Mohd Hafiz on 3/29/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuddyGroupCell : UITableViewCell

@property (nonatomic,retain) NSString *buddyUserId;
@property (retain, nonatomic) IBOutlet UIImageView *userImageView;
@property (retain, nonatomic) IBOutlet UILabel *usernameLabel;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UIView *approveButtonsView;
@property (retain, nonatomic) IBOutlet UIButton *noButton;
@property (retain, nonatomic) IBOutlet UIButton *yesButton;
@property (retain, nonatomic) IBOutlet UIButton *addGroupButton;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end