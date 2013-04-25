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
#import "ChatViewController.h"


@interface NewChatViewController : UIViewController<TBTabBarDelegate> {
    TBTabBar *tabBar;
}

@property (retain, nonatomic) ChatViewController *chatVc;
@property (retain, nonatomic) TBViewController *vc1, *vc2;
@property (retain, nonatomic) NSString *buddyId;

- (id)initWithTabTitle:(NSString *)title andBuddyId:(NSString *)bid;

@end
