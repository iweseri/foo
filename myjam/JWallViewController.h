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
#import "PersonalViewController.h"
#import "TBTabButton.h"


@interface JWallViewController : UIViewController<TBTabBarDelegate> {
    TBTabBar *tabBar;
    int plusPage;
    BOOL refreshPageDisabled;
}

@property (retain, nonatomic) PublicViewController *publicVc;
@property (retain, nonatomic) PersonalViewController *personalVc;
@property (retain, nonatomic) TBViewController *vc1, *vc2;


@end
