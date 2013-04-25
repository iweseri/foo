//
//  ChatViewController.h
//  myjam
//
//  Created by Mohd Hafiz on 4/4/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@interface ChatViewController : UIViewController<HPGrowingTextViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    HPGrowingTextView *textView;
    CGFloat tableHeight;
}
@property (retain, nonatomic) IBOutlet UILabel *usernameLabel;
@property (retain, nonatomic) NSMutableArray *tableData;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UITextField *chatTextField;
@property (retain, nonatomic) UIView *sendMsgView;
@property (retain, nonatomic) NSString *buddyUserId;
@property (retain, nonatomic) NSString *buddyUsername;
@property (retain, nonatomic) IBOutlet UIView *usernameView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *sendMsgIndicator;

- (id)initWithBuddyId:(NSString *)bid andUsername:(NSString *)username;

@end
