//
//  SuccessfulViewController.m
//  myjam
//
//  Created by M Ridhwan M Sari on 6/10/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "SuccessfulViewController.h"
#import "AppDelegate.h"

@interface SuccessfulViewController ()

@end

@implementation SuccessfulViewController

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
    // Do any additional setup after loading the view from its nib.
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        self.view.frame = CGRectMake(0,0,self.view.bounds.size.width, 568);
    } else {
        // code for 3.5-inch screen
        self.view.frame = CGRectMake(0,0,self.view.bounds.size.width, 480);
    }
    [self.view setBackgroundColor:[UIColor colorWithHex:@"#f1ebe4"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    if(self.isShowSeeds) {
        NSString *value = [NSString stringWithFormat:@"♦ %@",self.balanceSeed];
        [self.valueSeedLabel setText:value];
    } else {
        [self.infoSeedLabel setHidden:YES];
        [self.valueSeedLabel setHidden:YES];
    }
}

-(IBAction)gotoPurchaseHistory:(id)sender
{
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ShopViewController *sv1 =[[mydelegate.shopNavController viewControllers] objectAtIndex:0];
    mydelegate.isShowPurchaseHistory = YES;
    [mydelegate.shopNavController popToRootViewControllerAnimated:YES];
    [sv1.tabBar showViewControllerAtIndex:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
