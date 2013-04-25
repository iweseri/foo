//
//  DetailProductViewController.m
//  myjam
//
//  Created by Azad Johari on 1/30/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "DetailProductViewController.h"
#import "CompareRelatedViewController.h"
#import "CustomProduct.h"
#define kTableCellHeightC 70
@interface DetailProductViewController ()

@end

@implementation DetailProductViewController
@synthesize scrollView, aImages, productInfo,headerView,counter,selectedColor, selectedSize, buyButton, tempColorsForSize, tempSizesForColor, cartId, purchasedString;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    }
    return self;
}

- (void)setNSNCNotify:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"notifyClose"])
    {
        [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"reloadCartViewNotif"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNSNCNotify:) name:@"notifyClose" object:nil];
    
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
    tempColorsForSize = [[NSMutableArray alloc] init];
    tempSizesForColor = [[NSMutableArray alloc] init];
    counter = 0;
    self.selectedColor = @"none";
    self.selectedSize = @"none";
    self.cartId = @"";
    if ([[productInfo valueForKey:@"size_available"] count] > 0 ){
        counter = counter+1;
    }
    if ([[productInfo valueForKey:@"color_available"] count] > 0 ){
        counter = counter+2;
    }
    headerView = [[[NSBundle mainBundle] loadNibNamed:@"ProductHeaderView" owner:self options:nil]objectAtIndex:0];
    
    [headerView.rateView bringSubviewToFront:headerView.imageCarouselView];
    headerView.productName.text = [productInfo valueForKey:@"product_name"];
    headerView.rateView.editable = FALSE;
    headerView.rateView.selectedImage = [UIImage imageNamed:@"star.png"];
    headerView.rateView.nonSelectedImage = [UIImage imageNamed:@"grey_star.png"];
    headerView.rateView.maxRating = 5;
    
    //NSLog(@"rating %@",[productInfo valueForKey:@"product_rating"]);
    
    headerView.rateView.rating = [[productInfo valueForKey:@"product_rating"] doubleValue];
    if (headerView.rateView.rating == 0) {
        [headerView.rateView setHidden:YES];
    }
    headerView.productCat.text = [productInfo valueForKey:@"product_category"];
    headerView.shopName.text = [productInfo valueForKey:@"shop_name"];
    headerView.productPrice.text = [productInfo valueForKey:@"product_price"];
//    headerView.productPriceAfterDiscount.text = [productInfo valueForKey:@"product_price_before_discount"];
    
    if (![[productInfo valueForKey:@"product_price_before_discount"] isEqualToString:headerView.productPrice.text]) {
        headerView.productPrice.text = [productInfo valueForKey:@"product_price_before_discount"];
        headerView.productPriceAfterDiscount.text = [productInfo valueForKey:@"product_price"];
        [headerView.productPriceAfterDiscount setHidden:NO];
        [headerView.redLine setHidden:NO];
        
        CGSize textLabelSize = [headerView.productPrice.text sizeWithFont:[UIFont boldSystemFontOfSize:20]];
        headerView.redLine.frame  = CGRectMake(headerView.redLine.frame.origin.x, headerView.redLine.frame.origin.y, textLabelSize.width+35,3);
    }else{
        headerView.frame = CGRectMake(headerView.frame.origin.x, headerView.frame.origin.x, headerView.frame.size.width, headerView.frame.size.height-30);
    }
    
    self.productDesc.text = [productInfo valueForKey:@"product_description"];
    if ([[productInfo valueForKey:@"product_bulky"] isEqualToString:@"Y"]){
        if ([[productInfo valueForKey:@"product_fragile"] isEqualToString:@"Y"]){
            headerView.productState.image = [UIImage imageNamed:@"bulkyfragile.png"];
        }
        else{
            headerView.productState.image = [UIImage imageNamed:@"bulky.png"];
        }
    }
    else if([[productInfo valueForKey:@"product_fragile"] isEqualToString:@"Y"]){
        headerView.productState.image = [UIImage imageNamed:@"fragile.png"];
    }
    
    self.aImages = [[NSMutableArray alloc] initWithCapacity:[[productInfo valueForKey:@"product_image"] count]];
    for (int i=0; i< [[productInfo valueForKey:@"product_image"] count]; i++){
        
        [self retrieveImages:[[productInfo valueForKey:@"product_image"] objectAtIndex:i] ];
        
        
        
    }
    
    self.tableView.tableHeaderView = headerView;
    
    currentHeight = 30;
    headerView.shopName.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapCheckbox = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToShop)];
    [headerView.shopName addGestureRecognizer:tapCheckbox];
    
    //setup descLabel
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, currentHeight, 250, 10)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont systemFontOfSize:12]];
    [label setText:[productInfo valueForKey:@"product_description"]];
    [label setNumberOfLines:0];
    [label sizeToFit];
    
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, 250, label.frame.size.height);
    
    currentHeight += label.frame.size.height + 10;
    
    //setup descView
    self.bottomView.frame = CGRectMake(0, currentHeight, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
    
    currentHeight += self.bottomView.bounds.size.height;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, currentHeight)];
    
    [footerView addSubview:label];
    [label release];
    
    [footerView addSubview:self.bottomView];
    [self.bottomView release];
    
    [self.tableView setTableFooterView:footerView];
    [footerView release];
    
    //    self.view.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height);
    [self performSelectorInBackground:@selector(setupCompareRelated) withObject:self];
    
    [self setupCarousel];
    [DejalBezelActivityView removeViewAnimated:YES];
    // Do any additional setup after loading the view from its nib.
}
//--------------------------------------------------------------------------------------------
-(BOOL)getCompareRelatedFromAPI:(NSString *)type
{
    BOOL success = NO;
    NSString *urlString=nil, *dataContent=nil;
    if ([type isEqualToString:@"compare"]) {
        urlString = [NSString stringWithFormat:@"%@/api/shop_product_compare.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
        dataContent = [NSString stringWithFormat:@"{\"product_id\":\"%@\"}",self.productId];
    } else if([type isEqualToString:@"related"]) {
        urlString = [NSString stringWithFormat:@"%@/api/shop_product_related2.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
        dataContent = [NSString stringWithFormat:@"{\"product_id\":\"%@\",\"category_id\":\"%@\",\"flag\":\"related_product\"}",self.productId,self.categoryId];
    }
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"request %@\n%@\n\nresponse retrieveData: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] mutableCopy];
    //NSLog(@"dict %@",resultsDictionary);
    
    if([resultsDictionary count])
    {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        NSMutableArray *resultList;
        
        if ([status isEqualToString:@"ok"])
        {
            success = YES;
            resultList = [resultsDictionary objectForKey:@"list"];
            if([type isEqualToString:@"compare"]) {
                self.compareArray = resultList; NSLog(@"AAA :%@",self.compareArray); }
            else if ([type isEqualToString:@"related"]) {
                self.relatedArray = resultList; NSLog(@"BBB :%@",self.relatedArray); }
        }
    }
    [resultsDictionary release];
    return success;
}

-(void)setupCompareRelated
{
    if ([self getCompareRelatedFromAPI:@"compare"]) {
        if (![self.compareArray isKindOfClass:[NSString class]]) {
            CustomProduct *compare = [[CustomProduct alloc] initWithFrame:CGRectMake(0, 225, 320, 100)];
            int count=0;
            for (id row in self.compareArray) { count++; } NSLog(@"CNT :%d",count);
            if(count>3) {
                [self.viewAllCompare setHidden:NO];
                [self.viewAllCompare setTag:1];
                [self.viewAllCompare addTarget:self action:@selector(viewAll:) forControlEvents:UIControlEventTouchUpInside];
            }
            [self setupDataCompareRelated:compare toThe:self.compareArray];
            [self.bottomView addSubview:compare];
            [compare release];
        }
    }
    if ([self getCompareRelatedFromAPI:@"related"]) {
        if (![self.relatedArray isKindOfClass:[NSString class]]) {
            CustomProduct *related = [[CustomProduct alloc] initWithFrame:CGRectMake(0, 360, 320, 100)];
            int count=0;
            for (id row in self.relatedArray) { count++; } NSLog(@"CNT :%d",count);
            if(count>3) {
                [self.viewAllRelated setHidden:NO];
                [self.viewAllRelated setTag:1];
                [self.viewAllRelated addTarget:self action:@selector(viewAll:) forControlEvents:UIControlEventTouchUpInside];
            }
            [self setupDataCompareRelated:related toThe:self.relatedArray];
            [self.bottomView addSubview:related];
            [related release];
        }
    }
}

-(void)setupDataCompareRelated:(CustomProduct *)setData toThe:(NSMutableArray *)withData
{
    int count=0;
    for (id row in withData) { count++; }
    if (count > 0) {
        [setData.transView1 setHidden:NO];
        NSString *productName = [[withData objectAtIndex:0] valueForKey:@"product_name"];
        NSString *categoryName = [[withData objectAtIndex:0] valueForKey:@"product_category"];
        [self setMarquee:setData.transView1 toThe:productName and:categoryName];
        
        [setData.priceLabel1 setText:[[withData objectAtIndex:0] valueForKey:@"product_price"]];
        if ([[[withData objectAtIndex:0] valueForKey:@"product_rating"] isEqual:@"0.0"]) {
            [setData.rateView1 setHidden:YES];
        } else {
            [setData.rateView1 setRating:[[[withData objectAtIndex:0] valueForKey:@"product_rating"] doubleValue]];
            [setData.rateView1 setEditable:NO];
            [setData.rateView1 setSelectedImage:[UIImage imageNamed:@"star.png"]];
            [setData.rateView1 setNonSelectedImage:[UIImage imageNamed:@"grey_star.png"]];
            [setData.rateView1 setMaxRating:5];
        }
        [setData.buttonTap1 setTag:[[withData objectAtIndex:0] valueForKey:@"product_id"]];
        [setData.button1 setBackgroundImageWithURL:[[withData objectAtIndex:0] valueForKey:@"product_image"] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_icon"]];
        [setData.buttonTap1 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (count > 1) {
        [setData.transView2 setHidden:NO];
        NSString *productName = [[withData objectAtIndex:1] valueForKey:@"product_name"];
        NSString *categoryName = [[withData objectAtIndex:1] valueForKey:@"product_category"];
        [self setMarquee:setData.transView2 toThe:productName and:categoryName];
        
        [setData.priceLabel2 setText:[[withData objectAtIndex:1] valueForKey:@"product_price"]];
        if ([[[withData objectAtIndex:1] valueForKey:@"product_rating"] isEqual:@"0.0"]) {
            [setData.rateView2 setHidden:YES];
        } else {
            [setData.rateView2 setRating:[[[withData objectAtIndex:1] valueForKey:@"product_rating"] doubleValue]];
            [setData.rateView2 setEditable:NO];
            [setData.rateView2 setSelectedImage:[UIImage imageNamed:@"star.png"]];
            [setData.rateView2 setNonSelectedImage:[UIImage imageNamed:@"grey_star.png"]];
            [setData.rateView2 setMaxRating:5];
        }
        [setData.buttonTap2 setTag:[[withData objectAtIndex:1] valueForKey:@"product_id"]];
        [setData.button2 setBackgroundImageWithURL:[[withData objectAtIndex:1] valueForKey:@"product_image"] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_icon"]];
        [setData.buttonTap2 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (count > 2) {
        [setData.transView3 setHidden:NO];
        NSString *productName = [[withData objectAtIndex:2] valueForKey:@"product_name"];
        NSString *categoryName = [[withData objectAtIndex:2] valueForKey:@"product_category"];
        [self setMarquee:setData.transView3 toThe:productName and:categoryName];
        
        [setData.priceLabel3 setText:[[withData objectAtIndex:2] valueForKey:@"product_price"]];
        if ([[[withData objectAtIndex:2] valueForKey:@"product_rating"] isEqual:@"0.0"]) {
            [setData.rateView3 setHidden:YES];
        } else {
            [setData.rateView3 setRating:[[[withData objectAtIndex:2] valueForKey:@"product_rating"] doubleValue]];
            [setData.rateView3 setEditable:NO];
            [setData.rateView3 setSelectedImage:[UIImage imageNamed:@"star.png"]];
            [setData.rateView3 setNonSelectedImage:[UIImage imageNamed:@"grey_star.png"]];
            [setData.rateView3 setMaxRating:5];
        }
        [setData.buttonTap3 setTag:[[withData objectAtIndex:2] valueForKey:@"product_id"]];
        [setData.button3 setBackgroundImageWithURL:[[withData objectAtIndex:2] valueForKey:@"product_image"] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_icon"]];
        [setData.buttonTap3 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)setMarquee:(UIView *)setTransView toThe:(NSString *)product and:(NSString *)category
{
    MarqueeLabel *productNameLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0, 0, 90, 18) rate:20.0f andFadeLength:10.0f];
    productNameLabel.marqueeType = MLContinuous;
    productNameLabel.animationCurve = UIViewAnimationOptionCurveLinear;
    productNameLabel.numberOfLines = 1;
    productNameLabel.opaque = NO;
    productNameLabel.enabled = YES;
    productNameLabel.textAlignment = UITextAlignmentLeft;
    productNameLabel.textColor = [UIColor blackColor];
    productNameLabel.backgroundColor = [UIColor clearColor];
    productNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:10];
    productNameLabel.text = product;
    [setTransView addSubview:productNameLabel];
    [productNameLabel release];
    
    MarqueeLabel *categoryLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0, 14, 90, 18) rate:20.0f andFadeLength:10.0f];
    categoryLabel.marqueeType = MLContinuous;
    categoryLabel.animationCurve = UIViewAnimationOptionCurveLinear;
    categoryLabel.numberOfLines = 1;
    categoryLabel.opaque = NO;
    categoryLabel.enabled = YES;
    categoryLabel.textAlignment = UITextAlignmentLeft;
    categoryLabel.textColor = [UIColor blackColor];
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.font = [UIFont fontWithName:@"Helvetica" size:10];
    categoryLabel.text = category;
    [setTransView addSubview:categoryLabel];
    [categoryLabel release];
}

-(void)viewAll:(id)sender{
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
    [self performSelector:@selector(showAllProducts:) withObject:sender afterDelay:0.1];
}

- (void)showAllProducts:(id)sender
{
    //ProductViewAllViewController *detailViewController = [[ProductViewAllViewController alloc] initWith:_shopInfo andCat:[[_productArray objectAtIndex:[sender tag] ]valueForKey:@"category_name"]];
    CompareRelatedViewController *detailViewController = [[CompareRelatedViewController alloc] initWithNibName:@"CompareRelatedViewController" bundle:nil];
    detailViewController.productAllArray = self.compareArray;
    if ([sender tag] == 1) {
        detailViewController.catName = @"Compare Prices";
    } else {
        detailViewController.catName = @"Related Products";
    }
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.shopNavController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

-(void)tapAction:(id)sender{
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
    [self performSelector:@selector(showProductDetail:) withObject:sender afterDelay:0.1];
}

- (void)showProductDetail:(id)sender
{
    DetailProductViewController *detailViewController = [[DetailProductViewController alloc] initWithNibName:@"DetailProductViewController" bundle:nil];
    //NSString *prodId = [[[[_productArray objectAtIndex:([sender tag]/3)] valueForKey:@"product_list"] objectAtIndex:([sender tag]%3)] valueForKey:@"product_id" ];
    NSString *prodId = [sender tag];
    detailViewController.productInfo = [[MJModel sharedInstance] getProductInfoFor:prodId];
    detailViewController.productId = [prodId mutableCopy];
    detailViewController.categoryId = self.categoryId;
    detailViewController.buyButton =  [[NSString alloc] initWithString:@"ok"];
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.shopNavController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [DejalBezelActivityView removeViewAnimated:YES];
}
//--------------------------------------------------------------------------------------------
-(void)backToShop
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidUnload
{
    [self setHeaderView:nil];
    [self setProductDesc:nil];
    [self setSizeView:nil];
    [self setColorSelectView:nil];
    [self setTableView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(void)setupCarousel{
    carousel = [[Carousel alloc] initWithFrame:CGRectMake(0, 0, 236, 236)];
    carousel.delegate = self;
    // Add some images to carousel
    [carousel setImages:self.aImages];
    
    imgCounter = 0;
    [headerView.leftButton setHidden:YES];
    if ([self.aImages count] == 1) {
        [headerView.rightButton setHidden:YES];
    }
    
    CGPoint aOffset = CGPointMake(carousel.scroller.frame.size.width*imgCounter,0);
    [carousel.scroller setContentOffset:aOffset animated:YES];
    
    // Add carousel to view
    [headerView.imageCarouselView addSubview:carousel];
    
    // Add carousel side buttons
    [headerView.leftButton addTarget:self action:@selector(handleLeftButton) forControlEvents:UIControlEventTouchUpInside];
    [headerView.rightButton addTarget:self action:@selector(handleRightButton) forControlEvents:UIControlEventTouchUpInside];
    
    
}
- (void)handleLeftButton
{
    imgCounter--;
    CGPoint aOffset = CGPointMake(carousel.scroller.frame.size.width*imgCounter,0);
    [carousel.scroller setContentOffset:aOffset animated:YES];
    
    if(imgCounter == 0)
    {
        [headerView.leftButton setHidden:YES];
    }
    
    if(imgCounter == [self.aImages count]-2)
    {
        [headerView.rightButton setHidden:NO];
    }
}

- (void)handleRightButton
{
    imgCounter++;
    CGPoint aOffset = CGPointMake(carousel.scroller.frame.size.width*imgCounter,0);
    [carousel.scroller setContentOffset:aOffset animated:YES];
    
    if(imgCounter == 1)
    {
        [headerView.leftButton setHidden:NO];
    }
    
    if(imgCounter == [self.aImages count]-1)
    {
        [headerView.rightButton setHidden:YES];
    }
}

- (void)retrieveImages: (NSString *)uri
{
    ASIHTTPRequest *imageRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:uri]];
    
    [imageRequest startSynchronous];
    [imageRequest setTimeOutSeconds:2];
    // NSError *error = [imageRequest error];
    // NSString *contentType = [[imageRequest responseHeaders]
    //                  objectForKey:@"Content-Type"];
    UIImage *aImg = [[UIImage alloc] initWithData:[imageRequest responseData]];
    //NSLog(@"%@", [aImg class]);
    
    if ([aImg isKindOfClass:[NSData class]]||[aImg isKindOfClass:[UIImage class]] ){
        
        
    }else{
        //NSLog(@"img is null");
        aImg = [UIImage imageNamed:@"default_icon.png"];
    }
    [self.aImages addObject:aImg];
    
    [aImg release];
    [imageRequest release];
    

}

#pragma mark -
#pragma mark notification Center
- (void) receiveTestNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"reloadCartViewNotif"]) {
        NSLog (@"Successfully reload view! :%@",self.productId);
        productInfo = [[MJModel sharedInstance] getProductInfoFor:self.productId];
        [self.tableView reloadData];
        //        BuyNowCell *cell = (BuyNowCell *)[self.tableView cellForRowAtIndexPath:1];
        //        [cell setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark Carousel delegate

- (void)didScrollToPage:(int)page
{
    // Check currentpage
    
    imgCounter = page;
    if(imgCounter == 0)
    {
        [headerView.leftButton setHidden:YES];
    }
    
    if(imgCounter == [self.aImages count]-2)
    {
        [headerView.rightButton setHidden:NO];
    }
    
    if(imgCounter == 1)
    {
        [headerView.leftButton setHidden:NO];
    }
    
    if(imgCounter == [self.aImages count]-1)
    {
        [headerView.rightButton setHidden:YES];
    }
}
- (IBAction)facebookPressed:(id)sender {
    [self shareImageOnFBwith:[productInfo valueForKey:@"qrcode_id"] andImage:[aImages lastObject]];
}

- (IBAction)twitterPressed:(id)sender {
    [self shareImageOnTwitterFor: [productInfo valueForKey:@"qrcode_id"] andImage:[aImages lastObject]];
}

- (IBAction)emailPressed:(id)sender {
    [self shareImageOnEmailWithId:[productInfo valueForKey:@"qrcode_id"] withImage:[aImages lastObject]];
}

- (IBAction)favProdBtn:(id)sender
{
    FavFolderViewController *favFolderVC = [[FavFolderViewController alloc]init];
    
    favFolderVC.qrcodeId = [productInfo valueForKey:@"qrcode_id"];
    [self presentPopupViewController:favFolderVC animationType:MJPopupViewAnimationFade];
}

-(IBAction)readReviews{
//    ProductRatingListViewController *detailViewController = [[ProductRatingListViewController alloc] initWithNibName:@"ProductRatingListViewController" bundle:nil];
    
    ProductRatingListViewController *detailViewController = [[ProductRatingListViewController alloc] init];
    
    detailViewController.reviewList = [[MJModel sharedInstance] getProductReviewFor:_productId inPage:@"1"];
    
    detailViewController.productName = [productInfo valueForKey:@"product_name"];
    detailViewController.productId =[[ NSString alloc] initWithString:_productId];
    detailViewController.shopName = [productInfo valueForKey:@"shop_name"];
//    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [mydelegate.shopNavController pushViewController:detailViewController animated:YES];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

- (IBAction)reportProduct:(id)sender {
    
    //popDisabled = YES;
    
    ReportSpamViewController *detailView = [[ReportSpamViewController alloc] init];
    detailView.productId = self.productId;
    detailView.qrTitle = headerView.productName.text;
    detailView.qrProvider = headerView.shopName.text;
    detailView.qrDate = @"";
    detailView.qrAbstract = @"";
    detailView.qrType = headerView.productName.text;
    detailView.qrCategory = headerView.productCat.text;
    detailView.qrLabelColor = @"#ffffff";
    detailView.qrImage = [self.aImages objectAtIndex:0];
    [self.navigationController pushViewController:detailView animated:YES];
    [detailView release];
    
    
    //ProductReportViewController *detailViewController = [[ProductReportViewController alloc] initWithNibName:@"ProductReportViewController" bundle:nil andProductId:self.productId];
    
    
    //AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //[mydelegate.shopNavController pushViewController:detailViewController animated:YES];
    //[self.navigationController pushViewController:detailViewController animated:YES];
    //[detailViewController release];
    
}

-(void)buyNow:(id)sender{
    if (counter == 3){
        if ([selectedSize isEqualToString:@"none"]){
            [self createAlertFor:@"size"];
            return;
        } else if ([selectedColor isEqualToString:@"none"]){
            [self createAlertFor:@"color"];
            return;
        }
    }else if (counter == 2){
        if ([selectedColor isEqualToString:@"none"]){
            [self createAlertFor:@"color"];
            return;
        }
    }
    else if (counter == 1){
        if ([selectedSize isEqualToString:@"none"]){
            [self createAlertFor:@"size"];
            return;
        }
    }
    NSMutableString *param1 = nil;
    NSMutableString *param2 = nil;
    if ([selectedSize isEqual:@"none"]){
        param1 = [NSMutableString stringWithFormat:@"none"]; ;
    }
    else{
        param1 = [NSMutableString stringWithFormat:@"%@",[[[productInfo valueForKey:@"size_available"] objectAtIndex:[selectedSize intValue]] valueForKey:@"size_id"]];
    }
    if ([selectedColor isEqual:@"none" ]){
        param2 = [NSMutableString stringWithFormat:@"none"];
    }
    else{
        param2 = [NSMutableString stringWithFormat:@"%@",[[[productInfo valueForKey:@"color_available"] objectAtIndex:[selectedColor intValue]] valueForKey:@"color_id"]];
    }
    NSDictionary *purchaseStat = [[MJModel sharedInstance] addToCart:_productId withSize:[NSString stringWithString:param1]  andColor:[NSString stringWithString:param2] ];
    if ([[purchaseStat valueForKey:@"status"] isEqual:@"ok"]){
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"cartChanged"
         object:self];
        self.cartId = [NSString stringWithString:[purchaseStat valueForKey:@"cart_id"]];
        [self.tableView reloadData];
    }
}

-(void)createAlertFor:(NSString*)cat{
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"Please select a %@ before proceeding",cat] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
    [alert release];
}
//  [detailViewController release];


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (counter == 0){
        return 1;
    } else if (counter == 1){
        return 2;
    } else if (counter == 2){
        return 2;
    }
    else if (counter == 3){
        return 3;
    }
    
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (counter == 0){
        return 100;
    }  if (counter == 1){
        if (indexPath.row == 1){
            return 100;
        }
    }  if (counter == 2){
        if (indexPath.row == 1){
            return 100;
        }
    }
    if (counter == 3){
        if (indexPath.row == 2){
            return 100;
        }
    }
    
    return kTableCellHeightC;
}

- (void)setupBuyCell:(NSString *)CellIdentifier tableView:(UITableView *)tableView
{
}

- (void)setBuyNowCell:(BuyNowCell *)cell
{
    int butbool= 0;
    if ([[productInfo valueForKey:@"product_stockable"] isEqualToString:@"N"]){
        cell.limitedLabel.hidden = YES;
    }
    
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableArray *cartItems = [[NSMutableArray alloc] initWithArray:mydelegate.sidebarController.cartItems];
    for (int i = 0; i< [cartItems count]; i++){
        //NSLog(@"%@",[cartItems objectAtIndex:i]);
        if ([[[cartItems objectAtIndex:i ] valueForKey:@"shop_name"] isEqual:[productInfo valueForKey:@"shop_name"]] ){
            for (id row in [[cartItems objectAtIndex:i  ]valueForKey:@"item_list"]){
                //NSLog(@"row: %@", row);
                if ([self.productId isEqual:[row valueForKey:@"product_id"]]){
                    if (counter == 0){
                        butbool = 1;
                        break;
                    }
                    else if (counter == 3){
                        if ([[[[productInfo valueForKey:@"color_available"] objectAtIndex:[self.selectedColor intValue]] valueForKey:@"color_id"] isEqual:[row valueForKey:@"color_id"]]){
                            if ([[[[productInfo valueForKey:@"size_available"] objectAtIndex:[self.selectedSize intValue]] valueForKey:@"size_id"] isEqual:[row valueForKey:@"size_id"]]){
                                butbool =1;
                                break;
                            }
                            
                        }
                    }
                    else if (counter == 2){
                        if ([[[[productInfo valueForKey:@"color_available"] objectAtIndex:[self.selectedColor intValue]] valueForKey:@"color_id"] isEqual:[row valueForKey:@"color_id"]]){
                            butbool =1;
                            break;
                        }
                        
                    }
                    else if (counter == 1){
                        if ([[[[productInfo valueForKey:@"size_available"] objectAtIndex:[self.selectedSize intValue]] valueForKey:@"size_id"] isEqual:[row valueForKey:@"size_id"]]){
                            butbool =1;
                            break;
                        }
                    }
                }
            }
        }
    }
    if (butbool == 0){
        if ([[productInfo valueForKey:@"product_stock_balance_total"] isEqual:[NSNumber numberWithInt:0]]){
            [cell.button1 setBackgroundImage:[UIImage imageNamed:@"sold_out"] forState:UIControlStateNormal];
            [cell.button1 setTitle:@"" forState:UIControlStateNormal];
            cell.button1.userInteractionEnabled = NO;
            
        }
        else{
            [cell.button1 addTarget:self action:@selector(buyNow:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        cell.continueShoppingButton.hidden = YES;
        cell.checkOutButton.hidden = YES;
        
    } else{
        [cell.button1 setBackgroundImage:[UIImage imageNamed:@"added_cart"] forState:UIControlStateNormal];
        [cell.button1 setTitle:@"" forState:UIControlStateNormal];
        [cell.button1 addTarget:self action:@selector(showCart:) forControlEvents:UIControlEventTouchUpInside];
        cell.continueShoppingButton.hidden = NO;
        cell.continueShoppingButton.userInteractionEnabled = YES;
        [cell.continueShoppingButton addTarget:self action:@selector(continueShopping:) forControlEvents:UIControlEventTouchUpInside];
        cell.checkOutButton.hidden = NO;
        cell.checkOutButton.userInteractionEnabled = YES;
        [cell.checkOutButton addTarget:self action:@selector(checkOut:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setPurchaseCell:(PurchaseVerificationCell *)cell
{
    cell.webView.delegate = self;
    
    [cell.webView  loadHTMLString:[NSString stringWithFormat:@"<div id ='foo' align='justify' style='font-size:10px; font-family:verdana';>%@<div>",[productInfo valueForKey:@"order_info"]] baseURL:nil];
    
    [cell.webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('br')[0].style.fontFamily =\"Verdana\""];
    
    [cell.submitButton addTarget:self action:@selector(submitReport:) forControlEvents:UIControlEventTouchUpInside];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    if (counter == 0){
        if ([self.buyButton isEqualToString:@"ok"])
        {
            BuyNowCell *cell = (BuyNowCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BuyNowCell" owner:nil options:nil];
            if (cell == nil)
            {
                cell = [nib objectAtIndex:0];
                [self setBuyNowCell:cell];
                return cell;
            }
        }
        else{
            PurchaseVerificationCell *cell = (PurchaseVerificationCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PurchaseVerificationCell" owner:nil options:nil];
            if (cell == nil)
            {
                
                cell = [nib objectAtIndex:0];
                [self setPurchaseCell:cell];
                
                return cell;
            }
        }
    }
    else
    {
        
        if (counter ==1){
            SizeSelectionCell *cell = (SizeSelectionCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (indexPath.row==0){
                if (cell == nil)
                {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SizeSelectionCell" owner:nil options:nil];
                    cell = [nib objectAtIndex:0];
                }
                if ([self.purchasedString isEqualToString:@"purchased"])
                {
                    cell.sizeSelectView.sizeChoices = [NSMutableArray arrayWithObject:[self getSizeInfo:[productInfo valueForKey:@"size_available"] forId:[productInfo valueForKey:@"order_size_id"]]];
                    cell.sizeSelectView.editable = NO;
                    cell.sizeSelectView.sizeChoicesNum = 1;
                    cell.sizeSelectView.delegate = self;
                    cell.sizeSelectLabel.text = @"Selected size";
                    if (![self.selectedSize isEqual:@"none"])
                    {
                        cell.sizeSelectView.size = [self.selectedSize intValue];
                    }
                }
                else{
                    
                    cell.sizeSelectView.sizeChoices = [NSMutableArray arrayWithObjects:[productInfo valueForKey:@"size_available"], [productInfo valueForKey:@"stock_balance"], nil];
                    cell.sizeSelectView.editable = YES;
                    cell.sizeSelectView.sizeChoicesNum = [[productInfo valueForKey:@"size_available"] count];
                    cell.sizeSelectView.delegate = self;
                    
                    if (![self.selectedSize isEqual:@"none"])
                    {
                        cell.sizeSelectView.size = [self.selectedSize intValue];
                    }
                }
                
                return cell;
            }
            else{
                if ([self.buyButton isEqualToString:@"ok"])
                {
                    BuyNowCell *cell = (BuyNowCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BuyNowCell" owner:nil options:nil];
                    if (cell == nil)
                    {
                        cell = [nib objectAtIndex:0];
                        [self setBuyNowCell:cell];
                        return cell;
                    }
                }
                else{
                    PurchaseVerificationCell *cell = (PurchaseVerificationCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PurchaseVerificationCell" owner:nil options:nil];
                    if (cell == nil)
                    {
                        
                        cell = [nib objectAtIndex:0];
                        [self setPurchaseCell:cell];
                        
                        return cell;
                    }
                }
            }
        }
        
        else if (counter ==2){
            if (indexPath.row ==0){
                ColorSelectionCell *cell = (ColorSelectionCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil)
                {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ColorSelectionCell" owner:nil options:nil];
                    cell = [nib objectAtIndex:0];
                }
                if ([self.purchasedString isEqualToString:@"purchased"])
                {
                    NSMutableArray *arrayTemp = [NSMutableArray arrayWithObjects:[self getColorInfo:[productInfo valueForKey:@"color_available"] forId:[productInfo valueForKey:@"order_color_id"]],nil];
                    cell.colorSelectView.colorChoices = [NSMutableArray arrayWithObjects:arrayTemp,nil];
                    cell.colorSelectView.editable = NO;
                    cell.colorSelectView.colorChoicesNum = 1;
                    cell.colorSelectView.delegate = self;
                    cell.colorSelectTitle.text = @"Selected color";
                    if (![self.selectedSize isEqual:@"none"])
                    {
                        cell.colorSelectView.color = [self.selectedSize intValue];
                    }
                }else{
                    
                    cell.colorSelectView.colorChoices = [NSMutableArray arrayWithObjects:[productInfo valueForKey:@"color_available"], [productInfo valueForKey:@"stock_balance"], nil];
                    cell.colorSelectView.editable = YES;
                    cell.colorSelectView.colorChoicesNum = [[productInfo valueForKey:@"color_available"] count];
                    
                    cell.colorSelectView.delegate = self;
                    if (![self.selectedColor isEqual:@"none"]){
                        cell.colorSelectView.color =[self.selectedColor intValue];
                    }
                    
                }
                return cell;
            }
            else{
                if ([self.buyButton isEqualToString:@"ok"])
                {
                    BuyNowCell *cell = (BuyNowCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BuyNowCell" owner:nil options:nil];
                    if (cell == nil)
                    {
                        cell = [nib objectAtIndex:0];
                        [self setBuyNowCell:cell];
                        return cell;
                    }
                }
                else{
                    PurchaseVerificationCell *cell = (PurchaseVerificationCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PurchaseVerificationCell" owner:nil options:nil];
                    if (cell == nil)
                    {
                        
                        cell = [nib objectAtIndex:0];
                        [self setPurchaseCell:cell];
                        
                        return cell;
                    }
                }
            }
        }
        else  if (counter ==3){
            if (indexPath.row == 1){
                SizeSelectionCell *cell = (SizeSelectionCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil)
                {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SizeSelectionCell" owner:nil options:nil];
                    cell = [nib objectAtIndex:0];
                }
                if ([self.purchasedString isEqualToString:@"purchased"])
                {
                    NSMutableArray *arrayTemp = [NSMutableArray arrayWithObjects:[self getSizeInfo:[productInfo valueForKey:@"size_available"] forId:[productInfo valueForKey:@"order_size_id"]],nil];
                    cell.sizeSelectView.sizeChoices = [NSMutableArray arrayWithObjects:arrayTemp,nil];
                    cell.sizeSelectView.editable = NO;
                    cell.sizeSelectView.sizeChoicesNum = 1;
                    cell.sizeSelectView.delegate = self;
                    cell.sizeSelectLabel.text = @"Selected size";
                    if (![self.selectedSize isEqual:@"none"])
                    {
                        cell.sizeSelectView.size = [self.selectedSize intValue];
                    }
                }
                else{
                    if (![self.selectedSize isEqual:@"none"]){
                        cell.sizeSelectView.size =[self.selectedSize intValue];
                    }
                    cell.sizeSelectView.sizeChoices = [NSMutableArray arrayWithObjects:[productInfo valueForKey:@"size_available"] , [productInfo valueForKey:@"stock_balance"], nil];
                    cell.sizeSelectView.editable = YES;
                    cell.sizeSelectView.colorsForSize = tempColorsForSize;
                    cell.sizeSelectView.sizeChoicesNum = [[productInfo valueForKey:@"size_available"] count];
                    cell.sizeSelectView.delegate = self;
                    //NSLog(@"%@", tempColorsForSize);
                }
                return cell;
            }else if (indexPath.row ==0)
            {
                ColorSelectionCell *cell = (ColorSelectionCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil)
                {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ColorSelectionCell" owner:nil options:nil];
                    cell = [nib objectAtIndex:0];
                }
                if ([self.purchasedString isEqualToString:@"purchased"]){
                    NSMutableArray *arrayTemp = [NSMutableArray arrayWithObjects:[self getColorInfo:[productInfo valueForKey:@"color_available"] forId:[productInfo valueForKey:@"order_color_id"]],nil];
                    cell.colorSelectView.colorChoices = [NSMutableArray arrayWithObjects:arrayTemp,nil];
                    cell.colorSelectTitle.text = @"Selected color";
                    cell.colorSelectView.editable = NO;
                    cell.colorSelectView.colorChoicesNum = 1;
                    cell.colorSelectView.delegate = self;
                    if (![self.selectedSize isEqual:@"none"]){
                        cell.colorSelectView.color = [self.selectedSize intValue];
                    }
                }else{
                    if (![self.selectedColor isEqual:@"none"]){
                        cell.colorSelectView.color =[self.selectedColor intValue];
                    }
                    cell.colorSelectView.colorChoices = [NSMutableArray arrayWithObjects:[productInfo valueForKey:@"color_available"], [productInfo valueForKey:@"stock_balance" ] , nil ];
                    cell.colorSelectView.editable = YES;
                    cell.colorSelectView.sizesForColor = tempSizesForColor;
                    cell.colorSelectView.colorChoicesNum = [[productInfo valueForKey:@"color_available"] count];
                    
                    cell.colorSelectView.delegate = self;
                    // self.selectedColor = 0;
                }
                return cell;
            }
            else{
                if ([self.buyButton isEqualToString:@"ok"])
                {
                    BuyNowCell *cell = (BuyNowCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BuyNowCell" owner:nil options:nil];
                    if (cell == nil)
                    {
                        cell = [nib objectAtIndex:0];
                        [self setBuyNowCell:cell];
                        return cell;
                    }
                }
                else{
                    PurchaseVerificationCell *cell = (PurchaseVerificationCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PurchaseVerificationCell" owner:nil options:nil];
                    if (cell == nil)
                    {
                        
                        cell = [nib objectAtIndex:0];
                        [self setPurchaseCell:cell];
                        
                        return cell;
                    }
                }
            }
        }
    }
    return nil;
}

-(void)showCart:(id)sender{
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate handleTab5];
}
-(NSDictionary*)getColorInfo:(NSArray*)info forId:(NSString*)colorId{
    for (NSDictionary *row in info ){
        if ([[NSString stringWithFormat:@"%@",[row valueForKey:@"color_id" ] ]isEqualToString:colorId]){
            return row;
        }
    }
    return nil;
}
-(NSDictionary*)getSizeInfo:(NSArray*)info forId:(NSString*)sizeId{
    for (NSDictionary *row in info ){
        if ([[NSString stringWithFormat:@"%@",[row valueForKey:@"size_id" ]] isEqualToString:sizeId]){
            return row;
        }
    }
    return nil;
}

-(void)submitReport:(id)sender{
    
    ReportSpamViewController *detailView = [[ReportSpamViewController alloc] init];
    detailView.orderItemId = self.orderId;
    //NSLog(@"%@ -- ", detailView.orderItemId);
    detailView.productId = self.productId;
    detailView.qrTitle = headerView.productName.text;
    detailView.qrProvider = headerView.shopName.text;
    detailView.qrDate = @"";
    detailView.qrAbstract = @"";
    detailView.qrType = headerView.productName.text;
    detailView.qrCategory = headerView.productCat.text;
    detailView.qrLabelColor = @"#ffffff";
    detailView.qrImage = [self.aImages objectAtIndex:0];
    [self.navigationController pushViewController:detailView animated:YES];
    [detailView release];
    
//    ProductReportViewController *detailViewController = [[ProductReportViewController alloc] initWithNibName:@"ProductReportViewController" bundle:nil andProductId:self.productId];
//    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [mydelegate.shopNavController pushViewController:detailViewController animated:YES];
//    //[self.navigationController pushViewController:detailViewController animated:YES];
//    [detailViewController release];
}
-(void)checkOut:(id)sender{
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
    [self performSelector:@selector(processCheckout) withObject:nil afterDelay:0.0];
    
}

- (void)processCheckout
{
    CheckoutViewController *detailViewController = [[CheckoutViewController alloc] initWithNibName:@"CheckoutViewController" bundle:nil];
    if ([cartId isEqualToString:@""]){
        AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSArray *tempArray =  mydelegate.sidebarController.cartItems;
        for (id row in tempArray){
            //NSLog(@"%@",row);
            //NSLog(@"%@", [productInfo valueForKey:@"shop_name"]);
            if ([[productInfo valueForKey:@"shop_name"] isEqualToString:[row valueForKey:@"shop_name"]]){
                self.cartId = [row valueForKey:@"cart_id"];
                break;
            }
        }
        
    }
    NSMutableArray *tempAnswer =[[NSMutableArray alloc] initWithArray:[[MJModel sharedInstance] getCartListForCartId:cartId]] ;
    if([[[tempAnswer objectAtIndex:0] valueForKey:@"status"] isEqual:@"failure"]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"An error has occurred. Please try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
    }
    else{
        detailViewController.cartList = tempAnswer;
        detailViewController.footerView = [[[NSBundle mainBundle] loadNibNamed:@"checkOutFooterView" owner:self options:nil]objectAtIndex:0];
        detailViewController.footerType = @"0";
        AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [mydelegate.shopNavController pushViewController:detailViewController animated:YES];
    }
    [detailViewController release];
    [DejalBezelActivityView removeViewAnimated:YES];
}

-(void)continueShopping:(id)sender{
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.shopNavController popViewControllerAnimated:YES];
}
- (void)dealloc {
    [selectedColor release];
    [selectedSize release];
    [headerView release];
    [_productDesc release];
    [_sizeView release];
    [_colorSelectView release];
    [_tableView release];
    [buyButton release];
    [_productArray release];
    [_productAllArray release];
    [_shopInfo release];
    [_compareArray release];
    [_relatedArray release];
    [_viewAllCompare release];
    [_viewAllRelated release];
    [_categoryId release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}
-(void)sizeview:(SizeSelectView *)sizeView sizeDidChange:(int)size{
    self.selectedSize = [NSString stringWithFormat:@"%d", size];
    if (counter == 3){
        [tempSizesForColor removeAllObjects];
        for (NSDictionary *row in [productInfo valueForKey:@"stock_balance"]){
            
            if ([[[[productInfo valueForKey:@"size_available"] objectAtIndex:size] valueForKey:@"size_id"] isEqual:[NSString stringWithFormat:@"%@",[row valueForKey:@"size_id"]]]){
                
                [tempSizesForColor addObject:row];
            }
        }
        //  //NSLog(@"%@", tempArray);
        //= [NSMutableArray arrayWithArray:tempArray];
        [self.tableView reloadData];
    }
    else{
        
        if ([[[[productInfo valueForKey:@"stock_balance"] objectAtIndex:size] valueForKey:@"stock_balance"] isEqual:[NSNumber numberWithInt:0]]){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Out of stock" message:@"This product is currently out of stock." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            [alertView release];
            
        }else{
            self.selectedSize = [NSString stringWithFormat:@"%d", size];
            [self.tableView reloadData];
        }
    }
}
-(void)colorview:(ColorSelectView *)colorView colorDidChange:(int)color{
    if (counter == 3){
        self.selectedColor = [NSString stringWithFormat:@"%d", color];
        [tempColorsForSize removeAllObjects];
        for (NSDictionary *row in [productInfo valueForKey:@"stock_balance"]){
            
            if ([[[[productInfo valueForKey:@"color_available"] objectAtIndex:color] valueForKey:@"color_id"] isEqual:[NSString stringWithFormat:@"%@",[row valueForKey:@"color_id"]]]){
                
                [tempColorsForSize addObject:row];
            }
        }
        [self.tableView reloadData];
        
    }
    else{
        
        if ([[[[productInfo valueForKey:@"stock_balance"] objectAtIndex:color] valueForKey:@"stock_balance"] isEqual:[NSNumber numberWithInt:0]]){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Out of stock" message:@"This product is currently out of stock." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            [alertView release];
            
        }else{
            self.selectedColor = [NSString stringWithFormat:@"%d", color];
            [self.tableView reloadData];
        }
    }
    
}
-(void)clearSelectedSize{
    self.selectedSize = @"none";
    //NSLog(@"%@",selectedSize);
}
-(void)clearSelectedColor{
    self.selectedColor =@"none";
    //NSLog(@"%@",selectedColor);
}

@end
