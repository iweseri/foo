//
//  AddPhonebookViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 4/1/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "AddPhonebookViewController.h"
#import "AddBuddyHeader.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AddressBook/AddressBook.h>
#import "BuddyCell.h"
#import "ASIWrapper.h"
#import "CustomAlertView.h"
#import "DejalActivityView.h"
#import "AppDelegate.h"

#define kBuddyCellHeight 64

@interface AddPhonebookViewController ()

@end

@implementation AddPhonebookViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        FontLabel *titleViewUsingFL = [[FontLabel alloc] initWithFrame:CGRectZero fontName:@"jambu-font.otf" pointSize:22];
        titleViewUsingFL.text = @"J-Buddy";
        titleViewUsingFL.textAlignment = NSTextAlignmentCenter;
        titleViewUsingFL.backgroundColor = [UIColor clearColor];
        titleViewUsingFL.textColor = [UIColor whiteColor];
        [titleViewUsingFL sizeToFit];
        self.navigationItem.titleView = titleViewUsingFL;

        
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                          style:UIBarButtonItemStyleBordered
                                         target:nil
                                         action:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.delegate = self;
    [self.tableView setHidden:YES];
    [self.recordLabel setHidden:NO];
    joinTableData = [[NSMutableArray alloc] init];
    inviteTableData = [[NSMutableArray alloc] init];
    copyListOfJoin = [[NSMutableArray alloc] init];
    copyListOfInvite = [[NSMutableArray alloc] init];
    
    self.searchBar.delegate = self;
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, self.view.frame.size.width, 1)];
    [overlayView setBackgroundColor:[UIColor whiteColor]];
    [self.searchBar addSubview:overlayView]; // navBar is your UINavigationBar instance
    //[overlayView release];
    
//    [self getAutorizedForContact];
}

- (void)viewDidAppear:(BOOL)animated
{

//    [self performSelector:@selector(getAutorizedForContact) withObject:nil afterDelay:0.1];
//    [self.tableView reloadData];
//    searching = NO;
//    selectRowEnabled = YES;
    
    [self.loadingIndicator startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getAutorizedForContact];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            searching = NO;
            selectRowEnabled = YES;
            
            if ([inviteTableData count] || [joinTableData count]) {
                [self.tableView setHidden:NO];
                [self.recordLabel setHidden:YES];
            } else {
                [self.tableView setHidden:YES];
                [self.recordLabel setHidden:NO];
                self.recordLabel.text = @"No results.";
            }
            
            [self.loadingIndicator stopAnimating];
        });
    });
    
    NSLog(@"vda-addBuddy");
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"vwd-addBuddy"); //[self.tableData removeAllObjects];
    [self clearSearchBar:self.searchBar];
}

#pragma mark -
#pragma mark Get Contact Person

-(void)getAutorizedForContact
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            // First time access has been granted, add the contact
            [self getPersonOutOfAddressBook];
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        [self getPersonOutOfAddressBook];
    }
    else {
        CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Notifications are OFF" message:@"To add new buddy, you must enable Push Notifications. Go to your iPhone's Settings screen to enable. Return to Jam-bu, press 'OK' and enter again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
}

- (void)getPersonOutOfAddressBook
{
    CFErrorRef error = NULL;
    NSMutableArray *arrayOfContacts = [[NSMutableArray alloc] init];
    //    NSMutableArray *mobileData = [[NSMutableArray alloc] init];
    //    NSMutableArray *emailData = [[NSMutableArray alloc] init];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook != nil)
    {
        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSUInteger i = 0;
        for (i = 0; i < [allContacts count]; i++)
        {
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            
            ABMultiValueRef mobiles = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            NSString *mobile = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(mobiles, 0);
            
            ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
            NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, 0);
            
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            
            NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            NSString *fullname;
            if (![lastName length]) {
                fullname = firstName;
            }else{
                fullname = [NSString stringWithFormat:@"%@ %@",firstName, lastName];
            }
//            NSLog(@"-- %@, %@, %@", fullname, email, mobile);
            if (![fullname length]) {
                fullname = @"";
            }
            if (![email length]) {
                email = @"";
            }
            if (![mobile length]) {
                mobile = @"";
            }
            
            NSDictionary *contactDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                         fullname, @"name",
                                         email, @"email",
                                         mobile, @"mobile",
                                         nil];
            [arrayOfContacts addObject:contactDict];

        }
    }
    CFRelease(addressBook);
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrayOfContacts
                                                       options:NSJSONWritingPrettyPrinted error:&jsonError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", arrayOfContacts);
    [self retrieveDataFromAPIWithContactJSON:jsonString];
}

#pragma mark -
#pragma mark retrieve Data From API

- (void)retrieveDataFromAPIWithContactJSON:(NSString *)jsonString
{
    //[tableData removeAllObjects];
    [joinTableData removeAllObjects];
    [inviteTableData removeAllObjects];
    
//    NSLog(@"mobile %@", mobile);
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_match.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"contacts\":%@}",jsonString];
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    NSLog(@"result %@", resultsDictionary);
    if([resultsDictionary count]) {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        if ([status isEqualToString:@"ok"]) {
            for (id data in [resultsDictionary objectForKey:@"matched_list"]) {
                [joinTableData addObject:data];
            }
            for (id data in [resultsDictionary objectForKey:@"unmatched_list"]) {
                [inviteTableData addObject:data];
            }
        } else {
            CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"J-Buddy" message:[resultsDictionary objectForKey:@"status"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    
//    if (![joinTableData count] && ![inviteTableData count]) {
//        self.recordLabel.text = @"No results.";
//        [self.tableView setHidden:YES];
//    }else{
//        [self.tableView]
//    }
//    [self.tableView reloadData];
//    [DejalBezelActivityView removeViewAnimated:YES];
    
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
    
    //[copyListOfItems removeAllObjects];
    [copyListOfJoin removeAllObjects];
    [copyListOfInvite removeAllObjects];
    
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
    //NSMutableArray *srchTemp = [[NSMutableArray alloc]init];
    //srchTemp = [[self processSearch] copy]; NSLog(@"DATA:%@",[self processSearch]);
    for (id row in joinTableData) {
        NSString *username = [row objectForKey:@"username"];
        NSRange titleResultsRange = [username rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.length > 0)
            [copyListOfJoin addObject:row];
    }
    for (id row in inviteTableData) {
        NSString *username = [row objectForKey:@"username"];
        NSRange titleResultsRange = [username rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.length > 0)
            [copyListOfInvite addObject:row];
    }
}

//- (NSMutableArray*)processSearch
//{
//    NSMutableArray *searchTemp = [[NSMutableArray alloc]init];
//    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_search.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
//    NSString *dataContent = [NSString stringWithFormat:@"{\"search\":\"%@\"}",self.searchBar.text];
//
//    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
//    NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
//    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
//
//    if([resultsDictionary count]) {
//        NSString *status = [resultsDictionary objectForKey:@"status"];
//        if ([status isEqualToString:@"ok"]) {
//            for (id data in [resultsDictionary objectForKey:@"list"]) {
//                [searchTemp addObject:data];
//            }
//        }
//    }
//    return searchTemp;
//    //[resultsDictionary release];
//
////    if ([tableData count] > 0) {
////        [self.tableView setHidden:NO];
////        [self.noRecordLabel setHidden:YES];
////    }else{
////        [self.noRecordLabel setHidden:NO];
////        [self.tableView setHidden:YES];
////    }
//    //[self.tableView reloadData];
//    [self.loadingIndicator stopAnimating];
//}

#pragma mark -
#pragma mark TableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    AddBuddyHeader *header = [[[NSBundle mainBundle] loadNibNamed:@"AddBuddyHeader" owner:self options:nil]objectAtIndex:0];
    
    if (section == 0) {
        [header.contactLabel setHidden:NO];
        [header.inviteLabel setHidden:YES];
    } else {
        [header.contactLabel setHidden:YES];
        [header.inviteLabel setHidden:NO];
    }
    return header;
}

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(selectRowEnabled)
        return indexPath;
    else
        return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int totalRow;
    if (searching){
        if (section == 0) {
            totalRow = [copyListOfJoin count];
        } else {
            totalRow = [copyListOfInvite count];
        }
    }
    else {
        if (section == 0) {
            totalRow = [joinTableData count];
        } else {
            totalRow = [inviteTableData count];
        }
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
        if (indexPath.section == 0) {
            cellData = [copyListOfJoin objectAtIndex:indexPath.row];
        } else {
            cellData = [copyListOfInvite objectAtIndex:indexPath.row];
        }
    }else{
        if (indexPath.section == 0) {
            cellData = [joinTableData objectAtIndex:indexPath.row];
        } else {
            cellData = [inviteTableData objectAtIndex:indexPath.row];
        }
    }
//    NSLog(@"cell data %@",cellData);
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
    [cell.addButtton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [cell.addButtton setTintColor:[UIColor whiteColor]];
    if (indexPath.section == 0) {
        [cell.addButtton setBackgroundImage:[UIImage imageNamed:@"addBuddy"]
                                   forState:UIControlStateNormal];
        [cell.addButtton addTarget:self action:@selector(handleAddButtons:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell.addButtton setBackgroundImage:[UIImage imageNamed:@"inviteBuddy"]
                                   forState:UIControlStateNormal];
        if ([[cellData valueForKey:@"invited"] isEqualToString:@"true"]) {
            [cell.addButtton setEnabled:NO];
        }else{
            [cell.addButtton setEnabled:YES];
            [cell.addButtton addTarget:self action:@selector(handleAddButtons:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    [cell addSubview:cell.addButtton];
    NSLog(@"TAG:%d",indexPath.row);
    return cell;
}

- (void)handleAddButtons:(UIButton *)btn
{
//    [self clearSearchBar:self.searchBar];
    NSDictionary *buddyDict = nil;
    NSString *word = @"";
    
    if (btn.currentBackgroundImage == [UIImage imageNamed:@"addBuddy"]) {
        buddyDict = [joinTableData objectAtIndex:btn.tag];
        word = @"Add";
    }else{
        buddyDict = [inviteTableData objectAtIndex:btn.tag];
        word = @"Invite";
    }
    
    NSString *username = [buddyDict objectForKey:@"username"];
    NSInteger userId = [[buddyDict objectForKey:@"jambu_user_id"] integerValue];
    NSString *msg = [NSString stringWithFormat:@"%@ %@ to your buddy list?", word, username];
    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"J-BUDDY" message:msg delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    if (userId == 0) {
//        tmpData = [buddyDict objectForKey:@"email"]; // process invite methods
        tmpData = [NSString stringWithFormat:@"%d", btn.tag];
    }else{
        tmpData = [NSString stringWithFormat:@"%d", btn.tag];
        alert.tag = userId;
    }
    [alert show];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kBuddyCellHeight;
}

#pragma mark -
#pragma mark AlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (alertView.tag) {
//            [self processAddBuddy:alertView.tag];
            [self.loadingIndicator startAnimating];
            [self performSelector:@selector(processAddBuddy:) withObject:[NSNumber numberWithInt:alertView.tag] afterDelay:0];
        }else{
            [self performSelector:@selector(processInviteBuddy:) withObject:[NSNumber numberWithInt:[tmpData intValue]] afterDelay:0];
        }
    
    }
}

- (void)processAddBuddy:(NSNumber *)tagId
{
    NSInteger buddyId = [tagId integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_add.php?token=%@",APP_API_URL,[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]];
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
            [joinTableData removeObjectAtIndex:[tmpData integerValue]];
            [self.tableView reloadData];
//            NSIndexPath *ip = [NSIndexPath indexPathForRow:[tmpData integerValue] inSection:0];
//            BuddyCell *cell = (BuddyCell *)[self.tableView cellForRowAtIndexPath:ip];
//            cell.addButtton.hidden = YES;
//            [self.tableView beginUpdates];
//            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:ip, nil] withRowAnimation:UITableViewRowAnimationTop];
//            [self.tableView endUpdates];
            
        }else{
            CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"J-BUDDY" message:[resultsDictionary objectForKey:@"message"] delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [alert show];
        }
        
    }
    
    [self.loadingIndicator stopAnimating];

}

- (void)processInviteBuddy:(NSNumber *)index
{
    NSMutableDictionary *dict = [[inviteTableData objectAtIndex:[index intValue]] mutableCopy];
//    [[inviteTableData objectAtIndex:[index intValue]] setObject:@"true" forKey:@"invited"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_invite.php?token=%@",APP_API_URL,[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"email\":\"%@\"}", [dict objectForKey:@"email"]];
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    
    if([resultsDictionary count])
    {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        if ([status isEqualToString:@"ok"])
        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadBuddyList" object:nil];
//            
//            NSIndexPath *ip = [NSIndexPath indexPathForRow:[tmpData integerValue] inSection:0];
//            BuddyCell *cell = (BuddyCell *)[self.tableView cellForRowAtIndexPath:ip];
//            cell.addButtton.hidden = YES;
            [dict setObject:@"true" forKey:@"invited"];
            [inviteTableData replaceObjectAtIndex:[index intValue] withObject:dict];
            
            CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"J-BUDDY" message:[resultsDictionary objectForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        
    }
    
    [self.tableView reloadData];
    
    [self.loadingIndicator stopAnimating];
    
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

//- (void)dealloc {
//    [_tableView release];
//    [_loadingIndicator release];
//    [_noRecordLabel release];
//    [super dealloc];
//}
@end
