//
//  DetailPostViewController.h
//  myjam
//
//  Created by Mohd Hafiz on 5/13/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostHeaderView.h"
#import "MyPopupView.h"
#import "PostClass.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MessageUI/MessageUI.h>

@interface DetailPostViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, PostHeaderViewDelegate, MyPopupViewDelegate, MFMailComposeViewControllerDelegate>
{
    PostClass *data;
    CGFloat currentHeight;
//    NSMutableArray *tableData;
    NSMutableArray *commentArray;
    NSMutableArray *favArray;
    
    NSMutableArray *tableDataFavourite;
    NSArray *options;
    NSArray *options2;
    
    UILabel *commLabel;
    UILabel *favLabel;
    UILabel *dotLabel;
    
    NSString *commStr;
    NSString *favStr;
    
    CGFloat tmpValue;
    BOOL isShownQRImage;
    SLComposeViewController *mySLComposerSheet;
    BOOL reloadDisabled;
}

@property (retain, nonatomic) IBOutlet UIView *footerView;
@property (retain, nonatomic) IBOutlet UIButton *commentButton;
@property (retain, nonatomic) IBOutlet UIButton *favouriteButton;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIView *postContentView;
@property (retain, nonatomic) IBOutlet UILabel *postContentLabel;
@property (retain, nonatomic) IBOutlet UIView *postQRCodeContentView;
@property (retain, nonatomic) IBOutlet UIImageView *qrcodeImage;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *tableLoadingIndicator;
@property (retain, nonatomic) IBOutlet UILabel *tableLoadingLabel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *footerLoadingIndicator;
@property (retain, nonatomic) IBOutlet UIImageView *postImageView;
@property (retain, nonatomic) IBOutlet UILabel *postTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *postSubtitleLabel;
@property (retain, nonatomic) IBOutlet UIView *aPostView;

@property (nonatomic) NSInteger postId;
@property int currentView;
@property (retain, nonatomic) IBOutlet UIButton *rightButton;

- (IBAction)handlePostContentRightButton:(id)sender;
- (IBAction)handlePostContentLeftButton:(id)sender;


@end
