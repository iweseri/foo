//
//  ListPopupView.m
//  myjam
//
//  Created by M Ridhwan M Sari on 6/6/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "ListPopupView.h"

@implementation ListPopupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithDataList:(NSArray *)list andTag:(NSInteger)tag
{
    self = [super init];
    if (self) {
        self.listing = list;
        self.tag = tag;
        
        CGFloat currHeight = 35;
        CGFloat maxTableHeight = 385;
        CGFloat tableWidth = 270;
        CGFloat tableHeight = currHeight;
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,tableWidth,tableHeight) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        
        if ([list count] > 11) {
            tableHeight = maxTableHeight;
        } else {
            [tableView setScrollEnabled:NO];
            tableHeight = currHeight*[list count];
        }
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [tableView setFrame:CGRectMake(0,0,tableWidth,tableHeight)];
        [tableView setBounces:NO];
        
        [self setFrame:CGRectMake(0, 0, tableWidth, tableHeight)];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:tableView];
        [tableView reloadData];
        //[tableView release];        
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listing count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    NSLog(@"configureCell :%@",self.listing);
    // Configure the cell...
    [cell.textLabel setText:[self.listing objectAtIndex:indexPath.row]];
    [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate popView:self didSelectOptionAtIndex:indexPath.row];
    [self removeFromSuperview];
}

@end
