//
//  DetailPostViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 5/13/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "DetailPostViewController.h"
#import "ASIWrapper.h"
#import "PostTextCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "WallCommentCell.h"

#define kCommentView    1
#define kFavView        2
#define kCountingHolderViewTag 100

static CGFloat kPostHeaderHeight = 80;
static CGFloat kHeaderHeight = 250;
static CGFloat kMinCommentCellHeight = 90;
static CGFloat kFavCellHeight = 64;
static CGFloat kImageViewHeight = 200;

@interface DetailPostViewController ()

@end

@implementation DetailPostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        FontLabel *titleViewUsingFL = [[FontLabel alloc] initWithFrame:CGRectZero fontName:@"jambu-font.otf" pointSize:22];
        titleViewUsingFL.text = @"J-Wall";
        titleViewUsingFL.textAlignment = NSTextAlignmentCenter;
        titleViewUsingFL.backgroundColor = [UIColor clearColor];
        titleViewUsingFL.textColor = [UIColor whiteColor];
        [titleViewUsingFL sizeToFit];
        self.navigationItem.titleView = titleViewUsingFL;
        [titleViewUsingFL release];
        
        self.navigationItem.backBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                          style:UIBarButtonItemStyleBordered
                                         target:nil
                                         action:nil] autorelease];
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.currentView == 0) {
        self.currentView = kCommentView; // Default view
    }
    
    self.tableLoadingIndicator.frame = CGRectMake(self.view.frame.size.width/2-self.tableLoadingIndicator.frame.size.width/2,
                                             self.view.frame.size.height/2-self.tableLoadingIndicator.frame.size.height/2-100,
                                             self.tableLoadingIndicator.frame.size.width,
                                             self.tableLoadingIndicator.frame.size.height);
    
    self.tableLoadingLabel.frame = CGRectMake(self.view.frame.size.width/2-self.tableLoadingLabel.frame.size.width/2,
                                         self.tableLoadingIndicator.frame.origin.y+self.tableLoadingIndicator.frame.size.height+10,
                                         240,
                                         55);
    
    favArray = [[NSMutableArray alloc] init];
    commentArray = [[NSMutableArray alloc] init];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        self.view.frame = CGRectMake(0,0,self.view.bounds.size.width, 568);
    } else {
        // code for 3.5-inch screen
        self.view.frame = CGRectMake(0,0,self.view.bounds.size.width, 480);
    }
    
    // Add footer view for comment and fav
    self.footerView.frame = CGRectMake(0, self.view.frame.size.height-self.footerView.frame.size.height-44*3-2, self.footerView.frame.size.width, self.footerView.frame.size.height);
    [self.commentButton addTarget:self action:@selector(onClickedComment) forControlEvents:UIControlEventTouchUpInside];
    [self.favouriteButton addTarget:self action:@selector(onClickedFav) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.footerView];
    
    // resize tableView
    CGRect tmp = self.tableView.frame;
    tmp.size.height = self.view.frame.size.height-self.footerView.frame.size.height-44-22;
    self.tableView.frame = tmp;
    
    [self.tableView setBackgroundColor:[UIColor colorWithHex:@"#f8f8f8"]];
    [self.tableView setHidden:YES];
    
//    [self setup];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableLoadingLabel setHidden:YES];
    [self.tableLoadingIndicator setHidden:YES];
    
    [self setup];
}

- (void)setup
{
    BOOL success = [self retrieveData];
    if (success) {
//        if ([commentArray count] > 0 || [favArray count] > 0) {
//            
//        }else{
//            CGRect frame = self.tableView.frame;
//            
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height+5, 300, 24)];
//            [label setFont:[UIFont systemFontOfSize:14]];
//            label.tag = 5;
//            label.text = @"No comments. Be the first.";
//            [self.view insertSubview:label aboveSubview:self.tableView];
//            [label release];
//        }
        [self.tableLoadingLabel setHidden:YES];
        [self.tableLoadingIndicator setHidden:YES];
        [self.tableView setHidden:NO];
        [self.tableView reloadData];
    }
}

-(void)onClickedFav
{
    [self.footerLoadingIndicator setHidden:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *urlString = [NSString stringWithFormat:@"%@/api/wall_post_fav.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
        NSString *dataContent = [NSString stringWithFormat:@"{\"post_id\":\"%d\"}",(int)data.postId];
        
        NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
        NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
            NSLog(@"%@", resultsDictionary);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([[resultsDictionary valueForKey:@"status"] isEqualToString:@"ok"])
            {
                if ([[resultsDictionary valueForKey:@"is_fav"] intValue] == 1) {
                    [self.favouriteButton setImage:[UIImage imageNamed:@"btn-fav-unfav-mr"] forState:UIControlStateNormal];
                }else{
                    [self.favouriteButton setImage:[UIImage imageNamed:@"btn-fav-mr"] forState:UIControlStateNormal];
                }
                
//                [footerView setupWithFav:[resultsDictionary valueForKey:@"fav_count"] andComment:@""];
            }
            
            [self.footerLoadingIndicator setHidden:YES];
        });
    });
}

-(void)onClickedComment
{
    
}

- (BOOL)retrieveData
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/wall_post_list.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"post_id\":\"%d\"}", self.postId];
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    
    if ([[resultsDictionary valueForKey:@"status"] isEqualToString:@"ok"]) {
        
        NSDictionary *postDetails = [[resultsDictionary objectForKey:@"list"] objectAtIndex:0];
        data = [[PostClass alloc] init];
        data.postId = [[postDetails objectForKey:@"id"] integerValue];
        data.text = [NSString stringWithFormat:@"%@", [postDetails objectForKey:@"post_text"]];
        data.type = [postDetails objectForKey:@"post_type"];
        data.userId = [postDetails objectForKey:@"user_id"];
        data.username = [postDetails objectForKey:@"user_name"];
        data.datetime = [postDetails objectForKey:@"datetime"];
        data.avatarURL = [postDetails objectForKey:@"avatar_url"];
        data.isFavourite = [postDetails objectForKey:@"is_fav"];
        data.totalFavourite = [postDetails objectForKey:@"fav_count"];
        data.totalComment = [postDetails objectForKey:@"comment_count"];
        data.imageURL = [postDetails objectForKey:@"post_photo"];
        
        if ([data.isFavourite intValue] == 1) {
            [self.favouriteButton setImage:[UIImage imageNamed:@"btn-fav-unfav-mr"] forState:UIControlStateNormal];
        }else{
            [self.favouriteButton setImage:[UIImage imageNamed:@"btn-fav-mr"] forState:UIControlStateNormal];
        }

        NSDictionary *comments = [resultsDictionary objectForKey:@"comment"];
                                  
        // Store comment in table data
        for (id row in comments) {
            PostClass *commentData = [[PostClass alloc] init];
            commentData.text = [NSString stringWithFormat:@"%@", [row objectForKey:@"comment_text"]];
            commentData.userId = [row objectForKey:@"user_id"];
            commentData.username = [row objectForKey:@"user_name"];
            commentData.datetime = [row objectForKey:@"datetime"];
            commentData.avatarURL = [row objectForKey:@"avatar_url"];
            [commentArray addObject:commentData];
        }
        
        NSDictionary *favs = [resultsDictionary objectForKey:@"fav"];
        
        // Store favs in table data
        for (id row in favs) {
            PostClass *favData = [[PostClass alloc] init];
            favData.isFavourite = [row objectForKey:@"is_fav"];
            favData.userId = [row objectForKey:@"user_id"];
            favData.username = [row objectForKey:@"user_name"];
            favData.datetime = [row objectForKey:@"datetime"];
            favData.avatarURL = [row objectForKey:@"avatar_url"];
            [favArray addObject:favData];
        }
        
    }else{
        // If status error
        return NO;
    }
    
    return YES;
}

- (UIView *)setupViewWithFav:(NSString *)fav andComment:(NSString *)comment
{
    [self removeCountView]; // remove if exist
    
    UIView *countingHolderView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 260, 24)];
    countingHolderView.tag = kCountingHolderViewTag;
    
//    for (UILabel *label in countingHolderView.subviews) {
//        [label removeFromSuperview];
//        [label release];
//    }
    
    CGFloat totalWidth = 0;
    
    CGFloat favLabelWidth = [fav sizeWithFont:[UIFont boldSystemFontOfSize:14 ]].width;
    UILabel *favLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, favLabelWidth, countingHolderView.frame.size.height)];
    [favLabel setBackgroundColor:[UIColor clearColor]];
    [favLabel setTextColor:[UIColor colorWithHex:@"#D22042"]];
    [favLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [favLabel setText:fav];
    [favLabel setTag:0];
    [countingHolderView addSubview:favLabel];
    
    
    totalWidth += favLabel.frame.size.width + 10;
    
    UILabel *dotLabel = [[UILabel alloc] initWithFrame:CGRectMake(totalWidth, -6, 14, countingHolderView.frame.size.height)];
    [dotLabel setBackgroundColor:[UIColor clearColor]];
    [dotLabel setTextColor:[UIColor blackColor]];
    [dotLabel setFont:[UIFont boldSystemFontOfSize:30]];
    [dotLabel setText:@"."];
    [dotLabel setTextAlignment:NSTextAlignmentCenter];
    [countingHolderView addSubview:dotLabel];
    [dotLabel release];
    
    totalWidth += dotLabel.frame.size.width + 10;
    
    CGFloat commentLabelWidth = [comment sizeWithFont:[UIFont boldSystemFontOfSize:14 ]].width;
    UILabel *commLabel = [[UILabel alloc] initWithFrame:CGRectMake(totalWidth, 0, commentLabelWidth, countingHolderView.frame.size.height)];
    [commLabel setBackgroundColor:[UIColor clearColor]];
    [commLabel setTextColor:[UIColor colorWithHex:@"#D22042"]];
    [commLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [commLabel setText:comment];
    [commLabel setTag:1];
    [countingHolderView addSubview:commLabel];
    
    
    commLabel.userInteractionEnabled = YES;
    favLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFavs)];
    [favLabel addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showComments)];
    [commLabel addGestureRecognizer:tapGesture2];
    [tapGesture2 release];
    
    [favLabel release];
    [commLabel release];
    
    return countingHolderView;
}

- (void)removeCountView
{
    for (UIView *v in self.postContentView.subviews) {
        if (v.tag == kCountingHolderViewTag) {
            [v removeFromSuperview];
        }
    }
}

- (void)showComments
{
    self.currentView = kCommentView;
    [self.tableView reloadData];
}

- (void)showFavs
{
    self.currentView = kFavView;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.currentView == kCommentView) {
        return [commentArray count];
    }else{
        return [favArray count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0;
    
    // Get appropriate height for cell based on word / characters counting
    CGSize  textSize = { 251, 10000.0 };
    CGSize size = [data.text sizeWithFont:[UIFont systemFontOfSize:14]
                         constrainedToSize:textSize
                             lineBreakMode:UILineBreakModeWordWrap];
    
    if ([data.type isEqualToString:@"PHOTO"]) {
        size.height += kImageViewHeight + kPostHeaderHeight + 40;
    }else{
        size.height += kPostHeaderHeight + 40;
    }
    
    height = kHeaderHeight > size.height ? kHeaderHeight : size.height;
    NSLog(@"height %f", height);
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (self.currentView == kCommentView) {
        PostClass *aData = [commentArray objectAtIndex:indexPath.row];
        
        // Get appropriate height for cell based on word / characters counting
        CGSize  textSize = { 251, 10000.0 };
        CGSize size = [aData.text sizeWithFont:[UIFont systemFontOfSize:14]
                            constrainedToSize:textSize
                                lineBreakMode:UILineBreakModeWordWrap];
        
        height = size.height < kMinCommentCellHeight ? kMinCommentCellHeight : size.height;
        
    }else{
        height = kFavCellHeight;
    }
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat ypoint = 0;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, kHeaderHeight)];
    
    PostHeaderView *header = [[PostHeaderView alloc] init];
    header.tag = section;
    header.delegate = self;
    
    NSMutableString *fullText = [NSMutableString stringWithFormat:@"%@ ",data.username];
    
    if ([data.type isEqualToString:@"DEFAULT"]) {
        [fullText appendString:@"says"];
    }
    else if ([data.type isEqualToString:@"PHOTO"]) {
        [fullText appendString:@"shared a photo"];
    }
    
    [header setBoldText:data.username withFullText:fullText andTime:@"About 1 minute ago"];
    [header.imageView setImageWithURL:[NSURL URLWithString:data.avatarURL]
                     placeholderImage:[UIImage imageNamed:@"blank_avatar"]
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                if (!error) {
                                    
                                }else{
                                    NSLog(@"error retrieve image: %@",error);
                                }
                                
                            }];
    
    [headerView setBackgroundColor:[UIColor colorWithHex:@"#e8e8e8"]];
    [headerView addSubview:header];
//    ypoint += header.frame.size.height;
    
//    [self.postContentView setBackgroundColor:[UIColor yellowColor]];
    self.postContentLabel.frame = CGRectMake(10, ypoint, 250, self.postContentLabel.frame.size.height);
    [self.postContentLabel setFont:[UIFont systemFontOfSize:14]];
    [self.postContentLabel setNumberOfLines:0];
    [self.postContentLabel setText:data.text];
    [self.postContentLabel sizeToFit];
    [self.postContentLabel setBackgroundColor:[UIColor yellowColor]];
    
    // start post contentview below header
    self.postContentView.frame = CGRectMake(0, header.frame.size.height, self.postContentView.frame.size.width, self.postContentView.frame.size.height);

    ypoint += self.postContentLabel.frame.size.height + 10;

    
    if ([data.type isEqualToString:@"PHOTO"] && [data.imageURL length]) {
        UIImageView *postImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, ypoint, 270, kImageViewHeight)];
        [postImageView setImageWithURL:[NSURL URLWithString:data.imageURL]
                      placeholderImage:[UIImage imageNamed:@"default_icon"]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                 if (!error) {
                                     
                                 }else{
                                     NSLog(@"error retrieve image: %@",error);
                                 }
                                 
                             }];
        
        [self.postContentView addSubview:postImageView];
        ypoint += postImageView.frame.size.height + 10;
        [postImageView release];
        
        CGRect tmp = self.postContentView.frame;
        tmp.size.height = ypoint;
        self.postContentView.frame = tmp;
        
    }
    
    NSLog(@"%f", ypoint);
    
    
    UIView *countsView = [self setupViewWithFav:data.totalFavourite andComment:data.totalComment];
    CGFloat countsViewHeight = ypoint > kHeaderHeight - kPostHeaderHeight ? ypoint : kHeaderHeight - kPostHeaderHeight - countsView.frame.size.height;
    countsView.frame = CGRectMake(10, countsViewHeight, 240, 25);
//    CGRect tmp2 = countsView.frame;
//    tmp2.origin.y = headerView.frame.size.height-countsView.frame.size.height-4;
//    countsView.frame = tmp2;
    
    [self.postContentView addSubview:countsView];
    [countsView release];
    
    ypoint += countsView.frame.size.height;
    
    
    CGRect tmp = self.postContentView.frame;
    tmp.size.height = kHeaderHeight > (ypoint) ? kHeaderHeight : ypoint;
    self.postContentView.frame = tmp;
    
    [headerView addSubview:self.postContentView];
    
    self.postQRCodeContentView.frame = CGRectMake(320, self.postContentView.frame.origin.y, self.postQRCodeContentView.frame.size.width, self.postQRCodeContentView.frame.size.height);
    [self.postQRCodeContentView setBackgroundColor:[UIColor colorWithHex:@"#e8e8e8"]];
    
    [headerView insertSubview:self.postQRCodeContentView aboveSubview:self.postContentView];
    [self.qrcodeImage setImageWithURL:[NSURL URLWithString:@"http://www.jam-bu.com/qrcode/1254.png"]
                     placeholderImage:[UIImage imageNamed:@"default_icon"]
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                if (!error) {
                                    
                                }else{
                                    NSLog(@"error retrieve image: %@",error);
                                }
                                
                            }];
//    NSLog(@"%f", ypoint);
    
    
    return [headerView autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"section %d, row %d", indexPath.section, indexPath.row);
    
    WallCommentCell *cell = (WallCommentCell *)[tableView dequeueReusableCellWithIdentifier:@"WallCommentCell"];
    if (cell == nil)
    {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"WallCommentCell" owner:self options:nil];
        cell = [nibs objectAtIndex:0];
    }
    
    PostClass *aData = nil;
    if (self.currentView == kCommentView) {
        aData = [commentArray objectAtIndex:indexPath.row];
        
        [cell.commentLabel setHidden:NO];
        CGRect tmp = cell.commentLabel.frame;
        tmp.size.height = kMinCommentCellHeight;
        cell.commentLabel.frame = tmp;
        
        [cell.commentLabel setFont:[UIFont systemFontOfSize:14]];
        [cell.commentLabel setText:aData.text];
        [cell.commentLabel setNumberOfLines:0];
        [cell.commentLabel sizeToFit];

    }else{
        aData = [favArray objectAtIndex:indexPath.row];
        [cell.commentLabel setHidden:YES];
    }
    
    cell.username.text = aData.username;
    [cell.username setTextColor:[UIColor colorWithHex:@"#D22042"]];
    
    [cell.statusLabel setText:@"About 1 minutes ago"];
    [cell.thumbImageView setImageWithURL:[NSURL URLWithString:aData.avatarURL]
                     placeholderImage:[UIImage imageNamed:@"blank_avatar"]
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                if (!error) {
                                    
                                }else{
                                    NSLog(@"error retrieve image: %@",error);
                                }
                                
                            }];
    
    cell.backgroundView = [[[UIView alloc] initWithFrame:cell.bounds] autorelease];
    return cell;
}

- (void)addBlackView
{
    UIView *blackView = [[UIView alloc] initWithFrame:self.view.frame];
    [blackView setTag:99];
    [blackView setBackgroundColor:[UIColor blackColor]];
    [blackView setAlpha:0.5];
    [self.view addSubview:blackView];
    [blackView release];
}

- (void)removeBlackView
{
    UIView *blackView = [self.view viewWithTag:99];
    if ([self.view.subviews containsObject:blackView]) {
        [blackView removeFromSuperview];
    }
}

#pragma mark -
#pragma mark PostHeaderView delegate
- (void)tableHeaderView:(PostHeaderView *)headerView didClickOptionButton:(UIButton *)button
{
    NSLog(@"clicked %d",headerView.tag);
    
    MyPopupView *popup = [[MyPopupView alloc] initWithDataList:options andTag:headerView.tag];
    popup.delegate = self;
    CGFloat popupYPoint = self.view.frame.size.height/2-popup.frame.size.height/2;
    CGFloat popupXPoint = self.view.frame.size.width/2-popup.frame.size.width/2;
    
    popup.frame = CGRectMake(popupXPoint, popupYPoint, popup.frame.size.width, popup.frame.size.height);
    [self addBlackView];
    [self.view addSubview:popup];
}

#pragma mark -
#pragma mark MyPopupViewDelegate

- (void)popView:(MyPopupView *)popupView didSelectOptionAtIndex:(NSInteger)index
{
    NSLog(@"Clicked at post %d and selected option %d", popupView.tag, index);
    
    [self removeBlackView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_footerView release];
    [_commentButton release];
    [_favouriteButton release];
    [_tableView release];
    [_postContentView release];
    [_postContentLabel release];
    [_postQRCodeContentView release];
    [_qrcodeImage release];
    [_tableLoadingIndicator release];
    [_tableLoadingLabel release];
    [_footerLoadingIndicator release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setFooterView:nil];
    [self setCommentButton:nil];
    [self setFavouriteButton:nil];
    [self setTableView:nil];
    [self setPostContentView:nil];
    [self setPostContentLabel:nil];
    [self setPostQRCodeContentView:nil];
    [self setQrcodeImage:nil];
    [self setTableLoadingIndicator:nil];
    [self setTableLoadingLabel:nil];
    [self setFooterLoadingIndicator:nil];
    [super viewDidUnload];
}
- (IBAction)handlePostContentRightButton:(id)sender
{
    [UIView animateWithDuration:0.4 delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^
     {
         self.postQRCodeContentView.frame = CGRectMake(0, self.postContentView.frame.origin.y, self.postQRCodeContentView.frame.size.width, self.postQRCodeContentView.frame.size.height);
     }
                     completion:^(BOOL finished){}];
}

- (IBAction)handlePostContentLeftButton:(id)sender
{
    [UIView animateWithDuration:0.4 delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^
     {
         self.postQRCodeContentView.frame = CGRectMake(320, self.postContentView.frame.origin.y, self.postQRCodeContentView.frame.size.width, self.postQRCodeContentView.frame.size.height);
     }
                     completion:^(BOOL finished){}];
}
@end
