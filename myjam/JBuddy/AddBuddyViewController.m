//
//  AddBuddyViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 4/1/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "AddBuddyViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BuddyCell.h"
#import "ASIWrapper.h"
#import "CustomAlertView.h"
#import "DejalActivityView.h"
#import "AppDelegate.h"

#define kBuddyCellHeight 64

@interface AddBuddyViewController ()

@end

@implementation AddBuddyViewController

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
    copyListOfItems = [[NSMutableArray alloc] init];
    
    self.searchBar.delegate = self;
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, self.view.frame.size.width, 1)];
    [overlayView setBackgroundColor:[UIColor whiteColor]];
    [self.searchBar addSubview:overlayView]; // navBar is your UINavigationBar instance
    [overlayView release];
    
    //[self retrieveDataFromAPI];
}

- (void)viewDidAppear:(BOOL)animated
{
    //[self retrieveDataFromAPI];
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading..." width:100];
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

- (void)retrieveDataFromAPI
{
    [tableData removeAllObjects];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_search.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"search\":\"\"}"];
    
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
                [tableData addObject:data];
            }
            
        }
        
    }
    [self.tableView reloadData];
    [DejalBezelActivityView removeViewAnimated:YES];
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
    [copyListOfItems removeAllObjects];
    
    if([searchBar.text length] > 0) {
        
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
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    
//    [copyListOfItems removeAllObjects];
//    
//    if([searchText length] > 0) {
//        
//        searching = YES;
//        selectRowEnabled = YES;
//        //        self.tableView.scrollEnabled = YES;
//        [self searchTableView];
//    }
//    else {
//        
//        searching = NO;
//        //        selectRowEnabled = NO;
//        //        self.tableView.scrollEnabled = NO;
//    }
//    [self.tableView reloadData];
}

- (void) searchTableView {
    
    NSString *searchText = self.searchBar.text;
    NSMutableArray *srchTemp = [[NSMutableArray alloc]init];
    srchTemp = [[self processSearch] copy]; NSLog(@"DATA:%@",[self processSearch]);
    for (id row in srchTemp) {
        NSString *username = [row objectForKey:@"username"];
        NSRange titleResultsRange = [username rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.length > 0)
            [copyListOfItems addObject:row];
    }
}

- (NSMutableArray*)processSearch
{
    NSMutableArray *searchTemp = [[NSMutableArray alloc]init];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_search.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"search\":\"%@\"}",self.searchBar.text];
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    
    if([resultsDictionary count]) {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        if ([status isEqualToString:@"ok"]) {
            for (id data in [resultsDictionary objectForKey:@"list"]) {
                [searchTemp addObject:data];
            }
        }
    }
    return searchTemp;
    //[resultsDictionary release];
    
//    if ([tableData count] > 0) {
//        [self.tableView setHidden:NO];
//        [self.noRecordLabel setHidden:YES];
//    }else{
//        [self.noRecordLabel setHidden:NO];
//        [self.tableView setHidden:YES];
//    }
    //[self.tableView reloadData];
    [self.loadingIndicator stopAnimating];
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

#pragma mark -
#pragma mark TableView delegate


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
        cellData = [tableData objectAtIndex:indexPath.row];
    }
    NSLog(@"cell data %@",cellData);
    [cell.usernameLabel setTextColor:[UIColor colorWithHex:@"#D22042"]];
    cell.usernameLabel.text = [cellData valueForKey:@"username"];
    cell.statusLabel.text = [cellData valueForKey:@"status"];
    [cell.userImageView setImageWithURL:[NSURL URLWithString:[cellData valueForKey:@"image"]]
                       placeholderImage:[UIImage imageNamed:@"blank_avatar"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  if (!error) {
                                      
                                  }else{
                                      NSLog(@"error retrieve image: %@",error);
                                  }
                              }];
    cell.addButtton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cell.addButtton setFrame:CGRectMake(260, 12, 60, 50)];
    //[cell.addButtton setTag:[[cellData valueForKey:@"jambu_user_id"] intValue]];
    [cell.addButtton setTag:indexPath.row];
    [cell.addButtton setClipsToBounds:YES];
    [cell.addButtton.layer setCornerRadius:10.0f];
    [cell.addButtton.layer setBorderWidth:2];
    [cell.addButtton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [cell.addButtton setBackgroundImage:[UIImage imageNamed:@"addBuddy"]
                              forState:UIControlStateNormal];
    [cell.addButtton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [cell.addButtton setTintColor:[UIColor whiteColor]];
    [cell.addButtton addTarget:self action:@selector(handleAddButtons:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:cell.addButtton];
    NSLog(@"TAG:%d",indexPath.row);
    return cell;
}

- (void)handleAddButtons:(UIButton*)addBtn
{
    [self clearSearchBar:self.searchBar];
    NSString *username = [[tableData objectAtIndex:addBtn.tag] objectForKey:@"username"];
    NSInteger userId = [[tableData objectAtIndex:addBtn.tag] objectForKey:@"jambu_user_id"];
    NSString *msg = [NSString stringWithFormat:@"Add %@ to your buddy list?",username];
    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"J-BUDDY" message:msg delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = userId;
    [alert show];
    [alert release];
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self clearSearchBar:self.searchBar];
//    NSLog(@"tapped at index %d",indexPath.row);
//    NSString *username = [[tableData objectAtIndex:indexPath.row] objectForKey:@"username"];
//    NSString *userId = [[tableData objectAtIndex:indexPath.row] objectForKey:@"jambu_user_id"];
//    NSString *msg = [NSString stringWithFormat:@"Add %@ to your buddy list?",username];
//    
//    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"J-BUDDY" message:msg delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
//    alert.tag = [userId intValue];
//    [alert show];
//    [alert release];
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBuddyCellHeight;
}

#pragma mark -
#pragma mark AlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1)
    {
        [self processAddBuddy:alertView.tag];
    }
}

- (void)processAddBuddy:(int)buddyId
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_add.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"jambu_user_id\":\"%d\"}",buddyId];
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    
    if([resultsDictionary count])
    {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        if ([status isEqualToString:@"ok"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadBuddyList" object:nil];
            AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [mydelegate.buddyNavController popToViewController:[mydelegate.buddyNavController.viewControllers objectAtIndex:0] animated:YES];
            //[self.navigationController popViewControllerAnimated:YES];
        }
        
    }
    
    [resultsDictionary release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableView release];
    [_loadingIndicator release];
    [_noRecordLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [self setLoadingIndicator:nil];
    [self setNoRecordLabel:nil];
    [super viewDidUnload];
}
@end
