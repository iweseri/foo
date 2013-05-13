//
//  JWallViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 5/9/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "JWallViewController.h"
#import "CreatePostViewController.h"

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
        titleViewUsingFL.text = @"J-Wall";
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
    
    CGRect innerViewFrame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height-(tabBar.frame.size.height)-18-44);
    
    self.publicVc = [[PublicViewController alloc] init];
    self.publicVc.view.frame = innerViewFrame;
    self.personalVc = [[PersonalViewController alloc] init];
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
    int i = 0;
    for (UIButton* b in tabBar.buttons) {
        if (i++ == 2) {
            [b setSelected:NO];
        }
    }
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
//        if (plusPage == kPublic) {
//            NSLog(@"public");
//        }else if (plusPage == kPersonal) {
//            NSLog(@"personal");
//        }
        CreatePostViewController *createPost = [[CreatePostViewController alloc] init];
        [self.navigationController pushViewController:createPost animated:YES];
        [createPost release];
        
        return;
    }
    
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
