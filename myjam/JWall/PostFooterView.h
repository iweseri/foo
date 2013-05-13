//
//  PostFooterView.h
//  myjam
//
//  Created by Mohd Hafiz on 5/9/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostFooterView : UIView
@property (retain, nonatomic) IBOutlet UIView *countingHolderView;
@property (retain, nonatomic) IBOutlet UIButton *favoriteButton;
@property (retain, nonatomic) IBOutlet UIButton *commentButton;
@property (retain, nonatomic) UILabel *favouriteLabel;
@property (retain, nonatomic) UILabel *commentLabel;

- (void)setupWithFav:(NSString *)fav andComment:(NSString *)comment;

@end
