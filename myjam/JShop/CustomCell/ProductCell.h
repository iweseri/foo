//
//  ProductCell.h
//  myjam
//
//  Created by Azad Johari on 1/30/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIButton *button1;
@property (retain, nonatomic) IBOutlet UIButton *button2;

@property (retain, nonatomic) IBOutlet UILabel *priceLabel1;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel2;

@property (retain, nonatomic) IBOutlet UIButton *buttonTap1;
@property (retain, nonatomic) IBOutlet UIButton *buttonTap2;
@property (retain, nonatomic) IBOutlet UIView *transView2;
@property (retain, nonatomic) IBOutlet UIView *transView1;



@end
