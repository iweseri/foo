//
//  CreatePostViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 5/13/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "CreatePostViewController.h"
#import "TagBuddyViewController.h"
#import "ASIFormDataRequest.h"
#import "AppDelegate.h"

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
    }
    return self;
}

// push from JWallViewController
- (id)initWithPlaceholderText:(NSString*)holderText andWithLabel:(NSString*)type
{
    self = [super initWithNibName:@"CreatePostViewController" bundle:nil];
    if (self) {
        placeHolderText = holderText;
        textType = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    optionPhoto = [[NSArray alloc] initWithObjects:@"Choose from Gallery", @"Capture a photo", @"Cancel", nil];
    
    self.content = (TPKeyboardAvoidingScrollView *)self.view;
    [self.content setContentSize:CGSizeMake(self.view.frame.size.width, 416)];
    
    // Keyboard stuffings
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadView:)
                                                 name:@"reloadPostView"
                                               object:nil];
    
    cameraPicker = [[UIImagePickerController alloc] init];
    cameraPicker.delegate = self;
    
    [self setupView];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"CP-vda");
}

- (void)setupView
{
    self.postView.frame = CGRectMake(0, self.view.frame.size.height-157, 320, 40);
    
    self.textData.delegate = self;
    self.textData.text = placeHolderText;
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
    if ([self.textData.text isEqual:placeHolderText]) {
        [self.textData setText:@""];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.textData.text length]==0) {
        self.textData.text = @"What's on your mind?";
    }
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
#pragma mark keyboardSetup
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
	CGRect containerFrame = self.view.frame;
    containerFrame.origin.y = -kContentSize-kTagSize;
    self.view.frame = containerFrame;
    
//    self.content = (TPKeyboardAvoidingScrollView *)self.view;
//    [self.content setContentSize:CGSizeMake(self.view.frame.size.width, 460)];
//    CGPoint bottomOffset = CGPointMake(0, 650);
//    [self.content setContentOffset:bottomOffset animated:YES];
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set postView up
	self.postView.frame = CGRectMake(0, self.postView.frame.origin.y-143+kContentSize+kTagSize, 320, 40);
    
	// commit animations
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
	CGRect containerFrame = self.view.frame;
    containerFrame.origin.y = 0;
    self.view.frame = containerFrame;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set postView down
    self.postView.frame = CGRectMake(0, self.postView.frame.origin.y+143-kContentSize-kTagSize, 320, 40);
    
	// commit animations
	[UIView commitAnimations];
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
    NSString *type = @"DEFAULT";
    if ([self.textData.text isEqualToString:placeHolderText]) {
        self.textData.text = @"";
    }
    if (self.uploadImage == nil && [self.textData.text isEqual: @""] && self.tagId == nil) {
        NSLog(@"No data,cannot post.");
        self.textData.text = placeHolderText;
    }
    if ([self.textData.text isEqual: @""]) {
        NSLog(@"Status is required.");
    }else {
        if (self.uploadImage != nil) {
            type = @"PHOTO";
        }
        NSLog(@"\nText :%@\nImage :%@\nTag :%@",self.textData.text,self.uploadImage,self.tagId);
        [self.loadingIndicator startAnimating];
        [self performSelector:@selector(processPostToAPI:) withObject:type afterDelay:0.1f];
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
    NSData *imgData = UIImageJPEGRepresentation(self.uploadImage.image, 70);
    NSString *urlString = [NSString stringWithFormat:@"%@/api/wall_post.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    ASIFormDataRequest *asiRequest = [ASIFormDataRequest requestWithURL:url];
    [asiRequest addRequestHeader:@"Accept" value:@"application/json"];
    [asiRequest addRequestHeader:@"Content-Type" value:@"application/json"];
    [asiRequest addPostValue:self.textData.text forKey:@"post_text"];
    [asiRequest addPostValue:self.tagId forKey:@"post_tagged_user_ids"];
    [asiRequest addPostValue:typePost forKey:@"post_type"];
    [asiRequest addData:imgData withFileName:@"currImage.jpg" andContentType:@"image/jpeg" forKey:@"image"];
    [asiRequest setTimeOutSeconds:20];
    [asiRequest setShouldContinueWhenAppEntersBackground:YES];
    [asiRequest startSynchronous];
    NSError *error = [asiRequest error];
    if (!error) {
        [self clearImageCache];
        NSString *response = [asiRequest responseString];
        NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
        NSLog(@"RES :%@\nDIC :%@",response,resultsDictionary);
        if([resultsDictionary count]) {
            NSString *status = [resultsDictionary objectForKey:@"status"];
            if ([status isEqualToString:@"ok"]) {
                [self presentAlert:[resultsDictionary objectForKey:@"message"]];
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
}

- (void)presentAlert:(NSString*)msg
{
    CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"J-BUDDY" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (IBAction)addPhotos:(id)sender
{
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
    [super dealloc];
    [cameraPicker release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
