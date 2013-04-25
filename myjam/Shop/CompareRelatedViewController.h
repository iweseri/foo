//
//  CompareRelatedViewController.h
//  myjam
//
//  Created by Azad Johari on 2/13/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "ProductTableViewCellwoCat.h"
#import "DetailProductViewController.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "CustomHeaderCell.h"
//#import "CustomTableHeader.h"
//#import "ShopHeaderViewCell.h"
//#import "ShopInfoButtonCell.h"

@interface CompareRelatedViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *productAllArray;
@property (strong, nonatomic) NSMutableArray *productArray;
@property (retain, nonatomic) NSDictionary *shopInfo;
@property (strong, nonatomic) NSString *catName;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end
