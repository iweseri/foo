//
//  CheckoutViewController.m
//  myjam
//
//  Created by Azad Johari on 2/2/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "CheckoutViewController.h"
#define kTableCellHeightB 150
#define checkoutTag         1
#define seedTag             2
@interface CheckoutViewController ()

@end

@implementation CheckoutViewController
@synthesize tableView, footerView, paymentStatus;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Checkout";
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
        
        // Custom initialization
    }
    return self;
}
- (void)updatePage
{
    // All instances of TestClass will be notified
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"cartChanged"
     object:self];
    if ([_cartList count] >0){
        footerView.totalPrice.text =[[[[_cartList objectAtIndex:0]valueForKey:@"total"] componentsSeparatedByString:@":"] objectAtIndex:1];
        // footerView.adminFeeLabel.text = [[[[_cartList objectAtIndex:0] valueForKey:@"admin_fee"]componentsSeparatedByString:@":"] objectAtIndex:1];
        if ([self.footerType isEqual:@"1"]){
            footerView.shopNameLabel.text = [[_cartList objectAtIndex:0] valueForKey:@"shop_name"];
            footerView.deliveryLabel.text = [[_cartList objectAtIndex:0] valueForKey:@"delivery_fee"];
            footerView.gTotalLabel.text
            = [[[[_cartList objectAtIndex:0] valueForKey:@"grand_total"] componentsSeparatedByString:@":"] objectAtIndex:1];
            self.totalSeed = [[[_cartList objectAtIndex:0] valueForKey:@"grand_total_seed"] intValue];
            //for update checkout button value
            NSString *seedTitle = [NSString stringWithFormat:@"CHECKOUT WITH  ♦ %@",[NSString stringWithFormat:@"%@",[NSNumberFormatter localizedStringFromNumber:@(self.totalSeed) numberStyle:NSNumberFormatterDecimalStyle]]];
            [footerView.seedButton setTitle:seedTitle forState:UIControlStateNormal];
            NSLog(@"SEED:%d",self.totalSeed);
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Cart is empty. Please add an item." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        [alert release];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"vdl checkout");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shoppingCartChange:) name:@"cartChangedFromView" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PurchaseVerification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(PurchaseVerification:)
                                                 name:@"PurchaseVerification"
                                               object:nil];

    
    self.shopName.text = [[_cartList objectAtIndex:0] valueForKey:@"shop_name"];
    [self updatePage];
    if ([self.footerType isEqual:@"1"]){
        [footerView.checkOutButton setTag:checkoutTag];
        [footerView.checkOutButton addTarget:self action:@selector(checkOutPressed:) forControlEvents:UIControlEventTouchUpInside];
        [footerView.seedButton setTag:seedTag];
        NSString *seedTitle = [NSString stringWithFormat:@"CHECKOUT WITH  ♦ %@",[NSString stringWithFormat:@"%@",[NSNumberFormatter localizedStringFromNumber:@(self.totalSeed) numberStyle:NSNumberFormatterDecimalStyle]]];
        [footerView.seedButton setTitle:seedTitle forState:UIControlStateNormal];
        [footerView.seedButton addTarget:self action:@selector(checkOutPressed:) forControlEvents:UIControlEventTouchUpInside];
        footerView.jambuFeePrice.text = [[_cartList objectAtIndex:0] valueForKey:@"admin_fee"];
    }
    self.tableView.tableFooterView=footerView;
    [self.shopLogo setImageWithURL:[NSURL URLWithString:[[_cartList objectAtIndex:0] valueForKey:@"shop_logo"]]
                  placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
//    [self updatePage];
    [footerView.deliveryButton addTarget:self action:@selector(deliveryOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [_cartList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[_cartList objectAtIndex:section] valueForKey:@"item_list"] count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    CartItemViewCell *cell = (CartItemViewCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CartItemViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
    }
    [self createCellForIndex:indexPath cell:cell];
    
    return cell;
}
- (void)createCellForIndex:(NSIndexPath *)indexPath cell:(CartItemViewCell *)cell
{
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.productName.text = [[[[_cartList objectAtIndex:indexPath.section] valueForKey:@"item_list"] objectAtIndex:indexPath.row] valueForKey:@"product_name"];
    cell.priceLabel.text = [[[[_cartList objectAtIndex:indexPath.section] valueForKey:@"item_list"] objectAtIndex:indexPath.row] valueForKey:@"total_price"];
    cell.qtyLabel.text = [[[[_cartList objectAtIndex:indexPath.section] valueForKey:@"item_list"] objectAtIndex:indexPath.row] valueForKey:@"quantity"];
    if ([[[[[_cartList objectAtIndex:indexPath.section] valueForKey:@"item_list"] objectAtIndex:indexPath.row] valueForKey:@"color_code"] isEqual:@""]){
        cell.colorView.hidden = true;
    }
    else{
        [cell.colorView setBackgroundColor:[UIColor colorWithHex:[[[[_cartList objectAtIndex:indexPath.section] valueForKey:@"item_list"] objectAtIndex:indexPath.row] valueForKey:@"color_code"]]];
        [cell.colorView.layer setBorderColor:[[UIColor grayColor]CGColor]];
        [cell.colorView.layer setBorderWidth:1.0];
    }
    if ([[[[[_cartList objectAtIndex:indexPath.section] valueForKey:@"item_list"] objectAtIndex:indexPath.row] valueForKey:@"size_name"] isEqual:@""]){
        cell.sizeLabel.hidden=TRUE;
        [cell.aSizeLabel setHidden:YES];
    }else{
        cell.sizeLabel.text = [[[[_cartList objectAtIndex:indexPath.section] valueForKey:@"item_list"] objectAtIndex:indexPath.row] valueForKey:@"size_name" ];
        
    }
    
    if (![[[[[_cartList objectAtIndex:indexPath.section] valueForKey:@"item_list"] objectAtIndex:indexPath.row] valueForKey:@"product_image"]isKindOfClass: [NSNull class]])
    {[cell.productImage setImageWithURL:[NSURL URLWithString:[[[[_cartList objectAtIndex:indexPath.section] valueForKey:@"item_list"] objectAtIndex:indexPath.row] valueForKey:@"product_image"] ] placeholderImage:[UIImage imageNamed:@"default_icon.png"]] ;
    }
    else{
        cell.productImage.image = [UIImage imageNamed:@"default_icon.png"];
    }
    cell.buttonMinus.tag = 2*indexPath.row+ 1;
    cell.buttonPlus.tag = 2*indexPath.row;
    [cell.buttonPlus addTarget:self action:@selector(changeQty:) forControlEvents:UIControlEventTouchUpInside];
    [cell.buttonMinus addTarget:self action:@selector(changeQty:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableCellHeightB;
}

#pragma mark - Table view delegate

-(void)changeQty:(id)sender{
    NSString *newQty ;
    if (([sender tag] % 2) == 0){
        newQty = [NSString stringWithFormat:@"%d",([[[[[_cartList objectAtIndex:0] valueForKey:@"item_list"] objectAtIndex:([sender tag]/2)]  valueForKey:@"quantity" ]intValue] + 1) ];
        
    }
    else{
        if (![[[[[_cartList objectAtIndex:0] valueForKey:@"item_list"] objectAtIndex:([sender tag] / 2)] valueForKey:@"product_name"] isEqual:@"0"]){
            
            newQty = [NSString stringWithFormat:@"%d",([[[[[_cartList objectAtIndex:0] valueForKey:@"item_list"] objectAtIndex:([sender tag]/2)]  valueForKey:@"quantity" ]intValue] - 1) ];
            
        } else{
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Unsuccessful"
                                  message: @"Insufficient stock"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            return ;
        }
    }
    //TODO if cart empty
    if ([newQty isEqualToString:@"0"]){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Are you sure?"
                              message: @"Are you sure to remove the item?"
                              delegate: self
                              cancelButtonTitle:@"Yes"
                              otherButtonTitles:@"No",nil];
        alert.tag = [sender tag];
        [alert show];
        [alert release];
        
    }
    else{
        [self changeQuantity:newQty fromId:[sender tag]];
    }
    
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{ if (buttonIndex == 0)
{
    
    [self changeQuantity:@"0" fromId: alertView.tag];
}}

-(void)changeQuantity:(NSString*)qty fromId:(NSInteger)tag{
    NSMutableArray *arrayTemp;
    arrayTemp = [[NSMutableArray alloc] initWithArray:[[MJModel sharedInstance] updateProduct:[[[[_cartList objectAtIndex:0] valueForKey:@"item_list"] objectAtIndex:(tag/2)] valueForKey:@"cart_item_id"] forCart:[[_cartList objectAtIndex:0] valueForKey:@"cart_id"]  forQuantity:qty]];
    if ([qty isEqualToString:@"0"]){
        AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [mydelegate.shopNavController popToRootViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"cartChanged"
         object:self];
    }else{
        for (id row in arrayTemp){
            if ([[row valueForKey:@"cart_id"] isEqualToString:[[self.cartList objectAtIndex:0] valueForKey:@"cart_id"]]){
                self.cartList = [[NSMutableArray alloc] initWithObjects:row, nil];
            }
        }
        
        //NSLog(@"%@", _cartList);
        [self.tableView reloadData];
        [self updatePage];
    }
}
-(void)deliveryOptions:(id)sender{
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
    [self performSelector:@selector(processToDeliveryAddressPage) withObject:nil afterDelay:0.1];
}

- (void)processToDeliveryAddressPage
{
    AddressEditViewController *detailViewController = [[AddressEditViewController alloc] initWithNibName:@"AddressEditViewController" bundle:nil];
    detailViewController.addressInfo = [[MJModel sharedInstance] getDeliveryDetailforCart:[[_cartList objectAtIndex:0] valueForKey:@"cart_id"]];
    detailViewController.cartId = [[_cartList objectAtIndex:0] valueForKey:@"cart_id"];
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.shopNavController pushViewController:detailViewController animated:YES];
    [DejalBezelActivityView removeViewAnimated:YES];
    [detailViewController release];
}

- (void)dealloc {
    [tableView release];
    [_shopLogo release];
    [_shopName release];
    [paymentStatus release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setShopLogo:nil];
    [self setShopName:nil];
    
    [self setShopLogo:nil];
    [super viewDidUnload];
}
-(void)shoppingCartChange:(NSNotification *)notification{
    
    self.cartList = [[MJModel sharedInstance] getCartListForCartId:[[_cartList objectAtIndex:0] valueForKey:@"cart_id"]];
    //[NSString stringWithFormat:@"%d",[[[cartItems objectAtIndex:0] valueForKey:@"item_list" ] count] ]
    [self.tableView reloadData];
    [self updatePage];
    // [[[[[self tabBarController] tabBar] items] objectAtIndex:4] setBadgeValue:@"1"];
}
#pragma mark -
#pragma mark CheckoutPopupViewDelegate
- (void)popView:(CheckoutPopupView *)popupView didSelectOptionAtIndex:(NSInteger)index
{
    NSLog(@"Clicked at post %d and selected option %d", popupView.tag, index);
    [self removeBlackView];
    if (popupView.tag == checkoutTag) {
        if (index == 1) {
            //[self checkoutProcess];
            [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
            [self performSelector:@selector(checkoutProcess) withObject:nil afterDelay:0.0];
        }
    } else {
        if (index == 1) {
            //[self seedProcess];
            [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
            [self performSelector:@selector(seedProcess) withObject:nil afterDelay:0.0];
        }
    }
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

- (IBAction)checkOutPressed:(id)sender
{
    NSLog(@"Seed2:%d",self.totalSeed);
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    CheckoutPopupView *popup;
    if ([sender tag] == seedTag) {
        popup = [[CheckoutPopupView alloc] initWithDataList:self.totalSeed andTag:[sender tag]];
    } else {
        popup = [[CheckoutPopupView alloc] initWithDataList:nil andTag:[sender tag]];
    }
    
    popup.delegate = self;
    
    CGFloat popupYPoint = mydelegate.window.frame.size.height/2-popup.frame.size.height/2;
    CGFloat popupXPoint = mydelegate.window.frame.size.width/2-popup.frame.size.width/2;
    popup.frame = CGRectMake(popupXPoint, popupYPoint, popup.frame.size.width, popup.frame.size.height);
    
    [self addBlackView];
    [mydelegate.window addSubview:popup];
}

-(void)seedProcess {
    NSString *urlString = [NSString stringWithFormat:@"%@/api/shop_cart_checkout_deduct_seed_v2.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]copy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"seed_value\":%d,\"cart_id\":\"%@\"}",self.totalSeed,[[_cartList objectAtIndex:0]valueForKey:@"cart_id"]];
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"dataContent: %@\nresponse listing: %@", dataContent,response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    NSString *status = nil;
    NSMutableArray* list = nil;
    NSString *balanceSeed = 0;
    
    if([resultsDictionary count]) {
        status = [resultsDictionary objectForKey:@"status"];
        if ([status isEqualToString:@"ok"]) {
            list = [resultsDictionary objectForKey:@"list"];
            balanceSeed = [list valueForKey:@"balance_seed"];
            
            AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            mydelegate.balSeed = [balanceSeed integerValue];
            [mydelegate.seedViewLabel setText:[NSString stringWithFormat:@"♦ %@",[NSNumberFormatter localizedStringFromNumber:@(mydelegate.balSeed) numberStyle:NSNumberFormatterDecimalStyle]]];
            [[NSNotificationCenter defaultCenter ] postNotificationName:@"cartChanged" object:self];
            [[NSNotificationCenter defaultCenter ] postNotificationName:@"refreshPurchaseHistory" object:self];
            SuccessfulViewController *success = [[SuccessfulViewController alloc] init];
            [mydelegate.shopNavController popToRootViewControllerAnimated:NO];
            [mydelegate.shopNavController pushViewController:success animated:YES];
            success.isShowSeeds = YES;
            success.balanceSeed = balanceSeed;
            [success release];
        }
    }
    [DejalBezelActivityView removeViewAnimated:YES];
}

-(void)checkoutProcess {
    NSDictionary *respond = [[MJModel sharedInstance]getCheckoutUrlForId:[[_cartList objectAtIndex:0]valueForKey:@"cart_id"]];
    if ([[respond valueForKey:@"status" ] isEqual:@"ok"]){
        self.paymentStatus = @"processing";
        if ([[UIApplication sharedApplication] openURL:[NSURL URLWithString:[respond valueForKey:@"url"] ]]){
            AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            mydelegate.isReturnFromPayment = YES;
        }
    }
}

-(void)PurchaseVerification:(NSNotification *) notification{
    
    [DejalBezelActivityView removeViewAnimated:YES];
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (mydelegate.isReturnFromPayment == NO) {
        return;
    }
    
    mydelegate.isReturnFromPayment = NO;
    NSDictionary *purchaseStatus = [[MJModel sharedInstance] getPurchaseStatus:[[_cartList objectAtIndex:0] valueForKey:@"cart_id"]];
    if ([[purchaseStatus valueForKey:@"status"] isEqualToString:@"Paid"]){
        [[NSNotificationCenter defaultCenter ] postNotificationName:@"cartChanged" object:self];
        [[NSNotificationCenter defaultCenter ] postNotificationName:@"refreshPurchaseHistory" object:self];
        SuccessfulViewController *success = [[SuccessfulViewController alloc] init];
        [mydelegate.shopNavController popToRootViewControllerAnimated:NO];
        [mydelegate.shopNavController pushViewController:success animated:YES];
        success.isShowSeeds = NO;
        [success release];
    }
    else{
        CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"Failure" message:@"Purchase failed. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
    }
    
    
}
@end
