//
//  ChatViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 4/4/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "ChatViewController.h"
#import "SMMessageViewTableCell.h"
#import "ASIWrapper.h"

#define kBuddyCellHeight 64

@interface ChatViewController ()

@end

@implementation ChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (id)initWithBuddyId:(NSString *)bid andUsername:(NSString *)username
{
    self = [super init];
    if (self) {
        
        FontLabel *titleViewUsingFL = [[FontLabel alloc] initWithFrame:CGRectZero fontName:@"jambu-font.otf" pointSize:22];
        titleViewUsingFL.text = @"J-Buddy";
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
        
        self.buddyUserId = bid;
        self.buddyUsername = username;
    }
    
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

    self.usernameLabel.text = self.buddyUsername;
    tableHeight = 0;
    
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
                                             selector:@selector(updateMessageList)
                                                 name:@"updateMessageList"
                                               object:nil];
    
    self.tableData = [[NSMutableArray alloc] init];
    
//    [self retrieveDataFromAPI];
    [self setupView];
    [self.sendMsgIndicator setHidden:NO];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self retrieveDataFromAPI];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
            [self.sendMsgIndicator setHidden:YES];
        });
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadChatList" object:nil];
}

- (void)retrieveDataFromAPI
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_message_list.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"buddy_user_id\":\"%@\"}",self.buddyUserId];
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    
    if([resultsDictionary count])
    {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        if ([status isEqualToString:@"ok"])
        {
            for (id data in [resultsDictionary objectForKey:@"list"])
            {
                [self.tableData addObject:data];
                
            }
            
        }
        
    }
    
    [resultsDictionary release];
    
}

- (void)setupView
{
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.frame.size.height-196+32+30);
    self.sendMsgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-196, 320, 60)];
    
    [self.sendMsgView setBackgroundColor:[UIColor darkGrayColor]];
    [self.view addSubview:self.sendMsgView];
    
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 13, 232, 26)];
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 2;
	textView.returnKeyType = UIReturnKeyDone;
	textView.font = [UIFont systemFontOfSize:14.0f];
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    [self.sendMsgView addSubview:textView];
    
    UIButton *myBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    myBtn.frame = CGRectMake(250, 13, 60, 30);    //your desired size
    myBtn.clipsToBounds = YES;
    myBtn.layer.cornerRadius = 10.0f;
    [myBtn.layer setBorderWidth:2];
    [myBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    myBtn.backgroundColor = [UIColor colorWithHex:@"#D22042"];
    [myBtn setTitle:@"Send" forState:UIControlStateNormal];
    [myBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [myBtn setTintColor:[UIColor whiteColor]];
    [myBtn addTarget:self action:@selector(handleSendMessage) forControlEvents:UIControlEventTouchUpInside];
    
    [self.sendMsgView addSubview:myBtn];
    
    NSLog(@"table data %d ", [self.tableData count]);
}

#pragma mark -
#pragma mark updae message from nodejs

- (void)updateMessageList
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_message_list.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"buddy_user_id\":\"%@\",\"last_message_id\":\"%d\"}",self.buddyUserId,[[self getLastMessageId] intValue]];
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    
    if([resultsDictionary count])
    {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        if ([status isEqualToString:@"ok"])
        {
            for (id data in [resultsDictionary objectForKey:@"list"])
            {
                [self.tableData addObject:data];
                
            }
            [self.tableView reloadData];
            textView.text = @"";
        }
    }
    
    [resultsDictionary release];
    [self.sendMsgIndicator setHidden:YES];
}


#pragma mark -
#pragma mark Send message handler

- (void)handleSendMessage
{
    // Dont process empty data
    if (![textView.text length]) {
        return;
    }
    
    [self.sendMsgIndicator setHidden:NO];
    [self performSelector:@selector(processSendMsg) withObject:nil afterDelay:0.0];
}

- (void)processSendMsg
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_message_list.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"buddy_user_id\":\"%@\",\"last_message_id\":\"%@\",\"message\":\"%@\"}",self.buddyUserId,[self getLastMessageId], textView.text];
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    
    if([resultsDictionary count])
    {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        if ([status isEqualToString:@"ok"])
        {
            for (id data in [resultsDictionary objectForKey:@"list"])
            {
                [self.tableData addObject:data];
                
            }
            [self.tableView reloadData];
            textView.text = @"";
        }
        else{
            NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"type", @"", @"idate", @"", @"itime", [resultsDictionary objectForKey:@"message"], @"imessage", nil];
            [self.tableData addObject:msg];
            [self.tableView reloadData];
        }
    }
    
    [resultsDictionary release];
    [self.sendMsgIndicator setHidden:YES];
}

- (NSString *)getLastMessageId
{
    return [[self.tableData lastObject] objectForKey:@"message_id"];
}

#pragma mark -
#pragma mark TextView delegate

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [growingTextView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

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
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height)+75;
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	self.view.frame = containerFrame;
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.origin.y = self.tableView.frame.origin.y + keyboardBounds.size.height - self.sendMsgView.frame.size.height - 15;
    tableFrame.size.height = self.tableView.frame.size.height - 140;
    self.tableView.frame = tableFrame;
//    [self.tableView setContentOffset:CGPointMake(self.tableView.frame.size.width,tableHeight)];
	
    NSIndexPath* ip = [NSIndexPath indexPathForRow:[self.tableData count]-1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
	// commit animations
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = self.view.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	self.view.frame = containerFrame;

	self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.view.frame.origin.y, self.tableView.frame.size.width, self.view.frame.size.height-196+32+30);
	// commit animations
	[UIView commitAnimations];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.sendMsgView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.sendMsgView.frame = r;
}

#pragma mark -
#pragma mark TableView delegate

static CGFloat padding = 20.0;
static CGFloat kTailHeight = 5.0f; // to give space for text top padding
static CGFloat kMinCellHeight = 40;

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.usernameView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
    //	NSDictionary *s = (NSDictionary *) [messages objectAtIndex:indexPath.row];
	
	static NSString *CellIdentifier = @"MessageCellIdentifier";
	
	SMMessageViewTableCell *cell = (SMMessageViewTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[[SMMessageViewTableCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:CellIdentifier] autorelease];
	}
    
    NSDictionary *conversation = [self.tableData objectAtIndex:indexPath.row];
    
    NSString *sender = [conversation valueForKey:@"type"];
	NSString *date = [conversation valueForKey:@"idate"]; 
	NSString *message = [conversation valueForKey:@"imessage"]; 
	NSString *time = [conversation valueForKey:@"itime"];
	
	CGSize  textSize = { 205.0, 10000.0 };
	CGSize size = [message sizeWithFont:[UIFont boldSystemFontOfSize:13]
					  constrainedToSize:textSize
						  lineBreakMode:UILineBreakModeWordWrap];
	
	size.width += (padding/2);
	
	cell.messageContentView.text = message;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.userInteractionEnabled = NO;
	
    
	UIImage *bgImage = nil;

	if ([sender intValue] == 1) { // left aligned
        cell.senderAndTimeLabel.textAlignment = UITextAlignmentLeft;
        cell.senderAndTimeLabel.frame = CGRectMake(240, 10, 70, 28);
		bgImage = [[UIImage imageNamed:@"pink_conversation"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
		
		[cell.messageContentView setFrame:CGRectMake(padding, padding/2+kTailHeight, textSize.width, size.height)];
		
		[cell.bgImageView setFrame:CGRectMake( cell.messageContentView.frame.origin.x - padding/2,
											  cell.messageContentView.frame.origin.y - padding/2-kTailHeight,
											  textSize.width+padding,
											  size.height+padding)];
        
	} else {
        cell.senderAndTimeLabel.textAlignment = UITextAlignmentRight;
        cell.senderAndTimeLabel.frame = CGRectMake(10, 0, 70, 28);
		bgImage = [[UIImage imageNamed:@"gray_conversation"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
		
		[cell.messageContentView setFrame:CGRectMake(320 - textSize.width - padding,
													 padding/2-kTailHeight,
													 textSize.width,
													 size.height)];
		
		[cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2,
											  cell.messageContentView.frame.origin.y - padding/2+kTailHeight,
											  textSize.width+padding,
											  size.height+padding)];
		
	}
	
    
    if ([message isEqualToString:@"Request timed out."] || [message isEqualToString:@"Connection failure occured."]) {
        // Not yet error handling
    }
	cell.bgImageView.image = bgImage;
	cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@\n%@", time,date];
    
	return cell;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	NSDictionary *dict = (NSDictionary *)[self.tableData objectAtIndex:indexPath.row];
	NSString *msg = [dict objectForKey:@"imessage"];
	
	CGSize  textSize = { 205.0, 10000.0 };
	CGSize size = [msg sizeWithFont:[UIFont boldSystemFontOfSize:13]
				  constrainedToSize:textSize
					  lineBreakMode:UILineBreakModeWordWrap];
	
	size.height += padding*2;
	
	CGFloat height = size.height < kMinCellHeight ? kMinCellHeight : size.height;
    
    tableHeight += height;
    
    // Set tableview to last row
    if (indexPath.row == [self.tableData count]-1) {
        [self.tableView setContentOffset:CGPointMake(tableView.frame.size.width,tableHeight)];
    }
    
	return height;
	
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return [self.tableData count];
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
	
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_chatTextField release];
    [_tableView release];
    [_sendMsgView release];
    [_usernameLabel release];
    [_usernameView release];
    [_sendMsgIndicator release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setChatTextField:nil];
    [self setTableView:nil];
    [self setSendMsgView:nil];
    [self setUsernameLabel:nil];
    [self setUsernameView:nil];
    [self setSendMsgIndicator:nil];
    [super viewDidUnload];
}
@end
