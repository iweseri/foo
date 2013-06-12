//
//  FilterProductViewController.h
//  myjam
//
//  Created by M Ridhwan M Sari on 5/27/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListPopupView.h"
#import <SDWebImage/UIButton+WebCache.h>

@interface FilterProductViewController : UITableViewController<ListPopupViewDelegate>
{
    int rows;
    NSMutableArray *listOption;
    NSString *titleOption;
    NSString *showAllId;
    BOOL list;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIView *listView;
@property (nonatomic, retain) IBOutlet UIView *footerView;
@property (nonatomic, retain) NSMutableArray *tableData;
@property (nonatomic, retain) NSMutableArray *categoryData;
@property (nonatomic, retain) IBOutlet UILabel *catTitleLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, retain) IBOutlet UIButton *selectButton;
@property (nonatomic, retain) NSString *catTitle;
@property (nonatomic, retain) NSString *catId;

@end
