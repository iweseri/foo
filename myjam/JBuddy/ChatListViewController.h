//
//  ChatListViewController.h
//  myjam
//
//  Created by Mohd Hafiz on 3/29/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,retain) NSMutableArray *tableData;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UILabel *recordLabel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (retain, nonatomic) IBOutlet UILabel *loadingLabel;

@end
