//
//  PublicViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 5/9/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "PublicViewController.h"
//#import "WallPopupViewController.h"
//#import "PublicPopupView.h"s
#import "AppDelegate.h"

static CGFloat kHeaderHeight = 80;
static CGFloat kFooterHeight = 100;
static CGFloat kMinCellHeight = 44;

NSString *textPost = @"User's comment here. This is comment only yea? Others will be later.";
NSString *comm = @"33 Comments";
NSString *fav = @"12 Favs";

@interface PublicViewController ()

@end

@implementation PublicViewController

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

    // Init data array
    tableData = [[NSMutableArray alloc] init];
    options1 = [[NSArray alloc] initWithObjects:@"Share Facebook", @"Share Twitter", @"Share Email", @"Share to J-Wall", @"Report", @"Block User", @"Cancel", nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{

}


- (void)viewDidAppear:(BOOL)animated
{
    
}

#pragma mark -
#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kFooterHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get appropriate height for cell based on word / characters counting
    CGSize  textSize = { 300, 10000.0 };
	CGSize size = [textPost sizeWithFont:[UIFont systemFontOfSize:14]
				  constrainedToSize:textSize
					  lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = size.height < kMinCellHeight ? kMinCellHeight : size.height;
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    NSArray *nibs =  [[NSBundle mainBundle] loadNibNamed:@"PostHeaderView" owner:self options:nil];
    
//    PostHeaderView *header = (PostHeaderView *)[nibs objectAtIndex:0];
//    [header initView];
    
    PostHeaderView *header = [[PostHeaderView alloc] init];
    header.tag = section;
    header.delegate = self;
    [header setBoldText:@"Username" withFullText:@"Username shared a link" andTime:@"About 1 minute ago"];
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    PostFooterView *footer = [[PostFooterView alloc] init];
    [footer setupWithFav:fav andComment:comm];
    
    return footer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"section %d, row %d", indexPath.section, indexPath.row);
    
    PostTextCell *cell = (PostTextCell *)[tableView dequeueReusableCellWithIdentifier:@"PostTextCell"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PostTextCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Create dinamic label
    UILabel *postLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, cell.frame.size.width-20, kMinCellHeight)];
    [postLabel setBackgroundColor:[UIColor clearColor]];
    [postLabel setFont:[UIFont systemFontOfSize:14]];
    [postLabel setText:textPost];
    [postLabel setNumberOfLines:0];
    [postLabel sizeToFit];
    
    [cell addSubview:postLabel];
    [postLabel release];
    // To remove group cell border
    cell.backgroundView = [[[UIView alloc] initWithFrame:cell.bounds] autorelease];
    return cell;
}

- (void)addBlackView
{
    UIView *blackView = [[UIView alloc] initWithFrame:self.view.frame];
    [blackView setTag:99];
    [blackView setBackgroundColor:[UIColor blackColor]];
    [blackView setAlpha:0.3];
    [self.view addSubview:blackView];
    [blackView release];
}

- (void)removeBlackView
{
    UIView *blackView = [self.view viewWithTag:99];
    [blackView removeFromSuperview];
}

#pragma mark -
#pragma mark PostHeaderView delegate
- (void)tableHeaderView:(PostHeaderView *)headerView didClickOptionButton:(UIButton *)button
{
    NSLog(@"clicked %d",headerView.tag);
    
    MyPopupView *popup = [[MyPopupView alloc] initWithDataList:options1 andTag:headerView.tag];
    popup.delegate = self;
    CGFloat popupYPoint = self.view.frame.size.height/2-popup.frame.size.height/2;
    CGFloat popupXPoint = self.view.frame.size.width/2-popup.frame.size.width/2;
    
    popup.frame = CGRectMake(popupXPoint, popupYPoint, popup.frame.size.width, popup.frame.size.height);
    [self addBlackView];
    [self.view addSubview:popup];
}

#pragma mark -
#pragma mark MyPopupViewDelegate
- (void)popView:(MyPopupView *)popupView didSelectOptionAtIndex:(NSInteger)index
{
    NSLog(@"Clicked at post %d and selected option %d", popupView.tag, index);

    [self removeBlackView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
