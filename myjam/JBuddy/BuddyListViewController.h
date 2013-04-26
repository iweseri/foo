//
//  ChatListViewController.h
//  myjam
//
//  Created by Mohd Hafiz on 3/29/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuddyCell.h"

@interface BuddyListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    BOOL searching;
    BOOL selectRowEnabled;
    NSMutableArray *copyListOfItems;
}

@property (nonatomic,retain) NSMutableArray *tableData;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UILabel *recordLabel;
@property BOOL fromPlusButton;


@end
