//
//  BuySeedViewController.m
//  myjam
//
//  Created by M Ridhwan M Sari on 6/14/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "BuySeedViewController.h"
#import "WhatIsSeedViewController.h"
#import "AppDelegate.h"

@interface BuySeedViewController ()

@end

@implementation BuySeedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"JAM-BU Seeds";
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(buySeedVerification:)
                                                 name:@"buySeedVerification"
                                               object:nil];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[UIColor colorWithHex:@"#f1ebe4"]];
    seedData = [[NSMutableArray alloc] init];
    
    UITapGestureRecognizer *infoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whatIsNeedDesc)];
    [self.whatSeedLabel setUserInteractionEnabled:YES];
    [self.whatSeedLabel addGestureRecognizer:infoTap];
    [infoTap release];
    
    [self.balSeedLabel.layer setBorderWidth:1];
    [self.balSeedLabel.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    seedData = mydelegate.seedData;
    balSeed = mydelegate.balSeed;
    //BOOL success = [self retrieveDataFromAPI];
    //if (success) {
        NSLog(@"jeng");
        [self.balSeedLabel setText:[NSString stringWithFormat:@"♦ %d",balSeed]];
        
        [self.seed1Button setTitle:[[seedData objectAtIndex:0] valueForKey:@"seed_topup_value"] forState:UIControlStateNormal];
        [self.seed2Button setTitle:[[seedData objectAtIndex:1] valueForKey:@"seed_topup_value"] forState:UIControlStateNormal];
        [self.seed3Button setTitle:[[seedData objectAtIndex:2] valueForKey:@"seed_topup_value"] forState:UIControlStateNormal];
        
        NSString *prc1 = [NSString stringWithFormat:@"RM%@", [[[[seedData objectAtIndex:0] valueForKey:@"seed_price"] componentsSeparatedByString:@"."] objectAtIndex:0]];
        [self.rm1Label setText:prc1];
        NSString *prc2 = [NSString stringWithFormat:@"RM%@", [[[[seedData objectAtIndex:1] valueForKey:@"seed_price"] componentsSeparatedByString:@"."] objectAtIndex:0]];
        [self.rm1Label setText:prc2];
        NSString *prc3 = [NSString stringWithFormat:@"RM%@", [[[[seedData objectAtIndex:2] valueForKey:@"seed_price"] componentsSeparatedByString:@"."] objectAtIndex:0]];
        [self.rm1Label setText:prc3];
    //}
    
}

- (BOOL)retrieveDataFromAPI {
    NSString *urlString = [NSString stringWithFormat:@"%@/api/jambu_seed_topup.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]copy]];
    NSString *dataContent = @"";
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"dataContent: %@\nresponse listing: %@|%@", dataContent,response,urlString);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    NSString *status = nil;
    NSMutableArray* list = nil;
    
    if([resultsDictionary count])
    {
        status = [resultsDictionary objectForKey:@"status"];
        list = [resultsDictionary objectForKey:@"messages"];
        
        if ([status isEqualToString:@"ok"] && [list count]) {
            balSeed = [[resultsDictionary objectForKey:@"current_seed"] integerValue];
            for (id row in list) {
                [seedData addObject:row];
            }
            return YES;
        }
        return NO;
    }
    return NO;
}

- (void)setDefaultSeed {
    [self.seed1Button setBackgroundImage:[UIImage imageNamed:@"seed_off"] forState:UIControlStateNormal];
    [self.seed2Button setBackgroundImage:[UIImage imageNamed:@"seed_off"] forState:UIControlStateNormal];
    [self.seed3Button setBackgroundImage:[UIImage imageNamed:@"seed_off"] forState:UIControlStateNormal];
}
- (IBAction)setSeed1:(id)sender {
    [self setDefaultSeed];
    [self.seed1Button setBackgroundImage:[UIImage imageNamed:@"seed_on"] forState:UIControlStateNormal];
    seedTopupId = [[seedData objectAtIndex:0] valueForKey:@"seed_topup_id"];
}
- (IBAction)setSeed2:(id)sender {
    [self setDefaultSeed];
    [self.seed2Button setBackgroundImage:[UIImage imageNamed:@"seed_on"] forState:UIControlStateNormal];
    seedTopupId = [[seedData objectAtIndex:1] valueForKey:@"seed_topup_id"];
}
- (IBAction)setSeed3:(id)sender {
    [self setDefaultSeed];
    [self.seed3Button setBackgroundImage:[UIImage imageNamed:@"seed_on"] forState:UIControlStateNormal];
    seedTopupId = [[seedData objectAtIndex:2] valueForKey:@"seed_topup_id"];
}

- (void)whatIsNeedDesc {
    WhatIsSeedViewController *wis = [[WhatIsSeedViewController alloc] init];
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.otherNavController pushViewController:wis animated:YES];
    [wis release];
}

- (IBAction)checkoutAction:(id)sender {
    NSLog(@"topupID:%@",seedTopupId);
    CustomAlertView *alert;
    if (![seedTopupId isKindOfClass:[NSString class]]) {
        alert = [[CustomAlertView alloc] initWithTitle:@"JAM-BU SEEDS" message:@"Please select Top-up first." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    } else {
        alert = [[CustomAlertView alloc] initWithTitle:@"JAM-BU SEEDS" message:@"Press OK to continue." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
        alert.tag = kAlertSave;
    }
    [alert show];
    [alert release];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == kAlertSave){
        if (buttonIndex == 1) {
            [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading ..." width:100];
            NSLog(@"saved");
            [self performSelector:@selector(checkoutProcess) withObject:nil afterDelay:0.0];
        }
    }
}
- (void)checkoutProcess {
    NSString *urlString = [NSString stringWithFormat:@"%@/api/jambu_seed_topup_buy.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]copy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"topup_id\":\"%@\"}",seedTopupId];
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"dataContent: %@\nresponse listing: %@|%@", dataContent,response,urlString);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    
    if([resultsDictionary count]) {
        if ([[resultsDictionary objectForKey:@"status"] isEqualToString:@"ok"]) {
            if ([[UIApplication sharedApplication] openURL:[NSURL URLWithString:[resultsDictionary objectForKey:@"url"]]]){
                    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                mydelegate.isReturnFromPayment = YES;
            }
        }
    }
}
-(void)buySeedVerification:(NSNotification *) notification{
    [DejalBezelActivityView removeViewAnimated:YES];
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (mydelegate.isReturnFromPayment == NO) {
        return;
    }
    mydelegate.isReturnFromPayment = NO;
    NSString *urlString = [NSString stringWithFormat:@"%@/api/shop_seed_buy_check.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]copy]];
    NSString *dataContent = @"";
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"dataContent: %@\nresponse listing: %@|%@", dataContent,response,urlString);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    NSString *msg;
    
    if([[resultsDictionary objectForKey:@"status"] isEqualToString:@"Paid"]) {
//        [[NSNotificationCenter defaultCenter ] postNotificationName:@"cartChanged" object:self];
//        [[NSNotificationCenter defaultCenter ] postNotificationName:@"refreshPurchaseHistory" object:self];
        balSeed = [[resultsDictionary objectForKey:@"seed_available"] integerValue];
        [self.balSeedLabel setText:[NSString stringWithFormat:@"♦ %d",balSeed]];
        msg = @"Purchase successful. Thank you.";
    }
    else{
        msg = @"Purchase failed. Please try again.";
    }
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"JAM-BU SEEDS" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
    [alertView release];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
