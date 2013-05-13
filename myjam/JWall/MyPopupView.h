//
//  MyPopupView.h
//  myjam
//
//  Created by Mohd Hafiz on 5/13/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyPopupViewDelegate;

@interface MyPopupView : UIView

@property (nonatomic, retain) id<MyPopupViewDelegate> delegate;

- (id)initWithDataList:(NSArray *)list andTag:(NSInteger)tag;

@end

@protocol MyPopupViewDelegate

- (void)popView:(MyPopupView *)popupView didSelectOptionAtIndex:(NSInteger)index;

@end
