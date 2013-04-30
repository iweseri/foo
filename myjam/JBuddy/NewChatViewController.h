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
#import "BuddyListViewController.h"
#import "BuddyGroupListViewController.h"


@interface NewChatViewController : UIViewController<TBTabBarDelegate> {
    TBTabBar *tabBar;
}

@property (retain, nonatomic) BuddyListViewController *buddyVc;
@property (retain, nonatomic) BuddyGroupListViewController *buddyGroupVc;
@property (retain, nonatomic) TBViewController *vc1, *vc2;
@property (retain, nonatomic) NSString *buddyId;

@end
