//
//  EditGroupViewController.h
//  myjam
//
//  Created by Mohd Hafiz on 3/29/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "BuddyGroupCell.h"

@class TPKeyboardAvoidingScrollView;

@interface EditGroupViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, UISearchBarDelegate, UIAlertViewDelegate>
{
    BOOL searching;
    BOOL selectRowEnabled;
    NSMutableArray *copyListOfItems;
}
@property (retain, nonatomic) TPKeyboardAvoidingScrollView *scroller;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic,retain) NSMutableArray *tableData;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UILabel *recordLabel;
@property (retain, nonatomic) IBOutlet UIButton *groupButton;
@property (retain, nonatomic) NSMutableDictionary *groupArray;
@property (retain, nonatomic) NSString *groupId;
@property (retain, nonatomic) NSString *groupName;
@property BOOL fromPlusButton;

- (IBAction)groupChat:(id)sender;
- (id)initWithGroupId:(NSString*)group_id nGroupNameIs:(NSString*)group_name;

@end