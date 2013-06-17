//
//  JShopViewController.m
//  myjam
//
//  Created by nazri on 11/7/12.
//  Copyright (c) 2012 me-tech. All rights reserved.
//

#import "JShopViewController.h"
//#import "AppDelegate.h"
@interface ShopViewController ()

@end

@implementation JShopViewController

@synthesize apv, sbv, vc3, vc2, vc1, tabBar, searchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
        
        UIButton *settingsView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [settingsView addTarget:self action:@selector(handleSearchBar) forControlEvents:UIControlEventTouchUpInside];
        [settingsView setBackgroundImage:[UIImage imageNamed:@"search_icon"] forState:UIControlStateNormal];
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:settingsView];
        [self.navigationItem setLeftBarButtonItem:settingsButton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Setup screen for retina 4
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        self.view.frame = CGRectMake(0,0,self.view.bounds.size.width, 568);
    } else {
        // code for 3.5-inch screen
        self.view.frame = CGRectMake(0,0,self.view.bounds.size.width, 480);
    }
    
    CGRect innerViewFrame = CGRectMake(0,5,self.view.frame.size.width, self.view.frame.size.height-(tabBar.frame.size.height)-26);
    
    //notification for updateTotalCartTab
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTotalCartTab:)
                                                 name:@"updateTotalCartTab"
                                               object:nil];
    
    //notification to close sidebar
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSearchBar)
                                                 name:@"handleSearchBar"
                                               object:nil];
    //to close searchBar view.
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    frontLayerView = [[UIView alloc] initWithFrame:mydelegate.window.frame];
    [frontLayerView setBackgroundColor:[UIColor clearColor]];
    [frontLayerView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSearchBar)];
    [frontLayerView addGestureRecognizer:closeTap];
    [closeTap release];
    
    // To close sidebar only
    UISwipeGestureRecognizer *swipeLeftRecognizer;
    swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSearchBar)];
    [swipeLeftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [frontLayerView addGestureRecognizer:swipeLeftRecognizer];
    [swipeLeftRecognizer release];
    
    apv = [[AllProductViewController alloc] init];
    apv.view.frame = innerViewFrame;
    sbv = [[StarBuyViewController alloc] init];
    sbv.view.frame = innerViewFrame;
    

    vc1 = [[[TBViewController alloc] init] autorelease];
    [vc1.view addSubview:apv.view];
    vc2 = [[[TBViewController alloc] init] autorelease];
    [vc2.view addSubview:sbv.view];
   
    TBTabButton *t1 = [[TBTabButton alloc] initWithTitle:@"ALL"];
    t1.viewController = vc1;
    TBTabButton *t2 = [[TBTabButton alloc] initWithTitle:@"STAR BUYS"];
    t2.viewController = vc2;
    TBTabButton *t3 = [[TBTabButton alloc] initWithTitle:@"(0)"];
    //[t3 setNewTitle:@"2"];
    
    NSArray *a = [[NSArray alloc]initWithObjects:t1, t2, t3, nil];
    NSArray *s = [[NSArray alloc]initWithObjects:@"120", @"120", @"80", nil];
    tabBar = [[TBTabBar alloc] initWithButtonSize:s andItems:a];
    
    tabBar.delegate = self;
    [self.view addSubview:tabBar];
    [tabBar showDefaults];
    [self totalCart:mydelegate.totalCart];
}

- (void)updateTotalCartTab:(NSNotification *)num
{
    [self totalCart:[[num.userInfo objectForKey:@"counter"] intValue]];
    NSLog(@"--%@|%d", num.userInfo,[[num.userInfo objectForKey:@"counter"] intValue]);
}

- (void)totalCart:(NSInteger)total {
    NSString *strNum = [NSString stringWithFormat:@"(%d)",total];
    [tabBar setTitleButton:strNum forButtonIndex:2];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"vda-SHOP");
    int i = 0;
    for (UIButton* b in tabBar.buttons) {
        if (i++ == 2) {
            [b setSelected:NO];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showCart {
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    mydelegate.pageIndex = kShopTab;
    [mydelegate handleTab5];
}

- (void)switchViewController:(UIViewController *)viewController {
    
    if ([[[tabBar buttons] objectAtIndex:2] isTouchInside]) {
        [self showCart];
        [[tabBar.buttons objectAtIndex:2] setSelected:NO];
    } else {
        UIView *currentView = [self.view viewWithTag:SELECTED_VIEW_CONTROLLER_TAG];
        NSLog(@"VIEW :%@",currentView);
        [currentView removeFromSuperview];
    
        viewController.view.frame = CGRectMake(0,22,self.view.bounds.size.width, self.view.bounds.size.height-(tabBar.frame.size.height)-24);
    
        viewController.view.tag = SELECTED_VIEW_CONTROLLER_TAG;
        [self.view insertSubview:viewController.view belowSubview:tabBar];
    }
}
- (void)dealloc{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [apv release];
    [sbv release];
    [vc3 release];
    [vc2 release];
    [vc1 release];
}

- (void)handleSearchBar
{
    if (isSearchBarOpen) {
        NSLog(@"close");
        [self closeSearchBar];
    } else {
        NSLog(@"open");
        //setup searchBar view.
        searchBar = [[SearchBarView alloc] init];
        AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        searchBar.view.frame = CGRectMake(-260.0f, 0.0f, searchBar.view.frame.size.width, mydelegate.window.frame.size.height);
        [mydelegate.window addSubview:searchBar.view];
        [self openSearchBar];
    }
}

- (void)openSearchBar
{
    isSearchBarOpen = YES;
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.tabView.view addSubview:frontLayerView];
    [mydelegate.bannerView setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^
     {
         mydelegate.tabView.view.frame = CGRectMake(260.0f, 0.0f, mydelegate.window.frame.size.width, mydelegate.window.frame.size.height);
         mydelegate.bannerView.frame = CGRectMake(260, mydelegate.window.frame.size.height-39-34, mydelegate.window.frame.size.width, 34);
         searchBar.view.frame = CGRectMake(0.0f, 0.0f, searchBar.view.frame.size.width, mydelegate.window.frame.size.height);
         
     }
                     completion:^(BOOL finished){
                         //[DejalBezelActivityView activityViewForView:mydelegate.window withLabel:@"Loading ..." width:100];
                         //[self performSelector:@selector(updateCart) withObject:nil afterDelay:0.5];
                     }];
}
- (void)closeSearchBar
{
    isSearchBarOpen = NO;
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^
     {
         mydelegate.tabView.view.frame = CGRectMake(0, 0.0f, mydelegate.window.frame.size.width, mydelegate.window.frame.size.height);
         mydelegate.bannerView.frame = CGRectMake(0, mydelegate.window.frame.size.height-39-34, mydelegate.window.frame.size.width, 34);
         searchBar.view.frame = CGRectMake(-260.0f, 0.0f, searchBar.view.frame.size.width, mydelegate.window.frame.size.height);
         
     }
                     completion:^(BOOL finished){}];
    [mydelegate.bannerView setUserInteractionEnabled:YES];
    [frontLayerView removeFromSuperview];
}
@end
