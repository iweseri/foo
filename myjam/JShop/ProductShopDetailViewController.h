//
//  ProductShopDetailViewController.h
//  myjam
//
//  Created by M Ridhwan M Sari on 6/7/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "ShopDetailViewController.h"
#import "HeaderProductCell.h"
#import "ProductCell.h"
#import "ShopLoadingCell.h"
#import "AppDelegate.h"
#import "ASIWrapper.h"

@interface ProductShopDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    int pageCounter;
    int rows;
    int kDisplayPerScreen;
    NSString *catName;
}
@property (nonatomic, retain) NSMutableArray *productData;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSString *catId;
@property (nonatomic, retain) NSString *shopId;
@property (nonatomic, retain) NSString *shopName;

@property (nonatomic, retain) IBOutlet UILabel *shopTitleLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end
