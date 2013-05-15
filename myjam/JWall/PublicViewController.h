//
//  PublicViewController.h
//  myjam
//
//  Created by Mohd Hafiz on 5/9/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostFooterView.h"
#import "PostHeaderView.h"
#import "PostTextCell.h"
#import "MyPopupView.h"

@interface PublicViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, PostHeaderViewDelegate, PostFooterDelegate , MyPopupViewDelegate>
{
    NSMutableArray *tableData;
    NSArray *options;
    int pageCounter;
    BOOL isLastPage;
}
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (retain, nonatomic) IBOutlet UILabel *loadingLabel;

@end
