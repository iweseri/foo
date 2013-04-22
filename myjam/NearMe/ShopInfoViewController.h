//
//  ShopInfoViewController.h
//  myjam
//
//  Created by Azad Johari on 2/28/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "MJModel.h"
#import "CoreViewController.h"
#import "ShopDetailListingViewController.h"
#import "PrevMapNMViewController.h"
#import "ASIWrapper.h"

@interface ShopInfoViewController : CoreViewController<UIWebViewDelegate>
@property (retain, nonatomic) IBOutlet UIImageView *shopLogo;
@property (retain, nonatomic) IBOutlet UIWebView *shopAddress;
@property (retain, nonatomic) NSDictionary *shopAddInfo;
@property (retain, nonatomic) IBOutlet UIButton *visitButton;
@property (retain, nonatomic) IBOutlet UIButton *visitShopButton;
@property (nonatomic) NSInteger shopID;
@property (nonatomic, retain) NSString *topSellerOrNot;
@property (nonatomic, retain) IBOutlet UILabel *distanceLabel;
@property (nonatomic) float shopCoordLat;
@property (nonatomic) float shopCoordLong;
@property (nonatomic) NSInteger shopDistance;

@property (nonatomic, retain) NSString *shopName;
@property (retain, nonatomic) IBOutlet UIView *socialView;
@property (retain, nonatomic) IBOutlet UIView *infoView;
@property (retain, nonatomic) IBOutlet UIScrollView *scroller;
- (IBAction)visitShop:(id)sender;
- (IBAction)facebookPressed:(id)sender;
- (IBAction)twitterPressed:(id)sender;
- (IBAction)emailPressed:(id)sender;
- (IBAction)visitJSHyperAct:(id)sender;
- (IBAction)prevMapHyperAct:(id)sender;
@end
