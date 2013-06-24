//
//  AllProductDetailViewController.h
//  myjam
//
//  Created by M Ridhwan M Sari on 6/4/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "ShopDetailViewController.h"
#import "ProductWithHeaderCell.h"
#import "ShopLoadingCell.h"
#import "AppDelegate.h"
#import "ASIWrapper.h"

@interface AllProductDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    int pageCounter;
    int rows;
    int kDisplayPerScreen;
    NSString *message;
}
@property (nonatomic, retain) NSMutableArray *productData;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic) NSInteger catId;
@property (nonatomic, retain) NSString *catName;

- (id)initWithCatId:(NSInteger)cat_id;

@end
