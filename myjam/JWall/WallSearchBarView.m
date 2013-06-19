//
//  WallSearchBarView.m
//  myjam
//
//  Created by Mohd Hafiz on 6/14/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "WallSearchBarView.h"

@interface WallSearchBarView ()

@end

@implementation WallSearchBarView

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
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search for J-Lites/Keyword";
//    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableData = [[NSMutableArray alloc] initWithObjects:
                            [NSDictionary dictionaryWithObject:@"Show All" forKey:@"category_name"],
                            [NSDictionary dictionaryWithObject:@"J-Buddy Posts" forKey:@"category_name"], nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *filterParams = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", indexPath.row+1], @"filterOption", @"", @"searchText", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showPostsWithFilter" object:nil userInfo:filterParams];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"handleSearchBarWall" object:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSDictionary *filterParams = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"filterOption", searchBar.text, @"searchText", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showPostsWithFilter" object:nil userInfo:filterParams];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"handleSearchBarWall" object:nil];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
