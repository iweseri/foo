//
//  PublicViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 5/9/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "PublicViewController.h"
#import "DetailPostViewController.h"
#import "AppDelegate.h"
#import "PostClass.h"

static CGFloat kHeaderHeight = 80;
static CGFloat kFooterHeight = 100;
static CGFloat kMinCellHeight = 22;

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

    // Init data array
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
    
    
    [self.view setBackgroundColor:[UIColor colorWithHex:@"#e8e8e8"]];
    [self.tableView setBackgroundColor:[UIColor colorWithHex:@"#e8e8e8"]];

    [self.tableView setHidden:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView setHidden:YES];
    [self.loadingLabel setHidden:NO];
    [self.loadingIndicator setHidden:NO];
}

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
    [self setup];
}

- (void)setup
{
    pageCounter = 1;
    BOOL success = [self retrieveData:pageCounter];
    if (success) {
        NSLog(@"count %d",[tableData count]);
        [self.tableView setHidden:NO];
        [self.tableView reloadData];
        
        [self.loadingLabel setHidden:YES];
        [self.loadingIndicator setHidden:YES];
    }
}

- (BOOL)retrieveData:(NSUInteger)page
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/wall_post_list.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = @"";
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
//    NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    
    if ([[resultsDictionary valueForKey:@"status"] isEqualToString:@"ok"]) {
        
        // If already reached the last page in loadmore function
        if (NO) {
            isLastPage = YES;
            return YES;
        }
        
        NSDictionary *posts = [resultsDictionary objectForKey:@"list"];
        
        // Store schedules in table data
        for (id row in posts) {
            PostClass *data = [[PostClass alloc] init];
            data.postId = [[row objectForKey:@"id"] integerValue];
            data.text = [NSString stringWithFormat:@"%@", [row objectForKey:@"post_text"]];
            data.type = [row objectForKey:@"post_type"];
            data.userId = [row objectForKey:@"user_id"];
            data.username = [row objectForKey:@"user_name"];
            data.datetime = [row objectForKey:@"datetime"];
            data.avatarURL = [row objectForKey:@"avatar_url"];
            data.isFavourite = [row objectForKey:@"is_fav"];
            data.totalComment = [row objectForKey:@"comment_count"];
            data.totalFavourite = [row objectForKey:@"fav_count"];
            [tableData addObject:data];
        }
        
        // If list is empty
        if (![tableData count]) {
            return NO;
        }
    }else{
        // If status error
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kFooterHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostClass *data = [tableData objectAtIndex:indexPath.section];
//    NSLog(@"data text %@", data.text);
    
    // Get appropriate height for cell based on word / characters counting
    CGSize  textSize = { 300, 10000.0 };
	CGSize size = [data.text sizeWithFont:[UIFont systemFontOfSize:14]
				  constrainedToSize:textSize
					  lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = size.height < kMinCellHeight ? kMinCellHeight : size.height;
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    PostHeaderView *header = [[PostHeaderView alloc] init];
    header.tag = section;
    header.delegate = self;
    
    PostClass *data = [tableData objectAtIndex:section];
    
    NSMutableString *fullText = [NSMutableString stringWithFormat:@"%@ ",data.username];
    
    if ([data.type isEqualToString:@"DEFAULT"]) {
        [fullText appendString:@"says"];
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
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    PostFooterView *footer = [[PostFooterView alloc] init];
    footer.tag = section;
    footer.delegate = self;
    
    PostClass *data = [tableData objectAtIndex:section];
    [footer setupWithFav:data.totalFavourite andComment:data.totalComment];
    
    return footer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"section %d, row %d", indexPath.section, indexPath.row);
    
    PostTextCell *cell = (PostTextCell *)[tableView dequeueReusableCellWithIdentifier:@"PostTextCell"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PostTextCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    PostClass *data = [tableData objectAtIndex:indexPath.section];
    
    cell.postTextLabel.frame = CGRectMake(0, 0, tableView.frame.size.width-20, kMinCellHeight);
    [cell.postTextLabel setFont:[UIFont systemFontOfSize:14]];
    [cell.postTextLabel setText:data.text];
    [cell.postTextLabel sizeToFit];
    
    // Create dinamic label
//    UILabel *postLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, cell.frame.size.width-20, kMinCellHeight)];
//    [postLabel setBackgroundColor:[UIColor clearColor]];
//    [postLabel setFont:[UIFont systemFontOfSize:14]];
//    [postLabel setText:data.text];
//    [postLabel setNumberOfLines:0];
//    [postLabel sizeToFit];
//    
//    [cell addSubview:postLabel];
//    [postLabel release];
    // To remove group cell border
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
#pragma mark PostFooterView delegate

- (void)tableFooter:(PostFooterView *)footerView didClickedCommentAtIndex:(NSInteger)index
{
    NSLog(@"c index %d", index);
}

- (void)tableFooter:(PostFooterView *)footerView didClickedFavouriteAtIndex:(NSInteger)index
{
    NSLog(@"f index %d", index);
}

- (void)tableFooter:(PostFooterView *)footerView didClickedCommentLinkAtIndex:(NSInteger)index
{
    NSLog(@"cl index %d", index);
    
    AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    DetailPostViewController *detailvc = [[DetailPostViewController alloc] init];
    PostClass *data = [tableData objectAtIndex:index];
    detailvc.postId = data.postId;
    [mydelegate.otherNavController pushViewController:detailvc animated:YES];
    [detailvc release];
}

- (void)tableFooter:(PostFooterView *)footerView didClickedFavouriteLinkAtIndex:(NSInteger)index
{
    NSLog(@"fl index %d", index);
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
