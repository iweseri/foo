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
    [self.tableView setHidden:YES];
    self.tableData = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewDidAppear:)
                                                 name:@"reloadChatList"
                                               object:nil];
    
    [self.recordLabel setHidden:YES];
    self.loadingIndicator.frame = CGRectMake(self.view.frame.size.width/2-self.loadingIndicator.frame.size.width/2,
                                             self.view.frame.size.height/2-self.loadingIndicator.frame.size.height/2-100,
                                             self.loadingIndicator.frame.size.width,
                                             self.loadingIndicator.frame.size.height);
    
    self.loadingLabel.frame = CGRectMake(self.view.frame.size.width/2-self.loadingLabel.frame.size.width/2,
                                         self.loadingIndicator.frame.origin.y+self.loadingIndicator.frame.size.height+10,
                                         200,
                                         55);
}

- (void)viewDidAppear:(BOOL)animated
{
    AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [mydelegate removeChatBadge];
    
    [self.tableData removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self retrieveDataFromAPI];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.loadingLabel setHidden:YES];
            [self.loadingIndicator setHidden:YES];
        });
    });

    NSLog(@"vwa-chatList");
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
    
    if ([self.tableData count])
    {
        [self.tableView setHidden:NO];
        [self.recordLabel setHidden:YES];
    }else{
        [self.tableView setHidden:YES];
        [self.recordLabel setHidden:NO];
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
        [mydelegate.buddyNavController pushViewController:newChat animated:YES];
        [newChat release];
    } else {
        GroupChatViewController *newGChat = [[GroupChatViewController alloc] initWithGroupId:[buddy valueForKey:@"group_id"] andGroupname:[buddy valueForKey:@"username"]];
        [mydelegate.buddyNavController pushViewController:newGChat animated:YES];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_tableData release];
    [_tableView release];
    [_recordLabel release];
    [_loadingIndicator release];
    [_loadingLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableData:nil];
    [self setTableView:nil];
    [self setRecordLabel:nil];
    [self setLoadingIndicator:nil];
    [self setLoadingLabel:nil];
    [super viewDidUnload];
}
@end
