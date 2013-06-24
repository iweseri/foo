//
//  PublicViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 5/9/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "PublicViewController.h"
#import "DetailPostViewController.h"
#import "CreatePostViewController.h"
#import "AppDelegate.h"
#import "PostClass.h"
#import "PostTaggedCell.h"
#import "ConnectionClass.h"
#import "ShareCell.h"
#import <Twitter/Twitter.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "ReportSpamViewController.h"
#import "ShopLoadingCell.h"
#import <math.h>

#define kCommentView    1
#define kFavView        2
#define kOriginalPost   3

#define kPublic     1
#define kPersonal   2

#define kDisplayPerPage 5

static CGFloat kHeaderHeight = 80;
static CGFloat kFooterHeight = 100;
static CGFloat kMinCellHeight = 22;
static CGFloat kImageCellHeight = 260;
static CGFloat kMinCellTagHeight = 26;
//static CGFloat kMinCellShareHeight = 160;
static CGFloat kStartCalcCellShareHeight = 78;
static CGFloat kImageShareHeight = 200;


@interface PublicViewController ()

@end

@implementation PublicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    filterParameter = [NSString stringWithFormat:@"0"];
    searchParameter = @"";
    tableData = [[NSMutableArray alloc] init];
    self.loadingIndicator.frame = CGRectMake(self.view.frame.size.width/2-self.loadingIndicator.frame.size.width/2,
                                             self.view.frame.size.height/2-self.loadingIndicator.frame.size.height/2-100,
                                             self.loadingIndicator.frame.size.width,
                                             self.loadingIndicator.frame.size.height);
    
    self.loadingLabel.frame = CGRectMake(self.view.frame.size.width/2-self.loadingLabel.frame.size.width/2,
                                         self.loadingIndicator.frame.origin.y+self.loadingIndicator.frame.size.height+10,
                                         240,
                                         55);
    options = [[NSArray alloc] initWithObjects:@"Share Facebook", @"Share Twitter", @"Share Email", @"Share to J-Wall", @"Report", @"Block User", @"Cancel", nil];
    
    options2 = [[NSArray alloc] initWithObjects:@"Share Facebook", @"Share Twitter", @"Share Email", @"Share to J-Wall", @"Report", @"Cancel", nil];
    
    
    [self.view setBackgroundColor:[UIColor colorWithHex:@"#f1ebe4"]];
    [self.tableView setBackgroundColor:[UIColor colorWithHex:@"#f1ebe4"]];

    [self.tableView setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableData)
                                                 name:@"reloadWall"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableRow)
                                                 name:@"reloadWallPost"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showPostsWithFilter:)
                                                 name:@"showPostsWithFilter"
                                               object:nil];
    
    UITapGestureRecognizer *tapToReload = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setup)];
    [self.view addGestureRecognizer:tapToReload];
    [tapToReload release];
    
    showTopEnabled = NO;
}

- (void)showPostsWithFilter:(NSNotification *)n
{
    NSLog(@"dic %@", n.userInfo);
    showTopEnabled = YES;
    filterParameter = [[n.userInfo objectForKey:@"filterOption"] intValue];
    searchParameter = [[n.userInfo objectForKey:@"searchText"] copy];
//    [tableData removeAllObjects];
    [self setup];
//    [tableData]
    NSLog(@"reloadwithfilter");
}

- (void)reloadTableData
{
    showTopEnabled = YES;
//    [tableData removeAllObjects];
    [self setup];
    NSLog(@"reloadwall");
}

- (void)reloadTableRow
{
//    [tableData removeAllObjects];
    
    [self setup];
    
    NSLog(@"reloadwallPost");
}


//- (void)viewWillAppear:(BOOL)animated
//{
//    [self.tableView setHidden:YES];
//    [self.loadingLabel setHidden:NO];
//    [self.loadingIndicator setHidden:NO];
//}

- (void)viewDidDisappear:(BOOL)animated
{
    [self removeBlackView];
    // remove popupview if exist
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[MyPopupView class]]) {
            [v removeFromSuperview];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!reloadDisabled) {
        NSLog(@"Vda");
        filterParameter = @"";
        searchParameter = @"";
//        [tableData removeAllObjects];
        [self setup];
        
        
    }
    reloadDisabled = NO;
    
}

- (void)setup
{
    pageCounter = 1;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success = [self retrieveData:pageCounter];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                NSLog(@"count %d",[tableData count]);
                if ([tableData count]) {
                    [self.tableView setHidden:NO];
                    [self.tableView reloadData];
                }
                
                [self.loadingLabel setHidden:YES];
                [self.loadingIndicator setHidden:YES];
                
                if ([tableData count] && showTopEnabled) {
                    [self.tableView setContentOffset:CGPointZero animated:NO];
                    showTopEnabled = NO;
                }
                
            }else{
                self.loadingLabel.text = [NSString stringWithFormat:@"Connection problem occured.\nTap to reload."];
                [self.loadingIndicator setHidden:YES];
            }
        });
    });
}

- (BOOL)retrieveData:(NSUInteger)page
{
    self.loadingLabel.text = @"Loading ...";
//    self.view.userInteractionEnabled = NO;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/wall_post_list.php?token=%@",APP_API_URL,[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]];
    
    NSString *dataContent = [NSString stringWithFormat: @"{\"page\":%d,\"perpage\":%d,\"filter_option\":\"%d\",\"filter_search\":\"%@\"}", page, kDisplayPerPage, filterParameter, searchParameter];
    
    if (self.pageType == kPersonal)
    {
        dataContent = [NSString stringWithFormat: @"{\"page\":%d,\"perpage\":%d,\"is_private\":\"1\",\"filter_option\":\"%d\",\"filter_search\":\"%@\"}", page, kDisplayPerPage, filterParameter, searchParameter];
    }
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSMutableArray *newData = [[NSMutableArray alloc] init];
    
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    NSLog(@"%@\n %@", dataContent, resultsDictionary);
    if ([[resultsDictionary valueForKey:@"status"] isEqualToString:@"ok"]) {
        
        // If already reached the last page in loadmore function
//        if (NO) {
//            isLastPage = YES;
//            return YES;
//        }
        
        NSDictionary *posts = [resultsDictionary objectForKey:@"list"];
        
        // Store schedules in table data
        for (id row in posts)
        {
            PostClass *data = [[PostClass alloc] init];
            data.postId = [[row objectForKey:@"id"] integerValue];
            data.text = [NSString stringWithFormat:@"%@", [row objectForKey:@"post_text"]];
            data.type = [row objectForKey:@"post_type"];
            data.userId = [row objectForKey:@"user_id"];
            data.qrcodeId = [[row objectForKey:@"qrcode_id"] integerValue];
            data.username = [row objectForKey:@"user_name"];
            data.datetime = [row objectForKey:@"formatted_time"];
            data.avatarURL = [row objectForKey:@"avatar_url"];
            data.isFavourite = [row objectForKey:@"is_fav"];
            data.totalComment = [row objectForKey:@"comment_count"];
            data.totalFavourite = [row objectForKey:@"fav_count"];
            data.imageURL = [row objectForKey:@"post_photo"];
            data.sharedPostId = [[row objectForKey:@"shared_post_id"] integerValue];
            if (data.sharedPostId > 0) {
                data.sharedItem = [NSDictionary dictionaryWithDictionary:[row objectForKey:@"shared_from"]];
//                NSLog(@"data %@",[row objectForKey:@"shared_from"]);
            }
            
//            NSLog(@"shared item %@", data.sharedItem);
            NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
            NSMutableString *tmpString = [[NSMutableString alloc] initWithString:@""];
            
            // Store tagged users in array
            for (id kdata in [row objectForKey:@"tagged_buddies"]) {
                [tmpArray addObject:kdata];
            }
            
            // Store tagged users in string
            for (int i = 0; i < [tmpArray count]; i++) {
                if (i > 0) {
                    [tmpString appendString:@", "];
                }
                [tmpString appendFormat:@"%@", [[tmpArray objectAtIndex:i] valueForKey:@"username"]];
            }
            data.taggedUsersString = tmpString;
    
            data.taggedUsersArray = [tmpArray copy];
            [tmpArray release];
            [newData addObject:data];
        }
        
    }else{
        // If status error
        
        [newData release];
        return NO;
    }
    
    if ([newData count]) {
        if ([tableData count] && page == 1) {
            [tableData removeAllObjects];
        }
        
        [tableData addObjectsFromArray:newData];
        [newData release];
    }else{
        [newData release];
        return NO;
    }
    
    
    return YES;
}

#pragma mark -
#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableData count] && [tableData count] > kDisplayPerPage-1) {
        return [tableData count]+1;
    }
    return [tableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return 4;
    if (section < [tableData count]) {
        return 4;
    }else if (section == [tableData count] && [tableData count] > kDisplayPerPage-1) {
        return 1;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == [tableData count]) {
        return 0;
    }
    
    return kHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == [tableData count] ) {
        return 0;
    }
    
    return kFooterHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == [tableData count] && [tableData count] > kDisplayPerPage-1) {
        return 22;
    }
    
    PostClass *data = [tableData objectAtIndex:indexPath.section];
    
    if (indexPath.row == 0) { // for text
        
        // Get appropriate height for cell based on word / characters counting
        CGSize  textSize = { 300, 70 };
        CGSize size = [data.text sizeWithFont:[UIFont systemFontOfSize:14]
                            constrainedToSize:textSize
                                lineBreakMode:UILineBreakModeWordWrap];
        
        CGFloat height = size.height < kMinCellHeight ? kMinCellHeight : size.height;
        
        return height;
    }
    else if (indexPath.row == 1)
    {
        if ([data.taggedUsersArray count]) {
//            return kMinCellTagHeight;
            // Get appropriate height for cell based on word / characters counting
            CGSize  textSize = { 300, 10000.0 };
            CGSize size = [data.taggedUsersString sizeWithFont:[UIFont systemFontOfSize:14]
                                constrainedToSize:textSize
                                    lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat height = size.height < kMinCellTagHeight ? kMinCellTagHeight : size.height;
            
            return height;
        }else{
            return 0;
        }
    }
    else if (indexPath.row == 2){
        if ([data.type isEqualToString:@"PHOTO"])
        {
            return kImageCellHeight;
        }
        else{
            return 0;
        }
        
    }
    else if (indexPath.row == 3){
        if (data.sharedPostId > 0)
        {
            CGSize  textSize = { 280, 70 };
            CGSize size = [[data.sharedItem objectForKey:@"post_text"] sizeWithFont:[UIFont systemFontOfSize:12]
                                constrainedToSize:textSize
                                    lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat height = kStartCalcCellShareHeight + size.height + 10;
            if ([[data.sharedItem objectForKey:@"post_type"] isEqualToString:@"PHOTO"]) {
                height += kImageShareHeight + 10;
            }
            return height;
        }
        else{
            return 0;
        }
        
    }
    
    return 0;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (section == [tableData count]) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        return v;
    }
    
    PostHeaderView *header = [[PostHeaderView alloc] init];
    header.delegate = self;
    header.tag = section;
    
    PostClass *data = [tableData objectAtIndex:section];
    
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
    
    [header setBoldText:data.username withFullText:fullText boldPostfix:shareUsername andTime:data.datetime];
    
    [header.imageView setImageWithURL:[NSURL URLWithString:data.avatarURL]
                     placeholderImage:[UIImage imageNamed:@"blank_avatar"]];
    
    [header.qrcodeImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.jam-bu.com/qrcode/%d.png", data.qrcodeId]]
                           placeholderImage:[UIImage imageNamed:@"preview"]];
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == [tableData count]) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        return v;
    }
    
    PostFooterView *footer = [[PostFooterView alloc] init];
    footer.tag = section;
    footer.delegate = self;
    
    PostClass *data = [tableData objectAtIndex:section];
    [footer.deleteButton setHidden:YES];
    
    // Display delete button if user's own post and in private
    if ([data.userId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]])
    {
        if (self.pageType == kPersonal) {
            [footer.deleteButton setHidden:NO];
        }
    }
    
    [footer setupWithFav:data.totalFavourite andComment:data.totalComment];
    if ([data.isFavourite intValue] == 1) {
        [footer.favoriteButton setImage:[UIImage imageNamed:@"btn-fav-unfav-mr"] forState:UIControlStateNormal];
    }else{
        [footer.favoriteButton setImage:[UIImage imageNamed:@"btn-fav-mr"] forState:UIControlStateNormal];
    }
    
    return footer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"section %d, row %d", indexPath.section, indexPath.row);
    
    if (indexPath.section == [tableData count] && indexPath.row == 0){
        ShopLoadingCell *cell = (ShopLoadingCell*)[tableView dequeueReusableCellWithIdentifier:@"ShopLoadingCell"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ShopLoadingCell" owner:nil options:nil];
            cell = [nib objectAtIndex:0];
        }
        [cell.loadingIndicator startAnimating];
        
//        NSLog(@"loading");
        cell.backgroundView = [[[UIView alloc] initWithFrame:cell.bounds] autorelease];
        
        return cell;
        
    }
    
    PostClass *data = [tableData objectAtIndex:indexPath.section];
    
    if (indexPath.row == 0) // populate text data
    {
        PostTextCell *cell = (PostTextCell *)[tableView dequeueReusableCellWithIdentifier:@"PostTextCell"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PostTextCell" owner:nil options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        CGSize  textSize = { 300, 70 };
        CGSize size = [data.text sizeWithFont:[UIFont systemFontOfSize:14]
                            constrainedToSize:textSize
                                lineBreakMode:UILineBreakModeWordWrap];
        
        CGFloat height = size.height < kMinCellHeight ? kMinCellHeight : size.height;
        
        cell.postTextLabel.frame = CGRectMake(0, 0, tableView.frame.size.width-20, height);
        [cell.postTextLabel setFont:[UIFont systemFontOfSize:14]];
        
//        NSString *temp = data.text;
//        if ([temp length] > 100) {
//            NSRange range = [temp rangeOfComposedCharacterSequencesForRange:(NSRange){0, 100}];
//            temp = [temp substringWithRange:range];
//            temp = [temp stringByAppendingString:@" …"];
//        }
        if ([data.text length] > 120) {
            int len = [self getPostTextLessLength:data.text];
            NSString *temp = data.text;
            NSRange range = [temp rangeOfComposedCharacterSequencesForRange:(NSRange){0, len}];
            data.text = [temp substringWithRange:range];

            CGSize  newTextSize = { 10000, 40 };
            CGSize newSize = [data.text sizeWithFont:[UIFont systemFontOfSize:14]
                                constrainedToSize:newTextSize
                                    lineBreakMode:UILineBreakModeCharacterWrap];
//            double k = fmod(newSize.width, 300.0);
            CGFloat k = (float)((int)newSize.width % 300);
            NSLog(@"len %f", k);
//            data.text = [temp stringByAppendingString:@" … more"];
        }
        [cell.postTextLabel setText:data.text];

        cell.postTextLabel.numberOfLines = 3;
        
        
//        NSLog(@"label = %@", cell.postTextLabel.text);
        
        // To remove group cell border
        cell.backgroundView = [[[UIView alloc] initWithFrame:cell.bounds] autorelease];
        return cell;
    }
    else if (indexPath.row == 1)
    {
        PostTaggedCell *cell = (PostTaggedCell *)[tableView dequeueReusableCellWithIdentifier:@"PostTaggedCell"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PostTaggedCell" owner:nil options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        if ([data.taggedUsersArray count]) {
            [cell.taggedLabel setHidden:NO];
            [cell.taggedLabel setTextColor:[UIColor colorWithHex:@"#D22042"]];
            [cell.taggedLabel setText:data.taggedUsersString];
            cell.taggedLabel.frame = CGRectMake(0, 0, tableView.frame.size.width-30, kMinCellHeight);
            [cell.taggedLabel setFont:[UIFont systemFontOfSize:14]];
            [cell.taggedLabel sizeToFit];
        }else{
            [cell.taggedLabel setHidden:YES];
        }
        
        // To remove group cell border
        cell.backgroundView = [[[UIView alloc] initWithFrame:cell.bounds] autorelease];
        return cell;
    }
    else if (indexPath.row == 2){
        PostImageCell *cell = (PostImageCell *)[tableView dequeueReusableCellWithIdentifier:@"PostImageCell"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PostImageCell" owner:nil options:nil];
            cell = [nib objectAtIndex:0];
        }
        if ([data.type isEqualToString:@"PHOTO"])
        {
            [cell.postImageView setHidden:NO];
            [cell.postImageView setImageWithURL:[NSURL URLWithString:data.imageURL]
                               placeholderImage:[UIImage imageNamed:@"default_icon"]
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                          if (!error) {
                                              
                                          }else{
                                              NSLog(@"error retrieve image: %@",error);
                                          }
                                          
                                      }];
        }else{
            [cell.postImageView setHidden:YES];
        }
        // To remove group cell border
        cell.backgroundView = [[[UIView alloc] initWithFrame:cell.bounds] autorelease];
        return cell;

    }
    else if (indexPath.row == 3){
        
        static NSString *CellIdentifier = @"ShareCell";
        ShareCell *cell = (ShareCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[ShareCell alloc] init];
        }
        
        
        // To remove group cell border
        cell.backgroundView = [[[UIView alloc] initWithFrame:cell.bounds] autorelease];
        
        if (data.sharedPostId > 0) {
            [cell setupCell:data.sharedItem];
            cell.userInteractionEnabled = YES;
        }
        else {
            [cell setHidden:YES];
            cell.userInteractionEnabled = YES;
        }
        return cell;
        
    }
    
    [data release];
    
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        [self pushDetailPost:indexPath.section withOption:kOriginalPost];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == [tableData count] && [tableData count] > kDisplayPerPage-1) {
        pageCounter++;
        NSLog(@"here");
        [self loadMoreData];
    }
}

- (void)loadMoreData
{
    NSLog(@"Page now is %d", pageCounter);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success = [self retrieveData:pageCounter];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!success) {
                // Hide loading cell
                [UIView animateWithDuration:0.5 animations:^{
                    CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height-80);
                    [self.tableView setContentOffset:bottomOffset animated:YES];
                }];
                pageCounter--;
            }else{
                // Append new data to table and reload tableView
                [self.tableView reloadData];
            }

        });
    });
    
}

- (int)getPostTextLessLength:(NSString *)str
{
    NSArray *seperated = [str componentsSeparatedByString:@" "];
    
    int totalChar = 0;
    int totalWord = 0;
    for (NSString *word in seperated) {
        totalChar += [word length];
        
        if (totalChar > 100) {
            totalWord--;
            break;
        }else{
            totalWord++;
        }
    }
    
//    return tmp;
    NSRange wordRange = NSMakeRange(0,totalWord);
    NSString *result = [[seperated subarrayWithRange:wordRange] componentsJoinedByString:@" "];
    
    return [result length];
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
    NSLog(@"clicked %d",headerView.tag);
    
    PostClass *data = [tableData objectAtIndex:headerView.tag];
    
    NSArray *optionList = nil;
    if ([data.userId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]] ) {
        optionList = options2;
    }else{
        optionList = options;
    }
    
    // Store qrcode image
    currImage = headerView.qrcodeImageView.image;
    
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
#pragma mark PostFooterView delegate

- (void)tableFooter:(PostFooterView *)footerView didClickedCommentAtIndex:(NSInteger)index
{
    PostClass *data = [tableData objectAtIndex:index];
//    NSString *idForComment = [NSString stringWithFormat:@"%d",data.postId];
    AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CreatePostViewController *createComment = [[CreatePostViewController alloc] initWithPlaceholderText:@"Write a comment." withLabel:@"COMMENT" andComment:data.postId];
    [mydelegate.wallNavController pushViewController:createComment animated:YES];
    [createComment release];
    
    reloadDisabled = YES;
//    NSLog(@"commentPostId %@ index %d", idForComment, index);
}

- (void)tableFooter:(PostFooterView *)footerView didClickedFavouriteAtIndex:(NSInteger)index
{
    // Do fav or unfav the selected post
    
    [footerView.loadingIndicator setHidden:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        PostClass *data = [tableData objectAtIndex:index];
        
        NSString *urlString = [NSString stringWithFormat:@"%@/api/wall_post_fav.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
        NSString *dataContent = [NSString stringWithFormat:@"{\"post_id\":\"%d\"}",(int)data.postId];
        
        NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
        NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([[resultsDictionary valueForKey:@"status"] isEqualToString:@"ok"])
            {
                if ([[resultsDictionary valueForKey:@"is_fav"] intValue] == 1) {
                    [footerView.favoriteButton setImage:[UIImage imageNamed:@"btn-fav-unfav-mr"] forState:UIControlStateNormal];
                }else{
                    [footerView.favoriteButton setImage:[UIImage imageNamed:@"btn-fav-mr"] forState:UIControlStateNormal];
                }
                
                [footerView setupWithFav:[resultsDictionary valueForKey:@"fav_count"] andComment:@""];
            }
            
            [footerView.loadingIndicator setHidden:YES];
        });
    });

}

- (void)tableFooter:(PostFooterView *)footerView didClickedDeleteAtIndex:(NSInteger)index
{
    // delete selected post in personal
    
    [footerView.loadingIndicator setHidden:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        PostClass *data = [tableData objectAtIndex:index];
        
        NSString *urlString = [NSString stringWithFormat:@"%@/api/wall_post_delete.php?token=%@",APP_API_URL,[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]];
        NSString *dataContent = [NSString stringWithFormat:@"{\"post_id\":\"%d\"}", data.postId];
        
        NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
        NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
        NSLog(@"%@", resultsDictionary);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([[resultsDictionary valueForKey:@"status"] isEqualToString:@"ok"])
            {
//                [tableData removeAllObjects];
                [self setup];
            }
            
            [footerView.loadingIndicator setHidden:YES];
        });
    });
}

- (void)tableFooter:(PostFooterView *)footerView didClickedCommentLinkAtIndex:(NSInteger)index
{
    [self pushDetailPost:index withOption:kCommentView];
    
}

- (void)tableFooter:(PostFooterView *)footerView didClickedFavouriteLinkAtIndex:(NSInteger)index
{
    [self pushDetailPost:index withOption:kFavView];
}

- (void)pushDetailPost:(NSInteger)index withOption:(int)option
{
    
    AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    DetailPostViewController *detailvc = [[DetailPostViewController alloc] init];
    PostClass *data = [tableData objectAtIndex:index];
    
    if (option == kOriginalPost) {
        detailvc.postId = data.sharedPostId;
    }else{
        detailvc.postId = data.postId;
        detailvc.currentView = option;
    }
    
    [mydelegate.wallNavController pushViewController:detailvc animated:YES];
    [detailvc release];
    
}

#pragma mark -
#pragma mark MyPopupViewDelegate

- (void)popView:(MyPopupView *)popupView didSelectOptionAtIndex:(NSInteger)index
{
    if (index < 5 && ![ConnectionClass connected]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"J-ROOM" message:@"Connection problem occured." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
        [alert release];
        [self removeBlackView];
        return;
    }
    
    NSLog(@"Clicked at post index %d and selected option %d", popupView.tag, index);
    
    PostClass *data = [tableData objectAtIndex:popupView.tag];
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
        case 4:
        {
            
            
            ReportSpamViewController *detailView = [[ReportSpamViewController alloc] init];
            detailView.qrcodeId = [NSString stringWithFormat:@"%d",data.qrcodeId];
            detailView.postId = [NSString stringWithFormat:@"%d",data.postId];
            detailView.qrTitle = data.text;
            detailView.qrProvider = data.username;
            detailView.qrDate = data.datetime;
            detailView.qrAbstract = @"";
            detailView.qrType = @"J-ROOM";
            detailView.qrCategory = @"Wall Post";
            detailView.qrLabelColor = @"#0099FF";
//            detailView.qrImage = [UIImage imageNamed:@"avatar_blank"];
//            NSURL *iurl = [NSURL URLWithString: data.avatarURL];
            if (![data.type isEqualToString:@"PHOTO"]) {
               detailView.imageURL = [NSString stringWithFormat:@"http://www.jam-bu.com/qrcode/%d.png", data.qrcodeId];
            }else{
                detailView.imageURL = data.imageURL;
            }
//            NSData *imageData = [NSData dataWithContentsOfURL:iurl];
//            detailView.qrImage = [UIImage imageWithData:imageData];
  
            [mydelegate.wallNavController pushViewController:detailView animated:YES];
            [detailView release];
            break;
        }
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
//                [tableData removeAllObjects];
                [self setup];
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
        NSData *imageData = UIImagePNGRepresentation(currImage);
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
    [twitter addImage:currImage];
    
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

        [mySLComposerSheet addImage:currImage];
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
    [_tableView release];
    [_loadingIndicator release];
    [_loadingLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [self setLoadingIndicator:nil];
    [self setLoadingLabel:nil];
    [super viewDidUnload];
}
@end
