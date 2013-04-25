//
//  AddBuddyViewController.h
//  myjam
//
//  Created by Mohd Hafiz on 4/1/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddBuddyViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *tableData;
}
@property (retain, nonatomic) IBOutlet UITextField *searchTextField;
@property (retain, nonatomic) IBOutlet UIView *searchButtonView;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIView *fbPhoneSearchView;
@property (retain, nonatomic) IBOutlet UIButton *phonebookButton;
@property (retain, nonatomic) IBOutlet UIButton *fbButton;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (retain, nonatomic) IBOutlet UILabel *noRecordLabel;

@end
