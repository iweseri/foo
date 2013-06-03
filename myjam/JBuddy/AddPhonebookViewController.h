//
//  AddBuddyViewController.h
//  myjam
//
//  Created by Mohd Hafiz on 4/1/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddPhonebookViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
    BOOL searching;
    BOOL selectRowEnabled;
    NSMutableArray *copyListOfJoin;
    NSMutableArray *copyListOfInvite;
    NSMutableArray *joinTableData;
    NSMutableArray *inviteTableData;
    NSString *tmpData;
}
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (retain, nonatomic) IBOutlet UILabel *noRecordLabel;
@property (retain, nonatomic) IBOutlet UILabel *recordLabel;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;


@end
