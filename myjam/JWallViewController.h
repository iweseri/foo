//
//  JWallViewController.h
//  myjam
//
//  Created by Mohd Hafiz on 5/9/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBTabBar.h"
#import "PublicViewController.h"
//#import "PersonalViewController.h"
#import "TBTabButton.h"
#import "MyPopupView.h"
#import "WallSearchBarView.h"

@interface JWallViewController : UIViewController<TBTabBarDelegate, MyPopupViewDelegate> {
    TBTabBar *tabBar;
    int plusPage;
    BOOL refreshPageDisabled;
    NSArray *optionPersonal;
    WallSearchBarView *searchBar;
    BOOL isSearchBarOpen;
    UIView *frontLayerView;
}

@property (retain, nonatomic) PublicViewController *publicVc;
@property (retain, nonatomic) PublicViewController *personalVc;
@property (retain, nonatomic) TBViewController *vc1, *vc2;


@end
