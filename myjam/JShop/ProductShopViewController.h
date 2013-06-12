//
//  ProductShopViewController.h
//  myjam
//
//  Created by ME-Tech Mac User 2 on 5/23/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJModel.h"
#import "AppDelegate.h"
#import "ShopLoadingCell.h"
#import "ProductWithHeaderCell.h"
#import "ShopDetailViewController.h"
#import <SDWebImage/UIButton+WebCache.h>

@interface ProductShopViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    int pageCounter;
    int rows;
    int kDisplayPerScreen;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *productShopData;
@property (nonatomic, retain) NSString *shopId;
@property (nonatomic, retain) NSString *shopName;

@property (nonatomic, retain) IBOutlet UILabel *shopTitleLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end
