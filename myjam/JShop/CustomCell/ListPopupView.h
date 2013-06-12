//
//  ListPopupView.h
//  myjam
//
//  Created by M Ridhwan M Sari on 6/6/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ListPopupViewDelegate;

@interface ListPopupView : UIView<UITableViewDataSource,UITableViewDelegate>
{
    
}

@property (nonatomic, retain) id<ListPopupViewDelegate> delegate;
@property (nonatomic, retain) NSArray *listing;

- (id)initWithDataList:(NSArray *)list andTag:(NSInteger)tag;

@end

@protocol ListPopupViewDelegate

- (void)popView:(ListPopupView *)popupView didSelectOptionAtIndex:(NSInteger)index;

@end
