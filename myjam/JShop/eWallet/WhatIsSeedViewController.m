//
//  WhatIsSeedViewController.m
//  myjam
//
//  Created by M Ridhwan M Sari on 6/16/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "WhatIsSeedViewController.h"

@interface WhatIsSeedViewController ()

@end

@implementation WhatIsSeedViewController

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *info = @"Description goes here. JAM-BU SEED is JAM-BU’s virtual currency. It can be used to purchase goods from JAM-BU SHOP, gain extra discounts with the <b><font color=\"red\">SPIN-DISCOUNT</font></b>, etc. Description goes here. JAM-BU SEED is JAM-BU’s virtual currency. It can be used to purchase goods from JAM-BU SHOP, gain extra discounts with the <b><font color=\"red\">SPIN-DISCOUNT</font></b>, etc.";
    [self.infoView.scrollView setBounces:NO];
    [self.infoView loadHTMLString:[NSString stringWithFormat:@"<html><body bgcolor=\"#FFFFFF\" text=\"#000000\" face=\"Bookman Old Style, Book Antiqua, Garamond\" size=\"5\"><font face=\"arial\">%@</font></body></html>", info] baseURL: nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
