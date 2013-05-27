//
//  CreatePostViewController.h
//  myjam
//
//  Created by Mohd Hafiz on 5/13/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "MyPopupView.h"

@class TPKeyboardAvoidingScrollView;

@interface CreatePostViewController : UIViewController<MyPopupViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSArray *optionPhoto;
    NSString *placeHolderText;
    NSString *textType;
    NSInteger postIdComment;
    CGFloat kContentSize;
    CGFloat kTagSize;
    int photoType;
    //BOOL isTagged;
}
@property (retain, nonatomic) TPKeyboardAvoidingScrollView *content;
//@property (retain, nonatomic) NSString *placeHolderText;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (retain, nonatomic) IBOutlet UILabel *typeLabel;
@property (retain, nonatomic) IBOutlet UIView *postView;
@property (retain, nonatomic) UIView *contentView;
@property (retain, nonatomic) UILabel *tagLabelView;
@property (retain, nonatomic) IBOutlet UITextView *textData;
@property (retain, nonatomic) IBOutlet UIImageView *userImageView;
@property (retain, nonatomic) IBOutlet UIView *keyboardAccessoryView;

@property (nonatomic, retain) UIImageView *uploadImage;

//@property (nonatomic) BOOL isTagged;
@property (nonatomic, retain) NSString *tagName;
@property (nonatomic, retain) NSString *tagId;

- (id)initWithPlaceholderText:(NSString*)holderText withLabel:(NSString*)type andComment:(NSInteger)postId;

@end
