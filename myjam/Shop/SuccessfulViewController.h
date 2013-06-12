//
//  SuccessfulViewController.h
//  myjam
//
//  Created by M Ridhwan M Sari on 6/10/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuccessfulViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIButton *purchaseHistoryButton;
@property (nonatomic, retain) IBOutlet UIButton *topupSeedButton;
@property (nonatomic, retain) IBOutlet UILabel *infoSeedLabel;
@property (nonatomic, retain) IBOutlet UILabel *valueSeedLabel;
@property (nonatomic, retain) NSString *balanceSeed;
@property BOOL *isShowSeeds;

@end
