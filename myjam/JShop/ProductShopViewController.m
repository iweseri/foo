//
//  ProductShopViewController.m
//  myjam
//
//  Created by ME-Tech Mac User 2 on 5/23/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "ProductShopViewController.h"
#import "ProductShopDetailViewController.h"
#import "ShopClass.h"

#define kTableShopCellHeight 240

@interface ProductShopViewController ()

@end

@implementation ProductShopViewController

@synthesize productShopData;

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
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        kDisplayPerScreen = 3;
    } else {
        // code for 3.5-inch screen
        kDisplayPerScreen = 2;
    }
    
    self.title = @"JAM-BU Shop";
    FontLabel *titleView = [[FontLabel alloc] initWithFrame:CGRectZero fontName:@"jambu-font.otf" pointSize:22];
    titleView.text = self.title;
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.backgroundColor = [UIColor clearColor];
    titleView.textColor = [UIColor whiteColor];
    [titleView sizeToFit];
    self.navigationItem.titleView = titleView;
    [titleView release];
    
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    pageCounter = 1;
    //productShopData = [[NSMutableArray alloc] init];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"vda");
    [self.loadingIndicator startAnimating];
    if (![productShopData count] > 0) {
        [self.shopTitleLabel setText:self.shopName];
        productShopData = [[NSMutableArray alloc] init];
        [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.03f];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    rows = 0;
    rows = ([productShopData count]);
    NSLog(@"row %d",rows);
    
//    if (rows >= kDisplayPerScreen) {
//        rows += 1; // Extra row for loading cell
//    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSLog(@"index at %d",indexPath.row);
//    if (indexPath.row == rows-1 && rows-1 >= kDisplayPerScreen){
//        ShopLoadingCell *cell = (ShopLoadingCell*)[tableView dequeueReusableCellWithIdentifier:@"ShopLoadingCell"];
//        if (cell == nil)
//        {
//            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ShopLoadingCell" owner:nil options:nil];
//            cell = [nib objectAtIndex:0];
//        }
//        [cell.loadingIndicator startAnimating];
//        
//        NSLog(@"loading");
//        return cell;
//    } else {
    
        ProductWithHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProductWithHeaderCell" owner:nil options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.contentView.backgroundColor = [UIColor colorWithHex:@"#f1ebe4"];
        CGSize expectedLabelSize  = [[[productShopData objectAtIndex:indexPath.row] valueForKey:@"category_name"] sizeWithFont:[UIFont fontWithName:@"Verdana" size:12.0] constrainedToSize:CGSizeMake(150.0, cell.catNameLabel.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
        CGRect newFrame = cell.catNameLabel.frame;
        newFrame.size.width = expectedLabelSize.width;
        cell.catNameLabel.text =[[productShopData objectAtIndex:indexPath.row] valueForKey:@"category_name"];
        cell.catNameLabel.backgroundColor = [UIColor colorWithHex:@"#f1ebe4"];
        cell.catNameLabel.frame = newFrame;
        if ([[[productShopData objectAtIndex:indexPath.row] valueForKey:@"category_product_count"] integerValue]>2){
            cell.viewAllButton.tag = indexPath.row;
            cell.viewAllButton.backgroundColor = [UIColor colorWithHex:@"#f1ebe4"];
            [cell.viewAllButton addTarget:self action:@selector(viewAll:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            cell.viewAllButton.hidden = YES;
        }
        [self createCellForIndex:indexPath cell:cell];
        NSLog(@"configureCell");
        return cell;
//    }
    // Configure the cell...
}

- (void)createCellForIndex:(NSIndexPath *)indexPath cell:(ProductWithHeaderCell *)cell
{
    [cell.transView1 setHidden:YES];
    [cell.transView2 setHidden:YES];
    cell.button1.userInteractionEnabled = NO;
    cell.button2.userInteractionEnabled = NO;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewShop:)];
    UILabel *shopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
    shopNameLabel.textColor = [UIColor darkGrayColor];
    shopNameLabel.backgroundColor = [UIColor clearColor];
    shopNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    shopNameLabel.text = self.shopName;
    [shopNameLabel setTag:[self.shopId intValue]];
    [shopNameLabel setUserInteractionEnabled:YES];
    [shopNameLabel addGestureRecognizer:tap];
    [cell.transView1 addSubview:shopNameLabel];
    [tap release];
    [shopNameLabel release];
    
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 150, 20)];
    categoryLabel.textColor = [UIColor blackColor];
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    categoryLabel.text = [[[[productShopData objectAtIndex:indexPath.row] valueForKey:@"product_list"] objectAtIndex:0] valueForKey:@"product_name"];
    [cell.transView1 addSubview:categoryLabel];
    [categoryLabel release];
    
    cell.buttonTap1.tag =  2*indexPath.row+0;
    [cell.transView1 setHidden:NO];
    [[cell.button1 layer] setBorderWidth:3.0f];
    [[cell.button1 layer] setBorderColor:[UIColor whiteColor].CGColor];
    [cell.button1 setBackgroundImageWithURL:[NSURL URLWithString:[[[[productShopData objectAtIndex:indexPath.row] valueForKey:@"product_list"] objectAtIndex:0] valueForKey:@"product_image"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
    [cell.buttonTap1 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    UIView *leftPrice = [[ShopClass sharedInstance] priceViewFor:[[[[productShopData objectAtIndex:indexPath.row] valueForKey:@"product_list"] objectAtIndex:0] valueForKey:@"product_price"] and:[[[[productShopData objectAtIndex:indexPath.row] valueForKey:@"product_list"] objectAtIndex:0] valueForKey:@"product_discounted_price"]];
    [leftPrice setFrame:CGRectMake(154-leftPrice.frame.size.width, 179, leftPrice.frame.size.width, 20)];
    [cell addSubview:leftPrice];
    [leftPrice release];
    
    NSLog(@"here");
    if ([[[productShopData objectAtIndex:indexPath.row] valueForKey:@"product_list"] count] >1){
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewShop:)];
        UILabel *shopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
        shopNameLabel.textColor = [UIColor darkGrayColor];
        shopNameLabel.backgroundColor = [UIColor clearColor];
        shopNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        shopNameLabel.text = self.shopName;
        [shopNameLabel setTag:[self.shopId intValue]];
        [shopNameLabel setUserInteractionEnabled:YES];
        [shopNameLabel addGestureRecognizer:tap];
        [cell.transView2 addSubview:shopNameLabel];
        [tap release];
        [shopNameLabel release];
        
        UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 150, 20)];
        categoryLabel.textColor = [UIColor blackColor];
        categoryLabel.backgroundColor = [UIColor clearColor];
        categoryLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        categoryLabel.text = [[[[productShopData objectAtIndex:indexPath.row] valueForKey:@"product_list"] objectAtIndex:1] valueForKey:@"product_name"];
        [cell.transView2 addSubview:categoryLabel];
        [categoryLabel release];
        
        cell.buttonTap2.tag = 2*indexPath.row+1;
        [cell.transView2 setHidden:NO];
        [cell.buttonTap2 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        [[cell.button2 layer] setBorderWidth:3.0f];
        [[cell.button2 layer] setBorderColor:[UIColor whiteColor].CGColor];
        [cell.button2 setBackgroundImageWithURL:[NSURL URLWithString:[[[[productShopData objectAtIndex:indexPath.row] valueForKey:@"product_list"] objectAtIndex:1] valueForKey:@"product_image"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
        
        UIView *rightPrice = [[ShopClass sharedInstance] priceViewFor:[[[[productShopData objectAtIndex:indexPath.row] valueForKey:@"product_list"] objectAtIndex:1] valueForKey:@"product_price"] and:[[[[productShopData objectAtIndex:indexPath.row] valueForKey:@"product_list"] objectAtIndex:1] valueForKey:@"product_discounted_price"]];
        [rightPrice setFrame:CGRectMake(310-rightPrice.frame.size.width, 179, rightPrice.frame.size.width, 20)];
        [cell addSubview:rightPrice];
        [rightPrice release];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if(indexPath.row == rows-1 && rows-1 >= kDisplayPerScreen){
//        return 44; // Loading cell height
//    }
//    else{
//        return kTableShopCellHeight;
//    }
    return kTableShopCellHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == rows-1 && [cell isKindOfClass:[ShopLoadingCell class]]) {
        pageCounter++;
        [self.loadingIndicator setHidden:NO];
        [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.3f];
    }
}

- (void)reloadPage {
    [self.loadingIndicator setHidden:NO];
    [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:1.0f];
}

- (void)loadMoreData
{
    NSLog(@"Page now is %d",pageCounter);
    
    BOOL success = [self retrieveData];
    
    if (!success) {
        if ([productShopData count] == 0) {
            if (![self.tableView isHidden]) {
                [self.tableView setHidden:YES];
                UILabel *labelMsg = [[UILabel alloc]initWithFrame:CGRectMake(0, self.tableView.bounds.size.height/2, 320, 40)];
                [labelMsg setUserInteractionEnabled:YES];
                [labelMsg setText:[NSString stringWithFormat:@"%@\nTap to reload.",message]];
                [labelMsg setBackgroundColor:[UIColor clearColor]];
                [labelMsg setTextColor:[UIColor darkGrayColor]];
                [labelMsg setTextAlignment:NSTextAlignmentCenter];
                [labelMsg setNumberOfLines:2];
                [labelMsg setTag:505];
                [self.view addSubview:labelMsg];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadPage)];
                [labelMsg addGestureRecognizer:tap];
                [labelMsg release];
                [tap release];
            }
        } else {
            // Hide loading cell
            [UIView animateWithDuration:0.5 animations:^{
                CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height-44);
                [self.tableView setContentOffset:bottomOffset animated:YES];
            }];
        }
    }else{
        // Reload tableView
        if ([self.tableView isHidden]) {
            [self.tableView setHidden:NO];
            for (UILabel *v in [self.view subviews]) {
                if (v.tag == 505)
                    [v removeFromSuperview];
            }
        }
        NSLog(@"DATA :%@",productShopData);
        [self.tableView reloadData];
    }
    [self.loadingIndicator setHidden:YES];
    NSLog(@"%f : %f",self.tableView.contentSize.height,self.tableView.bounds.size.height);
    
}

- (NSString *)returnAPIURL
{
    return [NSString stringWithFormat:@"%@/api/shop_product_list.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]copy]];
}

- (NSString *)returnAPIDataContent
{
    return [NSString stringWithFormat:@"{\"shop_id\":%@,\"search_sort\":\"A-Z\"}",self.shopId];
}

- (BOOL)retrieveData
{
    NSString *urlString = [self returnAPIURL];
    NSString *dataContent = [self returnAPIDataContent];
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    //NSLog(@"dataContent: %@\nresponse listing: %@", dataContent,response);
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
                if ( ![[row objectForKey:@"category_product_count"] isEqual:[NSNumber numberWithInt:0]]){
                    [newData addObject:row];
                }
            }
        }else{
            message = [resultsDictionary objectForKey:@"message"];
        }
    }
    NSArray *newList = [NSArray arrayWithArray:newData];
    if ([newList count]) {
        [productShopData addObjectsFromArray:newList]; // Append new data to tableData
        return YES;
    }
    else{
        pageCounter--;
        return NO;
    }
}

#pragma mark - Table view delegate

-(void)viewAll:(id)sender{
    [self.loadingIndicator setHidden:NO];
    //[DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
    NSLog(@"VM :%@",[[productShopData objectAtIndex:[sender tag]] valueForKey:@"category_name"]);
    [self performSelector:@selector(viewMoreProduct:) withObject:sender afterDelay:0.3];
}
- (void)viewMoreProduct:(id)sender {
    ProductShopDetailViewController *detailProduct = [[ProductShopDetailViewController alloc]init];
    detailProduct.catId = [[productShopData objectAtIndex:[sender tag]] valueForKey:@"category_id"];
    detailProduct.shopName = self.shopName;
    detailProduct.shopId = self.shopId;
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.shopNavController pushViewController:detailProduct animated:YES];
    [detailProduct release];
}

-(void)viewShop:(UITapGestureRecognizer*)sender {
    //[DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
    UILabel *currTag = (UILabel *)sender.view;
    NSLog(@"GTS:%d",[currTag tag]);
    //[self performSelector:@selector(showShopProduct:) withObject:sender afterDelay:0.3];
}
- (void)showShopProduct:(UITapGestureRecognizer*)sender {
    UILabel *currTag = (UILabel *)sender.view;
    ShopDetailViewController *detailViewController = [[ShopDetailViewController alloc] init];
    detailViewController.shopID = [NSString stringWithFormat:@"%d",[currTag tag]];
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.shopNavController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

-(void)tapAction:(id)sender{
    [self.loadingIndicator setHidden:NO];
    NSLog(@"TAG:%d",[sender tag]);
    [self performSelector:@selector(showProduct:) withObject:sender afterDelay:0.3];
}
- (void)showProduct:(id)sender {
    DetailProductViewController *detailViewController = [[DetailProductViewController alloc] initWithNibName:@"DetailProductViewController" bundle:nil];
    NSString *prodId = [[[[productShopData objectAtIndex:[sender tag]/2] valueForKey:@"product_list"] objectAtIndex:[sender tag]%2] valueForKey:@"product_id"];
    detailViewController.productInfo = [[MJModel sharedInstance] getProductInfoFor:prodId];
    detailViewController.productId = [prodId mutableCopy];
    detailViewController.categoryId = [[productShopData objectAtIndex:[sender tag]/2] valueForKey:@"category_id"];
    detailViewController.buyButton =  [[NSString alloc] initWithString:@"ok"];
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.shopNavController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.loadingIndicator stopAnimating];
}

- (void)dealloc {
    [super dealloc];
    [productShopData release];
    [_tableView release];
}

@end
