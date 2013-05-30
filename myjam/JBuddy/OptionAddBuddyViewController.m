//
//  OptionAddBuddyViewController.m
//  myjam
//
//  Created by ME-Tech Mac User 2 on 5/10/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "OptionAddBuddyViewController.h"
#import "AddBuddyViewController.h"
#import "AddPhonebookViewController.h"

@interface OptionAddBuddyViewController ()

@end

@implementation OptionAddBuddyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    [self displayButton];
    // Do any additional setup after loading the view from its nib.
}

- (void)displayButton
{
    // search name button
    UIButton *nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nameButton setFrame:CGRectMake(20, 50, 280, 40)];    //your desired size
    [nameButton setTag:1];
    [nameButton setClipsToBounds:YES];
    [nameButton.layer setCornerRadius:10.0f];
    [nameButton.layer setBorderWidth:2];
    [nameButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [nameButton setBackgroundImage:[UIImage imageNamed:@"btn-srch-name"]
                          forState:UIControlStateNormal];
    //nameBtn.backgroundColor = [UIColor colorWithHex:@"#D22042"];
    [nameButton setTitle:@" SEARCH BUDDY BY NAME" forState:UIControlStateNormal];
    [nameButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [nameButton setTintColor:[UIColor whiteColor]];
    [nameButton addTarget:self action:@selector(optionTo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nameButton];
    
    // phonebook button
    UIButton *pBookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pBookButton setFrame:CGRectMake(20, 100, 280, 40)];
    [pBookButton setTag:2];
    [pBookButton setClipsToBounds:YES];
    [pBookButton.layer setCornerRadius:10.0f];
    [pBookButton.layer setBorderWidth:2];
    [pBookButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [pBookButton setBackgroundImage:[UIImage imageNamed:@"btn-srch-phonebook"]
                           forState:UIControlStateNormal];
    [pBookButton setTitle:@"     SEARCH FROM PHONEBOOK" forState:UIControlStateNormal];
    [pBookButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [pBookButton setTintColor:[UIColor whiteColor]];
    [pBookButton addTarget:self action:@selector(optionTo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pBookButton];
    
    // facebook button
    UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [facebookButton setFrame:CGRectMake(20, 150, 280, 40)];
    [facebookButton setTag:3];
    [facebookButton setClipsToBounds:YES];
    [facebookButton.layer setCornerRadius:10.0f];
    [facebookButton.layer setBorderWidth:2];
    [facebookButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [facebookButton setBackgroundImage:[UIImage imageNamed:@"btn-srch-facebook"]
                              forState:UIControlStateNormal];
    [facebookButton setTitle:@"   SEARCH FROM FACEBOOK" forState:UIControlStateNormal];
    [facebookButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [facebookButton setTintColor:[UIColor whiteColor]];
    [facebookButton addTarget:self action:@selector(optionTo:) forControlEvents:UIControlEventTouchUpInside];
    [facebookButton setEnabled:NO];
    [self.view addSubview:facebookButton];
}

- (void)optionTo:(UIButton*)search
{
    NSLog(@"%d",search.tag);
    if (search.tag == 1) { //search name
        AddBuddyViewController *addBuddy = [[AddBuddyViewController alloc] initWithNibName:@"AddBuddyViewController" bundle:nil];
        [self.navigationController pushViewController:addBuddy animated:YES];
        [addBuddy release];
    } else if(search.tag == 2) { //search phonebook
        AddPhonebookViewController *addPBook = [[AddPhonebookViewController alloc] initWithNibName:@"AddPhonebookViewController" bundle:nil];
        [self.navigationController pushViewController:addPBook animated:YES];
        [addPBook release];
    } else { //search facebook
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
