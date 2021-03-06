//
//  JWallViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 5/9/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "JWallViewController.h"
#import "CreatePostViewController.h"
#import "UnblockUsersViewController.h"
#import "AppDelegate.h"

#define kPublic     1
#define kPersonal   2

@interface JWallViewController ()

@end

@implementation JWallViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        FontLabel *titleViewUsingFL = [[FontLabel alloc] initWithFrame:CGRectZero fontName:@"jambu-font.otf" pointSize:22];
        titleViewUsingFL.text = @"J-ROOM";
        titleViewUsingFL.textAlignment = NSTextAlignmentCenter;
        titleViewUsingFL.backgroundColor = [UIColor clearColor];
        titleViewUsingFL.textColor = [UIColor whiteColor];
        [titleViewUsingFL sizeToFit];
        self.navigationItem.titleView = titleViewUsingFL;
        [titleViewUsingFL release];
        
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
    
    searchBar = [[WallSearchBarView alloc] initWithNibName:@"SearchBarView" bundle:nil];
    
    optionPersonal = [[NSArray alloc] initWithObjects:@"Create Post", @"Unblock Users", @"Cancel", nil];

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        self.view.frame = CGRectMake(0,0,self.view.bounds.size.width, 568);
    } else {
        // code for 3.5-inch screen
        self.view.frame = CGRectMake(0,0,self.view.bounds.size.width, 480);
    }
    
    CGRect innerViewFrame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height-(tabBar.frame.size.height)-18-44);
    
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
    
    self.publicVc = [[PublicViewController alloc] init];
    self.publicVc.pageType = kPublic;
    self.publicVc.view.frame = innerViewFrame;
    self.personalVc = [[PublicViewController alloc] init];
    self.personalVc.pageType = kPersonal;
    self.personalVc.view.frame = innerViewFrame;
    
    self.vc1 = [[[TBViewController alloc] init] autorelease];
    [self.vc1.view addSubview:self.publicVc.view];
    self.vc2 = [[[TBViewController alloc] init] autorelease];
    [self.vc2.view addSubview:self.personalVc.view];
    
    TBTabButton *t1 = [[TBTabButton alloc] initWithTitle:@"PUBLIC"];
    t1.viewController = self.vc1;
    TBTabButton *t2 = [[TBTabButton alloc] initWithTitle:@"PERSONAL"];
    t2.viewController = self.vc2;
    TBTabButton *t3 = [[TBTabButton alloc] initWithTitle:@"+"];
    
    NSArray *a = [NSArray arrayWithObjects:t1,t2,t3, nil];
    
    tabBar = [[TBTabBar alloc] initWithItems:a];
    
    tabBar.delegate = self;
    [self.view addSubview:tabBar];
    [tabBar showDefaults];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSearchBar)
                                                 name:@"handleSearchBarWall"
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!refreshPageDisabled) {
        [tabBar showDefaults];
        refreshPageDisabled = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    // To deselect 3rd button (+)
//    int i = 0;
//    for (UIButton* b in tabBar.buttons) {
//        if (i++ == 2) {
//            [b setSelected:NO];
//        }
//    }
}

- (void)switchViewController:(UIViewController *)viewController
{
    if (viewController == self.vc1) {
        plusPage = kPublic;
    }
    else if (viewController == self.vc2){
        plusPage = kPersonal;
    }else{
        refreshPageDisabled = YES;
        if (plusPage == kPublic) {
            NSLog(@"public");
            [self popupPlusPersonal];
        }else if (plusPage == kPersonal) {
            NSLog(@"personal");
            [self popupPlusPersonal];
        }
        return;
    }
    
    UIView *currentView = [self.view viewWithTag:SELECTED_VIEW_CONTROLLER_TAG];
    [currentView removeFromSuperview];
    
    viewController.view.frame = CGRectMake(0,28,self.view.bounds.size.width, self.view.bounds.size.height-(tabBar.frame.size.height)-24);
    
    viewController.view.tag = SELECTED_VIEW_CONTROLLER_TAG;
    [self.view insertSubview:viewController.view belowSubview:tabBar];
}

- (void)popupPlusPersonal
{
    MyPopupView *popup = [[MyPopupView alloc] initWithDataList:optionPersonal andTag:nil];
    popup.delegate = self;
    CGFloat popupYPoint = self.view.frame.size.height/2-popup.frame.size.height/2;
    CGFloat popupXPoint = self.view.frame.size.width/2-popup.frame.size.width/2;
    popup.frame = CGRectMake(popupXPoint, popupYPoint, popup.frame.size.width, popup.frame.size.height);
    [self addBlackView];
    [self.view addSubview:popup];
}

#pragma mark -
#pragma mark MyPopupViewDelegate

- (void)popView:(MyPopupView *)popupView didSelectOptionAtIndex:(NSInteger)index
{
    NSLog(@"Clicked at post %d and selected option %d", popupView.tag, index);
    
    [self removeBlackView];
    [self optionSelectedPopup:index];
}

- (void)optionSelectedPopup:(NSInteger)option
{
    if (option == 0) {
        NSLog(@"goto CreatePost");
        CreatePostViewController *createPost = [[CreatePostViewController alloc] initWithPlaceholderText:@"What's on your mind?" withLabel:@"CREATE POST" andComment:nil];
        //CreatePostViewController *createPost = [[CreatePostViewController alloc] init];
        [self.navigationController pushViewController:createPost animated:YES];
        [createPost release];
    }
    else if (option == 1) {
        NSLog(@"goto unblockUsers");
        UnblockUsersViewController *unblock = [[UnblockUsersViewController alloc] init];
        [self.navigationController pushViewController:unblock animated:YES];
        [unblock release];
    }
    [[tabBar.buttons objectAtIndex:2] setSelected:NO];
    if (plusPage == kPublic) {
        [[tabBar.buttons objectAtIndex:0] setSelected:YES];
    } else if (plusPage == kPersonal) {
        [[tabBar.buttons objectAtIndex:1] setSelected:YES];
    }
}

- (void)addBlackView
{
    UIView *blackView = [[UIView alloc] initWithFrame:self.view.frame];
    [blackView setTag:99];
    [blackView setBackgroundColor:[UIColor blackColor]];
    [blackView setAlpha:0.3];
    [self.view addSubview:blackView];
    [blackView release];
}

- (void)removeBlackView
{
    UIView *blackView = [self.view viewWithTag:99];
    [blackView removeFromSuperview];
}

#pragma mark -
#pragma mark SearchBar
- (void)handleSearchBar
{
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (isSearchBarOpen) {
        NSLog(@"close");
//        [mydelegate.seedViewLabel setHidden:NO];
        [self closeSearchBar];
    } else {
        NSLog(@"open");
        //setup searchBar view.
        
        
        [mydelegate.seedViewLabel setHidden:YES];
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
                     completion:^(BOOL finished){
                         [mydelegate.seedViewLabel setHidden:NO];
                     }];
    [mydelegate.bannerView setUserInteractionEnabled:YES];
    [frontLayerView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
