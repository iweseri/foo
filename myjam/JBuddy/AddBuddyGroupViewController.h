//
//  AddBuddyGroupViewController.h
//  myjam
//
//  Created by Mohd Hafiz on 4/1/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddBuddyGroupViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *tableData;
}
@property (retain, nonatomic) IBOutlet UITextField *subjectTextField;
@property (retain, nonatomic) IBOutlet UIButton *addBuddyButton;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (retain, nonatomic) IBOutlet UILabel *noRecordLabel;
@property (retain, nonatomic) IBOutlet UILabel *subjectNameLabel;
@property (retain, nonatomic) NSString *groupId;
@property (retain, nonatomic) NSString *subjectName;

- (IBAction)handleChangeSubject:(id)sender;
- (id)initWithGroupId:(NSString *)gid andGroupname:(NSString *)gname;

@end
