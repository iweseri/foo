//
//  WallCommentCell.h
//  myjam
//
//  Created by Mohd Hafiz on 5/15/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WallCommentCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *username;
@property (retain, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UILabel *commentLabel;

@end
