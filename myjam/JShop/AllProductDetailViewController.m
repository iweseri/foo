//
//  AllProductDetailViewController.m
//  myjam
//
//  Created by M Ridhwan M Sari on 6/4/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "AllProductDetailViewController.h"
#import "ProductShopViewController.h"
#import "ProductCell.h"
#import "HeaderProductCell.h"
#import "ShopClass.h"

#define kTableShopCellHeight 200

@interface AllProductDetailViewController ()

@end

@implementation AllProductDetailViewController

@synthesize productData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCatId:(NSInteger)cat_id {
    self = [super initWithNibName:@"AllProductDetailViewController" bundle:nil];
    if (self) {
        self.catId = cat_id;
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
        kDisplayPerScreen = 4;
    } else {
        // code for 3.5-inch screen
        kDisplayPerScreen = 3;
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
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"vda");
    [self.loadingIndicator startAnimating];
    if (![productData count] > 0) {
        productData = [[NSMutableArray alloc] init];
        [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.03f];
    } else {
        [self.loadingIndicator stopAnimating];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    rows = 0;
    if (([productData count] % 2) == 0)
        rows = ([productData count]/2)+1;
    else
        rows = (([productData count]/2) + 2);
    
//    if (rows >= kDisplayPerScreen) {
//        rows += 1; // Extra row for loading cell
//    }
    NSLog(@"row %d",rows);
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSLog(@"index at %d,row %d",indexPath.row,rows);
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
    
//    } else
    if(indexPath.row == 0) {
        HeaderProductCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HeaderProductCell" owner:nil options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.contentView.backgroundColor = [UIColor colorWithHex:@"#f1ebe4"];
        CGSize expectedLabelSize  = [self.catName sizeWithFont:[UIFont fontWithName:@"Verdana" size:12.0] constrainedToSize:CGSizeMake(150.0, cell.catNameLabel.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
        CGRect newFrame = cell.catNameLabel.frame;
        newFrame.size.width = expectedLabelSize.width;
        cell.catNameLabel.text = self.catName;
        cell.catNameLabel.backgroundColor = [UIColor colorWithHex:@"#f1ebe4"];
        cell.catNameLabel.frame = newFrame;
        [cell.viewAllButton setHidden:YES];
        return cell;
    } else {
        ProductCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProductCell" owner:nil options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.contentView.backgroundColor = [UIColor colorWithHex:@"#f1ebe4"];
        [self createCellForIndex:indexPath cell:cell];
        NSLog(@"configureCell");
        return cell;
    }
    // Configure the cell...
}

- (void)createCellForIndex:(NSIndexPath *)indexPath cell:(ProductCell *)cell
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
    shopNameLabel.text = [[productData objectAtIndex:(indexPath.row-1)*2+0] valueForKey:@"shop_name"];
    [shopNameLabel setTag:[[[productData objectAtIndex:(indexPath.row-1)*2+0] valueForKey:@"shop_id"] intValue]];
    [shopNameLabel setUserInteractionEnabled:YES];
    [shopNameLabel addGestureRecognizer:tap];
    [cell.transView1 addSubview:shopNameLabel];
    [tap release];
    [shopNameLabel release];
    
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 20, 150, 20)];
    categoryLabel.textColor = [UIColor blackColor];
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    categoryLabel.text = [[productData objectAtIndex:(indexPath.row-1)*2+0] valueForKey:@"product_name"];
    [cell.transView1 addSubview:categoryLabel];
    [categoryLabel release];
    
    cell.buttonTap1.tag =  2*(indexPath.row-1)+0;
    [cell.transView1 setHidden:NO];
    [[cell.button1 layer] setBorderWidth:3.0f];
    [[cell.button1 layer] setBorderColor:[UIColor whiteColor].CGColor];
    [cell.button1 setBackgroundImageWithURL:[NSURL URLWithString:[[productData objectAtIndex:(indexPath.row-1)*2+0] valueForKey:@"product_image"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
    [cell.buttonTap1 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    UIView *leftPrice = [[ShopClass sharedInstance] priceViewFor:[[productData objectAtIndex:(indexPath.row-1)*2+0] valueForKey:@"product_price"] and:[[productData objectAtIndex:(indexPath.row-1)*2+0] valueForKey:@"product_discounted_price"]];
    [leftPrice setFrame:CGRectMake(154-leftPrice.frame.size.width, 139, leftPrice.frame.size.width, 20)];
    [cell addSubview:leftPrice];
    [leftPrice release];
    
    NSLog(@"COUNT :%d|%d",[productData count],((indexPath.row-1)*2+1));
    if (((indexPath.row-1)*2+1) < [productData count]){
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewShop:)];
        UILabel *shopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 150, 20)];
        shopNameLabel.textColor = [UIColor darkGrayColor];
        shopNameLabel.backgroundColor = [UIColor clearColor];
        shopNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        shopNameLabel.text = [[productData objectAtIndex:(indexPath.row-1)*2+1] valueForKey:@"shop_name"];
        [shopNameLabel setTag:[[[productData objectAtIndex:(indexPath.row-1)*2+1] valueForKey:@"shop_id"] intValue]];
        [shopNameLabel setUserInteractionEnabled:YES];
        [shopNameLabel addGestureRecognizer:tap];
        [cell.transView2 addSubview:shopNameLabel];
        [tap release];
        [shopNameLabel release];
        
        UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 20, 150, 20)];
        categoryLabel.textColor = [UIColor blackColor];
        categoryLabel.backgroundColor = [UIColor clearColor];
        categoryLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        categoryLabel.text = [[productData objectAtIndex:(indexPath.row-1)*2+1] valueForKey:@"product_name"];
        [cell.transView2 addSubview:categoryLabel];
        [categoryLabel release];
      
        cell.buttonTap2.tag = 2*(indexPath.row-1)+1;
        [cell.transView2 setHidden:NO];
        [cell.buttonTap2 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        [[cell.button2 layer] setBorderWidth:3.0f];
        [[cell.button2 layer] setBorderColor:[UIColor whiteColor].CGColor];
        [cell.button2 setBackgroundImageWithURL:[NSURL URLWithString:[[productData objectAtIndex:(indexPath.row-1)*2+1] valueForKey:@"product_image"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
        
        UIView *rightPrice = [[ShopClass sharedInstance] priceViewFor:[[productData objectAtIndex:2*(indexPath.row-1)+1] valueForKey:@"product_price"] and:[[productData objectAtIndex:2*(indexPath.row-1)+1] valueForKey:@"product_discounted_price"]];
        [rightPrice setFrame:CGRectMake(310-rightPrice.frame.size.width, 139, rightPrice.frame.size.width, 20)];
        [cell addSubview:rightPrice];
        [rightPrice release];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if(indexPath.row == rows-1 && rows-1 >= kDisplayPerScreen){
//        return 44; // Loading cell height
//    } else
    if(indexPath.row == 0)
        return 40;
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

- (void)reloadPage {
    [self.loadingIndicator startAnimating];
    [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:1.0f];
}

- (void)loadMoreData
{
    NSLog(@"Page now is %d",pageCounter);
    
    BOOL success = [self retrieveData];
    
    if (!success) {
        if([productData count]==0) {
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
        NSLog(@"DATA :%@",productData);
        [self.tableView reloadData];
    }
    [self.loadingIndicator stopAnimating];
    NSLog(@"%f : %f",self.tableView.contentSize.height,self.tableView.bounds.size.height);
    
}

- (NSString *)returnAPIURL
{
    return [NSString stringWithFormat:@"%@/api/shop_product_subcat_list_v2.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]copy]];
}

- (NSString *)returnAPIDataContent
{
    return [NSString stringWithFormat:@"{\"category_id\":%d}",self.catId];
}

- (BOOL)retrieveData
{
    NSString *urlString = [self returnAPIURL];
    NSString *dataContent = [self returnAPIDataContent];
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"url: %@\ndataContent: %@",urlString,dataContent);
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
                [newData addObject:row];
            }
        }
        else{
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

-(void)viewShop:(UITapGestureRecognizer*)sender {
    UILabel *currTag = (UILabel *)sender.view;
    NSLog(@"GTS:%d",[currTag tag]);
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
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
//    ProductShopViewController *gotoShop = [[ProductShopViewController alloc] init];
//    gotoShop.shopId = [NSString stringWithFormat:@"%d",[currTag tag]];
//    gotoShop.shopName = [currTag text];
//    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [mydelegate.shopNavController pushViewController:gotoShop animated:YES];
//    [gotoShop release];
}

-(void)tapAction:(id)sender{
    //[self.loadingIndicator setHidden:NO];
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
    NSLog(@"TAG:%d | %@",[sender tag],[[productData objectAtIndex:[sender tag]] valueForKey:@"product_id"]);
    [self performSelector:@selector(showProduct:) withObject:sender afterDelay:0.3];
}
- (void)showProduct:(id)sender {
    DetailProductViewController *detailViewController = [[DetailProductViewController alloc] initWithNibName:@"DetailProductViewController" bundle:nil];
    NSString *prodId = [[productData objectAtIndex:[sender tag]] valueForKey:@"product_id"];
    detailViewController.productInfo = [[MJModel sharedInstance] getProductInfoFor:prodId];
    detailViewController.productId = [prodId mutableCopy];
    detailViewController.categoryId = [NSString stringWithFormat:@"%d",self.catId];
    detailViewController.buyButton =  [[NSString alloc] initWithString:@"ok"];
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.shopNavController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

- (void)dealloc {
    [super dealloc];
    [productData release];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.loadingIndicator stopAnimating];
    [DejalBezelActivityView removeViewAnimated:YES];
}

@end
