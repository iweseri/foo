//
//  NMProductListsViewController.m
//  myjam
//
//  Created by ME-Tech Mac User 2 on 2/28/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "NMProductListsViewController.h"
#import "AppDelegate.h"
#import "JambuCellNML.h"
#import "ShopInfoViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

@interface NMProductListsViewController ()

@end

@implementation NMProductListsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedCategories = @"";
    self.searchedText = @"";
    self.sortData = @"";
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        kDisplayPerscreen = 4;
    } else {
        // code for 3.5-inch screen
        kDisplayPerscreen = 3;
    }
    
    UIPanGestureRecognizer *slideRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:nil];
    slideRecognizer.delegate = self;
    [self.tableView addGestureRecognizer:slideRecognizer];
    [self loadData];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!self.refreshDisabled)
    {
        AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (![mydelegate.bottomSVAll.searchTextField.text isKindOfClass:[NSString class]]) {
            mydelegate.bottomSVAll.searchTextField.text = @"";
        } NSLog(@"AAA :%@",self.selectedCategories);
        if (![self.selectedCategories isKindOfClass:[NSString class]]) {
            self.selectedCategories = @"";
        } NSLog(@"BBB :%@",self.sortData);
        if (![self.sortData isKindOfClass:[NSString class]]) {
            self.sortData = @"";
        }
        
        [self.tableData removeAllObjects];
        [self.tableView reloadData];
        [self.loadingLabel setText:@"Loading ..."];
        [self.activityIndicator setHidden:NO];
        [self.activityIndicatorView setHidden:NO];
        [self loadData];
        
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }else{
        self.refreshDisabled = NO;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.view];
    
    if(gestureRecognizer.numberOfTouches == 2){
        if (translation.y < 0) {
            AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [mydelegate handleSwipeUp];
            return YES;
        }
    }
    else{
        //NSLog(@"%d",gestureRecognizer.numberOfTouches);
    }
    return NO;
}


- (void)loadData
{
    [self.activityIndicator startAnimating];
    //    [self performSelectorOnMainThread:@selector(setupView) withObject:nil waitUntilDone:YES];
    [self performSelector:@selector(setupView) withObject:nil afterDelay:0.0];
    //    [self setupView];
    //    [self performSelectorInBackground:@selector(setupView) withObject:nil];
    
}

- (void)setupView
{
    if (![self.searchedText isKindOfClass:[NSString class]]) {
        self.searchedText = @"";
    }
    NSString *isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"islogin"]copy];
    
    if ([isLogin isEqualToString:@"YES"]) {
        self.pageCounter = 1;
        self.tableData = [self loadMoreFromServer];
    }
    if ([self.tableData count]) {
        [self.tableView reloadData];
        [self.activityIndicator stopAnimating];
    }
}

#pragma mark -
#pragma mark Bottom Loadmore action

- (void) addItemsToEndOfTableView{
    [UIView animateWithDuration:0.3 animations:^{
        if (self.pageCounter >= self.totalPage) {
            CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height-kExtraCellHeight+5);
            [self.tableView setContentOffset:bottomOffset animated:YES];
        }
        else if (self.pageCounter < self.totalPage) {
            self.pageCounter++;
            NSArray *list = [self loadMoreFromServer];
            
            if ([list count] > 0) {
                [self.tableData addObjectsFromArray:list];
            }
        }
    }];
}

- (NSString *)returnAPIURL
{
    return [NSString stringWithFormat:@"%@/api/nearme_list.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
}

- (NSString *)returnAPIDataContent
{
    AppDelegate *setDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    //return [NSString stringWithFormat:@"{\"lat\":\"%f\",\"lng\":\"%f\",\"radius\":\"%d\",\"page\":\"%d\",\"perpage\":\"%d\",\"search\":\"%@\",\"category_id\":\"%@\",\"sort_by\":\"%@\"}",(double)setDelegate.currentLat,(double)setDelegate.currentLong,(NSInteger)setDelegate.withRadius,self.pageCounter, kListPerpage, self.searchedText, self.selectedCategories, self.sortData];
    return [NSString stringWithFormat:@"{\"lat\":\"3.024613\",\"lng\":\"101.616600\",\"radius\":\"%d\",\"page\":\"%d\",\"perpage\":\"%d\",\"search\":\"%@\",\"category_id\":\"%@\",\"sort_by\":\"%@\"}",(NSInteger)setDelegate.withRadius,self.pageCounter, kListPerpage, self.searchedText, self.selectedCategories, self.sortData];
}

- (NSMutableArray *)loadMoreFromServer
{
    NSString *urlString = [self returnAPIURL];
    
    NSString *dataContent = [self returnAPIDataContent];
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"URLSTRING: %@\ndataContent: %@\nresponse listings: %@",urlString,dataContent,response);
    NSMutableArray *newData = [[NSMutableArray alloc] init];
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    
    NSString *status = nil;
    NSMutableArray* list = nil;
    
    if([resultsDictionary count])
    {
        status = [resultsDictionary objectForKey:@"status"];
        list = [resultsDictionary objectForKey:@"list"];
        NSMutableArray* resultArray;
        
        if ([status isEqualToString:@"ok"] && [list count])
        {
            self.totalPage = [[resultsDictionary objectForKey:@"pagecount"] intValue];
            
            resultArray = [resultsDictionary objectForKey:@"list"];
            
            for (id row in resultArray)
            {
                MData *aData = [[MData alloc] init];
                
                aData.qrcodeId = [row objectForKey:@"shop_id"];
                aData.category = [row objectForKey:@"category"];
                aData.labelColor = [row objectForKey:@"color"];
                aData.contentProvider = [row objectForKey:@"shop_name"];
                aData.title = [self distanceConverter:[[row objectForKey:@"distance_in_meter"]intValue]];
                aData.date = [row objectForKey:@"date"];
                aData.abstract = [row objectForKey:@"idescription"];
                aData.type = @"";
                aData.degreeDecimal = [self degreeCalculatorWithLat:[[row objectForKey:@"shop_lat"]doubleValue] andLong:[[row objectForKey:@"shop_lng"]doubleValue]];
                aData.imageURL = [row objectForKey:@"shop_logo"];
                aData.shareType = @"";
                
                id objnul = aData.category;
                
                if (objnul != [NSNull null] && aData.labelColor && aData.qrcodeId && aData.title && aData.date && aData.type) {
                    [newData addObject:aData];
                }
                [aData release];
            }
            
            if (![resultArray count] || self.totalPage == 0)
            {
                [self.activityIndicator setHidden:YES];
                
                NSString *aMsg = [resultsDictionary objectForKey:@"message"];
                
                if([aMsg length] < 1)
                {
                    if (self.selectedCategories.length > 0) {
                        aMsg = @"No data matched.";
                    }
                }
                self.loadingLabel.text = [NSString stringWithFormat:@"%@",aMsg];
                [self.loadingLabel setTextAlignment:NSTextAlignmentCenter];
                self.loadingLabel.textColor = [UIColor grayColor];
            }
            
            NSLog(@"page now is %d",self.pageCounter);
            NSLog(@"totpage %d",self.totalPage);
            
            // if data is less, then hide the loading view
            if (([newData count] > 0 && [newData count] < kListPerpage)) {
                NSLog(@"here xx");
                [self.activityIndicatorView setHidden:YES];
            }
            
        }
        else
        {
            NSLog(@"Listing error (probably API error) but we treat as no records to close the (null) message.");
            [self.activityIndicatorView setHidden:NO];
            [self.activityIndicator setHidden:YES];
            self.loadingLabel.text = [NSString stringWithFormat:@"No records. Pull to refresh"];
            [self.loadingLabel setTextAlignment:NSTextAlignmentCenter];
            self.loadingLabel.textColor = [UIColor grayColor];
        }
        
    }
    
    
    if ([status isEqualToString:@"error"]) {
        [self.activityIndicatorView setHidden:NO];
        [self.activityIndicator setHidden:YES];
        
        NSString *errorMsg = [resultsDictionary objectForKey:@"message"];
        
        if([errorMsg length] < 1)
            errorMsg = @"Failed to retrieve data.";
        
        self.loadingLabel.text = [NSString stringWithFormat:@"%@",errorMsg];
        [self.loadingLabel setTextAlignment:NSTextAlignmentCenter];
        self.loadingLabel.textColor = [UIColor grayColor];
        
    }
    
    if ([status isEqualToString:@"ok"] && self.totalPage == 0) {
        NSLog(@"empty");
        [self.activityIndicatorView setHidden:NO];
        [self.activityIndicator setHidden:YES];
        self.loadingLabel.text = [NSString stringWithFormat:@"No records. Pull to refresh"];
        [self.loadingLabel setTextAlignment:NSTextAlignmentCenter];
        self.loadingLabel.textColor = [UIColor grayColor];
    }
    
    if ([status isEqualToString:@"ok"] && self.totalPage > 1 && ![[resultsDictionary objectForKey:@"list"] count]) {
        NSLog(@"data empty");
        [self.activityIndicatorView setHidden:YES];
    }
    [resultsDictionary release];
    
    return newData;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    
    NSString *compassFault = nil;
    double updatedHeading;
    //double radianConst;
    
    updatedHeading = newHeading.magneticHeading;
    //float headingFloat = 0 - newHeading.magneticHeading;
    
    //rotateImg.transform = CGAffineTransformMakeRotation(headingFloat*radianConst);
    float value = updatedHeading;
    if(value >= 0 && value < 23)
    {
        compassFault = [NSString stringWithFormat:@"%f° N",value];
    }
    else if(value >=23 && value < 68)
    {
        compassFault = [NSString stringWithFormat:@"%f° NE",value];
    }
    else if(value >=68 && value < 113)
    {
        compassFault = [NSString stringWithFormat:@"%f° E",value];
    }
    else if(value >=113 && value < 185)
    {
        compassFault = [NSString stringWithFormat:@"%f° SE",value];
    }
    else if(value >=185 && value < 203)
    {
        compassFault = [NSString stringWithFormat:@"%f° S",value];
    }
    else if(value >=203 && value < 249)
    {
        compassFault = [NSString stringWithFormat:@"%f° SE",value];
    }
    else if(value >=249 && value < 293)
    {
        compassFault = [NSString stringWithFormat:@"%f° W",value];
    }
    else if(value >=293 && value < 350)
    {
        compassFault = [NSString stringWithFormat:@"%f° NW",value];
    }
    
    NSLog(@"CompassFault: %@",compassFault);
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

static inline double radians (double degrees) {return degrees * M_PI/180;}

#pragma mark -
#pragma mark UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    [super scrollViewDidScroll:scrollView];
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"FeedCell";
    
    JambuCellNML *cell = (JambuCellNML *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"JambuCellNML" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    for (MarqueeLabel *label in cell.transView.subviews) {
        [label removeFromSuperview];
    }
    
    MarqueeLabel *shopeName;
    
    MData *fooData = [self.tableData objectAtIndex:indexPath.row];
    
    shopeName = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0, 0, 65, 17) rate:20.0f andFadeLength:10.0f];
    shopeName.marqueeType = MLContinuous;
    shopeName.animationCurve = UIViewAnimationOptionCurveLinear;
    shopeName.numberOfLines = 1;
    shopeName.opaque = NO;
    shopeName.enabled = YES;
    shopeName.textAlignment = NSTextAlignmentLeft;
    shopeName.textColor = [UIColor blackColor];
    shopeName.backgroundColor = [UIColor clearColor];
    shopeName.font = [UIFont fontWithName:@"Helvetica-Bold" size:10];
    shopeName.text = fooData.category;
    [cell.transView addSubview:shopeName];
    [shopeName release];
    
    shopeName = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0, 13, 65, 17) rate:20.0f andFadeLength:10.0f];
    shopeName.marqueeType = MLContinuous;
    shopeName.animationCurve = UIViewAnimationOptionCurveLinear;
    shopeName.numberOfLines = 1;
    shopeName.opaque = NO;
    shopeName.enabled = YES;
    shopeName.textAlignment = NSTextAlignmentLeft;
    shopeName.textColor = [UIColor blackColor];
    shopeName.backgroundColor = [UIColor clearColor];
    shopeName.font = [UIFont fontWithName:@"Helvetica" size:10];
    shopeName.text = fooData.category;
    [cell.transView addSubview:shopeName];
    [shopeName release];
    
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    NSInteger degreeDecimals = fooData.degreeDecimal + appDel.currentDecDegree;
    
    UIImage *imagePointer = [[UIImage imageNamed:@"arrowNaviHR.png"]imageRotatedByDegrees:degreeDecimals];
    UIImageView *pointing = [[UIImageView alloc]initWithImage:imagePointer];
    
    pointing.frame = CGRectMake(80, 0, 20, 15);
    [cell.transView addSubview:pointing];
    [pointing release];
    
    cell.providerLabel.text = fooData.contentProvider;
    cell.thumbsView.image = [UIImage imageNamed:fooData.imageURL];
    cell.dateLabel.text = fooData.date;
    cell.abstractLabel.text = fooData.abstract;
    cell.categoryLabel.text = fooData.category;
    cell.kmLabel.text = fooData.title;
    cell.labelView.backgroundColor = [UIColor colorWithHex:fooData.labelColor];
    [cell.thumbsView setImageWithURL:[NSURL URLWithString:fooData.imageURL]
                    placeholderImage:[UIImage imageNamed:@"default_icon"]
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                               if (!error) {
                                   
                               }else{
                                   NSLog(@"error retrieve image: %@",error);
                               }
                               
                           }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self processRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableCellHeight;
}

#pragma mark -
#pragma mark didSelectRow extended action
//for moreview to pass to spam (abstract n imageView)
- (void)processRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"INDEXPATH from JambuCellNML");
    //[DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
    ShopInfoViewController*detailView = [[ShopInfoViewController alloc] init];
    detailView.shopID = [[[self.tableData objectAtIndex:indexPath.row] qrcodeId]integerValue];
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.otherNavController pushViewController:detailView animated:YES];
    [detailView release];
}
//end

#pragma mark -
#pragma mark PullRefresh action

- (void)refresh {
    [self performSelector:@selector(addItem) withObject:nil afterDelay:0.0];
}

- (void)addItem { /* add item to top */
    self.pageCounter = 1;
    [self.tableData removeAllObjects];
    self.tableData = [[self loadMoreFromServer] mutableCopy];
    [self.tableView reloadData];
    
    [self stopLoading];
}

#pragma mark content filter

//- (void) refreshTableItemsWithFilter:(NSString *)str
//{
//    //NSLog(@"Filtering all list");
//    self.selectedCategories = @"";
//    self.selectedCategories = str;
//    self.pageCounter = 1;
//    [self.tableData removeAllObjects];
//    self.tableData = [[self loadMoreFromServer] mutableCopy];
//    [self.tableView reloadData];
//    [self.tableView setContentOffset:CGPointZero animated:YES];
//    
//}

- (void) refreshTableItemsWithFilter:(NSString *)str andSearchedText:(NSString *)pattern andSortBy:(NSString *)sort
{
    //    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
    
    
    NSLog(@"Filtering ALL list with searched text %@",str);
    self.selectedCategories = @"";
    self.selectedCategories = str;
    self.searchedText = @"";
    self.searchedText = pattern;
    self.sortData = @"";
    self.sortData = sort;
    self.pageCounter = 1;
    [self.tableData removeAllObjects];
    self.tableData = [[self loadMoreFromServer] mutableCopy];
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:YES];
    
    [DejalBezelActivityView removeViewAnimated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    self.activityIndicator=nil;
    self.activityIndicatorView=nil;
    self.footerActivityIndicator=nil;
    self.tableView=nil;
    self.tableData=nil;
    [super viewDidUnload];
}


- (void)dealloc {
    [[self activityIndicator] release];
    [[self activityIndicatorView] release];
    [[self footerActivityIndicator] release];
    [super dealloc];
}

@end
