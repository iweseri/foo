//
//  CreatePostViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 5/13/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "CreatePostViewController.h"
#import "DetailPostViewController.h"
#import "TagBuddyViewController.h"
#import "ASIFormDataRequest.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kKeyboardHeight 216
#define gallery 5142
#define camera  1014

@interface CreatePostViewController ()
@property (retain, nonatomic) UIImagePickerController *cameraPicker;
@end

@implementation CreatePostViewController

@synthesize cameraPicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        FontLabel *titleViewUsingFL = [[FontLabel alloc] initWithFrame:CGRectZero fontName:@"jambu-font.otf" pointSize:22];
        titleViewUsingFL.text = @"J-ROOM";
        titleViewUsingFL.textAlignment = NSTextAlignmentCenter;
        titleViewUsingFL.backgroundColor = [UIColor clearColor];
        titleViewUsingFL.textColor = [UIColor whiteColor];
        [titleViewUsingFL sizeToFit];
        self.navigationItem.titleView = titleViewUsingFL;
        [titleViewUsingFL release];
        
        self.navigationItem.backBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                          style:UIBarButtonItemStyleBordered
                                         target:nil
                                         action:nil] autorelease];
    }
    return self;
}

// push from JWallViewController (postId nil) | push from PublicViewController (postId mandatory)
- (id)initWithPlaceholderText:(NSString*)holderText withLabel:(NSString*)type andComment:(NSInteger)postId
{
    self = [super init];
    if (self) {
        placeHolderText = holderText;
        textType = type;
        postIdComment = postId;
        
        if ([textType isEqualToString:@"SHARE POST"]) {
            self.shareData = [[PostClass alloc] init];
        }
        
    }
    
    NSLog(@"ID:%d",postIdComment);
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        self.view.frame = CGRectMake(0,0,self.view.bounds.size.width, 568);
    } else {
        // code for 3.5-inch screen
        self.view.frame = CGRectMake(0,0,self.view.bounds.size.width, 480);
    }

    
    // Do any additional setup after loading the view from its nib.
    optionPhoto = [[NSArray alloc] initWithObjects:@"Choose from Gallery", @"Capture a photo", @"Cancel", nil];
    
    self.content = (TPKeyboardAvoidingScrollView *)self.view;
//    [self.content setContentSize:CGSizeMake(self.contentView.frame.size.width, self.contentView.frame.size.height-100)];
    
    // Keyboard stuffings
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadView:)
                                                 name:@"reloadPostView"
                                               object:nil];
    
    cameraPicker = [[UIImagePickerController alloc] init];
    cameraPicker.delegate = self;
    
    [self setupView];
//    [self.textData becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"CP-vda");
//    [self.textData becomeFirstResponder];
//    if ([self.textData.text isEqual:placeHolderText]) {
//        [self.textData setText:@""];
//    }
}

- (void)setupView
{
//    [self.postView setHidden:YES];
    self.postView.frame = CGRectMake(0, (self.view.frame.size.height-44*3 - 5)-self.postView.frame.size.height, 320, 40);
    NSLog(@"postview %f", self.postView.frame.origin.y);
    self.textData.delegate = self;
    self.textData.text = placeHolderText;
    self.textData.inputAccessoryView = self.keyboardAccessoryView;
    //[self.textData setContentSize:CGSizeMake(220, 60)];
    //self.textData.contentInset = UIEdgeInsetsZero;
    self.typeLabel.text = textType;
    
    UIButton *nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nameButton setFrame:CGRectMake(235, 5, 70, 30)];    //your desired size
    [nameButton setTag:1];
    [nameButton setClipsToBounds:YES];
    [nameButton.layer setCornerRadius:10.0f];
    [nameButton.layer setBorderWidth:2];
    [nameButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    nameButton.backgroundColor = [UIColor colorWithHex:@"#D22042"];
    [nameButton setTitle:@"POST" forState:UIControlStateNormal];
    [nameButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [nameButton setTintColor:[UIColor grayColor]];
    [nameButton addTarget:self action:@selector(processPost) forControlEvents:UIControlEventTouchUpInside];
    [self.postView addSubview:nameButton];

    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [postButton setFrame:CGRectMake(235, 5, 70, 30)];    //your desired size
    [postButton setTag:1];
    [postButton setClipsToBounds:YES];
    [postButton.layer setCornerRadius:10.0f];
    [postButton.layer setBorderWidth:2];
    [postButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    postButton.backgroundColor = [UIColor colorWithHex:@"#D22042"];
    [postButton setTitle:@"POST" forState:UIControlStateNormal];
    [postButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [postButton setTintColor:[UIColor grayColor]];
    [postButton addTarget:self action:@selector(processPost) forControlEvents:UIControlEventTouchUpInside];
    [self.keyboardAccessoryView addSubview:postButton];
    
    NSString *imgURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_avatar_url"];
    [self.userImageView setImageWithURL:[NSURL URLWithString:imgURL]
                      placeholderImage:[UIImage imageNamed:@"blank_avatar.png"]];
    
    if ([textType isEqualToString:@"SHARE POST"]) {
        self.shareView.frame = CGRectMake(10, 180, self.shareView.frame.size.width, self.shareView.frame.size.height);
        [self.view addSubview:self.shareView];
        self.shareView.backgroundColor = [UIColor colorWithHex:@"#f1f1f1"];
        self.shareView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.shareView.layer.borderWidth = 1.0f;
        
        NSString *urlImage = self.shareData.avatarURL;
        
        if ([[self.shareData.sharedItem objectForKey:@"post_type"] isEqualToString:@"PHOTO"]) {
            urlImage = [self.shareData.sharedItem objectForKey:@"post_photo"];
        }
        else if ([self.shareData.type isEqualToString:@"PHOTO"])
        {
            urlImage = self.shareData.imageURL;
        }
        
        [self.sourceImageView setImageWithURL:[NSURL URLWithString:urlImage]
                           placeholderImage:[UIImage imageNamed:@"default_icon"]];
        self.topLabel.text = self.shareData.username;
        [self.topLabel sizeToFit];
        self.subtitleLabel.text = self.shareData.text;
        [self.subtitleLabel sizeToFit];
        
        [self.shareView release];
    }
}

- (void)reloadView:(NSNotification*)tagData
{
    if (tagData != nil) {
        NSArray *tData = [tagData object];
        self.tagId = [tData objectAtIndex:0];
        self.tagName = [tData objectAtIndex:1];
        NSLog(@"reloadView:%@|%@|%@",self.tagName,self.uploadImage,tData);
    }
    if ([self.tagId length]>0) {
        kTagSize = 20.0f;
        self.tagLabelView = [[UILabel alloc] initWithFrame:CGRectMake(86, 153, 220, kTagSize)];
        [self.tagLabelView setFont:[UIFont systemFontOfSize:14]];
        [self.tagLabelView setBackgroundColor:[UIColor lightGrayColor]];
        [self.tagLabelView setText:self.tagName];
        [self.view addSubview:self.tagLabelView];
        [self.tagLabelView release];
        NSLog(@"tagged:%@",self.tagLabelView.text);
    } else {
        kTagSize = 0.0f;
    }
    if (self.uploadImage != nil) {
        NSLog(@"img");
        kContentSize = 100.0f;
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 160+kTagSize, 320, kContentSize)];
        self.uploadImage.frame = CGRectMake(86, 0, 90, 90);
        
        [self.contentView addSubview:self.uploadImage];
        [self.view addSubview:self.contentView];
        [self.contentView release];
    } else {
        kContentSize = 0.0f;
    }
}

#pragma mark -
#pragma mark textView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
//    [self.content adjustOffsetToIdealIfNeeded];
//    [self.content setContentSize:CGSizeMake(self.contentView.frame.size.width, self.contentView.frame.size.height-44)];
    
    if ([self.textData.text isEqual:placeHolderText]) {
        [self.textData setText:@""];
    }
    
    [self.postView setHidden:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.textData.text length]==0) {
        self.textData.text = placeHolderText;
    }
//    NSLog(@"postview %f", self.postView.frame.origin.y);
    self.postView.frame = CGRectMake(0, (self.view.frame.size.height-44-26)-self.postView.frame.size.height, 320, 40);
    [self.postView setHidden:NO];
//    [[NSNotificationCenter defaultCenter ] postNotificationName:UIKeyboardDidHideNotification object:self];

}

#pragma mark -
#pragma mark MyPopupViewDelegate
- (void)popView:(MyPopupView *)popupView didSelectOptionAtIndex:(NSInteger)index
{
    NSLog(@"Clicked at post %d and selected option %d", popupView.tag, index);
    [self removeBlackView];
    if (index == 0) {
        [self imagedFromGallery];
    }
    else if (index == 1) {
        [self imagedFromCamera];
    }
}

- (void)addBlackView
{
    UIView *blackView = [[UIView alloc] initWithFrame:self.view.frame];
    [blackView setTag:99];
    [blackView setBackgroundColor:[UIColor blackColor]];
    [blackView setAlpha:0.3];
    [self.view addSubview:blackView];
    [blackView release];
}

- (void)removeBlackView
{
    UIView *blackView = [self.view viewWithTag:99];
    [blackView removeFromSuperview];
}

#pragma mark -
#pragma mark Add Photo
- (void)imagedFromGallery
{
    photoType = gallery;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage,nil];
        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker animated:YES];
        [imagePicker release];
    }
}

- (void)imagedFromCamera
{
    photoType = camera;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        cameraPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
        cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        
        UIView *controllerView = cameraPicker.view;
        controllerView.tag = camera;
        controllerView.alpha = 0.0;
        controllerView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [[[[UIApplication sharedApplication] delegate] window] addSubview:controllerView];
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             controllerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                             controllerView.alpha = 1.0;
                         }
                         completion:nil
         ];
        //[imagePicker release];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if([mediaType isEqualToString:(NSString *) kUTTypeImage])
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.uploadImage = [[UIImageView alloc ] initWithImage:image];
        [self reloadView:nil];
        //[self performSelectorInBackground:@selector(uploadImage) withObject:self];
    }
    if (photoType == gallery) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        UIView *cameraView = [[[[UIApplication sharedApplication] delegate] window] viewWithTag:camera];
        [cameraView removeFromSuperview];
    }

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (photoType == gallery) {
        NSLog(@"galleryClosed");
        [self dismissModalViewControllerAnimated:YES];
    } else {
        UIView *cameraView = [[[[UIApplication sharedApplication] delegate] window] viewWithTag:camera];
        [cameraView removeFromSuperview];
        NSLog(@"cameraClosed");
    }
}

- (void)processPost
{
    NSString *typePost = @"postStatus";
    if ([self.textData.text isEqualToString:placeHolderText]) {
        self.textData.text = @"";
    }
    if (self.uploadImage == nil && [self.textData.text isEqual: @""] && self.tagId == nil) {
//        [self presentAlert:@"No data, cannot post."];
//        self.textData.text = placeHolderText;
    }
    
    if ([self.textData.text isEqualToString: @""]) {
        [self presentAlert:@"Status is required."];
        self.textData.text = placeHolderText;
    }else {
        NSNumber *tempId = postIdComment;
        if (tempId != nil) {
            typePost = @"postComment";
        }
        NSLog(@"ID:%d",postIdComment);
        NSLog(@"\nText :%@\nImage :%@\nTag :%@",self.textData.text,self.uploadImage,self.tagId);
        [self.loadingIndicator startAnimating];
//        [self performSelector:@selector(processPostToAPI:) withObject:typePost afterDelay:0.0f];
        [self processPostToAPI:typePost];
    }
}

- (void)clearImageCache
{
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
}

- (void)processPostToAPI:(NSString*)typePost
{
    NSString *apiFile = nil;
    NSString *type = @"DEFAULT";
    if ([typePost isEqualToString:@"postStatus"] || [textType isEqualToString:@"SHARE POST"]) {
        NSLog(@"POST");
        apiFile = @"wall_post.php";
    } else {
        NSLog(@"COMMENT:%d",postIdComment);
        apiFile = @"wall_post_comment.php";
    }
    NSData *imgData = UIImageJPEGRepresentation(self.uploadImage.image, 0.3);
    NSString *urlString = [NSString stringWithFormat:@"%@/api/%@?token=%@", APP_API_URL, apiFile,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSLog(@"urlstr %@", urlString);
    ASIFormDataRequest *asiRequest = [ASIFormDataRequest requestWithURL:url];
    [asiRequest addRequestHeader:@"Accept" value:@"application/json"];
    [asiRequest addRequestHeader:@"Content-Type" value:@"application/json"];
    
    if ([typePost isEqualToString:@"postStatus"]) {
        [asiRequest addPostValue:self.textData.text forKey:@"post_text"];
        [asiRequest addPostValue:self.tagId forKey:@"post_tagged_user_ids"];
        
        if ([textType isEqualToString:@"SHARE POST"])
        {
            [asiRequest addPostValue:[NSString stringWithFormat:@"%d",self.shareData.postId] forKey:@"post_id"];
        }
    } else {
        [asiRequest addPostValue:self.textData.text forKey:@"comment_text"];
        [asiRequest addPostValue:[NSString stringWithFormat:@"%d",postIdComment] forKey:@"post_id"];
    }
    
    if (self.uploadImage != nil) {
        type = @"PHOTO";
        [asiRequest addData:imgData withFileName:@"currImage.jpg" andContentType:@"image/jpeg" forKey:@"image"];
        NSLog(@"is photo");
    }
    [asiRequest addPostValue:type forKey:@"post_type"];
    [asiRequest setTimeOutSeconds:20];
    [asiRequest setShouldContinueWhenAppEntersBackground:YES];
    
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [asiRequest startSynchronous];

        
//        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [asiRequest error];
            if (!error) {
                [self clearImageCache];
                NSString *response = [asiRequest responseString];
                NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
                NSLog(@"RES :%@\nDIC :%@",response, resultsDictionary);
                if([resultsDictionary count]) {
                    NSString *status = [resultsDictionary objectForKey:@"status"];
                    if ([status isEqualToString:@"ok"]) {
                        
                        if ([[self parentViewController] isEqual:[DetailPostViewController class]]) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCommentList" object:nil];
                            
                            NSLog(@"GEt in");
                        }
                        else{
                            if ([typePost isEqualToString:@"postStatus"]) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadWall" object:self];
                            } else {
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadWallPost" object:self];
                            }
                        }
                        
                        
                        [self.navigationController popViewControllerAnimated:YES];
                    } else {
                        [self presentAlert:[resultsDictionary objectForKey:@"message"]];
                    }
                }
                [resultsDictionary release];
            }else{
                NSString *error = [NSString stringWithFormat:@"%@",[asiRequest error]];
                NSLog(@"error: %@",error);
                if (!([error rangeOfString:@"timed out"].location == NSNotFound)) {
                    [self presentAlert:@"Request timed out."];
                }else if (!([error rangeOfString:@"connection failure"].location == NSNotFound)) {
                    [self presentAlert:@"Connection failure occured."];
                }
                else [self presentAlert:@"Connection error."];
            }
            [url release];
            [self.loadingIndicator stopAnimating];
//        });
//    });
}

- (void)presentAlert:(NSString*)msg
{
    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"J-ROOM" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (IBAction)addPhotos:(id)sender
{
    [self.textData resignFirstResponder];
    
    MyPopupView *popup = [[MyPopupView alloc] initWithDataList:optionPhoto andTag:nil];
    popup.delegate = self;
    CGFloat popupYPoint = self.view.frame.size.height/2-popup.frame.size.height/2;
    CGFloat popupXPoint = self.view.frame.size.width/2-popup.frame.size.width/2;
    
    popup.frame = CGRectMake(popupXPoint, popupYPoint, popup.frame.size.width, popup.frame.size.height);
    [self addBlackView];
    [self.view addSubview:popup];
}

- (IBAction)addBuddies:(id)sender
{
    [self.textData resignFirstResponder];
    TagBuddyViewController *createPost = [[TagBuddyViewController alloc] init];
    [self.navigationController pushViewController:createPost animated:YES];
    [createPost release];
}

- (void)dealloc
{
    [_userImageView release];
    [_keyboardAccessoryView release];
    [_sourceImageView release];
    [_topLabel release];
    [_subtitleLabel release];
    [_shareView release];
    [super dealloc];
    [cameraPicker release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setUserImageView:nil];
    [self setKeyboardAccessoryView:nil];
    [self setSourceImageView:nil];
    [self setTopLabel:nil];
    [self setSubtitleLabel:nil];
    [self setShareView:nil];
    [super viewDidUnload];
}
@end
