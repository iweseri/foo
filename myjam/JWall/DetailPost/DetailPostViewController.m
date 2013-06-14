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
#import "AppDelegate.h"
#import "CreatePostViewController.h"

#define kCommentView    1
#define kFavView        2
#define kCountingHolderViewTag 100

static CGFloat kTopHeaderHeight = 80;
static CGFloat kHeaderHeight = 260;
static CGFloat kMinCommentCellHeight = 90;
static CGFloat kFavCellHeight = 64;
static CGFloat kPostImageViewHeight = 260-20;
static CGFloat kCommentImageViewHeight = 120;

@interface DetailPostViewController ()

@end

@implementation DetailPostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        FontLabel *titleViewUsingFL = [[FontLabel alloc] initWithFrame:CGRectZero fontName:@"jambu-font.otf" pointSize:22];
        titleViewUsingFL.text = @"J-ROOM";
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
    
    // Create loading view before things get loaded in viewDidAppear()
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
    options = [[NSArray alloc] initWithObjects:@"Share Facebook", @"Share Twitter", @"Share Email", @"Share to J-Wall", @"Report", @"Block User", @"Cancel", nil];
    
    options2 = [[NSArray alloc] initWithObjects:@"Share Facebook", @"Share Twitter", @"Share Email", @"Share to J-Wall", @"Report", @"Cancel", nil];
    
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
    
    // Resize tableView
    CGRect tmp = self.tableView.frame;
    tmp.size.height = self.view.frame.size.height-self.footerView.frame.size.height-44-24;
    self.tableView.frame = tmp;
    
    [self.tableView setBackgroundColor:[UIColor colorWithHex:@"#f8f8f8"]];
    [self.tableView setHidden:YES];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCommentList)
                                                 name:@"updateCommentList"
                                               object:nil];
//    [self setup];
    reloadDisabled = YES;
    [self setup];
}

- (void)updateCommentList
{
    [self setup];
    
    NSIndexPath* ip = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!reloadDisabled) {
        [self.tableLoadingLabel setHidden:YES];
        [self.tableLoadingIndicator setHidden:YES];
        
        // Start retreive data and setup views
        [self setup];
        
        
        NSLog(@"vda detail");
    }
    
    reloadDisabled = NO;
}

- (void)setup
{
    [favArray removeAllObjects];
    [commentArray removeAllObjects];
    
    BOOL success = [self retrieveData];
    if (success) {
        [self.tableLoadingLabel setHidden:YES];
        [self.tableLoadingIndicator setHidden:YES];
        [self.tableView setHidden:NO];
        [self.tableView reloadData];
    }
}

-(void)onClickedFav
{
    // Submit like to server
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
                
                [self updateViewForFav:[resultsDictionary valueForKey:@"fav_count"] andComment:@""];
                [favArray removeAllObjects];
                [self setup];
            }
            
            [self.footerLoadingIndicator setHidden:YES];
        });
    });
}

-(void)onClickedComment
{
    // Open compose comment page
    reloadDisabled = YES;
    AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CreatePostViewController *createComment = [[CreatePostViewController alloc] initWithPlaceholderText:@"Write a comment." withLabel:@"COMMENT" andComment:data.postId];
    [mydelegate.wallNavController pushViewController:createComment animated:YES];
    [createComment release];
}

- (BOOL)retrieveData
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/wall_post_list.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"post_id\":\"%d\"}", self.postId];
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    
    NSLog(@"%@", resultsDictionary);
    
    if ([[resultsDictionary valueForKey:@"status"] isEqualToString:@"ok"]) {
        
        NSDictionary *postDetails = [[resultsDictionary objectForKey:@"list"] objectAtIndex:0];
        data = [[PostClass alloc] init];
        data.postId = [[postDetails objectForKey:@"id"] integerValue];
        data.qrcodeId = [[postDetails objectForKey:@"qrcode_id"] integerValue]; 
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
        data.sharedPostId = [[postDetails objectForKey:@"shared_post_id"] integerValue];
        if (data.sharedPostId > 0) {
            data.sharedItem = [NSDictionary dictionaryWithDictionary:[postDetails objectForKey:@"shared_from"]];
            //                NSLog(@"data %@",[row objectForKey:@"shared_from"]);
        }
        
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
            commentData.imageURL = [row objectForKey:@"comment_photo"];
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

- (void)updateViewForFav:(NSString *)fav andComment:(NSString *)comment
{
    if ([fav length] > 0 && [comment length] > 0) {
        favStr = fav;
        commStr = comment;
    }else if ([fav length] == 0){
        fav = favStr;
    }else if ([comment length] == 0){
        comment = commStr;
    }
    
    UIView *countingHolderView = [self.view viewWithTag:kCountingHolderViewTag];
    CGFloat totalWidth = 0;
    
    CGFloat favLabelWidth = [fav sizeWithFont:[UIFont boldSystemFontOfSize:14 ]].width;
    [favLabel setText:fav];
    favLabel.frame = CGRectMake(0, 0, favLabelWidth, countingHolderView.frame.size.height);
    totalWidth += favLabel.frame.size.width + 10;
    
    dotLabel.frame = CGRectMake(totalWidth, -6, 14, countingHolderView.frame.size.height);
    totalWidth += dotLabel.frame.size.width + 10;
    
    CGFloat commentLabelWidth = [comment sizeWithFont:[UIFont boldSystemFontOfSize:14 ]].width;
    [commLabel setText:comment];
    commLabel.frame = CGRectMake(totalWidth, 0, commentLabelWidth, countingHolderView.frame.size.height);
}

- (UIView *)setupViewWithFav:(NSString *)fav andComment:(NSString *)comment
{
    [self removeCountView]; // Remove previous if exist

    UIView *countingHolderView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 260, 24)];
    countingHolderView.tag = kCountingHolderViewTag;
    
    // Store current label value
    commStr = comment;
    favStr = fav;
    
    CGFloat totalWidth = 0;
    
    CGFloat favLabelWidth = [fav sizeWithFont:[UIFont boldSystemFontOfSize:14 ]].width;
    favLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, favLabelWidth, countingHolderView.frame.size.height)];
    [favLabel setBackgroundColor:[UIColor clearColor]];
    [favLabel setTextColor:[UIColor colorWithHex:@"#D22042"]];
    [favLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [favLabel setText:fav];
    [favLabel setTag:0];
    [countingHolderView addSubview:favLabel];
    
    
    totalWidth += favLabel.frame.size.width + 10;
    
    dotLabel = [[UILabel alloc] initWithFrame:CGRectMake(totalWidth, -6, 14, countingHolderView.frame.size.height)];
    [dotLabel setBackgroundColor:[UIColor clearColor]];
    [dotLabel setTextColor:[UIColor blackColor]];
    [dotLabel setFont:[UIFont boldSystemFontOfSize:30]];
    [dotLabel setText:@"."];
    [dotLabel setTextAlignment:NSTextAlignmentCenter];
    [countingHolderView addSubview:dotLabel];
    [dotLabel release];
    
    totalWidth += dotLabel.frame.size.width + 10;
    
    CGFloat commentLabelWidth = [comment sizeWithFont:[UIFont boldSystemFontOfSize:14 ]].width;
    commLabel = [[UILabel alloc] initWithFrame:CGRectMake(totalWidth, 0, commentLabelWidth, countingHolderView.frame.size.height)];
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

- (int)getNumberOfLinesInString:(NSString *)text
{
    int numberOfLines, index, stringLength = [text length];
    
    for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++)
    {
        index = NSMaxRange([text lineRangeForRange:NSMakeRange(index, 0)]);
    }
    NSLog(@"no line %d", numberOfLines);
    
    return numberOfLines;
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
    
    if (isShownQRImage) {
        return kHeaderHeight + 30;
    }else{
        if ([data.type isEqualToString:@"PHOTO"]) {
            size.height += kPostImageViewHeight + kTopHeaderHeight + 40 + 10;
        }else{
            size.height += kTopHeaderHeight + 40;
        }
        
        height = kHeaderHeight + 30 > size.height ? kHeaderHeight + 30 : size.height;
        NSLog(@"height %f", height);
    }
    
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
        
//        int numOfLinesOccured = [self getNumberOfLinesInString:aData.text];
//        size.height += 24*numOfLinesOccured;
        
        // if comment contains image, then add height to cell
        if ([aData.imageURL length]) {
            size.height += kCommentImageViewHeight+80;
        }
        
        height = size.height < kMinCommentCellHeight ? kMinCommentCellHeight : size.height;
        
    }else{
        height = kFavCellHeight;
    }
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Y point dinamically calculate for contentView below the top header
    CGFloat ypoint = 5;
    
    // Uiview to be return as header view contains top header, content view (text and image post) & counting (favs and comments)
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, kHeaderHeight)];
    
    // Create top header with user's thumbs, time post and status
    PostHeaderView *header = [[PostHeaderView alloc] init];
    header.tag = section;
    header.delegate = self;
    
    NSMutableString *fullText = [NSMutableString stringWithFormat:@"%@ ",data.username];
    
    NSString *shareUsername = @"";
    if (data.sharedPostId){
        
        shareUsername = [data.sharedItem objectForKey:@"user_name"];
        
        [fullText appendFormat:@"shared %@'s post", shareUsername];
    }else{
        if ([data.type isEqualToString:@"DEFAULT"]) {
            [fullText appendString:@"says"];
        }
        else{
            [fullText appendString:@"shared a photo"];
        }
        
    }
    
    [header setBoldText:data.username withFullText:fullText boldPostfix:shareUsername andTime:@"About 1 minute ago"];
    
    [header.imageView setImageWithURL:[NSURL URLWithString:data.avatarURL]
                     placeholderImage:[UIImage imageNamed:@"blank_avatar"]
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                if (!error) {
                                    
                                }else{
                                    NSLog(@"error retrieve image: %@",error);
                                }
                                
                            }];
    
    [headerView setBackgroundColor:[UIColor colorWithHex:@"#f1ebe4"]];
    
    // Add top header to subview
    [headerView addSubview:header];

    
    // Create Textlabel for post with text
    self.postContentLabel.frame = CGRectMake(10, ypoint, 250, self.postContentLabel.frame.size.height);
    [self.postContentLabel setFont:[UIFont systemFontOfSize:14]];
    [self.postContentLabel setNumberOfLines:0];
    [self.postContentLabel setText:data.text];
    [self.postContentLabel sizeToFit];
    
    // Start post contentview below header contains text and image (if exist)
    self.postContentView.frame = CGRectMake(0, header.frame.size.height, self.postContentView.frame.size.width, self.postContentView.frame.size.height);

    ypoint += self.postContentLabel.frame.size.height + 10;

    // Setup imageView if got photo in post
    if ([data.type isEqualToString:@"PHOTO"] && [data.imageURL length]) {
        UIImageView *postImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, ypoint, 320-40, kPostImageViewHeight)];
        postImageView.clipsToBounds = YES;
        [postImageView setImageWithURL:[NSURL URLWithString:data.imageURL]
                      placeholderImage:[UIImage imageNamed:@"default_icon"]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                 if (!error) {
                                     
                                 }else{
                                     NSLog(@"error retrieve image: %@",error);
                                 }
                                 
                             }];
        
        [self.postContentView insertSubview:postImageView belowSubview:self.rightButton];
        ypoint += postImageView.frame.size.height + 10;
        [postImageView release];
        
        CGRect tmp = self.postContentView.frame;
        tmp.size.height = ypoint;
        self.postContentView.frame = tmp;
        
    }else if (data.sharedPostId > 0){
        self.aPostView.frame = CGRectMake(10, ypoint, self.aPostView.frame.size.width, self.aPostView.frame.size.height);
        [self.postContentView addSubview:self.aPostView];
        self.aPostView.backgroundColor = [UIColor colorWithHex:@"#f1f1f1"];
        self.aPostView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.aPostView.layer.borderWidth = 1.0f;
        
        NSString *urlImage = [data.sharedItem objectForKey:@"avatar_url"];
        
        if ([[data.sharedItem objectForKey:@"post_type"] isEqualToString:@"PHOTO"]) {
            urlImage = [data.sharedItem objectForKey:@"post_photo"];
        }
        
        [self.postImageView setImageWithURL:[NSURL URLWithString:urlImage]
                             placeholderImage:[UIImage imageNamed:@"default_icon"]];
        self.postTitleLabel.text = [data.sharedItem objectForKey:@"user_name"];
        [self.postTitleLabel sizeToFit];
        self.postSubtitleLabel.text = [data.sharedItem objectForKey:@"post_text"];
        [self.postSubtitleLabel sizeToFit];
        
//        [self.aPostView release];
        ypoint += self.aPostView.frame.size.height + 10;
        CGRect tmp = self.postContentView.frame;
        tmp.size.height = ypoint;
        self.postContentView.frame = tmp;
    }

    [headerView addSubview:self.postContentView];
    
    // Create slider uiview for display qrcode
    self.postQRCodeContentView.frame = CGRectMake(320, self.postContentView.frame.origin.y, self.postQRCodeContentView.frame.size.width, self.postQRCodeContentView.frame.size.height);
    
    if (isShownQRImage == YES) {
        // Get the qrcode view inside and contentview outside
        CGRect tmp = self.postContentView.frame;
        tmp.size.height = self.postQRCodeContentView.frame.size.height;
        tmp.origin.x = -320;
        self.postContentView.frame = tmp;
        
        CGRect tmp2 = self.postQRCodeContentView.frame;
        tmp2.origin.x = 0;
        self.postQRCodeContentView.frame = tmp2;
    }else{
        
        // display contentview only
        CGRect tmp = self.postContentView.frame;
        tmp.size.height = kHeaderHeight - kTopHeaderHeight > (ypoint) ? kHeaderHeight - kTopHeaderHeight : ypoint;
        self.postContentView.frame = tmp;
    }
    
    // Setup Favs and comments label and add to headerView
    UIView *countsView = [self setupViewWithFav:data.totalFavourite andComment:data.totalComment];
    
    // Adjust contentView cgpoint
    if (isShownQRImage) {
        countsView.frame = CGRectMake(10, kHeaderHeight+5, 240, 25);
    }else{
        CGFloat countsViewHeight = ypoint > kHeaderHeight - kTopHeaderHeight ? ypoint : kHeaderHeight - kTopHeaderHeight - countsView.frame.size.height;
        if (![data.type isEqualToString:@"PHOTO"]) {
            countsViewHeight += 29;
        }
        countsView.frame = CGRectMake(10, kTopHeaderHeight + countsViewHeight, 240, 25);
    }
    
    [headerView addSubview:countsView];
    [countsView release];
    
    [self.postQRCodeContentView setBackgroundColor:[UIColor colorWithHex:@"#f1ebe4"]];

    // Add qrcode to sliderView
    [headerView insertSubview:self.postQRCodeContentView aboveSubview:self.postContentView];
    [self.qrcodeImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.jam-bu.com/qrcode/%d.png", data.qrcodeId]]
                     placeholderImage:[UIImage imageNamed:@"preview"]
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                if (!error) {
                                    
                                }else{
                                    NSLog(@"error retrieve image: %@",error);
                                }
                                
                            }];
//    return headerView;
    return [headerView autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Setup cell for comments and favs listing
    WallCommentCell *cell = (WallCommentCell *)[tableView dequeueReusableCellWithIdentifier:@"WallCommentCell"];
    if (cell == nil)
    {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"WallCommentCell" owner:self options:nil];
        cell = [nibs objectAtIndex:0];
    }
    
    cell.clipsToBounds = YES;
    
    PostClass *aData = nil;
    if (self.currentView == kCommentView) {
        aData = [commentArray objectAtIndex:indexPath.row];
        
        [cell.commentLabel setHidden:NO];
        CGRect tmp = cell.commentLabel.frame;
        tmp.size.width = 280;
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
    
    // Add image view if photo comment exist
    if ([aData.imageURL length]) {
        [cell.commentImageView setHidden:NO];
//        NSLog(@"cell for row url %@", aData.imageURL);
        CGFloat photoPointY = cell.commentLabel.frame.origin.y + cell.commentLabel.frame.size.height;
        CGRect tmp = cell.commentImageView.frame;
        tmp.origin.y = photoPointY + 5;
        cell.commentImageView.frame = tmp;
//        UIImageView *commentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, photoPointY + 5, kCommentImageViewHeight+20, kCommentImageViewHeight-10)];
        cell.commentImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        cell.commentImageView.layer.borderWidth = 0.5;
        [cell.commentImageView setImageWithURL:[NSURL URLWithString:aData.imageURL]
                            placeholderImage:[UIImage imageNamed:@"default_icon"]];
    }else{
        [cell.commentImageView setHidden:YES];
    }
    
    cell.backgroundView = [[[UIView alloc] initWithFrame:cell.bounds] autorelease];
    return cell;
}

- (void)addBlackView
{
    AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIView *blackView = [[UIView alloc] initWithFrame:mydelegate.window.frame];
    [blackView setTag:99];
    [blackView setBackgroundColor:[UIColor blackColor]];
    [blackView setAlpha:0.5];
    //    [self.view addSubview:blackView];
    [mydelegate.window addSubview:blackView];
    [blackView release];
}

- (void)removeBlackView
{
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *blackView = [mydelegate.window viewWithTag:99];
    if ([mydelegate.window.subviews containsObject:blackView]) {
        [blackView removeFromSuperview];
    }
}

#pragma mark -
#pragma mark PostHeaderView delegate
- (void)tableHeaderView:(PostHeaderView *)headerView didClickOptionButton:(UIButton *)button
{
    NSLog(@"clicked %d", headerView.tag);
    
    NSArray *optionList = nil;
    if ([data.userId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]] ) {
        optionList = options2;
    }else{
        optionList = options;
    }
    
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    MyPopupView *popup = [[MyPopupView alloc] initWithDataList:optionList andTag:headerView.tag];
    popup.delegate = self;
    CGFloat popupYPoint = mydelegate.window.frame.size.height/2-popup.frame.size.height/2;
    CGFloat popupXPoint = mydelegate.window.frame.size.width/2-popup.frame.size.width/2;
    
    popup.frame = CGRectMake(popupXPoint, popupYPoint, popup.frame.size.width, popup.frame.size.height);
    
    [self addBlackView];
    [mydelegate.window addSubview:popup];
    [popup release];
}


#pragma mark -
#pragma mark MyPopupViewDelegate

- (void)popView:(MyPopupView *)popupView didSelectOptionAtIndex:(NSInteger)index
{
    AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    switch (index) {
        case 0:
            [self shareImageOnFB:data.qrcodeId];
            break;
        case 1:
            [self shareImageOnTwitter:data.qrcodeId];
            break;
        case 2:
            [self shareImageOnEmail:data.qrcodeId];
            break;
        case 3:
        {
            CreatePostViewController *createPost = [[CreatePostViewController alloc] initWithPlaceholderText:@"What's on your mind?" withLabel:@"SHARE POST" andComment:nil];
            createPost.shareData = data;
            [mydelegate.wallNavController pushViewController:createPost animated:YES];
            [createPost release];
            break;
        }
            break;
        case 4:
        {
            ReportSpamViewController *detailView = [[ReportSpamViewController alloc] init];
            detailView.qrcodeId = [NSString stringWithFormat:@"%d", data.qrcodeId];
            detailView.postId = [NSString stringWithFormat:@"%d", data.postId];
            detailView.qrTitle = data.text;
            detailView.qrProvider = data.username;
            detailView.qrDate = data.datetime;
            detailView.qrAbstract = @"";
            detailView.qrType = @"J-ROOM";
            detailView.qrCategory = @"Wall Post";
            detailView.qrLabelColor = @"#0099FF";
            
            if (![data.type isEqualToString:@"PHOTO"]) {
                detailView.imageURL = [NSString stringWithFormat:@"http://www.jam-bu.com/qrcode/%d.png", data.qrcodeId];
            }else{
                detailView.imageURL = data.imageURL;
            }
            [mydelegate.wallNavController pushViewController:detailView animated:YES];
            [detailView release];
            break;
        }
            break;
        case 5:
        {
            if ([data.userId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]]) {
                break;
            }
            NSString *urlString = [NSString stringWithFormat:@"%@/api/wall_user_block.php?token=%@",APP_API_URL,[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]];
            
            NSString *dataContent = [NSString stringWithFormat:@"{\"buddy_user_id\":\"%@\"}",data.userId];
            
            NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
            
            NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
            
            if ([[resultsDictionary valueForKey:@"status"] isEqualToString:@"ok"]) {
                // popnavigation controller
            }
            break;
        }
        default:
            break;
    }
    [self removeBlackView];
}

#pragma mark -
#pragma mark share action handler

- (void)addShareItemtoServer:(NSInteger)aQRcodeId withShareType:(NSString *)aType
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/qrcode_share.php?token=%@",APP_API_URL,[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]];
    
    NSString *dataContent = [NSString stringWithFormat:@"{\"qrcode_id\":%d,\"share_type\":\"%@\"}",aQRcodeId,aType];
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    
    NSDictionary *resultsDictionary = [[response objectFromJSONString] mutableCopy];
    
    if([resultsDictionary count])
    {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        
        if ([status isEqualToString:@"ok"])
        {
            NSLog(@"Success share");
        }
        else{
            NSLog(@"share error!");
        }
    }
    
}

- (void)shareImageOnEmail:(NSInteger)qrcodeId
{
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"JAM-BU App"];
        
        //        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        //        [imgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.jam-bu.com/qrcode/%d.png", qrcodeId]]
        //                         placeholderImage:[UIImage imageNamed:@"preview"]
        //                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        //                                    if (!error) {
        //
        //                                    }else{
        //                                        NSLog(@"error retrieve image: %@",error);
        //                                    }
        //
        //                                }];
        NSData *imageData = UIImagePNGRepresentation(self.qrcodeImage.image);
        [mailer addAttachmentData:imageData mimeType:@"image/png" fileName:[NSString stringWithFormat:@"%d", qrcodeId]];
        NSString *emailBody = [NSString stringWithFormat:@"Scan this QR code. \n\nJAM-BU App: %@/?qrcode_id=%d",APP_API_URL,qrcodeId];
        [mailer setMessageBody:emailBody isHTML:NO];
        AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [mydelegate.wallNavController presentModalViewController:mailer animated:YES];
        [mailer release];
        
        [self addShareItemtoServer:qrcodeId withShareType:@"email"];
    }
    else
    {
        CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Save" message:@"Please configure your mail in Mail Application" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    
}

- (void)shareImageOnTwitter:(NSInteger)qrcodeId
{
    //CHECK VERSION FIRST. Constant can refer from Constant.h
    if(SYSTEM_VERSION_EQUAL_TO(@"5.0") || SYSTEM_VERSION_EQUAL_TO(@"5.1"))
    {
        [self twitterAPIShare:qrcodeId];
    }
    else if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        [self callAPIShare:kOPTION_TWITTER withQRcodeId:qrcodeId];
    }
}
- (void)shareImageOnFB:(NSInteger)qrcodeId
{
    //check version first and then call method
    if(SYSTEM_VERSION_EQUAL_TO(@"5.0") || SYSTEM_VERSION_EQUAL_TO(@"5.1"))
    {
        CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Unsupported iOS Version" message:@"Sorry. Your iOS version doesn't support Facebook Share." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        [self callAPIShare:kOPTION_FB withQRcodeId:qrcodeId];
    }
}
- (void)twitterAPIShare:(NSInteger)qrcodeId //for iOS 5 and 5.1
{
    TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
    
    [twitter setInitialText:@""];
    //    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    //    [imgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.jam-bu.com/qrcode/%d.png", qrcodeId]]
    //            placeholderImage:[UIImage imageNamed:@"preview"]
    //                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
    //                       if (!error) {
    //
    //                       }else{
    //                           NSLog(@"error retrieve image: %@",error);
    //                       }
    //
    //                   }];
    [twitter addImage:self.qrcodeImage.image];
    
    [self presentViewController:twitter animated:YES completion:nil];
    
    twitter.completionHandler = ^(TWTweetComposeViewControllerResult res) {
        
        if(res == TWTweetComposeViewControllerResultDone) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Successfully posted." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [alert show];
            [alert release];
            
            [self addShareItemtoServer:qrcodeId withShareType:@"twitter"];
            
        }
        if(res == TWTweetComposeViewControllerResultCancelled) {
            /*
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Cancelled" message:@"You Cancelled posting the Tweet." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
             
             [alert show];
             */
        }
        [self dismissModalViewControllerAnimated:YES];
        
    };
    
    
}

- (void)callAPIShare:(int)option withQRcodeId:(NSInteger)qrcodeId
{
    NSString *serviceType = nil;
    NSString *type = nil;
    if (option == kOPTION_FB) {
        serviceType = SLServiceTypeFacebook;
        type = @"Facebook";
    }else if (option == kOPTION_TWITTER){
        serviceType = SLServiceTypeTwitter;
        type = @"Twitter";
    }
    
    mySLComposerSheet = [[SLComposeViewController alloc] init];
    mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:serviceType];
    
    if([SLComposeViewController isAvailableForServiceType:serviceType]) //check if account is linked
    {
        //        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        //        [imgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.jam-bu.com/qrcode/%d.png", qrcodeId]]
        //                placeholderImage:[UIImage imageNamed:@"preview"]
        //                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        //                           if (!error) {
        //
        //                           }else{
        //                               NSLog(@"error retrieve image: %@",error);
        //                           }
        //
        //                       }];
        
        [mySLComposerSheet addImage:self.qrcodeImage.image];
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            NSString *output;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    output = @"Action Cancelled";
                    [self dismissModalViewControllerAnimated:YES];
                    break;
                case SLComposeViewControllerResultDone:
                    output = @"Post Successful";
                    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Save" message:output delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                    [self dismissModalViewControllerAnimated:YES];
                    break;
                    
                    [self addShareItemtoServer:qrcodeId withShareType:[type lowercaseString]];
            }
            
        }];
        
        
        
    }else{
        CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Save" message:[NSString stringWithFormat:@"Please add your %@ account in IOS Device Settings and allow JAM-BU to access your %@ information.",type,type] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    
}

#pragma mark -
#pragma mark MFMail delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSString *msg;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            msg = @"";
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            msg = [NSString stringWithFormat:@"Email has been saved to draft"];
            break;
        case MFMailComposeResultSent:
            //NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            msg = [NSString stringWithFormat:@"Email has been successfully sent"];
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            msg = [NSString stringWithFormat:@"Email was not sent, possibly due to an error"];
            break;
        default:
            //NSLog(@"Mail not sent.");
            break;
    }
    
    if (![msg isEqualToString:@""]) {
        CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Save" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // Remove the mail view
    [mydelegate.wallNavController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
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
    [_rightButton release];
    [_postImageView release];
    [_postTitleLabel release];
    [_postSubtitleLabel release];
    [_aPostView release];
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
    [self setRightButton:nil];
    [self setPostImageView:nil];
    [self setPostTitleLabel:nil];
    [self setPostSubtitleLabel:nil];
    [self setAPostView:nil];
    [super viewDidUnload];
}
- (IBAction)handlePostContentRightButton:(id)sender
{
    isShownQRImage = YES;
    
    [UIView animateWithDuration:0.4 delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^
     {
         self.postQRCodeContentView.frame = CGRectMake(0, self.postContentView.frame.origin.y, self.postQRCodeContentView.frame.size.width, self.postQRCodeContentView.frame.size.height);
     }
                     completion:^(BOOL finished){
                         [self.tableView reloadData];
                     }];
}

- (IBAction)handlePostContentLeftButton:(id)sender
{
    isShownQRImage = NO;
    
    [UIView animateWithDuration:0.4 delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^
     {
         self.postQRCodeContentView.frame = CGRectMake(320, self.postContentView.frame.origin.y, self.postQRCodeContentView.frame.size.width, self.postQRCodeContentView.frame.size.height);
     }
                     completion:^(BOOL finished){
                         [self.tableView reloadData];
                     }];
}
@end
