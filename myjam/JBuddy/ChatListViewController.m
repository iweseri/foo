//
//  ChatListViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 3/29/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "ChatListViewController.h"
#import "ASIWrapper.h"
#import "BuddyCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ChatViewController.h"
#import "GroupChatViewController.h"
#import "AppDelegate.h"

#define kBuddyCellHeight 64

@interface ChatListViewController ()

@end

@implementation ChatListViewController


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
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableData removeAllObjects];
    [self retrieveDataFromAPI];
    [self.tableView reloadData];
}


- (void)viewWillDisappear:(BOOL)animated
{

}

- (void)retrieveDataFromAPI
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_chat_list.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
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
#pragma mark TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"rows %d",[self.tableData count]);
    
    if ([self.tableData count])
    {
        [self.tableView setHidden:NO];
        [self.recordLabel setHidden:YES];
    }else{
        [self.tableView setHidden:YES];
        [self.recordLabel setHidden:NO];
    }
    return [self.tableData count];
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

    NSDictionary *cellData = [self.tableData objectAtIndex:indexPath.row];
    NSLog(@"cell data %@",cellData);
    [cell.usernameLabel setTextColor:[UIColor colorWithHex:@"#D22042"]];
    cell.usernameLabel.text = [cellData valueForKey:@"username"];
    cell.statusLabel.text = [cellData valueForKey:@"status"];
    cell.dateLabel.text = [cellData valueForKey:@"idate"];
    cell.timeLabel.text = [cellData valueForKey:@"itime"];

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
    NSDictionary *buddy = [self.tableData objectAtIndex:indexPath.row];
    
    AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([[buddy valueForKey:@"group_id"]intValue] == 0) {
        ChatViewController *newChat = [[ChatViewController alloc] initWithBuddyId:[buddy valueForKey:@"buddy_user_id"] andUsername:[buddy valueForKey:@"username"]];
        [mydelegate.otherNavController pushViewController:newChat animated:YES];
        [newChat release];
    } else {
        GroupChatViewController *newGChat = [[GroupChatViewController alloc] initWithGroupId:[buddy valueForKey:@"group_id"] andGroupname:[buddy valueForKey:@"username"]];
        [mydelegate.otherNavController pushViewController:newGChat animated:YES];
        [newGChat release];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBuddyCellHeight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableData release];
    [_tableView release];
    [_recordLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableData:nil];
    [self setTableView:nil];
    [self setRecordLabel:nil];
    [super viewDidUnload];
}
@end
