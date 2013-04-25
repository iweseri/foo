//
//  JBuddyViewController.h
//  myjam
//
//  Created by Mohd Hafiz on 3/29/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBTabBar.h"
#import "TBTabButton.h"
#import "ChatListViewController.h"
#import "BuddyListViewController.h"


@interface JBuddyViewController : UIViewController<TBTabBarDelegate> {
    TBTabBar *tabBar;
    int plusPage;
    BOOL refreshPageDisabled;
}

@property (retain, nonatomic) ChatListViewController *chatListVc;
@property (retain, nonatomic) BuddyListViewController *buddyListVc;
@property (retain, nonatomic) TBViewController *vc1, *vc2;

@end
