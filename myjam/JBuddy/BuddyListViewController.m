//
//  ChatListViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 3/29/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "BuddyListViewController.h"
#import "ASIWrapper.h"
#import "AppDelegate.h"
#import "ChatViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kBuddyCellHeight 64

@interface BuddyListViewController ()

@end

@implementation BuddyListViewController


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
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.delegate = self;
    self.tableData = [[NSMutableArray alloc] init];
    copyListOfItems = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadBuddyList)
                                                 name:@"reloadBuddyList"
                                               object:nil];
    
    if (self.fromPlusButton) {
        [self retrieveDataFromAPI];
         [self.tableView reloadData];
         searching = NO;
         selectRowEnabled = YES;
    }
    self.searchBar.delegate = self;
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, self.view.frame.size.width, 1)];
    [overlayView setBackgroundColor:[UIColor whiteColor]];
    [self.searchBar addSubview:overlayView]; // navBar is your UINavigationBar instance
    [overlayView release];
}

- (void)reloadBuddyList
{
    [self retrieveDataFromAPI];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self retrieveDataFromAPI];
    [self.tableView reloadData];
    searching = NO;
    selectRowEnabled = YES; NSLog(@"vwa-newchat");
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"vwd-newchat"); //[self.tableData removeAllObjects];
    [self clearSearchBar:self.searchBar];
}

- (void)retrieveDataFromAPI
{
    [self.tableData removeAllObjects];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_new_chat_list.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = @"";
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];

    if([resultsDictionary count])
    {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        if ([status isEqualToString:@"ok"])
        {
            for (id data in [resultsDictionary objectForKey:@"list"])
            {
                [self.tableData addObject:data];
            }
            
        }
        
    }
    
    [resultsDictionary release];
}

#pragma mark -
#pragma mark SearchBar delegate

- (void)clearSearchBar:(UISearchBar*)sBar
{
    sBar.text = @"";
    [sBar setShowsCancelButton:NO animated:YES];
    searching = NO;
    [self.tableView reloadData];
    [sBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    
//    searching = YES;
//    selectRowEnabled = NO;
//    self.tableView.scrollEnabled = NO;
    [self.searchBar setShowsCancelButton:YES animated:NO];
    UIButton *cancelButton = nil;
    for(UIView *subView in theSearchBar.subviews){
        if([subView isKindOfClass:UIButton.class]){
            cancelButton = (UIButton*)subView;
        }
    }
    [cancelButton setTintColor:[UIColor lightGrayColor]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self clearSearchBar:searchBar];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    
    [copyListOfItems removeAllObjects];
    
    if([searchText length] > 0) {
        
        searching = YES;
        selectRowEnabled = YES;
//        self.tableView.scrollEnabled = YES;
        [self searchTableView];
    }
    else {
        
        searching = NO;
//        selectRowEnabled = NO;
//        self.tableView.scrollEnabled = NO;
    }
    
    [self.tableView reloadData];
}

- (void) searchTableView {
    
    NSString *searchText = self.searchBar.text;
    
    for (id row in self.tableData) {
        NSString *username = [row objectForKey:@"username"];
        NSRange titleResultsRange = [username rangeOfString:searchText options:NSCaseInsensitiveSearch];

        if (titleResultsRange.length > 0)
            [copyListOfItems addObject:row];
    }
}


#pragma mark -
#pragma mark TableView delegate

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(selectRowEnabled)
        return indexPath;
    else
        return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    int totalRow;
    
    if (searching){
        totalRow = [copyListOfItems count];
    }
    else {
        totalRow = [self.tableData count];
    }
    
    if (totalRow)
    {
        [self.tableView setHidden:NO];
        [self.recordLabel setHidden:YES];
    }else{
        [self.tableView setHidden:YES];
        [self.recordLabel setHidden:NO];
    }
    
    return totalRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"BuddyCell";
    
    BuddyCell *cell = (BuddyCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BuddyCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
    }

    NSDictionary *cellData = nil;
    if (searching) {
        cellData = [copyListOfItems objectAtIndex:indexPath.row];
    }else{
        cellData = [self.tableData objectAtIndex:indexPath.row];
    }
    
    NSLog(@"cell data %@",cellData);
    
    cell.buddyUserId = [cellData valueForKey:@"buddy_user_id"];
    cell.usernameLabel.text = [cellData valueForKey:@"username"];
    cell.statusLabel.text = [cellData valueForKey:@"status"];
    [cell.timeLabel setHidden:YES];
    [cell.dateLabel setHidden:YES];
    if ([cell.statusLabel.text isEqualToString:@"Pending Approval"]) {
        [cell.usernameLabel setTextColor:[UIColor colorWithHex:@"#00CC66"]];
        cell.statusLabel.text = @"Requested an invite. Accept?";
        
        [cell.approveButtonsView setHidden:NO];

        cell.noButton.tag = [cell.buddyUserId intValue];
        cell.yesButton.tag = [cell.buddyUserId intValue];
        
//        NSLog(@"xxxx %d", cell.yesButton.tag);
        [cell.noButton addTarget:self action:@selector(handleNotApproveButtons:) forControlEvents:UIControlEventTouchUpInside];
        [cell.yesButton addTarget:self action:@selector(handleApproveButtons:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([cell.statusLabel.text isEqualToString:@"Buddy Request Sent"]) {
        [cell.usernameLabel setTextColor:[UIColor colorWithHex:@"#00CC66"]];
        cell.statusLabel.text = @"*Pending invite";
        
    }
    else{
        if (self.fromPlusButton == YES){
            [cell.approveButtonsView setHidden:YES];
        }else{
            [cell.approveButtonsView setHidden:NO];
            [cell.noButton setHidden:YES];
            [cell.yesButton setImage:[UIImage imageNamed:@"btn-delete-mr"] forState:UIControlStateNormal];
            cell.yesButton.tag = [cell.buddyUserId intValue];
            [cell.yesButton addTarget:self action:@selector(handleDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    [cell.usernameLabel setTextColor:[UIColor colorWithHex:@"#D22042"]];

    [cell.userImageView setImageWithURL:[NSURL URLWithString:[cellData valueForKey:@"image"]]
                       placeholderImage:[UIImage imageNamed:@"blank_avatar"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  if (!error) {
                                      
                                  }else{
                                      NSLog(@"error retrieve image: %@",error);
                                  }
                                  
                              }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self clearSearchBar:self.searchBar];
    
    NSLog(@"tapped at index %d",indexPath.row);
    
    NSString *status = [[self.tableData objectAtIndex:indexPath.row] objectForKey:@"status"];
    if (![status isEqualToString:@"Pending Approval"] && ![status isEqualToString:@"Buddy Request Sent"]) {
    
        NSDictionary *buddy = [self.tableData objectAtIndex:indexPath.row];
        
        ChatViewController *newChat = [[ChatViewController alloc] initWithBuddyId:[buddy valueForKey:@"buddy_user_id"] andUsername:[buddy valueForKey:@"username"]];
        
        AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [mydelegate.otherNavController pushViewController:newChat animated:YES];
        [newChat release];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBuddyCellHeight;
}

- (void)handleApproveButtons:(UIButton *)button
{
    NSLog(@"YES");
    [self processApproveBuddy:button.tag withStatus:@"Confirm"];
}

- (void)handleNotApproveButtons:(UIButton *)button
{
    NSLog(@"NO");
    [self processApproveBuddy:button.tag withStatus:@"Delete Request"];
}

- (void)handleDeleteButton:(UIButton *)button
{
    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"J-BUDDY" message:@"Delete from your buddy list?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = button.tag;
    [alert show];
    [alert release];
}

- (void)processApproveBuddy:(int)buddyId withStatus:(NSString *)action
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_list.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"buddy_user_id\":\"%d\",\"action\":\"%@\"}",buddyId,action];
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    
    if([resultsDictionary count])
    {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        if ([status isEqualToString:@"ok"])
        {
            [self.tableData removeAllObjects];
            [self retrieveDataFromAPI];
            [self.tableView reloadData];
        }
        
    }
    
    [resultsDictionary release];
}

#pragma mark -
#pragma mark AlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1)
    {
        [self processApproveBuddy:alertView.tag withStatus:@"Delete Request"];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableView release];
    [_searchBar release];
    [_recordLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [self setSearchBar:nil];
    [self setRecordLabel:nil];
    [super viewDidUnload];
}
@end
