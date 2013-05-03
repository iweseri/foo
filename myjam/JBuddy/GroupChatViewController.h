//
//  GroupChatViewController.h
//  myjam
//
//  Created by Mohd Hafiz on 4/4/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@interface GroupChatViewController : UIViewController<HPGrowingTextViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    HPGrowingTextView *textView;
    CGFloat tableHeight;
}
@property (retain, nonatomic) IBOutlet UILabel *usernameLabel;
@property (retain, nonatomic) NSMutableArray *tableData;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UITextField *chatTextField;
@property (retain, nonatomic) UIView *sendMsgView;
@property (retain, nonatomic) NSString *buddyGroupId;
@property (retain, nonatomic) NSString *buddyGroupname;
@property (retain, nonatomic) IBOutlet UIView *usernameView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *sendMsgIndicator;

- (id)initWithGroupId:(NSString *)gid andGroupname:(NSString *)groupname;
- (IBAction)editGroup:(id)sender;
@end
