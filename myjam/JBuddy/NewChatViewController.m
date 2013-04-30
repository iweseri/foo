//
//  JBuddyViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 3/29/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "NewChatViewController.h"

@interface NewChatViewController ()

@end

@implementation NewChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];;
    if (self) {
        FontLabel *titleViewUsingFL = [[FontLabel alloc] initWithFrame:CGRectZero fontName:@"jambu-font.otf" pointSize:22];
        titleViewUsingFL.text = @"J-Buddy";
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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        self.view.frame = CGRectMake(0,0,self.view.bounds.size.width, 568);
    } else {
        // code for 3.5-inch screen
        self.view.frame = CGRectMake(0,0,self.view.bounds.size.width, 480);
    }
    
    CGRect innerViewFrame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height-(tabBar.frame.size.height)-26);

    self.buddyVc = [[BuddyListViewController alloc] init];
    self.buddyVc.fromPlusButton = YES;
    self.buddyVc.view.frame = innerViewFrame;
    self.buddyGroupVc = [[BuddyGroupListViewController alloc] init];
    self.buddyGroupVc.fromPlusButton = YES;
    self.buddyGroupVc.view.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height-(tabBar.frame.size.height));

    self.vc1 = [[[TBViewController alloc] init]autorelease];
    [self.vc1.view addSubview:self.buddyVc.view];
    self.vc2 = [[[TBViewController alloc] init]autorelease];
    [self.vc2.view addSubview:self.buddyGroupVc.view];
    
    TBTabButton *t1 = [[TBTabButton alloc] initWithTitle:@"NEW CHAT"];
    t1.viewController = self.vc1;
    TBTabButton *t2 = [[TBTabButton alloc] initWithTitle:@"NEW GROUP"];
    t2.viewController = self.vc2;
    
    NSArray *a = [NSArray arrayWithObjects:t1, t2, nil];
    
    tabBar = [[TBTabBar alloc] initWithItems:a];
    
    tabBar.delegate = self;
    [self.view addSubview:tabBar];
    [tabBar showDefaults];
}


- (void)switchViewController:(UIViewController *)viewController
{
    NSLog(@"JBUDDY switchViewController");
    
    UIView *currentView = [self.view viewWithTag:SELECTED_VIEW_CONTROLLER_TAG];
    [currentView removeFromSuperview];
    
    viewController.view.frame = CGRectMake(0,28,self.view.bounds.size.width, self.view.bounds.size.height-(tabBar.frame.size.height)-24);
    
    viewController.view.tag = SELECTED_VIEW_CONTROLLER_TAG;
    [self.view insertSubview:viewController.view belowSubview:tabBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
