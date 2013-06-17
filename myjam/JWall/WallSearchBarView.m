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
    self.
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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
