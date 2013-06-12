//
//  CheckoutPopupView.h
//  myjam
//
//  Created by M Ridhwan M Sari on 6/6/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CheckoutPopupViewDelegate;

@interface CheckoutPopupView : UIView<UITableViewDataSource,UITableViewDelegate>
{
    
}

@property (nonatomic, retain) id<CheckoutPopupViewDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIButton *yesButton;
@property (nonatomic, retain) IBOutlet UIButton *noButton;
@property (nonatomic, retain) IBOutlet UIView *seedView;
@property (nonatomic, retain) IBOutlet UILabel *seedLabel;

- (id)initWithDataList:(NSInteger)data andTag:(NSInteger)tag;

@end

@protocol CheckoutPopupViewDelegate

- (void)popView:(CheckoutPopupView *)popupView didSelectOptionAtIndex:(NSInteger)index;

@end
