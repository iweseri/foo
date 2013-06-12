//
//  DescriptionCell.h
//  myjam
//
//  Created by M Ridhwan M Sari on 5/29/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DescriptionCell : UITableViewCell
//InfoCell
@property (nonatomic, retain) IBOutlet UILabel *descLabel;
@property (nonatomic, retain) IBOutlet UILabel *shopLabel;
@property (nonatomic, retain) IBOutlet UILabel *catLabel;
@property (nonatomic, retain) IBOutlet UIImageView *shopLogo;
//@property (nonatomic, retain) IBOutlet UIView *readMoreView;

//ReadMoreCell
@property (nonatomic, retain) IBOutlet UILabel *readMoreLabel;

//HeaderRowCell
@property (nonatomic, retain) IBOutlet UILabel *headerRowLabel;
@property (nonatomic, retain) IBOutlet UILabel *colorHeaderRow;

//RowCell
@property (nonatomic, retain) IBOutlet UITextView *rowInfoTextView;
//@property (nonatomic, retain) IBOutlet UILabel *rowInfoLabel;

//PromotionCell
@property (nonatomic, retain) IBOutlet UIView *colorLabel1;
@property (nonatomic, retain) IBOutlet UIView *colorLabel2;
@property (nonatomic, retain) IBOutlet UILabel *shopPLabel1;
@property (nonatomic, retain) IBOutlet UILabel *shopPLabel2;
@property (nonatomic, retain) IBOutlet UILabel *titlePLabel1;
@property (nonatomic, retain) IBOutlet UILabel *titlePLabel2;
@property (nonatomic, retain) IBOutlet UILabel *datePLabel1;
@property (nonatomic, retain) IBOutlet UILabel *datePLabel2;
@property (nonatomic, retain) IBOutlet UILabel *descPLabel1;
@property (nonatomic, retain) IBOutlet UILabel *descPLabel2;
@property (nonatomic, retain) IBOutlet UILabel *catPLabel1;
@property (nonatomic, retain) IBOutlet UILabel *catPLabel2;
@property (nonatomic, retain) IBOutlet UIImageView *pImage1;
@property (nonatomic, retain) IBOutlet UIImageView *pImage2;

//ProductCell
@property (nonatomic, retain) IBOutlet UIImageView *productImage1;
@property (nonatomic, retain) IBOutlet UIImageView *productImage2;
@property (nonatomic, retain) IBOutlet UILabel *shopLabel1;
@property (nonatomic, retain) IBOutlet UILabel *shopLabel2;
@property (nonatomic, retain) IBOutlet UILabel *proLabel1;
@property (nonatomic, retain) IBOutlet UILabel *proLabel2;
@property (nonatomic, retain) IBOutlet UIButton *visitShopButton;

//ShareCell
@property (nonatomic, retain) IBOutlet UIButton *shareFBButton;
@property (nonatomic, retain) IBOutlet UIButton *shareTwitterButton;
@property (nonatomic, retain) IBOutlet UIButton *shareEmailButton;
@end
