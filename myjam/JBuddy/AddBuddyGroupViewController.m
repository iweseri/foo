//
//  AddBuddyGroupViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 4/1/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "AddBuddyGroupViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BuddyCell.h"
#import "ASIWrapper.h"
#import "CustomAlertView.h"

#define kBuddyCellHeight 64

@interface AddBuddyGroupViewController ()

@end

@implementation AddBuddyGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithGroupId:(NSString *)gid andGroupname:(NSString *)gname
{
    self = [super init];
    if (self) {
        FontLabel *titleViewUsingFL = [[FontLabel alloc] initWithFrame:CGRectZero fontName:@"jambu-font.otf" pointSize:22];
        titleViewUsingFL.text = @"J-Buddy";
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
        self.groupId = gid;
        self.subjectName = gname;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    tableData = [[NSMutableArray alloc] init];
    self.subjectNameLabel.text = self.subjectName;
    self.subjectTextField.delegate = self;
}

- (IBAction)handleChangeSubject:(id)sender
{
    [self.loadingIndicator startAnimating];
    [self.subjectTextField resignFirstResponder];
    if ([self.subjectTextField.text length] > 0) {
        [self performSelector:@selector(processChanged) withObject:nil afterDelay:0.5];
    } else {
        CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"J-BUDDY" message:@"Please insert Subject" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)processChanged //list participants
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_group.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"group_id\":\"%@\",\"group_title\":\"%@\",\"action\":\"change_group_title\"}",self.groupId,self.subjectTextField.text];
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    
    if([resultsDictionary count]) {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        if ([status isEqualToString:@"ok"]) {
            NSDictionary *newSubject = [NSDictionary dictionaryWithObjectsAndKeys:self.subjectTextField.text,@"newSubject",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSubjectName" object:newSubject];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    [resultsDictionary release];
    [self.loadingIndicator stopAnimating];
}

- (void)listparticipants
{
    if ([tableData count] > 0) {
        [tableData removeAllObjects];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_group.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"group_id\":\"%@\",\"action\":\"\"}",self.groupId];
    
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
    
    [resultsDictionary release];
    
    if ([tableData count] > 0) {
        [self.tableView setHidden:NO];
        [self.noRecordLabel setHidden:YES];
    }else{
        [self.noRecordLabel setHidden:NO];
        [self.tableView setHidden:YES];
    }
    
    [self.tableView reloadData];
    [self.loadingIndicator stopAnimating];
}

#pragma mark -
#pragma mark Textfield delegate

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
#pragma mark TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
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
    
    NSDictionary *cellData = [tableData objectAtIndex:indexPath.row];
    
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
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tapped at index %d",indexPath.row);
    
//    NSString *username = [[tableData objectAtIndex:indexPath.row] objectForKey:@"username"];
//    NSString *userId = [[tableData objectAtIndex:indexPath.row] objectForKey:@"jambu_user_id"];
//    NSString *msg = [NSString stringWithFormat:@"Add %@ to your buddy list?",username];
//    
//    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"J-BUDDY" message:msg delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
//    alert.tag = [userId intValue];
//    [alert show];
//    [alert release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBuddyCellHeight;
}

#pragma mark -
#pragma mark AlertView delegate

//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if (buttonIndex == 1)
//    {
//        [self processAddBuddy:alertView.tag];
//    }
//}
//
//- (void)processAddBuddy:(int)buddyId
//{
//    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_add.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
//    NSString *dataContent = [NSString stringWithFormat:@"{\"jambu_user_id\":\"%d\"}",buddyId];
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
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadBuddyList" object:nil];
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//        
//    }
//    
//    [resultsDictionary release];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_subjectTextField release];
    [_tableView release];
    [_loadingIndicator release];
    [_noRecordLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setSubjectTextField:nil];
    [self setTableView:nil];
    [self setLoadingIndicator:nil];
    [self setNoRecordLabel:nil];
    [super viewDidUnload];
}
@end
