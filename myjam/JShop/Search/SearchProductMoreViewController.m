//
//  SearchProductMoreViewController.m
//  myjam
//
//  Created by M Ridhwan M Sari on 6/20/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "SearchProductMoreViewController.h"

@interface SearchProductMoreViewController ()

@end

@implementation SearchProductMoreViewController

- (void)viewDidAppear:(BOOL)animated
{
    self.productData = [[NSMutableArray alloc] init];
    NSMutableArray *newData = [[NSMutableArray alloc] init];
    for (id row in self.tempdata) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    [row objectForKey:@"product_id"], @"product_id",
                    [row objectForKey:@"product_name"], @"product_name",
                    [row objectForKey:@"product_price"], @"product_price",
                    [row objectForKey:@"product_discounted_price"], @"product_discounted_price",
                    [row objectForKey:@"shop_id"], @"shop_id",
                    [row objectForKey:@"shop_name"], @"shop_name",
                    [row objectForKey:@"star_buy"], @"star_buy",
                    [row objectForKey:@"image"], @"product_image", nil];
        [newData addObject:dict];
        [dict release];
    }
    [self.productData addObjectsFromArray:newData];
    [self.tableView reloadData];
}
@end