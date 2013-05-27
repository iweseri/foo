//
//  UnblockUsersViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 4/1/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "UnblockUsersViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AddressBook/AddressBook.h>
#import "BuddyGroupCell.h"
#import "ASIWrapper.h"
#import "CustomAlertView.h"
#import "DejalActivityView.h"
#import "AppDelegate.h"

#define kBuddyCellHeight 64

@interface UnblockUsersViewController ()

@end

@implementation UnblockUsersViewController

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
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.delegate = self;
    tableData = [[NSMutableArray alloc] init];
    copyListOfData = [[NSMutableArray alloc] init];
    listBuddy = [[NSMutableDictionary alloc] init];
    
    self.searchBar.delegate = self;
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, self.view.frame.size.width, 1)];
    [overlayView setBackgroundColor:[UIColor whiteColor]];
    [self.searchBar addSubview:overlayView]; // navBar is your UINavigationBar instance
    [overlayView release];
}

- (void)viewDidAppear:(BOOL)animated
{
//    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading..." width:100];
    [self.loadingIndicator setHidden:NO];
    [self performSelector:@selector(retrieveDataFromAPI) withObject:nil afterDelay:0.1];
    [self.tableView reloadData];
    searching = NO;
    selectRowEnabled = YES; NSLog(@"vda-addBuddy");
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"vwd-addBuddy"); //[self.tableData removeAllObjects];
    [self clearSearchBar:self.searchBar];
}

#pragma mark -
#pragma mark retrieve Data From API

- (void)retrieveDataFromAPI
{
    [tableData removeAllObjects];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/wall_user_blocked.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@""];
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    
    if([resultsDictionary count]) {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        if ([status isEqualToString:@"ok"]) {
            for (id data in [resultsDictionary objectForKey:@"list"]) {
                [tableData addObject:data];
            }
        } else {
            //CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"J-Wall" message:[resultsDictionary objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //[alert show];
        }
        
    }
    [self.tableView reloadData];
//    [DejalBezelActivityView removeViewAnimated:YES];
    
    [self.loadingIndicator setHidden:YES];
    [resultsDictionary release];
}

- (void)unblockBuddyToAPI:(NSString*)memberId
{
    
    [self.loadingIndicator setHidden:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *urlString = [NSString stringWithFormat:@"%@/api/wall_user_unblock.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
        NSString *dataContent = [NSString stringWithFormat:@"{\"buddy_user_ids\":\"%@\"}",memberId];
        
        NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
        NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
        NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if([resultsDictionary count]) {
                NSString *status = [resultsDictionary objectForKey:@"status"];
                if ([status isEqualToString:@"ok"]) {
//                    [self triggerRequiredAlert:[resultsDictionary objectForKey:@"message"]];
                    AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [mydelegate.otherNavController popToViewController:[mydelegate.otherNavController.viewControllers objectAtIndex:1] animated:NO];
                    
                } else {
                    [self triggerRequiredAlert:[resultsDictionary objectForKey:@"message"]];
                }
            }
        });
        
        [self.loadingIndicator setHidden:YES];
        [resultsDictionary release];
    });

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
    
    [copyListOfData removeAllObjects];
    
    if([searchText length] > 0) {
        searching = YES;
        selectRowEnabled = YES;
        //self.tableView.scrollEnabled = YES;
        [self searchTableView];
    }
    else {
        searching = NO;
        //selectRowEnabled = NO;
        //self.tableView.scrollEnabled = NO;
    }
    [self.tableView reloadData];
}

- (void) searchTableView {
    
    NSString *searchText = self.searchBar.text;
    for (id row in tableData) {
        NSString *username = [row objectForKey:@"username"];
        NSRange titleResultsRange = [username rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.length > 0)
            [copyListOfData addObject:row];
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
        totalRow = [copyListOfData count];
    }
    else {
        totalRow = [tableData count];
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
    NSLog(@"cell data %@\nJENG:%@",copyListOfData,tableData);
    NSDictionary *cellData = nil;
    if (searching) {
        cellData = [copyListOfData objectAtIndex:indexPath.row];
    }else{
        cellData = [tableData objectAtIndex:indexPath.row];
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
    NSLog(@"ARRAY :%@\nKEY :%@\nBID :%@",listBuddy,[listBuddy objectForKey:cell.buddyUserId],cell.buddyUserId);
    if ([cell.buddyUserId isEqual:[listBuddy objectForKey:cell.buddyUserId]]) {
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
        buddy = [copyListOfData objectAtIndex:indexPath.row];
    }else{
        buddy = [tableData objectAtIndex:indexPath.row];
    }
    NSString *buddyID = [buddy valueForKey:@"userid"];
    NSLog(@"BuddyID :%@",[buddy valueForKey:@"userid"]);
    
    [self handleTapGroupList:buddyID toThe:cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBuddyCellHeight;
}

- (void)handleTapGroupList:(NSString*)bID toThe:(BuddyGroupCell*)cell
{
    if ([bID isEqual:[listBuddy objectForKey:bID]]) {
        [listBuddy removeObjectForKey:bID];
        [cell.addGroupButton setImage:[UIImage imageNamed:@"checkbox_inactive"] forState:UIControlStateNormal];
    } else {
        [listBuddy setObject:bID forKey:bID];
        [cell.addGroupButton setImage:[UIImage imageNamed:@"checkbox_active"] forState:UIControlStateNormal];
    }
}

- (IBAction)unblockUser:(id)sender {
    
    NSMutableString *strData = [NSMutableString stringWithFormat:@""];
    int i = 0;
    for (id row in listBuddy) {
        if (i == 0) {
            strData = [NSString stringWithFormat:@"%@",row];
        } else {
            strData = [NSString stringWithFormat:@"%@,%@",strData,row];
        } i++;
    }
    NSLog(@"GROUP :%@",strData);
    
    if ([strData length]<1) {
        [self triggerRequiredAlert:@"Please select member."];
    } else {
        [self unblockBuddyToAPI:strData];
    }
}

- (void)triggerRequiredAlert:(NSString*)msg
{
    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"J-Wall" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setLoadingIndicator:nil];
    [self setNoRecordLabel:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [_tableView release];
    [_loadingIndicator release];
    [_noRecordLabel release];
    [super dealloc];
}
@end
