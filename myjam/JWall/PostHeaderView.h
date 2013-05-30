//
//  PostHeaderView.h
//  myjam
//
//  Created by Mohd Hafiz on 5/9/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostHeaderViewDelegate;

@interface PostHeaderView : UIView

@property (retain, nonatomic) IBOutlet UIView *textPostView;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UIButton *optionButton;
@property (strong, nonatomic) id<PostHeaderViewDelegate>delegate;
@property (retain, nonatomic) IBOutlet UIImageView *qrcodeImageView;

//- (void)initView;
- (void)setBoldText:(NSString *)prefix withFullText:(NSString *)text andTime:(NSString *)timeText;
@end

@protocol PostHeaderViewDelegate
- (void)tableHeaderView:(PostHeaderView *)headerView didClickOptionButton:(UIButton *)button;
@end