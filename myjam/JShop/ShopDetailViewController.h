//
//  ShopDetailViewController.h
//  myjam
//
//  Created by M Ridhwan M Sari on 5/28/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopDetailViewController : UITableViewController<UITextViewDelegate>//<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *headerName;
    NSInteger expandedRowIndex;
    CGRect newCFrame;
    //CGFloat contactHeight;
    CGFloat descHeight;
    BOOL openDesc;
}
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSString *shopID;
@property (nonatomic, retain) NSDictionary *dataInfo;

@end
