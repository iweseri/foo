//
//  SearchBarView.m
//  myjam
//
//  Created by M Ridhwan M Sari on 5/26/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "SearchBarView.h"
#import "FilterProductViewController.h"
#import "ProductShopViewController.h"
#import "SearchProductViewController.h"
#import "SearchBarHeaderCell.h"
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
    self.searchBar.delegate = self;
    
//    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, self.view.frame.size.width, 1)];
//    [overlayView setBackgroundColor:[UIColor whiteColor]];
//    [self.searchBar addSubview:overlayView]; // navBar is your UINavigationBar instance
//    [overlayView release];
    
    [self loadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) { NSLog(@"row1:%d",[self.tableData count]+1);
        return [self.tableData count]+1;
    } else { NSLog(@"row2:%d",[self.shopData count]+1);
        return [self.shopData count]+1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    if (indexPath.row == 0) {
        SearchBarHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell  = [[[NSBundle mainBundle] loadNibNamed:@"SearchBarHeaderCell" owner:nil options:nil]  objectAtIndex:0];
        }
        (indexPath.section == 0) ? [cell.titleLabel setText:@"CATEGORIES"] : [cell.titleLabel setText:@"MERCHANTS"];
        NSLog(@"CNT1:%d-%d",indexPath.row,indexPath.section);
        return cell;
    } else {
        SearchBarCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell)
        {
            cell  = [[[NSBundle mainBundle] loadNibNamed:@"SearchBarCell" owner:nil options:nil]  objectAtIndex:0];
        }
        if (indexPath.section == 0) {
            [cell.catLabel setText:[[self.tableData objectAtIndex:indexPath.row-1] valueForKey:@"category_name"]];
        } else {
            [cell.catLabel setText:[[self.shopData objectAtIndex:indexPath.row-1] valueForKey:@"shop_name"]];
        }
        NSLog(@"CNT:%d-%d",indexPath.row,indexPath.section);
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 50;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"section:%d n row:%d",indexPath.section,indexPath.row);
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (indexPath.section == 0) {
        NSLog(@"row :%@ n %@",[[self.tableData objectAtIndex:indexPath.row-1]objectForKey:@"category_id"],[[self.tableData objectAtIndex:indexPath.row-1]objectForKey:@"category_name"]);
        FilterProductViewController *filter = [[FilterProductViewController alloc] init];
        filter.catId = [[self.tableData objectAtIndex:indexPath.row-1]objectForKey:@"category_id"];
        filter.catTitle = [[self.tableData objectAtIndex:indexPath.row-1]objectForKey:@"category_name"];
        [mydelegate.shopNavController pushViewController:filter animated:YES];
        [filter release];
    } else {
        ProductShopViewController *shop = [[ProductShopViewController alloc] init];
        shop.shopId = [[self.shopData objectAtIndex:indexPath.row-1]objectForKey:@"shop_id"];
        shop.shopName = [[self.shopData objectAtIndex:indexPath.row-1]objectForKey:@"shop_name"];
        [mydelegate.shopNavController pushViewController:shop animated:YES];
        [shop release];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"handleSearchBar" object:nil];
}

- (void)loadData
{
    self.tableData = [[NSMutableArray alloc] init];
    self.shopData = [[NSMutableArray alloc] init];
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
        NSLog(@"SHOP :%@",self.shopData);
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
    NSMutableArray* sList = nil;
    
    if([resultsDictionary count])
    {
        status = [resultsDictionary objectForKey:@"status"];
        list = [resultsDictionary objectForKey:@"list"];
        sList = [resultsDictionary objectForKey:@"shop_list"];
        
        if ([status isEqualToString:@"ok"]) {
            if([list count])
                [self.tableData addObjectsFromArray:list];
            if ([sList count])
                [self.shopData addObjectsFromArray:sList];
            return YES;
        }
        return NO;
    }
    else
        return NO;
}

#pragma mark -
#pragma mark SearchBar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {

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
    [searchBar resignFirstResponder];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    SearchProductViewController *search = [[SearchProductViewController alloc] initWithNibName:@"AllProductViewController" bundle:nil];
    search.searchText = searchBar.text;
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.shopNavController pushViewController:search animated:YES];
    [search release];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"handleSearchBar" object:nil];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_searchBar release];
    [super dealloc];
    [_tableData release];
    [_shopData release];
    [self.tableView release];
}

- (void)viewDidUnload {
    [self setSearchBar:nil];
    [super viewDidUnload];
}
@end
