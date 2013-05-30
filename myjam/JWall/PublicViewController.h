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
#import "PostImageCell.h"
#import "MyPopupView.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MessageUI/MessageUI.h>

@interface PublicViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, PostHeaderViewDelegate, PostFooterDelegate , MyPopupViewDelegate, MFMailComposeViewControllerDelegate>
{
    NSMutableArray *tableData;
    NSArray *options, *options2;
    int pageCounter;
    BOOL isLastPage;
    SLComposeViewController *mySLComposerSheet;
    UIImage *currImage;
}
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (retain, nonatomic) IBOutlet UILabel *loadingLabel;
@property (nonatomic) int pageType;

@end
