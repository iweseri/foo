//
//  TBTabBar.h
//  TweetBotTabBar
//
//  Created by Jerish Brown on 6/27/11.
//  Copyright 2011 i3Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TBTabBarDelegate;
@interface TBTabBar : UIView {
    NSMutableArray *_buttonData;
    NSMutableArray *_buttons;
    NSMutableArray *_statusLights;
    id<TBTabBarDelegate> delegate;
}

@property (assign) id<TBTabBarDelegate> delegate;
@property (retain) NSMutableArray *buttons;

-(id)initWithItems:(NSArray *)items;
-(id)initWithFrame:(CGRect)frameSize andItems:(NSArray *)items;
-(id)initWithButtonSize:(NSArray *)buttonSize andItems:(NSArray *)items; //for J-Shop

-(void)showDefaults;
-(void)showViewControllerAtIndex:(NSUInteger)index;

-(void)touchDownForButton:(UIButton*)button;
-(void)touchUpForButton:(UIButton*)button;
-(void)setTitleButton:(NSString*)aTitle forButtonIndex:(NSInteger)ind;
@end

@protocol TBTabBarDelegate
-(void)switchViewController:(UIViewController*)vc;
@end