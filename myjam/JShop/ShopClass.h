//
//  ShopClass.h
//  myjam
//
//  Created by M Ridhwan M Sari on 6/11/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopClass : NSObject

+ (ShopClass*) sharedInstance;
- (UIView*)priceViewFor:(NSString*)normalPrice and:(NSString*)discountPrice;

@end
