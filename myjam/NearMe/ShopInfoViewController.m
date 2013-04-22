//
//  ShopInfoViewController.m
//  myjam
//
//  Created by Azad Johari on 2/28/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "ShopInfoViewController.h"
#import "ShopDetailListingViewController.h"
#import "DejalActivityView.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

@interface ShopInfoViewController ()

@end

@implementation ShopInfoViewController
@synthesize shopAddInfo,shopID, shopLogo, shopAddress, scroller, shopDistance;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Near Me";
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
    }
    return self;
}

- (void)refreshScroller
{
    self.scroller.contentSize = self.scroller.frame.size;
    self.scroller.frame = self.view.frame;
    if (self.scroller.frame.size.height > 350){
        [ scroller setContentSize:CGSizeMake(320, self.shopAddress.frame.size.height+350+90) ];
        
    }
    [self.view addSubview:self.scroller];
}

- (void)viewDidLoad
{
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
    [self performSelector:@selector(setupView) withObject:nil afterDelay:0.0f];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)setupView
{
    [self getShopCoordNDistFromAPI];
    
    self.shopAddInfo = [[NSDictionary alloc] initWithDictionary:[[MJModel sharedInstance]getAddressForStore:[NSString stringWithFormat:@"%d",shopID]]];
    [self refreshScroller];
    [self.shopLogo setImageWithURL:[NSURL URLWithString:[shopAddInfo valueForKey:@"shop_logo"]] placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
    
    [[self.shopAddress scrollView] setBounces:NO];
    //modification to add font
    
    NSString *setContent = [NSString stringWithFormat:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\"><head><title></title></head><body style='font-family:Arial; font-size:12px; text-align:justify;'>%@</body></html>",[shopAddInfo valueForKey:@"shop_info"]];
    
    [shopAddress loadHTMLString:setContent baseURL:nil];
    
    NSLog(@"self.shopdistance: %d",shopDistance);
    self.distanceLabel.text = [self distanceConverter:shopDistance];
    
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSInteger degreeDecimals = [self degreeCalculatorWithLat:self.shopCoordLat andLong:self.shopCoordLong] + appDel.currentDecDegree;
    UIImage *imagePointer = [[UIImage imageNamed:@"arrowNaviHR.png"]imageRotatedByDegrees:degreeDecimals];
    UIImageView *pointing = [[UIImageView alloc]initWithImage:imagePointer];
    
    pointing.frame = CGRectMake(70, 120, 40, 40);
    [self.scroller addSubview:pointing];
    [pointing release];
    [DejalBezelActivityView removeViewAnimated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    CGRect frame = aWebView.frame;
    frame.size.height = 1;
    aWebView.frame = frame;
    CGSize fittingSize = [aWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    aWebView.frame = frame;
    self.infoView.frame = CGRectMake(0,MAX(125,25+fittingSize.height),self.infoView.frame.size.width,self.infoView.frame.size.height);
    self.socialView.frame = CGRectMake(0, self.infoView.frame.origin.y+130, self.infoView.frame.size.width, self.socialView.frame.size.height);
    if (self.infoView.frame.origin.y+130+self.socialView.frame.size.height < 400){
        self.scroller.scrollEnabled = NO;
    }
    //self.visitButton.frame = CGRectMake(0,MAX(125,25+fittingSize.height),self.visitButton.frame.size.width,self.visitButton.frame.size.height);
    //self.socialView.frame = CGRectMake(0, self.visitButton.frame.origin.y+55, self.socialView.frame.size.width, self.socialView.frame.size.height);
//    if (self.visitButton.frame.origin.y+55+self.socialView.frame.size.height < 400){
//        self.scroller.scrollEnabled = NO;
//    }
    [self refreshScroller];
    //NSLog(@"size: %f, %f", fittingSize.width, fittingSize.height);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [shopLogo release];
    [shopAddress release];
    [scroller release];
    [_visitButton release];
    [_socialView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setShopLogo:nil];
    [self setShopAddress:nil];
    [self setVisitButton:nil];
    [self setSocialView:nil];
    [super viewDidUnload];
}

- (NSInteger)degreeCalculatorWithLat:(double)latitude andLong:(double)longitude
{
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    NSLog(@"Curr Lat: %f",appDel.currentLat);
    NSLog(@"Curr Long: %f",appDel.currentLong);
    NSLog(@"Curr DecDegree: %d",appDel.currentDecDegree);
    
    float fromLat = degreesToRadians(appDel.currentLat);
    float fromLong = degreesToRadians(appDel.currentLong);
    float toLat = degreesToRadians(latitude);
    float toLong = degreesToRadians(longitude);
    
    float getDegree = radiandsToDegrees(atan2(sin(toLong-fromLong)*cos(toLat), cos(fromLat)*sin(toLat)-sin(fromLat)*cos(toLat)*cos(toLong-fromLong)));
    
    if (getDegree >= 0) { return getDegree; }
    else { return 360+getDegree; }
    
    NSLog(@"Degree: %f",getDegree);
    
    return getDegree;
}
- (void)getShopCoordNDistFromAPI
{
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/nearme_map.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"lat\":\"%f\",\"lng\":\"%f\",\"radius\":\"%d\"}",appDel.currentLat,appDel.currentLong,appDel.withRadius];
    
    NSLog(@"UrlString %@ and datacontent %@",urlString,dataContent);
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"request %@\n%@\n\nresponse retrieveData: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] mutableCopy];
    
    NSLog(@"dict %@",resultsDictionary);
    
    if([resultsDictionary count])
    {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        
        if ([status isEqualToString:@"ok"])
        {
            for (id row in [resultsDictionary objectForKey:@"list"])
            {
                NSLog(@"row shopID: %@",[row objectForKey:@"shop_id"]);
                NSInteger shopIDStr = [[row objectForKey:@"shop_id"]intValue];
                NSInteger shopIDStrCurrent = self.shopID;
                
                if (shopIDStr == shopIDStrCurrent)
                {
                    NSLog(@"row shopID detected: %d",shopIDStr);
                    self.shopCoordLat = [[row objectForKey:@"shop_lat"]doubleValue];
                    self.shopCoordLong = [[row objectForKey:@"shop_lng"]doubleValue];
                    self.shopDistance = [[row objectForKey:@"distance_in_meter"]integerValue];
                    NSLog(@"%d:%f:%f",self.shopDistance,self.shopCoordLat,self.shopCoordLong);
                }
            }
        }
    }
    else
    {
        CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Near Me" message:@"Connection error. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (NSString *)distanceConverter:(NSInteger)distanceInMeter
{
    NSString *distance = @"";
    
    float distanceInMeter2 = (float)distanceInMeter;
    float convertToKM = distanceInMeter2 / 1000;
    NSString *floatItToKMInString = [NSString stringWithFormat:@"%.1f",(float)convertToKM];
    float floatItToKM = [floatItToKMInString floatValue];
    
    NSLog(@"Convert To KM: %f",convertToKM);
    NSLog(@"Float It To KM: %f",floatItToKM);
    NSLog(@"Float It To Meter: %d",distanceInMeter);
    
    if (floatItToKM < 1.0)
    {
        NSLog(@"Less than 1.0: %@",floatItToKMInString);
        distance = [NSString stringWithFormat:@"%d m",distanceInMeter];
    }
    else
    {
        NSLog(@"More than 1.0 : %@",floatItToKMInString);
        distance = [NSString stringWithFormat:@"%.1f km",(float)convertToKM];
    }
    
    return distance;
}
- (IBAction)prevMapHyperAct:(id)sender
{
    NSLog(@"Preview Map Action Voided!");
    
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    PrevMapNMViewController *prevMapNMVC = [[PrevMapNMViewController alloc]init];
    prevMapNMVC.shopID = shopID;
    
    [myDelegate.otherNavController pushViewController:prevMapNMVC animated:YES];
}
- (IBAction)visitJSHyperAct:(id)sender
{
    NSLog(@"Visit JAM-BU Shop Action Voided!");
    
    ShopDetailListingViewController *detailViewController = [[ShopDetailListingViewController alloc] init];
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
    detailViewController.productArray = [[NSMutableArray alloc] initWithArray:[[MJModel sharedInstance] getTopListOfItemsFor:[NSString stringWithFormat:@"%d",self.shopID]]];
    
    detailViewController.shopInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",self.shopID],@"shop_id",
                                     self.shopName, @"shop_name",
                                     self.topSellerOrNot,@"shop_top_seller", nil];
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.otherNavController pushViewController:detailViewController animated:YES];
}

- (IBAction)visitShop:(id)sender {
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    for (int i=0 ; i< [mydelegate.shopNavController.viewControllers count]; i++){
        
        if( [[[mydelegate.shopNavController.viewControllers objectAtIndex:i] class] isEqual:[ShopDetailListingViewController class]])
        {
            [mydelegate.shopNavController popToViewController:[mydelegate.shopNavController.viewControllers objectAtIndex:i] animated:YES];
            break;
        }
    }
}

- (IBAction)facebookPressed:(id)sender {
    [self shareImageOnFBwith:[self.shopAddInfo  valueForKey:@"qrcode_id"] andImage:self.shopLogo.image];
}

- (IBAction)twitterPressed:(id)sender {
    [self shareImageOnTwitterFor:[self.shopAddInfo  valueForKey:@"qrcode_id"] andImage:self.shopLogo.image];
}

- (IBAction)emailPressed:(id)sender {
    [self shareImageOnEmailWithId:[self.shopAddInfo  valueForKey:@"qrcode_id"] withImage:self.shopLogo.image];
}
@end