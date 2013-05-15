//
//  PostFooterView.h
//  myjam
//
//  Created by Mohd Hafiz on 5/9/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostFooterDelegate;

@interface PostFooterView : UIView

@property (retain, nonatomic) IBOutlet UIView *countingHolderView;
@property (retain, nonatomic) IBOutlet UIButton *favoriteButton;
@property (retain, nonatomic) IBOutlet UIButton *commentButton;
@property (retain, nonatomic) UILabel *favouriteLabel;
@property (retain, nonatomic) UILabel *commentLabel;
@property (retain, nonatomic) id<PostFooterDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIView *bottomLineView;

- (void)setupWithFav:(NSString *)fav andComment:(NSString *)comment;

@end

@protocol PostFooterDelegate

- (void)tableFooter:(PostFooterView *)footerView didClickedCommentAtIndex:(NSInteger)index;
- (void)tableFooter:(PostFooterView *)footerView didClickedFavouriteAtIndex:(NSInteger)index;
- (void)tableFooter:(PostFooterView *)footerView didClickedCommentLinkAtIndex:(NSInteger)index;
- (void)tableFooter:(PostFooterView *)footerView didClickedFavouriteLinkAtIndex:(NSInteger)index;

@end