//
//  AppDelegate.m
//  myjam
//
//  Created by nazri on 11/7/12.
//  Copyright (c) 2012 me-tech. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>

#import "AppDelegate.h"
#import "FBAppDelegate.h"

#import "HomeViewController.h"
#import "ShopViewController.h"
#import "ScanQRViewController.h"
#import "BoxViewController.h"
#import "LoginViewController.h"
#import "NewsViewController.h"
#import "MoreViewController.h"
#import "CreateViewController.h"
#import "SidebarView.h"
#import "ASIWrapper.h"
#import "ConnectionClass.h"
#import "ErrorViewController.h"
#import "JSONKit.h"
#import "SocketIOPacket.h"

#define kCloseSwipeBottom   1
#define kCloseSideBar       2

static double kAnimateDuration = 0.35f;
static double kAnimateDurationBottomView = 0.5f;
static CGFloat bannerHeight = 34;

//static double kBottomFrameHeight = 145.0f; // commented for retina 4

@implementation AppDelegate

NSString *const FBSessionStateChangedNotification = @"com.threezquare.jambu:FBSessionStateChangedNotification"; //fb login

@synthesize window;
@synthesize socketIO;
@synthesize sidebarController;
@synthesize bottomSVAll, bottomSVNews, bottomSVPromo, bottomSVScanBox, bottomSVShareBox, bottomSVFavBox, bottomSVCreateBox,bottomSVJShop, bottomSVJSPurchase, bottomNearMe;

@synthesize sideBarOpen;
@synthesize bottomViewOpen;
@synthesize tabView;
@synthesize homeNavController, scanNavController, boxNavController, shopNavController;
@synthesize bannerView;
@synthesize tutorial;
@synthesize otherNavController;
@synthesize swipeOptionString;
@synthesize cartCounter;
- (void)dealloc
{
    [frontLayerView release];
    [window release];
    [tabView release];
    [bannerView release];
    [tutorial release];
    [bottomSVAll release];
    [bottomSVNews release];
    [bottomSVPromo release];
    [bottomSVScanBox release];
    [bottomSVShareBox release];
    [bottomSVFavBox release];
    [bottomSVCreateBox release];
    [bottomSVJShop release];
    [bottomSVJSPurchase release];
    [sidebarController release];
    [homeNavController release];
    [scanNavController release];
    [boxNavController release];
    [shopNavController release];
    [otherNavController release];
    [bottomNearMe release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Create socket nodejs client
    socketIO = [[SocketIO alloc] initWithDelegate:self];
    [self initViews];
    
    [self.window makeKeyAndVisible];
    [self.window setNeedsDisplay];
    
    return YES;
}

- (void)initViews
{
    // local cache dictionaries
    NSUserDefaults *localData = [NSUserDefaults standardUserDefaults];
    
    [localData setObject:@"NO" forKey:@"connectedToNodeJS"];
    // if internetconnection is good
    if ([ConnectionClass connected])
    {
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithHex:@"#D22042"]];
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed: @"header_bg"] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor whiteColor],
          UITextAttributeTextShadowColor,
          [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
          UITextAttributeTextShadowOffset,
          [UIFont fontWithName:@"jambu-font.otf" size:0.0],
          UITextAttributeFont,
          nil]];
        
        // Everytime launch show tutorial until 500 times
        // from 1-5 times, if click home, then show tutorial again. after 5th launched, show only once
        //        NSUserDefaults *localData = [NSUserDefaults standardUserDefaults];
        NSString *counterKey = [NSString stringWithFormat:@"counter%@",[localData objectForKey:@"tokenString"]];
        
        NSString *counter = [localData objectForKey:counterKey];
        //NSLog(@"counter tutorial %@",counter);
        if (counter != nil) {
            int val = [counter intValue];
            [localData setObject:[NSString stringWithFormat:@"%d",++val] forKey:counterKey];
            if (val < 500) {
                [localData setObject:@"YES" forKey:@"isDisplayTutorial"];
            }
            else{
                [localData setObject:@"NO" forKey:@"isDisplayTutorial"];
            }
            
        }
        
        NSString *isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"islogin"]copy];
        //NSLog(@"login is %@",isLogin);
        
        // check if login is remembered in local cache
        if ([isLogin isEqualToString:@"NO"] || !counter) {
            [self presentLoginPage];
        }else{
            //NSLog(@"not presentlogin");
            [localData setObject:@"YES" forKey:@"isProfileUpdated"];
            if (![self isSetupDone]) {
                [self setupViews];
            }
            [self connectNodeJS];
        }
        [localData setObject:@"NO" forKey:@"noConnection"];
        [localData synchronize];
    }else{
        ErrorViewController *errorpage = [[ErrorViewController alloc] init];
        errorpage.errorOption = kERROR_NO_INTERNET_CONNECTION;
        [self.window addSubview:errorpage.view];
        [errorpage release];
        
        [localData setObject:@"YES" forKey:@"noConnection"];
    }
    
    UIImage *nearMeIco = [UIImage imageNamed:@"near_me_icon.png"];
    self.nearMeBtn = [[UIButton alloc]initWithFrame:CGRectMake(280, 28, nearMeIco.size.width-2, nearMeIco.size.height-2)];
    [self.nearMeBtn setHidden:YES];
    [self.nearMeBtn setBackgroundImage:nearMeIco forState:UIControlStateNormal];
    [self.nearMeBtn addTarget:self action:@selector(gotoNM) forControlEvents:UIControlEventTouchUpInside];
    
    //UIBarButtonItem *nearMeBarBtnItem = [[UIBarButtonItem alloc]initWithCustomView:self.nearMeBtn];
    [self.window addSubview:self.nearMeBtn];
    [self.nearMeBtn release];
}

- (void)gotoNM //NEAR ME VC
{
    NSLog(@"Goto NM");
    
    NMTabViewController *nearMeVC = [[NMTabViewController alloc] init];
    
    [self.otherNavController popToRootViewControllerAnimated:NO];
    [self.otherNavController pushViewController:nearMeVC animated:NO];
    [nearMeVC release];
    [self.tabView activateController:4];
    
    
    // Manually change the selected tabButton
    for (int i = 0; i < [self.tabView.tabItemsArray count]; i++) {
        if (i == 4) {
            [[self.tabView.tabItemsArray objectAtIndex:i] toggleOn:YES];
        } else {
            [[self.tabView.tabItemsArray objectAtIndex:i] toggleOn:NO];
        }
    }
}

- (void)clearViews
{
    [tabView.view removeFromSuperview];
    [sidebarController.view removeFromSuperview];
    [bottomSVAll.view removeFromSuperview];
    [bottomSVNews.view removeFromSuperview];
    [bottomSVPromo.view removeFromSuperview];
    [bottomSVScanBox.view removeFromSuperview];
    [bottomSVShareBox.view removeFromSuperview];
    [bottomSVFavBox.view removeFromSuperview];
    [bottomSVCreateBox.view removeFromSuperview];
    [bottomSVJShop.view removeFromSuperview];
    [bottomSVJSPurchase.view removeFromSuperview];
    [bottomNearMe.view removeFromSuperview];
    [frontLayerView release];
    [tabView release];
    [bottomSVAll release];
    [bottomSVNews release];
    [bottomSVPromo release];
    [bottomSVScanBox release];
    [sidebarController release];
    [homeNavController release];
    [scanNavController release];
    [boxNavController release];
    [shopNavController release];
    [bottomNearMe release];
}

- (void)setupViews
{
    //NSLog(@"setting up all views");
    
    self.isSetupDone = YES;
    
    self.arrayTemp = [[NSMutableArray alloc] init];
    
    // Sidebar for profile and create menu
    sidebarController = [[SidebarView alloc] init];
    
    // Bottom filter view
    bottomSVAll = [[BottomSwipeView alloc] init];
    bottomSVNews = [[BottomSwipeViewNews alloc] init];
    bottomSVPromo = [[BottomSwipeViewPromo alloc] init];
    
    bottomSVScanBox = [[BottomSwipeViewScanBox alloc] init];
    bottomSVShareBox = [[BottomSwipeViewShareBox alloc] init];
    bottomSVFavBox = [[BottomSwipeViewFavBox alloc] init];
    bottomSVCreateBox = [[BottomSwipeViewCreateBox alloc] init];
    bottomNearMe = [[BottomSwipeViewNearMe alloc] init];
    
    // Init viewcontrollers
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    ShopViewController *shopVC = [[ShopViewController alloc] init];
    ScanQRViewController *scanVC = [[ScanQRViewController alloc] init];
    BoxViewController *boxVC = [[BoxViewController alloc] init];
    CreateViewController *createVC = [[CreateViewController alloc] init];
    bottomSVJShop = [[BottomSwipeViewJShop alloc] init];
    bottomSVJSPurchase = [[BottomSwipeViewJSPurchase alloc] init];
    
    // Init navigationControllers for TabbarController
    homeNavController = [[UINavigationController alloc] initWithRootViewController:homeVC];
    shopNavController = [[UINavigationController alloc] initWithRootViewController:shopVC];
    scanNavController = [[UINavigationController alloc] initWithRootViewController:scanVC];
    boxNavController = [[UINavigationController alloc] initWithRootViewController:boxVC];
    otherNavController = [[UINavigationController alloc] initWithRootViewController:createVC];
    
    //    // Init TabBarItem
    //    GTabTabItem *tabItem1 = [[GTabTabItem alloc] initWithFrame:CGRectMake(0, 0, 64, 39) normalState:@"home_selected" toggledState:@"home"];
    //	GTabTabItem *tabItem2 = [[GTabTabItem alloc] initWithFrame:CGRectMake(64, 0, 64, 39) normalState:@"shop_selected" toggledState:@"shop"];
    //	GTabTabItem *tabItem3 = [[GTabTabItem alloc] initWithFrame:CGRectMake(128, 0, 64, 39) normalState:@"scan_selected" toggledState:@"scan"];
    //	GTabTabItem *tabItem4 = [[GTabTabItem alloc] initWithFrame:CGRectMake(192, 0, 64, 39) normalState:@"box_selected" toggledState:@"box"];
    //	GTabTabItem *tabItem5 = [[GTabTabItem alloc] initWithFrame:CGRectMake(256, 0, 64, 39) normalState:@"more" toggledState:@"more"];
    // Init TabBarItem
    NSString *normalStateTB1 = nil;
    NSString *normalStateTB2 = nil;
    NSString *normalStateTB3 = nil;
    NSString *normalStateTB4 = nil;
    NSString *normalStateTB5 = nil;
    NSString *toggledStateTB1 = nil;
    NSString *toggledStateTB2 = nil;
    NSString *toggledStateTB3 = nil;
    NSString *toggledStateTB4 = nil;
    NSString *toggledStateTB5 = nil;
    
    screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568)
    {
        // code for 4-inch screen
        //NSLog(@"Set On 4inch button");
        normalStateTB1 = @"home";
        toggledStateTB1 = @"home_selected";
        normalStateTB2 = @"shop";
        toggledStateTB2 = @"shop_selected";
        normalStateTB3 = @"scan";
        toggledStateTB3 = @"scan_selected";
        normalStateTB4 = @"box";
        toggledStateTB4 = @"box_selected";
        normalStateTB5 = @"more2";
        toggledStateTB5 = @"more2";
    }
    else
    {
        // code for 3.5-inch screen
        //NSLog(@"Set On 3.5inch button");
        normalStateTB1 = @"home_lr";
        toggledStateTB1 = @"home_selected_lr";
        normalStateTB2 = @"shop_lr";
        toggledStateTB2 = @"shop_selected_lr";
        normalStateTB3 = @"scan_lr";
        toggledStateTB3 = @"scan_selected_lr";
        normalStateTB4 = @"box_lr";
        toggledStateTB4 = @"box_selected_lr";
        normalStateTB5 = @"more2_lr";
        toggledStateTB5 = @"more2_lr";
    }
    
    GTabTabItem *tabItem1 = [[GTabTabItem alloc] initWithFrame:CGRectMake(0, 0, 64, 39) normalState:normalStateTB1 toggledState:toggledStateTB1];
	GTabTabItem *tabItem2 = [[GTabTabItem alloc] initWithFrame:CGRectMake(64, 0, 64, 39) normalState:normalStateTB2 toggledState:toggledStateTB2];
	GTabTabItem *tabItem3 = [[GTabTabItem alloc] initWithFrame:CGRectMake(128, 0, 64, 39) normalState:normalStateTB3 toggledState:toggledStateTB3];
	GTabTabItem *tabItem4 = [[GTabTabItem alloc] initWithFrame:CGRectMake(192, 0, 64, 39) normalState:normalStateTB4 toggledState:toggledStateTB4];
	GTabTabItem *tabItem5 = [[GTabTabItem alloc] initWithFrame:CGRectMake(256, 0, 64, 39) normalState:normalStateTB5 toggledState:toggledStateTB5];
    
    // Disable Tabbutton2
    tabItem2.userInteractionEnabled = YES;
    
    // Asign controllers and tabItems
	NSMutableArray *viewControllersArray = [[NSMutableArray alloc] init];
	[viewControllersArray addObject:homeNavController];
	[viewControllersArray addObject:shopNavController];
    [viewControllersArray addObject:scanNavController];
    [viewControllersArray addObject:boxNavController];
    [viewControllersArray addObject:otherNavController];
	
	NSMutableArray *tabItemsArray = [[NSMutableArray alloc] init];
	[tabItemsArray addObject:tabItem1];
	[tabItemsArray addObject:tabItem2];
	[tabItemsArray addObject:tabItem3];
	[tabItemsArray addObject:tabItem4];
	[tabItemsArray addObject:tabItem5];
	
	tabView = [[GTabBar alloc] initWithTabViewControllers:viewControllersArray tabItems:tabItemsArray initialTab:0];
    
    // Custom tabItem for sidebar
    [tabItem5 addTarget:self action:@selector(handleTab5) forControlEvents:UIControlEventTouchUpInside];
    
    sidebarController.view.frame = CGRectMake(320.0f, 0.0f, sidebarController.view.frame.size.width, self.window.frame.size.height);
    
    bottomSVAll.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVAll.view.frame.size.width, bottomSVAll.view.frame.size.height);
    
    bottomSVNews.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVNews.view.frame.size.width, bottomSVNews.view.frame.size.height);
    
    bottomSVPromo.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVPromo.view.frame.size.width, bottomSVPromo.view.frame.size.height);
    
    bottomSVScanBox.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVScanBox.view.frame.size.width, bottomSVScanBox.view.frame.size.height);
    
    bottomSVShareBox.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVShareBox.view.frame.size.width, bottomSVShareBox.view.frame.size.height);
    
    bottomSVFavBox.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVFavBox.view.frame.size.width, bottomSVFavBox.view.frame.size.height);
    
    bottomSVCreateBox.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVCreateBox.view.frame.size.width, bottomSVCreateBox.view.frame.size.height);
    
    bottomSVJShop.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVJShop.view.frame.size.width, bottomSVJShop.view.frame.size.height);
    
    bottomSVJSPurchase.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVJSPurchase.view.frame.size.width, bottomSVJSPurchase.view.frame.size.height);
    
    bottomNearMe.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomNearMe.view.frame.size.width, bottomNearMe.view.frame.size.height);
    
    [self.window addSubview:sidebarController.view];
    [self.window addSubview:tabView.view];
    
    UISwipeGestureRecognizer *twoFingerSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp)];
    [twoFingerSwipe setDirection:UISwipeGestureRecognizerDirectionUp];
    [twoFingerSwipe setNumberOfTouchesRequired:2];
    [self.window addGestureRecognizer:twoFingerSwipe];
    [twoFingerSwipe release];
    
    // Setup Banner View
    bannerView = [[Banner alloc] initWithFrame:CGRectMake(0, self.window.frame.size.height-39-bannerHeight, self.window.frame.size.width, bannerHeight)];
    [self.window insertSubview:bannerView aboveSubview:tabView.view];
    
    // Setup Tutorial View
    tutorial = [[TutorialView alloc] initWithFrame:self.window.frame];
    [tutorial setAlpha:0.6];
    [tutorial setHidden:YES];
    
    
    // To close bottom swipe and sidebar
    frontLayerView = [[UIView alloc] initWithFrame:self.window.frame];
    [frontLayerView setBackgroundColor:[UIColor clearColor]];
    [frontLayerView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnLayerView)];
    [frontLayerView addGestureRecognizer:closeTap];
    [closeTap release];
    
    // To close sidebar only
    UISwipeGestureRecognizer *swipeRightRecognizer;
    swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleTab5)];
    [swipeRightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [frontLayerView addGestureRecognizer:swipeRightRecognizer];
    [swipeRightRecognizer release];
    
    // To close bottom search
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [swipeDown setNumberOfTouchesRequired:2];
    [self.window addGestureRecognizer:swipeDown];
    [swipeDown release];
    
    
    [self.window addSubview:tutorial];
}

- (void)handleTapOnLayerView
{
    // To be implemented
    if (LayerOption == kCloseSideBar) {
        [self handleTab5];
    }else if(LayerOption == kCloseSwipeBottom)
    {
        [self handleSwipeUp];
    }
}

- (void)closeSidebar
{
    if (showCamera && screenBounds.size.height != 568) {
        [self.tabView activateController:kScannerTab];
        showCamera = NO;
        [blackView removeFromSuperview];
    }
    
    if (self.isCheckoutFromSideBar) {
        [self.tabView activateController:kShopTab];
        self.isCheckoutFromSideBar = NO;
    }
    
    sideBarOpen = NO;
    [homeNavController.view setUserInteractionEnabled:YES];
    [bannerView setUserInteractionEnabled:YES];
    [bottomSVAll.view setHidden:NO];
    [bottomSVNews.view setHidden:NO];
    [bottomSVPromo.view setHidden:NO];
    [bottomSVScanBox.view setHidden:NO];
    [bottomSVShareBox.view setHidden:NO];
    [bottomSVFavBox.view setHidden:NO];
    [bottomSVCreateBox.view setHidden:NO];
    [bottomSVJShop.view setHidden:NO];
    [bottomSVJSPurchase.view setHidden:NO];
    [bottomNearMe.view setHidden:NO];
    
    [UIView animateWithDuration:kAnimateDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^
     {
         tabView.view.frame = CGRectMake(0, 0.0f, self.window.frame.size.width, self.window.frame.size.height);
         bannerView.frame = CGRectMake(0, self.window.frame.size.height-39-bannerHeight, self.window.frame.size.width, bannerHeight);
         sidebarController.view.frame = CGRectMake(320.0f, 0.0f, sidebarController.view.frame.size.width, self.window.frame.size.height);
         
     }
                     completion:^(BOOL finished){}];
    
    [frontLayerView removeFromSuperview];
    [DejalBezelActivityView removeViewAnimated:YES];
}

- (void)openSidebar
{
    
    if (self.pageIndex == kScannerTab && screenBounds.size.height != 568) {
        [self.tabView activateController:kHomeTab];
        
        blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, 320, self.window.frame.size.height-44-39-20)];
        [blackView setBackgroundColor:[UIColor blackColor]];
        [self.tabView.view addSubview:blackView];
        [blackView release];
        
        showCamera = YES;
    }
    
    [self.tabView.view addSubview:frontLayerView];
    
    sideBarOpen = YES;
    [homeNavController.view setUserInteractionEnabled:NO];
    [bannerView setUserInteractionEnabled:NO];
    [bottomSVAll.view setHidden:YES];
    [bottomSVNews.view setHidden:YES];
    [bottomSVPromo.view setHidden:YES];
    [bottomSVScanBox.view setHidden:YES];
    [bottomSVShareBox.view setHidden:YES];
    [bottomSVFavBox.view setHidden:YES];
    [bottomSVCreateBox.view setHidden:YES];
    [bottomSVJShop.view setHidden:YES];
    [bottomSVJSPurchase.view setHidden:YES];
    [bottomNearMe.view setHidden:YES];
    
    // Reset scrollview to top
    //        CGPoint topOffset = CGPointMake(0,0);
    // [sidebarController.scroller setContentOffset:topOffset animated:NO];
    
    [UIView animateWithDuration:kAnimateDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^
     {
         tabView.view.frame = CGRectMake(-260.0f, 0.0f, self.window.frame.size.width, self.window.frame.size.height);
         bannerView.frame = CGRectMake(-260, self.window.frame.size.height-39-bannerHeight, self.window.frame.size.width, bannerHeight);
         sidebarController.view.frame = CGRectMake(60.0f, 0.0f, sidebarController.view.frame.size.width, self.window.frame.size.height);
         
     }
                     completion:^(BOOL finished){
                         [DejalBezelActivityView activityViewForView:self.window withLabel:@"Loading ..." width:100];
                         [self performSelector:@selector(updateCart) withObject:nil afterDelay:0.5];
                         
                         
                     }];
}

- (void)updateCart
{
    [[NSNotificationCenter defaultCenter ] postNotificationName:@"cartChanged" object:self];
    [DejalBezelActivityView removeViewAnimated:YES];
}

// Handle sidebar
- (void)handleTab5
{
    //NSLog(@"handleSideBar");
    //    [[NSNotificationCenter defaultCenter ] postNotificationName:@"cartChanged" object:self];
    LayerOption = kCloseSideBar;
    
    if ([self sideBarOpen])
    {
        [self closeSidebar];
        
    }else{
        [self openSidebar];
    }
}

- (void)handleSwipeUp
{
    
    LayerOption = kCloseSwipeBottom;
    
    //NSLog(@"handleSwipeUp");
    NSString *isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"islogin"] copy];
    
    if ([isLogin isEqualToString:@"NO"]) {
        //NSLog(@"islogin");
        return;
    }
    
    if (self.swipeBottomEnabled == NO) {
        NSLog(@"Swipedbottom disabled");
        return;
    }
    
    if ([self bottomViewOpen])
    {
        bottomViewOpen = NO;
        [UIView animateWithDuration:kAnimateDurationBottomView delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^
         {
             //if (swipeOptionString == nil)
             //{
             //bottomController.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomController.view.frame.size.width, bottomController.view.frame.size.height);
             //}
             if ([swipeOptionString isEqual:@"home-all"] || swipeOptionString == nil)
             {
                 bottomSVAll.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVAll.view.frame.size.width, bottomSVAll.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"home-news"])
             {
                 bottomSVNews.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVNews.view.frame.size.width, bottomSVNews.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"home-promo"])
             {
                 bottomSVPromo.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVPromo.view.frame.size.width, bottomSVPromo.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"scan"])
             {
                 bottomSVScanBox.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVScanBox.view.frame.size.width, bottomSVScanBox.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"share"])
             {
                 bottomSVShareBox.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVShareBox.view.frame.size.width, bottomSVShareBox.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"favourite"])
             {
                 bottomSVFavBox.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVFavBox.view.frame.size.width, bottomSVFavBox.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"create"])
             {
                 bottomSVCreateBox.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVCreateBox.view.frame.size.width, bottomSVCreateBox.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"shop"])
             {
                 bottomSVJShop.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVJShop.view.frame.size.width, bottomSVJShop.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"purchase"])
             {
                 bottomSVJSPurchase.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomSVJSPurchase.view.frame.size.width, bottomSVJSPurchase.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"nearme"])
             {
                 bottomNearMe.view.frame = CGRectMake(0.0f, self.window.frame.size.height, bottomNearMe.view.frame.size.width, bottomNearMe.view.frame.size.height);
             }
             
         }
                         completion:^(BOOL finished){
                             //if (swipeOptionString == nil)
                             //{
                             //[bottomController.view removeFromSuperview];
                             //}
                             if ([swipeOptionString isEqual:@"home-all"] || swipeOptionString == nil)
                             {
                                 [bottomSVAll.view removeFromSuperview];
                             }
                             else if ([swipeOptionString isEqual:@"home-news"])
                             {
                                 [bottomSVNews.view removeFromSuperview];
                             }
                             else if ([swipeOptionString isEqual:@"home-promo"])
                             {
                                 [bottomSVPromo.view removeFromSuperview];
                             }
                             else if ([swipeOptionString isEqual:@"scan"])
                             {
                                 [bottomSVScanBox.view removeFromSuperview];
                             }
                             else if ([swipeOptionString isEqual:@"share"])
                             {
                                 [bottomSVShareBox.view removeFromSuperview];
                             }
                             else if ([swipeOptionString isEqual:@"favourite"])
                             {
                                 [bottomSVFavBox.view removeFromSuperview];
                             }
                             else if ([swipeOptionString isEqual:@"create"])
                             {
                                 [bottomSVCreateBox.view removeFromSuperview];
                             }
                             else if ([swipeOptionString isEqual:@"shop"])
                             {
                                 [bottomSVJShop.view removeFromSuperview];
                             }
                             else if ([swipeOptionString isEqual:@"purchase"])
                             {
                                 [bottomSVJSPurchase.view removeFromSuperview];
                             }
                             else if ([swipeOptionString isEqual:@"nearme"])
                             {
                                 [bottomNearMe.view removeFromSuperview];
                             }
                         }];
        //        [tabView.view setUserInteractionEnabled:YES];
        [homeNavController.view setUserInteractionEnabled:YES];
        [frontLayerView removeFromSuperview];
        
    }else{
        [self.tabView.view addSubview:frontLayerView];
        [homeNavController.view setUserInteractionEnabled:NO];
        //        [tabView.view setUserInteractionEnabled:NO];
        
        bottomViewOpen = YES;
        //if (swipeOptionString == nil)
        //{
        //[self.window addSubview:bottomController.view];
        //[self.window bringSubviewToFront:bottomController.view];
        //}
        if ([swipeOptionString isEqual:@"home-all"] || swipeOptionString == nil)
        {
            [self.window addSubview:bottomSVAll.view];
            [self.window bringSubviewToFront:bottomSVAll.view];
        }
        else if ([swipeOptionString isEqual:@"home-news"])
        {
            [self.window addSubview:bottomSVNews.view];
            [self.window bringSubviewToFront:bottomSVNews.view];
        }
        else if ([swipeOptionString isEqual:@"home-promo"])
        {
            [self.window addSubview:bottomSVPromo.view];
            [self.window bringSubviewToFront:bottomSVPromo.view];
        }
        else if ([swipeOptionString isEqual:@"scan"])
        {
            [self.window addSubview:bottomSVScanBox.view];
            [self.window bringSubviewToFront:bottomSVScanBox.view];
        }
        else if ([swipeOptionString isEqual:@"share"])
        {
            [self.window addSubview:bottomSVShareBox.view];
            [self.window bringSubviewToFront:bottomSVShareBox.view];
        }
        else if ([swipeOptionString isEqual:@"favourite"])
        {
            [self.window addSubview:bottomSVFavBox.view];
            [self.window bringSubviewToFront:bottomSVFavBox.view];
        }
        else if ([swipeOptionString isEqual:@"create"])
        {
            [self.window addSubview:bottomSVCreateBox.view];
            [self.window bringSubviewToFront:bottomSVCreateBox.view];
        }
        else if ([swipeOptionString isEqual:@"shop"])
        {
            [self.window addSubview:bottomSVJShop.view];
            [self.window bringSubviewToFront:bottomSVJShop.view];
        }
        else if ([swipeOptionString isEqual:@"purchase"])
        {
            [self.window addSubview:bottomSVJSPurchase.view];
            [self.window bringSubviewToFront:bottomSVJSPurchase.view];
        }
        else if ([swipeOptionString isEqual:@"nearme"])
        {
            [self.window addSubview:bottomNearMe.view];
            [self.window bringSubviewToFront:bottomNearMe.view];
        }
        
        [UIView animateWithDuration:kAnimateDurationBottomView delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^
         {
             // change here for 4 retina
             //if (swipeOptionString == nil)
             //{
             //bottomController.view.frame = CGRectMake(0.0f, self.window.frame.size.height-bottomController.view.frame.size.height, bottomController.view.frame.size.width, bottomController.view.frame.size.height);
             //}
             if ([swipeOptionString isEqual:@"home-all"] || swipeOptionString == nil)
             {
                 bottomSVAll.view.frame = CGRectMake(0.0f, self.window.frame.size.height-bottomSVAll.view.frame.size.height, bottomSVAll.view.frame.size.width, bottomSVAll.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"home-news"])
             {
                 bottomSVNews.view.frame = CGRectMake(0.0f, self.window.frame.size.height-bottomSVNews.view.frame.size.height, bottomSVNews.view.frame.size.width, bottomSVNews.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"home-promo"])
             {
                 bottomSVPromo.view.frame = CGRectMake(0.0f, self.window.frame.size.height-bottomSVPromo.view.frame.size.height, bottomSVPromo.view.frame.size.width, bottomSVPromo.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"scan"])
             {
                 bottomSVScanBox.view.frame = CGRectMake(0.0f, self.window.frame.size.height-bottomSVScanBox.view.frame.size.height, bottomSVScanBox.view.frame.size.width, bottomSVScanBox.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"share"])
             {
                 bottomSVShareBox.view.frame = CGRectMake(0.0f, self.window.frame.size.height-bottomSVShareBox.view.frame.size.height, bottomSVShareBox.view.frame.size.width, bottomSVShareBox.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"favourite"])
             {
                 bottomSVFavBox.view.frame = CGRectMake(0.0f, self.window.frame.size.height-bottomSVFavBox.view.frame.size.height, bottomSVFavBox.view.frame.size.width, bottomSVFavBox.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"create"])
             {
                 bottomSVCreateBox.view.frame = CGRectMake(0.0f, self.window.frame.size.height-bottomSVCreateBox.view.frame.size.height, bottomSVCreateBox.view.frame.size.width, bottomSVCreateBox.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"shop"])
             {
                 bottomSVJShop.view.frame = CGRectMake(0.0f, self.window.frame.size.height-bottomSVJShop.view.frame.size.height, bottomSVJShop.view.frame.size.width, bottomSVJShop.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"purchase"])
             {
                 bottomSVJSPurchase.view.frame = CGRectMake(0.0f, self.window.frame.size.height-bottomSVJSPurchase.view.frame.size.height, bottomSVJSPurchase.view.frame.size.width, bottomSVJSPurchase.view.frame.size.height);
             }
             else if ([swipeOptionString isEqual:@"nearme"])
             {
                 bottomNearMe.view.frame = CGRectMake(0.0f, self.window.frame.size.height-bottomNearMe.view.frame.size.height, bottomNearMe.view.frame.size.width, bottomNearMe.view.frame.size.height);
             }
         }
                         completion:^(BOOL finished){
                             //if (swipeOptionString == nil)
                             //{
                             //[bottomController.activityView startAnimating];
                             
                             //[bottomController performSelector:@selector(setupCatagoryList) withObject:self afterDelay:0.2f];
                             //}
                             if ([swipeOptionString isEqual:@"home-all"] || swipeOptionString == nil)
                             {
                                 [bottomSVAll.activityView startAnimating];
                                 
                                 [bottomSVAll performSelector:@selector(setupCatagoryList) withObject:self afterDelay:0.2f];
                             }
                             else if ([swipeOptionString isEqual:@"home-news"])
                             {
                                 [bottomSVNews.activityView startAnimating];
                                 
                                 [bottomSVNews performSelector:@selector(setupCatagoryList) withObject:self afterDelay:0.2f];
                             }
                             else if ([swipeOptionString isEqual:@"home-promo"])
                             {
                                 [bottomSVPromo.activityView startAnimating];
                                 
                                 [bottomSVPromo performSelector:@selector(setupCatagoryList) withObject:self afterDelay:0.2f];
                             }
                             else if ([swipeOptionString isEqual:@"scan"])
                             {
                                 [bottomSVScanBox.activityView startAnimating];
                                 
                                 [bottomSVScanBox performSelector:@selector(setupCatagoryList) withObject:self afterDelay:0.2f];
                             }
                             else if ([swipeOptionString isEqual:@"share"])
                             {
                                 [bottomSVShareBox.activityView startAnimating];
                                 
                                 [bottomSVShareBox performSelector:@selector(setupCatagoryList) withObject:self afterDelay:0.2f];
                             }
                             else if ([swipeOptionString isEqual:@"favourite"])
                             {
                                 [bottomSVFavBox.activityView startAnimating];
                                 
                                 [bottomSVFavBox performSelector:@selector(setupCatagoryList) withObject:self afterDelay:0.2f];
                             }
                             else if ([swipeOptionString isEqual:@"create"])
                             {
                                 [bottomSVCreateBox.activityView startAnimating];
                                 
                                 [bottomSVCreateBox performSelector:@selector(setupCatagoryList) withObject:self afterDelay:0.2f];
                             }
                             else if ([swipeOptionString isEqual:@"shop"])
                             {
                                 [bottomSVJShop.activityView startAnimating];
                                 
                                 [bottomSVJShop performSelector:@selector(setupCatagoryList) withObject:self afterDelay:0.2f];
                             }
                             else if ([swipeOptionString isEqual:@"purchase"])
                             {
                                 [bottomSVJSPurchase.activityView startAnimating];
                                 
                                 [bottomSVJSPurchase performSelector:@selector(setupCatagoryList) withObject:self afterDelay:0.2f];
                             }
                             else if ([swipeOptionString isEqual:@"nearme"])
                             {
                                 [bottomNearMe.activityView startAnimating];
                                 
                                 [bottomNearMe performSelector:@selector(setupCatagoryList) withObject:self afterDelay:0.2f];
                             }
                         }];
    }
}

- (void)presentLoginPage
{
    //NSLog(@"present login");
    LoginViewController *loginvc = [[LoginViewController alloc] init];
    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginvc];
    [loginNav setNavigationBarHidden:YES];
    [self.window addSubview:loginNav.view];
    [loginvc release];
    [loginNav.view release];
    
}

#pragma mark -
#pragma mark SocketIO methods and delegate

- (void)connectNodeJS
{
    NSLog(@"connect nodejs");
    [socketIO connectToHost:@"202.71.110.204" onPort:80];
}

- (void)sendTokenNodeJS
{
    SocketIOCallback cb = ^(id argsData) {
        NSDictionary *response = argsData;
        // do something with response
        NSLog(@"token nodejs ack arrived: %@", response);
    };
    
    NSDictionary *datadict = [NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"] forKey:@"token"];
    [socketIO sendEvent:@"login" withData:datadict andAcknowledge:cb];
}

- (void)disconnectNodeJS
{
    [socketIO disconnect];
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSLog(@"didReceiveEvent()");
    NSLog(@"packet: %@",[packet data]);
    
    NSDictionary *data = [packet dataAsJSON];
    //    NSString *conn = [[NSUserDefaults standardUserDefaults] objectForKey:@"connectedToNodeJS"];
    //    if ([conn isEqualToString:@"NO"]) {
    //        if ([[data objectForKey:@"name"] isEqualToString:@"connected"]) {
    //            [self sendTokenNodeJS];
    //            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"connectedToNodeJS"];
    //        }
    //    }
    
    if ([[data objectForKey:@"name"] isEqualToString:@"server_to_client"]) {
        NSDictionary *msg = [[data objectForKey:@"args"] objectAtIndex:0];
        if ([[msg objectForKey:@"message"] isEqualToString:@"conversation_list_updated"]) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"updateMessageList"
             object:nil];
            [self playAlertSound];
        }
        else if ([[msg objectForKey:@"message"] isEqualToString:@"buddy_list_updated"])
        {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"reloadBuddyList"
             object:nil];
            [self playAlertSound];
        }
    }
    
}

- (void)socketIODidConnect:(SocketIO *)socket
{
    NSString *conn = [[NSUserDefaults standardUserDefaults] objectForKey:@"connectedToNodeJS"];
    if ([conn isEqualToString:@"NO"]) {
        [self sendTokenNodeJS];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"connectedToNodeJS"];
    }
}

- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"Nodejs disconnect. Reconnecting ..");
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"connectedToNodeJS"];
    //        [self connectNodeJS];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"islogin"] isEqualToString:@"YES"]) {
        [self connectNodeJS];
    }
}


- (void) socketIO:(SocketIO *)socket failedToConnectWithError:(NSError *)error
{
    NSLog(@"failedToConnectWithError() %@", error);
}

- (void)playAlertSound
{
    SystemSoundID audioEffect;
    NSURL *pathSound = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"beep-beep" ofType:@"mp3"] isDirectory:NO];
    AudioServicesCreateSystemSoundID((CFURLRef) pathSound, &audioEffect);
    AudioServicesPlaySystemSound(audioEffect);
    // call the following function when the sound is no longer used
    // (must be done AFTER the sound is done playing)
    //    AudioServicesDisposeSystemSoundID(audioEffect);
}



#pragma mark -
#pragma mark FB LOGIN

/*
 * Callback for session changes. // fblogin
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                //NSLog(@"User session found");
                
                [self performSelector:@selector(performAutoFBLogin) withObject:nil afterDelay:0.0f];
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)performAutoFBLogin
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"runFBlogin" object:self];
}

#pragma mark
#pragma mark CustomBadge
- (void)removeCustomBadge
{
    for (UIView *aView in [[[tabView tabItemsArray] objectAtIndex:4
                            ]  subviews]) {
        if ([aView isKindOfClass:[CustomBadge class]])
        {
            [aView removeFromSuperview];
            //            [aView release];
        }
    }
}

- (void)setCustomBadgeWithText:(NSString *)text
{
    for (UIView *aView in [[[tabView tabItemsArray] objectAtIndex:4]  subviews]) {
        if ([aView isKindOfClass:[CustomBadge class]])
        {
            [aView removeFromSuperview];
            //            [aView release];
        }
    }
    
    cartCounter = [CustomBadge customBadgeWithString:text
                                     withStringColor:[UIColor whiteColor]
                                      withInsetColor:[UIColor redColor]
                                      withBadgeFrame:YES
                                 withBadgeFrameColor:[UIColor whiteColor]
                                           withScale:0.7
                                         withShining:YES];
    cartCounter.tag = 2000;
    
    UITapGestureRecognizer *badgeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTab5)];
    [cartCounter addGestureRecognizer:badgeTap];
    [badgeTap release];
    
    CGFloat x = 38;
    
    if ([text intValue] >= 100) {
        x = 24;
    }else if([text intValue] >= 10){
        x = 32;
    }
    
    cartCounter.frame = CGRectMake(x, 4, cartCounter.frame.size.width, cartCounter.frame.size.height);
    [[[tabView tabItemsArray] objectAtIndex:4]  addSubview:cartCounter];
    //    [cartCounter release];
}

/*
 * Opens a Facebook session and optionally shows the login UX. //fb login
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    
    NSArray *permissions = [NSArray arrayWithObjects:@"email", nil];
    
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session, FBSessionState state,
                                                             NSError *error) {
                                             NSLog(@"%@",error);
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:nil];
                                             if ([error code] == 2)
                                             {
                                                 CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Login to Facebook" message:@"Permission refused. Unable to login to JAM-BU using Facebook ID." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                 [alert show];
                                                 [alert release];
                                             }
                                             else if([error code])
                                             {
                                                 CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Login to Facebook" message:@"Unable to login. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                 [alert show];
                                                 [alert release];
                                             }
                                         }];
}

- (NSString *)checkQRCodeType:(NSString *)qrcodeid
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/qrcode_type.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"qrcode_id\":%@}",qrcodeid];
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    //NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    //NSLog(@"dict %@",resultsDictionary);
    
    if([resultsDictionary count])
    {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        if ([status isEqualToString:@"ok"])
        {
            NSString *type = [resultsDictionary objectForKey:@"qrcode_type"];
            
            if ([type isEqualToString:@"Product"]) {
                NSString *productid = [resultsDictionary objectForKey:@"product_id"];
                return productid;
            }
            
        }
    }
    
    return @"0"; // normal qrcode, other than product
}

/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    // attempt to extract a token from the url
    
//    NSError *error = nil;
    NSString *urlString = [NSString stringWithFormat:@"%@",url];
    NSLog(@"url: %@", urlString);
    
//    [error rangeOfString:@"timed out"].location == NSNotFound
    if ([url isEqual:[NSURL URLWithString:@"jambu://www.jam-bu.com/" ]])
    {
        if ([[[[self shopNavController] topViewController] class] isEqual:[CheckoutViewController class]])
        {
            self.isReturnFromPayment = YES;
            [[NSNotificationCenter defaultCenter]  postNotificationName:@"PurchaseVerification" object:self];
        }

    }else if ([urlString hasPrefix:@"jambu://www.jam-bu.com/?qrcode_id="]){
        NSArray *splittedURL = [urlString componentsSeparatedByString:@"="];
        NSString *qrcodeId = [[[splittedURL objectAtIndex:1] componentsSeparatedByString:@"&"] objectAtIndex:0];
        NSLog(@"captured qrcode = %@",qrcodeId);
        
        [tabView activateController:kHomeTab]; // set active tabcontroller at box
        self.pageIndex = kHomeTab;
        // Manually change the selected tabButton
        for (int i = 0; i < [tabView.tabItemsArray count]; i++) {
            if (i == kHomeTab) {
                [[tabView.tabItemsArray objectAtIndex:i] toggleOn:YES];
            } else {
                [[tabView.tabItemsArray objectAtIndex:i] toggleOn:NO];
            }
        }
        
        NSString *productId = [self checkQRCodeType:qrcodeId];
        
        if ([productId intValue] > 0)
        {
            // type of product
            DetailProductViewController *detailViewController = [[DetailProductViewController alloc] initWithNibName:@"DetailProductViewController" bundle:nil];
            //        NSString *prodId = productId;
            detailViewController.productInfo = [[MJModel sharedInstance] getProductInfoFor:productId];
            detailViewController.buyButton =  [[NSString alloc] initWithString:@"ok"];
            detailViewController.productId = [productId mutableCopy];
            [boxNavController pushViewController:detailViewController animated:YES];
        }
        else{
            MoreViewController *more = [[MoreViewController alloc] init];
            more.qrcodeId = qrcodeId;
//            [boxNavController popToRootViewControllerAnimated:YES];
            
            [homeNavController pushViewController:more animated:YES];
            [more release];
        }
        

    }
    else{
        return [FBSession.activeSession handleOpenURL:url];
    }
    
    return YES;
}

- (void)closeSession
{
    [FBSession.activeSession closeAndClearTokenInformation];
}

#pragma mark -
#pragma mark update profile

- (void)showUpdateProfileDialog
{
    
    NSUserDefaults *localData = [NSUserDefaults standardUserDefaults];
    if ([[localData objectForKey:@"isProfileUpdated"] isEqualToString:@"NO"])
    {
        CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"Update Jambulite Profile" message:@"Do you want to update your Jambulite Profile?" delegate:self cancelButtonTitle:@"       Skip       " otherButtonTitles:@" Jambulite Profile ",nil];
        [alert show];
        [alert release];
        
        // Just set to YES, to not appear when come to home again. just show when login. login will check if already updated or not.
        [localData setObject:@"YES" forKey:@"isProfileUpdated"];
        [localData synchronize];
    }
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1)
    {
        [self.sidebarController pushProfileViewController];
    }
}

#pragma mark -

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if ([ConnectionClass connected]) {
        [[NSNotificationCenter defaultCenter ] postNotificationName:@"cartChanged" object:self];
        NSUserDefaults *localData = [NSUserDefaults standardUserDefaults];
        //NSLog(@"get connected!");
        
        if ([[localData objectForKey:@"noConnection"] isEqualToString:@"YES"]) {
            [localData setObject:@"NO" forKey:@"noConnection"];
            [localData synchronize];
            [self initViews];
        }
        
        [FBSettings publishInstall:kAppID];
        [FBSession.activeSession handleDidBecomeActive]; //fb login
    }
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [FBSession.activeSession close]; //fb login
}

@end
