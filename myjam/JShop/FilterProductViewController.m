//
//  FilterProductViewController.m
//  myjam
//
//  Created by M Ridhwan M Sari on 5/27/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "FilterProductViewController.h"
#import "ASIWrapper.h"
#import "AppDelegate.h"
#import "ProductCell.h"
#import "ShopClass.h"

@interface FilterProductViewController ()

@end

@implementation FilterProductViewController

@synthesize tableView,tableData,categoryData;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"JAM-BU Shop";
    FontLabel *titleView = [[FontLabel alloc] initWithFrame:CGRectZero fontName:@"jambu-font.otf" pointSize:22];
    titleView.text = self.title;
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.backgroundColor = [UIColor clearColor];
    titleView.textColor = [UIColor whiteColor];
    [titleView sizeToFit];
    self.navigationItem.titleView = titleView;
    [titleView release];
    // Custom initialization
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
    [self.listView setBackgroundColor:[UIColor colorWithHex:@"#f1ebe4"]];
    [self.footerView setBackgroundColor:[UIColor colorWithHex:@"#f1ebe4"]];
    [self.tableView setBackgroundColor:[UIColor colorWithHex:@"#f1ebe4"]];
    [self.selectButton setTitle:@"   *Show All" forState:UIControlStateNormal];
    //[self loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"vda");
    [self.loadingIndicator startAnimating];
    if (![tableData count] > 0) {
        [self.catTitleLabel setText:self.catTitle];
        tableData = [[NSMutableArray alloc] init];
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.03f];
    } else {
        [self.loadingIndicator setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    rows = 0;
    if (([tableData count] % 2) == 0)
        rows = ([tableData count]/2);
    else
        rows = (([tableData count]/2) + 1);
    NSLog(@"row %d",rows);
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)cellTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ProductCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProductCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.contentView.backgroundColor = [UIColor colorWithHex:@"#f1ebe4"];
    // Configure the cell...
    [self createCellForIndex:indexPath cell:cell];
    NSLog(@"configure");
    return cell;
}

- (void)createCellForIndex:(NSIndexPath *)indexPath cell:(ProductCell *)cell
{
    [cell.transView1 setHidden:YES];
    [cell.transView2 setHidden:YES];
    cell.button1.userInteractionEnabled = NO;
    cell.button2.userInteractionEnabled = NO;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *shopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 150, 20)];
    shopNameLabel.textColor = [UIColor darkGrayColor];
    shopNameLabel.backgroundColor = [UIColor clearColor];
    shopNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    shopNameLabel.text = [[tableData objectAtIndex:2*indexPath.row+0] valueForKey:@"shop_name"];
    [cell.transView1 addSubview:shopNameLabel];
    [shopNameLabel release];
    
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 20, 150, 20)];
    categoryLabel.textColor = [UIColor blackColor];
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    categoryLabel.text = [[tableData objectAtIndex:2*indexPath.row+0] valueForKey:@"product_name"];
    [cell.transView1 addSubview:categoryLabel];
    [categoryLabel release];
    
    cell.buttonTap1.tag =  2*indexPath.row+0;
    [cell.transView1 setHidden:NO];
    [[cell.button1 layer] setBorderWidth:3.0f];
    [[cell.button1 layer] setBorderColor:[UIColor whiteColor].CGColor];
    [cell.button1 setBackgroundImageWithURL:[NSURL URLWithString:[[tableData objectAtIndex:2*indexPath.row+0] valueForKey:@"product_image"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
    [cell.buttonTap1 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    UIView *leftPrice = [[ShopClass sharedInstance] priceViewFor:[[tableData objectAtIndex:2*indexPath.row+0] valueForKey:@"product_price"] and:[[tableData objectAtIndex:2*indexPath.row+0] valueForKey:@"product_discounted_price"]];
    [leftPrice setFrame:CGRectMake(154-leftPrice.frame.size.width, 139, leftPrice.frame.size.width, 20)];
    [cell addSubview:leftPrice];
    [leftPrice release];
    
    if (2*indexPath.row+1 < [tableData count]){
        UILabel *shopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 150, 20)];
        shopNameLabel.textColor = [UIColor darkGrayColor];
        shopNameLabel.backgroundColor = [UIColor clearColor];
        shopNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        shopNameLabel.text = [[tableData objectAtIndex:2*indexPath.row+1] valueForKey:@"shop_name"];
        [cell.transView2 addSubview:shopNameLabel];
        [shopNameLabel release];
        
        UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 20, 150, 20)];
        categoryLabel.textColor = [UIColor blackColor];
        categoryLabel.backgroundColor = [UIColor clearColor];
        categoryLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        categoryLabel.text = [[tableData objectAtIndex:2*indexPath.row+1] valueForKey:@"product_name"];
        [cell.transView2 addSubview:categoryLabel];
        [categoryLabel release];
        
        cell.buttonTap2.tag = 2*indexPath.row+1;
        [cell.transView2 setHidden:NO];
        [cell.buttonTap2 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        [[cell.button2 layer] setBorderWidth:3.0f];
        [[cell.button2 layer] setBorderColor:[UIColor whiteColor].CGColor];
        [cell.button2 setBackgroundImageWithURL:[NSURL URLWithString:[[tableData objectAtIndex:2*indexPath.row+1] valueForKey:@"product_image"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
        
        UIView *rightPrice = [[ShopClass sharedInstance] priceViewFor:[[tableData objectAtIndex:2*indexPath.row+1] valueForKey:@"product_price"] and:[[tableData objectAtIndex:2*indexPath.row+1] valueForKey:@"product_discounted_price"]];
        [rightPrice setFrame:CGRectMake(310-rightPrice.frame.size.width, 139, rightPrice.frame.size.width, 20)];
        [cell addSubview:rightPrice];
        [rightPrice release];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

#pragma mark - Table view delegate

- (void)loadData
{
    if (!list) {
        categoryData = [[NSMutableArray alloc] init];
        listOption = [[NSMutableArray alloc] init];
        list = [self retrieveListCategory];
        if ([categoryData count]) {
            showAllId = self.catId;
            [listOption addObject:@"*Show All"];
            for (id row in categoryData) {
                [listOption addObject:[row objectForKey:@"category_name"]];
            }
            titleOption = [NSString stringWithFormat:@"   %@",[listOption objectAtIndex:0]];
            [self.selectButton setTitle:titleOption forState:UIControlStateNormal];
        } else {
            [self.selectButton setEnabled:NO];
        }
    }
    BOOL success = [self retrieveData];
    
    if (!success) {
        NSLog(@"Request time out | %@",tableData);
        //[tableView setHidden:YES];
    }else if([tableData count]==0) {
        NSLog(@"DATA EMPTY :%@",tableData);
        //[tableView setHidden:YES];
    }else{
        // Reload tableView
        NSLog(@"DATA :%@",tableData);
        [tableView setHidden:NO];
        [tableView reloadData];
    }
    [self.loadingIndicator setHidden:YES];
}

- (NSString *)returnAPIURL
{
    return [NSString stringWithFormat:@"%@/api/shop_product_subcat_list_v2.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]copy]];
}

- (NSString *)returnAPIDataContent
{
    return [NSString stringWithFormat:@"{\"category_id\":%@}",self.catId];
}

- (BOOL)retrieveData
{
    NSString *urlString = [self returnAPIURL];
    NSString *dataContent = [self returnAPIDataContent];
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"url: %@\ndataContent: %@",urlString,dataContent);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    NSString *status = nil;
    NSMutableArray* plist = nil;
    
    if([resultsDictionary count])
    {
        status = [resultsDictionary objectForKey:@"status"];
        plist = [resultsDictionary objectForKey:@"list"];
        
        if ([status isEqualToString:@"ok"] && [plist count]) {
            if ([tableData count]) {
                [tableData removeAllObjects];
            }
            [tableData addObjectsFromArray:plist];
            return YES;
        }
        return NO;
    }
    else
        return NO;
}

- (BOOL)retrieveListCategory
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/shop_subcat_filter_v2.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]copy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"category_id\":%@}",self.catId];
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"url: %@\ndataContent: %@",urlString,dataContent);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    NSString *status = nil;
    NSMutableArray* cList = nil;
    
    if([resultsDictionary count])
    {
        status = [resultsDictionary objectForKey:@"status"];
        cList = [resultsDictionary objectForKey:@"list"];
         NSLog(@"catData:%@",cList);
        if ([status isEqualToString:@"ok"]) {
            if([cList count])
                [categoryData addObjectsFromArray:cList]; NSLog(@"catData2:%@",categoryData);
            return YES;
        }
        return NO;
    }
    else
        return NO;
}

#pragma mark -
#pragma mark MyPopupViewDelegate
- (void)popView:(ListPopupView *)popupView didSelectOptionAtIndex:(NSInteger)index
{
    NSLog(@"Clicked at post %d and selected option %d", popupView.tag, index);
    [self removeBlackView];
    
    titleOption = [NSString stringWithFormat:@"   %@",[listOption objectAtIndex:index]];
    [self.selectButton setTitle:titleOption forState:UIControlStateNormal];
    if (index == 0) {
        self.catId = showAllId; }
    else {
        self.catId = [[categoryData objectAtIndex:index-1] valueForKey:@"category_id"];
    }
    [self.loadingIndicator setHidden:NO];
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0.03f];
}

- (void)addBlackView
{
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *blackView = [[UIView alloc] initWithFrame:mydelegate.window.frame];
    //UIView *blackView = [[UIView alloc] initWithFrame:self.view.frame];
    [blackView setTag:99];
    [blackView setBackgroundColor:[UIColor blackColor]];
    [blackView setAlpha:0.3];
    [mydelegate.window addSubview:blackView];
    //[self.view addSubview:blackView];
    [blackView release];
}

- (void)removeBlackView
{
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *blackView = [mydelegate.window viewWithTag:99];
    //UIView *blackView = [self.view viewWithTag:99];
    [blackView removeFromSuperview];
}

- (IBAction)selectCategory:(id)sender
{
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    ListPopupView *popup = [[ListPopupView alloc] initWithDataList:listOption andTag:nil];
    popup.delegate = self;
    CGFloat popupYPoint = mydelegate.window.frame.size.height/2-popup.frame.size.height/2;
    CGFloat popupXPoint = mydelegate.window.frame.size.width/2-popup.frame.size.width/2;
    popup.frame = CGRectMake(popupXPoint, popupYPoint, popup.frame.size.width, popup.frame.size.height);
    
    [self addBlackView];
    [mydelegate.window addSubview:popup];
    [popup release];
}

-(void)tapAction:(id)sender{
    [self.loadingIndicator setHidden:NO];
    NSLog(@"TAG:%d|%@",[sender tag],[[tableData objectAtIndex:[sender tag]] valueForKey:@"product_name"]);
    [self performSelector:@selector(showProduct:) withObject:sender afterDelay:0.3];
}
- (void)showProduct:(id)sender {
    DetailProductViewController *detailViewController = [[DetailProductViewController alloc] initWithNibName:@"DetailProductViewController" bundle:nil];
    NSString *prodId = [[tableData objectAtIndex:[sender tag]] valueForKey:@"product_id"];
    detailViewController.productInfo = [[MJModel sharedInstance] getProductInfoFor:prodId];
    detailViewController.productId = [prodId mutableCopy];
    detailViewController.categoryId = [[tableData objectAtIndex:[sender tag]] valueForKey:@"category_id"];
    detailViewController.buyButton =  [[NSString alloc] initWithString:@"ok"];
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.shopNavController pushViewController:detailViewController animated:YES];
    //[self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.loadingIndicator stopAnimating];
}

- (void)dealloc {
    [super dealloc];
    [tableData release];
    [tableView release];
    [categoryData release];
    [_listView release];
    [_catTitleLabel release];
    [_selectButton release];
    [listOption release];
}

@end
