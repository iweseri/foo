//
//  AllProductViewController.m
//  myjam
//
//  Created by M Ridhwan M Sari on 5/27/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "AllProductViewController.h"
#import "AllProductDetailViewController.h"
#import "ProductShopViewController.h"
#import "ShopClass.h"

#define kTableShopCellHeight 240

@interface AllProductViewController ()

@end

@implementation AllProductViewController

@synthesize productData;

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
    refreshDisabled = YES;
    productData = [[NSMutableArray alloc] init];
    [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.03f];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"vda");
    if (refreshDisabled) {
        pageCounter = 1;
        productData = [[NSMutableArray alloc] init];
        if (message != nil) {
            [self.loadingIndicator startAnimating];
            [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:1.0f];
        }else{
            [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.03f];
        }
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
    //if (([productData count] % 2) == 0){
        rows = ([productData count]);
    //}
    //else{
      //  rows = (([productData count]/2) + 1);
    //}
    NSLog(@"row %d",rows);
    
    if (rows >= kDisplayPerScreen) {
        rows += 1; // Extra row for loading cell
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSLog(@"index at %d",indexPath.row);
    if (indexPath.row == rows-1 && rows-1 >= kDisplayPerScreen){
        ShopLoadingCell *cell = (ShopLoadingCell*)[tableView dequeueReusableCellWithIdentifier:@"ShopLoadingCell"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ShopLoadingCell" owner:nil options:nil];
            cell = [nib objectAtIndex:0];
        }
        [cell.loadingIndicator startAnimating];
        
        NSLog(@"loading");
        return cell;
        
    } else {
        
        ProductWithHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProductWithHeaderCell" owner:nil options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.contentView.backgroundColor = [UIColor colorWithHex:@"#f1ebe4"];
        CGSize expectedLabelSize  = [[[productData objectAtIndex:indexPath.row] valueForKey:@"category_name"] sizeWithFont:[UIFont fontWithName:@"Verdana" size:12.0] constrainedToSize:CGSizeMake(150.0, cell.catNameLabel.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
        CGRect newFrame = cell.catNameLabel.frame;
        newFrame.size.width = expectedLabelSize.width;
        cell.catNameLabel.text =[[productData objectAtIndex:indexPath.row] valueForKey:@"category_name"];
        cell.catNameLabel.backgroundColor = [UIColor colorWithHex:@"#f1ebe4"];
        cell.catNameLabel.frame = newFrame;
        if ([[[productData objectAtIndex:indexPath.row] valueForKey:@"count"] integerValue]>2){
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
    }
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
    UILabel *shopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 150, 20)];
    shopNameLabel.textColor = [UIColor darkGrayColor];
    shopNameLabel.backgroundColor = [UIColor clearColor];
    shopNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    shopNameLabel.text = [[[[productData objectAtIndex:indexPath.row] valueForKey:@"list"] objectAtIndex:0] valueForKey:@"shop_name"];
    [shopNameLabel setTag:[[[[[productData objectAtIndex:indexPath.row] valueForKey:@"list"] objectAtIndex:0] valueForKey:@"shop_id"] intValue]];
    [shopNameLabel setUserInteractionEnabled:YES];
    [shopNameLabel addGestureRecognizer:tap];
    [cell.transView1 addSubview:shopNameLabel];
    [tap release];
    [shopNameLabel release];
    
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 20, 150, 20)];
    categoryLabel.textColor = [UIColor blackColor];
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    categoryLabel.text = [[[[productData objectAtIndex:indexPath.row] valueForKey:@"list"] objectAtIndex:0] valueForKey:@"product_name"];
    [cell.transView1 addSubview:categoryLabel];
    [categoryLabel release];
    
    cell.buttonTap1.tag =  2*indexPath.row+0;
    [cell.transView1 setHidden:NO];
    [[cell.button1 layer] setBorderWidth:3.0f];
    [[cell.button1 layer] setBorderColor:[UIColor whiteColor].CGColor];
    [cell.button1 setBackgroundImageWithURL:[NSURL URLWithString:[[[[productData objectAtIndex:indexPath.row] valueForKey:@"list"] objectAtIndex:0] valueForKey:@"image"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
    [cell.buttonTap1 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    UIView *leftPrice = [[ShopClass sharedInstance] priceViewFor:[[[[productData objectAtIndex:indexPath.row] valueForKey:@"list"] objectAtIndex:0] valueForKey:@"product_price"] and:[[[[productData objectAtIndex:indexPath.row] valueForKey:@"list"] objectAtIndex:0] valueForKey:@"product_discounted_price"]];
    [leftPrice setFrame:CGRectMake(154-leftPrice.frame.size.width, 179, leftPrice.frame.size.width, 20)];
    [cell addSubview:leftPrice];
    [leftPrice release];
    
    if ([[[productData objectAtIndex:indexPath.row] valueForKey:@"list"] count] >1){
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewShop:)];
        UILabel *shopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 150, 20)];
        shopNameLabel.textColor = [UIColor darkGrayColor];
        shopNameLabel.backgroundColor = [UIColor clearColor];
        shopNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        shopNameLabel.text = [[[[productData objectAtIndex:indexPath.row] valueForKey:@"list"] objectAtIndex:1] valueForKey:@"shop_name"];
        [shopNameLabel setTag:[[[[[productData objectAtIndex:indexPath.row] valueForKey:@"list"] objectAtIndex:1] valueForKey:@"shop_id"] intValue]];
        [shopNameLabel setUserInteractionEnabled:YES];
        [shopNameLabel addGestureRecognizer:tap];
        [cell.transView2 addSubview:shopNameLabel];
        [tap release];
        [shopNameLabel release];
        
        UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 20, 150, 20)];
        categoryLabel.textColor = [UIColor blackColor];
        categoryLabel.backgroundColor = [UIColor clearColor];
        categoryLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        categoryLabel.text = [[[[productData objectAtIndex:indexPath.row] valueForKey:@"list"] objectAtIndex:1] valueForKey:@"product_name"];
        [cell.transView2 addSubview:categoryLabel];
        [categoryLabel release];
        
        cell.buttonTap2.tag = 2*indexPath.row+1;
        [cell.transView2 setHidden:NO];
        [cell.buttonTap2 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        [[cell.button2 layer] setBorderWidth:3.0f];
        [[cell.button2 layer] setBorderColor:[UIColor whiteColor].CGColor];
        [cell.button2 setBackgroundImageWithURL:[NSURL URLWithString:[[[[productData objectAtIndex:indexPath.row] valueForKey:@"list"] objectAtIndex:1] valueForKey:@"image"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
        
        UIView *rightPrice = [[ShopClass sharedInstance] priceViewFor:[[[[productData objectAtIndex:indexPath.row] valueForKey:@"list"] objectAtIndex:1] valueForKey:@"product_price"] and:[[[[productData objectAtIndex:indexPath.row] valueForKey:@"list"] objectAtIndex:1] valueForKey:@"product_discounted_price"]];
        [rightPrice setFrame:CGRectMake(310-rightPrice.frame.size.width, 179, rightPrice.frame.size.width, 20)];
        [cell addSubview:rightPrice];
        [rightPrice release];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == rows-1 && rows-1 >= kDisplayPerScreen){
        return 44; // Loading cell height
    }
    else{
        return kTableShopCellHeight;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == rows-1 && [cell isKindOfClass:[ShopLoadingCell class]]) {
        pageCounter++;
        [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.2];
    }
}

- (void)loadMoreData
{
    NSLog(@"Page now is %d",pageCounter);
    
    BOOL success = [self retrieveData];
    
    if (!success) {
        if([productData count]==0) {
            
            if (![self.tableView isHidden]) {
                [self.tableView setHidden:YES];
                UILabel *labelMsg = [[UILabel alloc]initWithFrame:CGRectMake(0, self.tableView.bounds.size.height/2, 320, 20)];
                [labelMsg setText:message];
                [labelMsg setTag:505];
                [labelMsg setBackgroundColor:[UIColor clearColor]];
                [labelMsg setTextColor:[UIColor darkGrayColor]];
                [labelMsg setTextAlignment:NSTextAlignmentCenter];
                [self.view addSubview:labelMsg];
                [labelMsg release];
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
            for (UIButton *v in [self.view subviews]) {
                if (v.tag == 505)
                    [v removeFromSuperview];
            }
        }
        message = nil;
        [self.tableView reloadData];
    }
    [self.loadingIndicator stopAnimating];
    NSLog(@"%f : %f",self.tableView.contentSize.height,self.tableView.bounds.size.height);
    
}

- (NSString *)returnAPIURL
{
    return [NSString stringWithFormat:@"%@/api/shop_product_list_v2.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]copy]];
}

- (NSString *)returnAPIDataContent
{
    return [NSString stringWithFormat:@"{\"page\":%d,\"perpage\":%d,\"flag\":\"firstDisplay\"}",pageCounter, 5];
}

- (BOOL)retrieveData
{
    NSString *urlString = [self returnAPIURL];
    NSString *dataContent = [self returnAPIDataContent];
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
        NSMutableArray* resultArray;
        
        if ([status isEqualToString:@"ok"] && [list count]) {            
            resultArray = [resultsDictionary objectForKey:@"list"];
            
            for (id row in resultArray) {
                if ( ![[row objectForKey:@"count"] isEqual:[NSNumber numberWithInt:0]]){
                    [newData addObject:row];
                }
            }
        } else {
            message = [resultsDictionary objectForKey:@"message"];
        }
    }
    NSArray *newList = [NSArray arrayWithArray:newData];
    if ([newList count]) {
        [productData addObjectsFromArray:newList]; // Append new data to tableData
        return YES;
    }
    else{
        pageCounter--;
        return NO;
    }
    
}

#pragma mark - Table view delegate

-(void)viewAll:(id)sender{
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
    [self performSelector:@selector(viewMoreProduct:) withObject:sender afterDelay:0.3];
}

- (void)viewMoreProduct:(id)sender
{
    NSLog(@"VM :%d",[sender tag]);
    AllProductDetailViewController *detailViewController = [[AllProductDetailViewController alloc] initWithCatId:[[[productData objectAtIndex:[sender tag]] valueForKey:@"category_id"] intValue]];
    detailViewController.catName = [[productData objectAtIndex:[sender tag]] valueForKey:@"category_name"];
    
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.shopNavController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

-(void)viewShop:(UITapGestureRecognizer*)sender {
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
    UILabel *currTag = (UILabel *)sender.view;
    NSLog(@"GTS:%d,%@,%@",[currTag tag],[NSString stringWithFormat:@"%d",[currTag tag]], [currTag text]);
    [self performSelector:@selector(showShopProduct:) withObject:sender afterDelay:0.3];
}
- (void)showShopProduct:(UITapGestureRecognizer*)sender {
    UILabel *currTag = (UILabel *)sender.view;
    ShopAddressViewController *detailViewController = [[ShopAddressViewController alloc] init];
    detailViewController.shopId = [NSString stringWithFormat:@"%d",[currTag tag]];
    detailViewController.shopName = [currTag text];
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.shopNavController pushViewController:detailViewController animated:YES];
    [detailViewController release];
//    //for directly to list product by shop
//    ProductShopViewController *gotoShop = [[ProductShopViewController alloc] init];
//    gotoShop.shopId = [NSString stringWithFormat:@"%d",[currTag tag]];
//    gotoShop.shopName = [currTag text];
//    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [mydelegate.shopNavController pushViewController:gotoShop animated:YES];
//    [gotoShop release];
//    //for directly to shop location (new)
//    ShopDetailViewController *detailViewController = [[ShopDetailViewController alloc] init];
//    detailViewController.shopID = [NSString stringWithFormat:@"%d",[currentTag tag]];
//    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [mydelegate.shopNavController pushViewController:detailViewController animated:YES];
//    [detailViewController release];
}

-(void)tapAction:(id)sender{
    
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
    NSLog(@"TAG:%d",[sender tag]);
    NSLog(@"Name :%@",[[[[productData objectAtIndex:[sender tag]/2] valueForKey:@"list"] objectAtIndex:[sender tag]%2] valueForKey:@"product_name"]);
    [self performSelector:@selector(showProduct:) withObject:sender afterDelay:0.3];
}

- (void)showProduct:(id)sender
{
    DetailProductViewController *detailViewController = [[DetailProductViewController alloc] initWithNibName:@"DetailProductViewController" bundle:nil];
    NSString *prodId = [[[[productData objectAtIndex:[sender tag]/2] valueForKey:@"list"] objectAtIndex:[sender tag]%2] valueForKey:@"product_id"];
    detailViewController.productInfo = [[MJModel sharedInstance] getProductInfoFor:prodId];
    detailViewController.productId = [prodId mutableCopy];
    detailViewController.categoryId = [[productData objectAtIndex:[sender tag]/2] valueForKey:@"category_id"];
    detailViewController.buyButton =  [[NSString alloc] initWithString:@"ok"];
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.shopNavController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

- (void)viewDidDisappear:(BOOL)animated {
    [DejalBezelActivityView removeViewAnimated:YES];
}

- (void)dealloc {
    [super dealloc];
    [productData release];
    [_tableView release];
}

@end
