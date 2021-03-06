//
//  SearchBarView.h
//  myjam
//
//  Created by M Ridhwan M Sari on 5/26/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchBarView : UITableViewController<UISearchBarDelegate>
{
    NSString *message;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSMutableArray *tableData;
@property (retain, nonatomic) NSMutableArray *shopData;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;

- (NSString *)returnAPIURL;
- (NSString *)returnAPIDataContent;
- (BOOL)retrieveData;

@end
