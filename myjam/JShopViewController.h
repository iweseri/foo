//
//  JShopViewController.h
//  myjam
//
//  Created by nazri on 11/7/12.
//  Copyright (c) 2012 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBTabBar.h"
#import "TBTabButton.h"
#import "SearchBarView.h"
#import "AllProductViewController.h"
#import "StarBuyViewController.h"
#import "PurchasedHistoryViewController.h"

@class AllProductViewController;
@class PurchasedHistoryViewController;

@interface JShopViewController : UIViewController <TBTabBarDelegate>
{
    BOOL isSearchBarOpen;
    UIView *frontLayerView;
}

@property (retain, nonatomic) TBTabBar *tabBar;
@property (retain, nonatomic) AllProductViewController *apv;
@property (retain, nonatomic) StarBuyViewController *sbv;
//@property (retain, nonatomic) PurchasedHistoryViewController *phv;
@property (retain, nonatomic) SearchBarView *searchBar;
@property (retain, nonatomic) TBViewController *vc3;
@property (retain, nonatomic) TBViewController *vc2;
@property (retain, nonatomic) TBViewController *vc1;

@end
