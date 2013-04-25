//
//  CustomProduct.h
//  myjam
//
//  Created by ME-Tech Mac User 2 on 2/20/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateView.h"

@interface CustomProduct : UIView

@property (retain, nonatomic) IBOutlet UIButton *button1;
@property (retain, nonatomic) IBOutlet UIButton *button2;
@property (retain, nonatomic) IBOutlet UIButton *button3;
@property (retain, nonatomic) IBOutlet UIButton *buttonTap1;
@property (retain, nonatomic) IBOutlet UIButton *buttonTap2;
@property (retain, nonatomic) IBOutlet UIButton *buttonTap3;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel1;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel2;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel3;
@property (retain, nonatomic) IBOutlet RateView *rateView1;
@property (retain, nonatomic) IBOutlet RateView *rateView2;
@property (retain, nonatomic) IBOutlet RateView *rateView3;
@property (retain, nonatomic) IBOutlet UIView *transView1;
@property (retain, nonatomic) IBOutlet UIView *transView2;
@property (retain, nonatomic) IBOutlet UIView *transView3;

@end
