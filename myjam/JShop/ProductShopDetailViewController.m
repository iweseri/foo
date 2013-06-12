//
//  ProductShopDetailViewController.m
//  myjam
//
//  Created by M Ridhwan M Sari on 6/7/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "ProductShopDetailViewController.h"
#import "ShopClass.h"

#define kTableShopCellHeight 200

@interface ProductShopDetailViewController ()

@end

@implementation ProductShopDetailViewController

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
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"vda");
    [self.loadingIndicator startAnimating];
    if (![productData count] > 0) {
        [self.shopTitleLabel setText:self.shopName];
        productData = [[NSMutableArray alloc] init];
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
    
    if (rows >= kDisplayPerScreen) {
        rows += 1; // Extra row for loading cell
    }
    NSLog(@"row %d",rows);
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSLog(@"index at %d,row %d",indexPath.row,rows);
    if (indexPath.row == rows-1 && rows-1 >= kDisplayPerScreen){ NSLog(@"loadingCell");
        ShopLoadingCell *cell = (ShopLoadingCell*)[tableView dequeueReusableCellWithIdentifier:@"ShopLoadingCell"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ShopLoadingCell" owner:nil options:nil];
            cell = [nib objectAtIndex:0];
        }
        [cell.loadingIndicator startAnimating];
        
        NSLog(@"loading");
        return cell;
        
    } else if(indexPath.row == 0) { NSLog(@"headerCell");
        HeaderProductCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HeaderProductCell" owner:nil options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.contentView.backgroundColor = [UIColor colorWithHex:@"#f1ebe4"];
        CGSize expectedLabelSize  = [catName sizeWithFont:[UIFont fontWithName:@"Verdana" size:12.0] constrainedToSize:CGSizeMake(150.0, cell.catNameLabel.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
        CGRect newFrame = cell.catNameLabel.frame;
        newFrame.size.width = expectedLabelSize.width;
        cell.catNameLabel.text = catName;
        cell.catNameLabel.backgroundColor = [UIColor colorWithHex:@"#f1ebe4"];
        cell.catNameLabel.frame = newFrame;
        [cell.viewAllButton setHidden:YES];
        return cell;
    } else { NSLog(@"productCell");
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
    shopNameLabel.text = self.shopName;
    [shopNameLabel setTag:[self.shopId intValue]];
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
        shopNameLabel.text = self.shopName;
        [shopNameLabel setTag:[self.shopId intValue]];
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
        
        UIView *rightPrice = [[ShopClass sharedInstance] priceViewFor:[[productData objectAtIndex:(indexPath.row-1)*2+1] valueForKey:@"product_price"] and:[[productData objectAtIndex:(indexPath.row-1)*2+1] valueForKey:@"product_discounted_price"]];
        [rightPrice setFrame:CGRectMake(310-rightPrice.frame.size.width, 139, rightPrice.frame.size.width, 20)];
        [cell addSubview:rightPrice];
        [rightPrice release];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == rows-1 && rows-1 >= kDisplayPerScreen){
        return 44; // Loading cell height
    } else if(indexPath.row == 0)
        return 40;
    else{
        return kTableShopCellHeight;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == rows-1 && [cell isKindOfClass:[ShopLoadingCell class]]) {
        pageCounter++;
        [self.loadingIndicator setHidden:NO];
        [self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.2];
    }
}

- (void)loadMoreData
{
    NSLog(@"Page now is %d",pageCounter);
    
    BOOL success = [self retrieveData];
    
    if (!success) {
        if([productData count]==0) {
            [self.tableView setHidden:YES];
            UILabel *labelMsg = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-65, self.view.frame.size.height/2-50, 250, 20)];
            [labelMsg setText:@"Request time out."];
            [labelMsg setBackgroundColor:[UIColor clearColor]];
            [labelMsg setTextColor:[UIColor darkGrayColor]];
            [labelMsg sizeToFit];
            [self.view addSubview:labelMsg];
            [labelMsg release];
            
        } else {
            // Hide loading cell
            [UIView animateWithDuration:0.5 animations:^{
                CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height-44);
                
                [self.tableView setContentOffset:bottomOffset animated:YES];
            }];
        }
    }else{
        // Reload tableView
        NSLog(@"DATA :%@",productData);
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
    return [NSString stringWithFormat:@"{\"shop_id\":\"%@\",\"category_id\":\"%@\",\"page\":%d,\"perpage\":%d,\"search_sort\":\"A-Z\"}",self.shopId,self.catId,pageCounter, 5];
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
        NSMutableArray* resultArray = nil;
        
        if ([status isEqualToString:@"ok"] && [list count]) {
            for (id row in list) {
                catName = [row objectForKey:@"category_name"];
                if ( ![[row objectForKey:@"category_product_count"] isEqual:[NSNumber numberWithInt:0]] )
                {
                    resultArray = [row objectForKey:@"product_list"];
                }
            }
            if ([resultArray count] > 0) {
                for (id row in resultArray)
                    [newData addObject:row];
            }
            NSLog(@"DATAs :%@ | %@ | %@",newData,self.catId,catName);
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
    NSLog(@"TAG:%d | %@",[sender tag],[[productData objectAtIndex:[sender tag]] valueForKey:@"product_id"]);
    [self performSelector:@selector(showProduct:) withObject:sender afterDelay:0.3];
}
- (void)showProduct:(id)sender {
    DetailProductViewController *detailViewController = [[DetailProductViewController alloc] initWithNibName:@"DetailProductViewController" bundle:nil];
    NSString *prodId = [[productData objectAtIndex:[sender tag]] valueForKey:@"product_id"];
    detailViewController.productInfo = [[MJModel sharedInstance] getProductInfoFor:prodId];
    detailViewController.productId = [prodId mutableCopy];
    detailViewController.categoryId = self.catId;
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
    [productData release];
    [_tableView release];
}

@end
