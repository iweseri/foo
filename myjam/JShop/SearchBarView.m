//
//  SearchBarView.m
//  myjam
//
//  Created by M Ridhwan M Sari on 5/26/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "SearchBarView.h"
#import "FilterProductViewController.h"
#import "SearchBarCell.h"
#import "AppDelegate.h"
#import "ASIWrapper.h"

@interface SearchBarView ()

@end

@implementation SearchBarView

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
    [self loadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return ([self.tableData count] > 0) ? [self.tableData count] : 0;
    //return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SearchBarCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell  = [[[NSBundle mainBundle] loadNibNamed:@"SearchBarCell" owner:nil options:nil]  objectAtIndex:0];
    }
    [cell.catLabel setText:[[self.tableData objectAtIndex:indexPath.row] valueForKey:@"category_name"]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"row :%@ n %@",[[self.tableData objectAtIndex:indexPath.row]objectForKey:@"category_id"],[[self.tableData objectAtIndex:indexPath.row]objectForKey:@"category_name"]);
    FilterProductViewController *filter = [[FilterProductViewController alloc] init];
    filter.catId = [[self.tableData objectAtIndex:indexPath.row]objectForKey:@"category_id"];
    filter.catTitle = [[self.tableData objectAtIndex:indexPath.row]objectForKey:@"category_name"];
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.shopNavController pushViewController:filter animated:YES];
    [filter release];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"handleSearchBar" object:nil];
}

- (void)loadData
{
    self.tableData = [[NSMutableArray alloc] init];
    BOOL success = [self retrieveData];
    
    if (!success) {
        NSLog(@"Request time out");
        UILabel *labelMsg = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-75, self.view.frame.size.height/2-10, 200, 20)];
        [labelMsg setText:@"Request time out"];
        [labelMsg setBackgroundColor:[UIColor clearColor]];
        [labelMsg setTextColor:[UIColor whiteColor]];
        [self.view addSubview:labelMsg];
        [labelMsg release];
        //[self.tableView setHidden:YES];
    }else if([self.tableData count]==0) {
        NSLog(@"DATA EMPTY :%@",self.tableData);
        [self.tableView setHidden:YES];
    }else{
        // Reload tableView
        NSLog(@"DATA :%@",self.tableData);
        [self.tableView setHidden:NO];
        [self.tableView reloadData];
    }
}

- (NSString *)returnAPIURL
{
    return [NSString stringWithFormat:@"%@/api/shop_maincat_filter_v2.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]copy]];
}

- (NSString *)returnAPIDataContent
{
    return @"";//[NSString stringWithFormat:@"{\"main_cat_id\":%d,\"cat_id\":%d}",0, 0];
}

- (BOOL)retrieveData
{
    NSString *urlString = [self returnAPIURL];
    NSString *dataContent = [self returnAPIDataContent];
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"url: %@\ndataContent: %@", urlString, dataContent);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    NSString *status = nil;
    NSMutableArray* list = nil;
    
    if([resultsDictionary count])
    {
        status = [resultsDictionary objectForKey:@"status"];
        list = [resultsDictionary objectForKey:@"list"];
        
        if ([status isEqualToString:@"ok"] && [list count]) {
            [self.tableData addObjectsFromArray:list];
            return YES;
        }
        return NO;
    }
    else
        return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [super dealloc];
    [_tableData release];
    [self.tableView release];
}

@end
