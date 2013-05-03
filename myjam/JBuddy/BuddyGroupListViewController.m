//
//  BuddyGroupListViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 3/29/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "BuddyGroupListViewController.h"
#import "ASIWrapper.h"
#import "AppDelegate.h"
#import "ChatViewController.h"
#import "GroupChatViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kFrameHeightOnKeyboardUp 315
#define kBuddyGroupCellHeight 64

@interface BuddyGroupListViewController ()

@end

@implementation BuddyGroupListViewController


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
    
    self.scroller = (TPKeyboardAvoidingScrollView*)self.view;
    [self.scroller setContentSize:CGSizeMake(self.contentView.frame.size.width, kFrameHeightOnKeyboardUp)];
    [self.scroller addSubview:self.contentView];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.delegate = self;
    self.tableData = [[NSMutableArray alloc] init];
    copyListOfItems = [[NSMutableArray alloc] init];
    self.searchBar.delegate = self;
    
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, self.view.frame.size.width, 1)];
    [overlayView setBackgroundColor:[UIColor whiteColor]];
    [self.searchBar addSubview:overlayView]; // navBar is your UINavigationBar instance
    [overlayView release];
    
    [self.subjectLabel setTextColor:[UIColor colorWithHex:@"#D22042"]];
    [self.participantLabel setTextColor:[UIColor colorWithHex:@"#D22042"]];
    self.subjectTextfield.delegate  = self;
    self.groupArray = [[NSMutableDictionary alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"vwa-NEWGROUP");
    [self retrieveDataFromAPI];
    [self.tableView reloadData];
    searching = NO;
    selectRowEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    //[self.tableData removeAllObjects];
}

- (void)retrieveDataFromAPI
{
    [self.tableData removeAllObjects];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_new_chat_list.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = @"";
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];

    if([resultsDictionary count]) {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        if ([status isEqualToString:@"ok"]) {
            for (id data in [resultsDictionary objectForKey:@"list"]) {
                [self.tableData addObject:data];
            }
        }
    }
    [resultsDictionary release];
}

#pragma mark -
#pragma mark Textfield delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField and:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark SearchBar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    //searching = YES;
    //selectRowEnabled = NO;
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
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    searching = NO;
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
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
    static NSString *simpleTableIdentifier = @"BuddyGroupCell";
    BuddyGroupCell *cell = (BuddyGroupCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BuddyGroupCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSLog(@"cell data %@\nJENG:%@",copyListOfItems,self.tableData);
    NSDictionary *cellData = nil;
    if (searching) {
        cellData = [copyListOfItems objectAtIndex:indexPath.row];
    }else{
        cellData = [self.tableData objectAtIndex:indexPath.row];
    }
    NSLog(@"cell data %@",cellData);
    
    cell.buddyUserId = [cellData valueForKey:@"buddy_user_id"];
    [cell.usernameLabel setText:(NSString*)[cellData valueForKey:@"username"]];
    [cell.statusLabel setText:[cellData valueForKey:@"status"]];
    [cell.timeLabel setHidden:YES];
    [cell.dateLabel setHidden:YES];
    [cell.approveButtonsView setHidden:YES];
    [cell.noButton setHidden:YES];
    [cell.usernameLabel setTextColor:[UIColor colorWithHex:@"#D22042"]];
    [cell.userImageView setImageWithURL:[NSURL URLWithString:[cellData valueForKey:@"image"]]
                       placeholderImage:[UIImage imageNamed:@"blank_avatar"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  if (!error) { }else{
                                      NSLog(@"error retrieve image: %@",error);
                                  }
                              }];
    NSLog(@"ARRAY :%@\nKEY :%@\nBID :%@",self.groupArray,[self.groupArray objectForKey:cell.buddyUserId],cell.buddyUserId);
    if ([cell.buddyUserId isEqual:[self.groupArray objectForKey:cell.buddyUserId]]) {
     [cell.addGroupButton setImage:[UIImage imageNamed:@"checkbox_active"] forState:UIControlStateNormal];
    } else {
     [cell.addGroupButton setImage:[UIImage imageNamed:@"checkbox_inactive"] forState:UIControlStateNormal];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tapped at index %d",indexPath.row);
    
    BuddyGroupCell *cell = (BuddyGroupCell *)[tableView cellForRowAtIndexPath:indexPath];

    NSDictionary *buddy = nil;
    
    if (searching) {
        buddy = [copyListOfItems objectAtIndex:indexPath.row];
    }else{
        buddy = [self.tableData objectAtIndex:indexPath.row];
    }
        NSString *buddyID = [buddy valueForKey:@"buddy_user_id"];
        NSLog(@"BuddyID :%@",[buddy valueForKey:@"buddy_user_id"]);
        
        [self handleTapGroupList:buddyID toThe:cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBuddyGroupCellHeight;
}

- (void)handleTapGroupList:(NSString*)bID toThe:(BuddyGroupCell*)cell
{
    if ([bID isEqual:[self.groupArray objectForKey:bID]]) {
        [self.groupArray removeObjectForKey:bID];
        [cell.addGroupButton setImage:[UIImage imageNamed:@"checkbox_inactive"] forState:UIControlStateNormal];
    } else {
        [self.groupArray setObject:bID forKey:bID];
        [cell.addGroupButton setImage:[UIImage imageNamed:@"checkbox_active"] forState:UIControlStateNormal];
    }
    NSMutableString *strData = [NSMutableString stringWithFormat:@""];
    int i = 0;
    for (id row in self.groupArray) {
        if (i == 0) {
            strData = [NSString stringWithFormat:@"%@",row];
        } else {
            strData = [NSString stringWithFormat:@"%@,%@",strData,row];
        } i++;
    }
    NSLog(@"SUBJECT :%@\nGROUP :%@",self.subjectTextfield.text,strData);
}

- (IBAction)groupChat:(id)sender {
    
    NSMutableString *strData = [NSMutableString stringWithFormat:@""];
    int i = 0;
    for (id row in self.groupArray) {
        if (i == 0) {
            strData = [NSString stringWithFormat:@"%@",row];
        } else {
            strData = [NSString stringWithFormat:@"%@,%@",strData,row];
        } i++;
    }
    NSLog(@"SUBJECT :%@\nGROUP :%@",self.subjectTextfield.text,strData);
    GroupChatViewController *newChat = [[GroupChatViewController alloc] init];
    AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [mydelegate.otherNavController pushViewController:newChat animated:YES];
    [newChat release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_groupArray release];
    [_tableView release];
    [_searchBar release];
    [_recordLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setGroupArray:nil];
    [self setTableView:nil];
    [self setSearchBar:nil];
    [self setRecordLabel:nil];
    [super viewDidUnload];
}

//- (void)handleApproveButtons:(UIButton *)button
//{
//    NSLog(@"YES");
//    [self processApproveBuddy:button.tag withStatus:@"Confirm"];
//}
//
//- (void)handleNotApproveButtons:(UIButton *)button
//{
//    NSLog(@"NO");
//    [self processApproveBuddy:button.tag withStatus:@"Delete Request"];
//}
//
//- (void)handleDeleteButton:(UIButton *)button
//{
//    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"J-BUDDY" message:@"Delete from your buddy list?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
//    alert.tag = button.tag;
//    [alert show];
//    [alert release];
//}
//
//- (void)processApproveBuddy:(int)buddyId withStatus:(NSString *)action
//{
//    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_list.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
//    NSString *dataContent = [NSString stringWithFormat:@"{\"buddy_user_id\":\"%d\",\"action\":\"%@\"}",buddyId,action];
//    
//    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
//    NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
//    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
//    
//    if([resultsDictionary count])
//    {
//        NSString *status = [resultsDictionary objectForKey:@"status"];
//        if ([status isEqualToString:@"ok"])
//        {
//            [self.tableData removeAllObjects];
//            [self retrieveDataFromAPI];
//            [self.tableView reloadData];
//        }
//        
//    }
//    
//    [resultsDictionary release];
//}
//
//#pragma mark -
//#pragma mark AlertView delegate

//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if (buttonIndex == 1)
//    {
//        [self processApproveBuddy:alertView.tag withStatus:@"Delete Request"];
//    }
//}

@end
