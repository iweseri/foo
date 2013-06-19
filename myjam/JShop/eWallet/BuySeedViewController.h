//
//  BuySeedViewController.h
//  myjam
//
//  Created by M Ridhwan M Sari on 6/14/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuySeedViewController : UIViewController<UIAlertViewDelegate>
{
    NSMutableArray *seedData;
    NSInteger balSeed;
    NSString *seedTopupId;
}

@property (nonatomic, retain) IBOutlet UIButton *seed1Button;
@property (nonatomic, retain) IBOutlet UIButton *seed2Button;
@property (nonatomic, retain) IBOutlet UIButton *seed3Button;

@property (nonatomic, retain) IBOutlet UILabel *rm1Label;
@property (nonatomic, retain) IBOutlet UILabel *rm2Label;
@property (nonatomic, retain) IBOutlet UILabel *rm3Label;

@property (nonatomic, retain) IBOutlet UILabel *balSeedLabel;
@property (nonatomic, retain) IBOutlet UIButton *checkoutButton;
@property (nonatomic, retain) IBOutlet UILabel *whatSeedLabel;

@end
