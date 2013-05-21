//
//  PostClass.h
//  myjam
//
//  Created by Mohd Hafiz on 5/14/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostClass : NSObject

@property (nonatomic) NSInteger postId;
@property (nonatomic) NSInteger qrcodeId;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *avatarURL;
@property (nonatomic, retain) NSString *datetime;
@property (nonatomic, retain) NSString *isFavourite;
@property (nonatomic, retain) NSString *totalFavourite;
@property (nonatomic, retain) NSString *totalComment;
@property (nonatomic, retain) NSString *imageURL;

@end
