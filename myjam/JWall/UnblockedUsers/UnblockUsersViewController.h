//
//  UnblockUsersViewController.h
//  myjam
//
//  Created by Mohd Hafiz on 4/1/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnblockUsersViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
    BOOL searching;
    BOOL selectRowEnabled;
    NSMutableArray *copyListOfData;
    NSMutableArray *tableData;
    NSMutableDictionary *listBuddy;
}
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (retain, nonatomic) IBOutlet UILabel *noRecordLabel;
@property (retain, nonatomic) IBOutlet UILabel *recordLabel;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UIButton *unblockButton;


@end
