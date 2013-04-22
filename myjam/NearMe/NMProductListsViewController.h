//
//  NMProductListsViewController.h
//  myjam
//
//  Created by ME-Tech Mac User 2 on 2/28/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "PullRefreshTableViewController.h"
#import "UIImage-Extensions.h"
#import <MapKit/MapKit.h>
#import "MarqueeLabel.h"
#import "ASIWrapper.h"
#import "JSONKit.h"

#define kListPerpage        5
#define kTableCellHeight    125
#define kExtraCellHeight    54

@interface NMProductListsViewController : PullRefreshTableViewController<ASIHTTPRequestDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate>
{
    NSString *responseData;
    int kDisplayPerscreen;
}

@property BOOL refreshDisabled;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,retain) NSMutableArray *tableData;
@property (retain, nonatomic) NSString *selectedCategories;
@property (retain, nonatomic) NSString *searchedText;
@property (retain, nonatomic) NSString *sortData;

@property (nonatomic) double currentLat;
@property (nonatomic) double currentLong;
@property (nonatomic) NSInteger withRadius;

- (void) refreshTableItemsWithFilter:(NSString *)str andSearchedText:(NSString *)pattern andSortBy:(NSString *)sort;

@end