//
//  StarBuyViewController.h
//  myjam
//
//  Created by M Ridhwan M Sari on 5/27/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "ShopDetailViewController.h"
#import "ProductWithHeaderCell.h"
#import "ShopLoadingCell.h"
#import "AppDelegate.h"
#import "ASIWrapper.h"

@interface StarBuyViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    int pageCounter;
    int rows;
    int kDisplayPerScreen;
    NSString *message;
}
@property (nonatomic, retain) NSMutableArray *productData;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end
