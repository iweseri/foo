//
//  GroupChatViewController.m
//  myjam
//
//  Created by Mohd Hafiz on 4/4/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "GroupChatViewController.h"
#import "SMMessageViewTableCell.h"
#import "AddBuddyGroupViewController.h"
#import "AppDelegate.h"
#import "ASIWrapper.h"

#define kBuddyCellHeight 64

@interface GroupChatViewController ()

@end

@implementation GroupChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithGroupId:(NSString *)gid andGroupname:(NSString *)groupname
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
        self.buddyGroupId = gid;
        self.buddyGroupname = groupname;
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

    self.usernameLabel.text = self.buddyGroupname;
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
                                             selector:@selector(updateGroupMessageList)
                                                 name:@"updateGroupMessageList"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSubjectName:)
                                                 name:@"updateSubjectName"
                                               object:nil];
    
    self.tableData = [[NSMutableArray alloc] init];
    [self setupView];
   
    [self.sendMsgIndicator startAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self retrieveDataFromAPI];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
            [self.sendMsgIndicator stopAnimating];
        });
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadChatList" object:nil];
}

- (void)updateSubjectName:(NSNotification *)name {
    [self.usernameLabel setText:[name object]];
    NSLog(@"SUBJEK :%@",[name object]);
}

- (void)retrieveDataFromAPI
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_group_message.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"group_id\":\"%@\",\"action\":\"\"}",self.buddyGroupId];
    
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
#pragma mark update message from nodejs

- (void)updateGroupMessageList
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_group_message.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"group_id\":\"%@\",\"last_message_id\":\"%d\",\"action\":\"get_new\"}",self.buddyGroupId,[[self getLastMessageId] intValue]];
    
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
    
    [self.sendMsgIndicator stopAnimating];
}

#pragma mark -
#pragma mark Send message handler

- (void)handleSendMessage
{
    // Dont process empty data
    if (![textView.text length]) {
        return;
    }
    [self.sendMsgIndicator startAnimating];
    [self performSelector:@selector(processSendMsg) withObject:nil afterDelay:0.0];
}

- (void)processSendMsg
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/buddy_group_message.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"group_id\":\"%@\",\"message\":\"%@\",\"action\":\"send\"}",self.buddyGroupId, textView.text];
    
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
            NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"message_type", @"", @"idate", @"", @"datetime", [resultsDictionary objectForKey:@"message"], @"message", nil];
            [self.tableData addObject:msg];
            [self.tableView reloadData];
        }
    }
    
    [resultsDictionary release];
    [self.sendMsgIndicator stopAnimating];
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
    return 30;
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
    
    NSString *sender = [conversation valueForKey:@"message_type"];
	NSString *username = [conversation valueForKey:@"username"];
	NSString *message = [conversation valueForKey:@"message"];
	NSString *time = [conversation valueForKey:@"datetime"];
	
    CGSize  textSize = {0,0};
    if([sender intValue] == 1) {
        textSize = CGSizeMake(255.0, 10000.0);
    } else {
        textSize = CGSizeMake(205.0, 10000.0);
    }
	CGSize size = [message sizeWithFont:[UIFont boldSystemFontOfSize:13]
					  constrainedToSize:textSize
						  lineBreakMode:UILineBreakModeWordWrap];
	size.width += (padding/2);
    
	[cell.senderAndTimeLabel setHidden:NO];
    [cell.messageContentView setHidden:NO];
    [cell.dateDesc setHidden:YES];
    [cell.notifyDesc setHidden:YES];
    
	cell.messageContentView.text = message;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.userInteractionEnabled = NO;
	UIImage *bgImage = nil;

	if([sender intValue] == 1) { //display notification
        [cell.senderAndTimeLabel setHidden:YES];
        [cell.messageContentView setHidden:YES];
        [cell.notifyDesc setHidden:NO];
        [cell.notifyDesc setText:message];
        [cell.notifyDesc setFrame:CGRectMake(10, 2, textSize.width+50, size.height)];
    }
    else if([sender intValue] == 2) { //display date
        [cell.senderAndTimeLabel setHidden:YES];
        [cell.messageContentView setHidden:YES];
        [cell.dateDesc setHidden:NO];
        [cell.dateDesc setText:message];
        [cell.dateDesc setFrame:CGRectMake((320-(textSize.width+50))/2, kTailHeight, textSize.width+50, size.height)];
    }
    else if([sender intValue] == 3) { //display your chat (right aligned)
        username = @"Me";
        cell.senderAndTimeLabel.textAlignment = UITextAlignmentRight;
        cell.senderAndTimeLabel.frame = CGRectMake(10, 0+10, 70, 28);
		bgImage = [[UIImage imageNamed:@"gray_conversation"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
		
		[cell.messageContentView setFrame:CGRectMake(320 - textSize.width - padding,
													 padding-kTailHeight,
													 textSize.width,
													 size.height)];
		
		[cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2,
											  cell.messageContentView.frame.origin.y - padding/2+kTailHeight,
											  textSize.width+padding,
											  size.height+padding)];
        
	} else { //display your buddy (left aligned)
        cell.senderAndTimeLabel.textAlignment = UITextAlignmentLeft;
        cell.senderAndTimeLabel.frame = CGRectMake(240, 10+8, 70, 28);
		bgImage = [[UIImage imageNamed:@"green_conversation"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
        
		[cell.messageContentView setFrame:CGRectMake(padding, (padding+kTailHeight), textSize.width, size.height)];
		
		[cell.bgImageView setFrame:CGRectMake( cell.messageContentView.frame.origin.x - padding/2,
											  cell.messageContentView.frame.origin.y - padding/2-kTailHeight,
											  textSize.width+padding,
											  size.height+padding)];
        NSLog(@"SIZE:%f|%f",size.height,cell.messageContentView.frame.origin.y);
	}
    if ([message isEqualToString:@"Request timed out."] || [message isEqualToString:@"Connection failure occured."]) {
        // Not yet error handling
    }
	cell.bgImageView.image = bgImage;
	cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@\n@ %@",username,time];
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *dict = (NSDictionary *)[self.tableData objectAtIndex:indexPath.row];
	NSString *msg = [dict objectForKey:@"message"];
	CGSize  textSize = { 205.0, 10000.0 };
	CGSize size = [msg sizeWithFont:[UIFont boldSystemFontOfSize:13]
				  constrainedToSize:textSize
					  lineBreakMode:UILineBreakModeWordWrap];
	
	size.height += padding*2;
	CGFloat height = size.height < kMinCellHeight ? kMinCellHeight : size.height;
    tableHeight += height;
    
    if ([[dict objectForKey:@"message_type"]intValue] == 1) {
        height = 20; //height for notification
    } else if ([[dict objectForKey:@"message_type"]intValue] == 2) {
        height = 26; //height for displaying date
    }
    
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

- (IBAction)editGroup:(id)sender {
    AddBuddyGroupViewController *newChat = [[AddBuddyGroupViewController alloc] initWithGroupId:self.buddyGroupId andGroupname:self.buddyGroupname];
    AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [mydelegate.buddyNavController pushViewController:newChat animated:YES];
    [newChat release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
