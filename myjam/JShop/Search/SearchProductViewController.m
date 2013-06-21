//
//  SearchProductViewController.m
//  myjam
//
//  Created by M Ridhwan M Sari on 6/20/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "SearchProductViewController.h"
#import "SearchProductMoreViewController.h"

@interface SearchProductViewController ()

@end

@implementation SearchProductViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    rows = 0;
    rows = ([self.productData count]);
    NSLog(@"row %d",rows);
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 240;
}

- (BOOL)retrieveData
{
    [self.tableView setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 345)];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/shop2_product_list.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]copy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"filter_search\":\"%@\"}",self.searchText];
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    //NSLog(@"dataContent: %@\nresponse listing: %@|%@", dataContent,response,urlString);
    NSMutableArray *newData = [[NSMutableArray alloc] init];
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    NSString *status = nil;
    NSMutableArray* list = nil;
    
    if([resultsDictionary count])
    {
        status = [resultsDictionary objectForKey:@"status"];
        list = [resultsDictionary objectForKey:@"list"];
        
        if ([status isEqualToString:@"ok"] && [list count]) {
            
            for (id row in list) {
                NSMutableDictionary *dict;
                if ( ![[row objectForKey:@"total_products"] isEqual:[NSNumber numberWithInt:0]]) {
                    dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[row objectForKey:@"category_id"], @"category_id", [row objectForKey:@"category_name"], @"category_name", [row objectForKey:@"total_products"], @"count",[row objectForKey:@"products"], @"list", nil];
                    [newData addObject:dict];
                    [dict release];
                }
            }
        }
    }
    if ([newData count]) {
        [self.productData addObjectsFromArray:newData];
        return YES;
    }
    else{
        pageCounter--;
        return NO;
    }
}

- (void)viewMoreProduct:(id)sender
{
    NSLog(@"VM :%d",[sender tag]);
    SearchProductMoreViewController *detailViewController = [[SearchProductMoreViewController alloc] initWithCatId:[[[self.productData objectAtIndex:[sender tag]] valueForKey:@"category_id"] intValue]];
    detailViewController.tempdata = [[[self.productData objectAtIndex:[sender tag]] valueForKey:@"list"] copy];
    detailViewController.catName = [[self.productData objectAtIndex:[sender tag]] valueForKey:@"category_name"];
    
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.shopNavController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

@end
