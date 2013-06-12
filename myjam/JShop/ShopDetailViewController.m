//
//  ShopDetailViewController.m
//  myjam
//
//  Created by M Ridhwan M Sari on 5/28/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "ShopDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ProductShopViewController.h"
#import "DescriptionCell.h"
#import "ASIWrapper.h"

@interface ShopDetailViewController ()

@end

@implementation ShopDetailViewController

//@synthesize dataInfo;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"JAM-BU Shop";
        FontLabel *titleView = [[FontLabel alloc] initWithFrame:CGRectZero fontName:@"jambu-font.otf" pointSize:22];
        titleView.text = self.title;
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.backgroundColor = [UIColor clearColor];
        titleView.textColor = [UIColor whiteColor];
        [titleView sizeToFit];
        self.navigationItem.titleView = titleView;
        [titleView release];
        // Custom initialization
        
        self.navigationItem.backBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                          style:UIBarButtonItemStyleBordered
                                         target:nil
                                         action:nil] autorelease];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataInfo = [[NSDictionary alloc] init];
    [self setData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)retrieveDataFromAPI
{    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/shop_details_v2.php?token=%@",APP_API_URL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]mutableCopy]];
    NSString *dataContent = [NSString stringWithFormat:@"{\"shop_id\":\"%@\"}",self.shopID];
    
    NSString *response = [ASIWrapper requestPostJSONWithStringURL:urlString andDataContent:dataContent];
    NSLog(@"request %@\n%@\n\nresponse data: %@", urlString, dataContent, response);
    NSDictionary *resultsDictionary = [[response objectFromJSONString] copy];
    
    if([resultsDictionary count]) {
        NSString *status = [resultsDictionary objectForKey:@"status"];
        if ([status isEqualToString:@"ok"]) {
            self.dataInfo = [resultsDictionary objectForKey:@"list"];
        }
    }
    [resultsDictionary release];
}

- (void)setData
{
    expandedRowIndex = -1;
    //dataInfo = [[NSDictionary alloc] init];
    headerName = [[NSArray alloc] initWithObjects:@"",@"",@"CONTACT",@"TERMS & POLICY",@"PROMOTIONS",@"PRODUCTS",@"SHARE SHOP", nil];
    [self retrieveDataFromAPI];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [headerName count] + (expandedRowIndex != -1 ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger dataIndex = [self dataIndexForRowIndex:row];
    NSString *dataObject = [headerName objectAtIndex:dataIndex];
    
    if(dataIndex == 0){
        DescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DescriptionCell" owner:nil options:nil];
            cell = [nib objectAtIndex:0];
        }
        [self cellInfo:cell];
        return cell;
    } else if(dataIndex == 1){
        DescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReadMoreCell"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DescriptionCell" owner:nil options:nil];
            cell = [nib objectAtIndex:1];
        }
        return cell;
    } else {
        BOOL expandedCell = expandedRowIndex != -1 && expandedRowIndex + 1 == row;
        if (!expandedCell)
        {
//            DescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderRowCell"];
//            if (!cell) {
//               NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DescriptionCell" owner:nil options:nil];
//                cell = [nib objectAtIndex:2];
//            }
//            [cell.headerRowLabel setText:dataObject];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"data"];
            if (!cell)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"data"];
            cell.textLabel.text = dataObject;
            cell.contentView.backgroundColor = [UIColor colorWithHex:@"#D61C44"];
            return cell;
        } else {
            if(dataIndex==2 || dataIndex==3) {
                DescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RowCell"];
                if (cell == nil) {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DescriptionCell" owner:nil options:nil];
                    cell = [nib objectAtIndex:3];
                }
                if (dataIndex == 2) {
                    [cell.rowInfoTextView setFrame:newCFrame];
                    [cell.rowInfoTextView setText:[[self.dataInfo objectForKey:@"shop_contact_ios"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"]];
                } else {
                    [cell.rowInfoTextView setFrame:newCFrame];
                    [cell.rowInfoTextView setText:[self.dataInfo objectForKey:@"shop_terms_policy"]];
                }
                return cell;
            } else if(dataIndex == 4){
                DescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PromotionCell"];
                if (cell == nil) {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DescriptionCell" owner:nil options:nil];
                    cell = [nib objectAtIndex:4];
                }
                [self cellPromotion:cell];
                return cell;
            } else if(dataIndex == 5){
                DescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductCell"];
                if (cell == nil) {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DescriptionCell" owner:nil options:nil];
                    cell = [nib objectAtIndex:5];
                }
                [self cellProduct:cell];
                return cell;
            } else {
                DescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShareCell"];
                if (cell == nil) {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DescriptionCell" owner:nil options:nil];
                    cell = [nib objectAtIndex:6];
                }
                // Setup share button in shareVIew
                [cell.shareFBButton addTarget:self action:@selector(shareImageOnFB) forControlEvents:UIControlEventTouchUpInside];
                [cell.shareTwitterButton addTarget:self action:@selector(shareImageOnTwitter) forControlEvents:UIControlEventTouchUpInside];
                [cell.shareEmailButton addTarget:self action:@selector(shareImageOnEmail) forControlEvents:UIControlEventTouchUpInside];
                //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"expanded"];
                //if (!cell)
                    //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"expanded"];
                //cell.textLabel.text = dataObject;
                //cell.detailTextLabel.text = [NSString stringWithFormat:@"Details for cell that is '%d'", dataIndex];
                return cell;
            }
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    BOOL preventReopen = NO;
    
    if (row == expandedRowIndex + 1 && expandedRowIndex != -1)
        return nil;
    
    [tableView beginUpdates];
    if (row == 0) {
        if (!openDesc) openDesc = NO; else openDesc = YES;
    } else if (row == 1) {
        if (!openDesc) {
            openDesc = YES;
            if (expandedRowIndex != -1) {
                NSInteger rowToRemove = expandedRowIndex + 1;
                preventReopen = row == expandedRowIndex;
                if (row > expandedRowIndex)
                    row--;
                expandedRowIndex = -1;
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:rowToRemove inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            }
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            NSLog(@"buka");
        } else {
            openDesc = NO;
            NSLog(@"tutup");
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } else {
        if (expandedRowIndex != -1) {
            NSInteger rowToRemove = expandedRowIndex + 1;
            preventReopen = row == expandedRowIndex;
            if (row > expandedRowIndex)
                row--;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.contentView.backgroundColor = [UIColor colorWithHex:@"#D61C44"];
//            NSIndexPath *ip = [NSIndexPath indexPathForRow:expandedRowIndex inSection:0];
//            DescriptionCell *cell = (DescriptionCell *)[self.tableView cellForRowAtIndexPath:ip];
//            [cell.colorHeaderRow setBackgroundColor:[UIColor colorWithHex:@"#D61C44"]];
            NSLog(@"delete row %d on %d of expended %d",rowToRemove,row, expandedRowIndex);
            expandedRowIndex = -1;
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:rowToRemove inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            
        }
        NSInteger rowToAdd = -1;
        if (!preventReopen) {
            rowToAdd = row + 1;
            expandedRowIndex = row;
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:rowToAdd inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.contentView.backgroundColor = [UIColor lightGrayColor];
//            NSIndexPath *ip = [NSIndexPath indexPathForRow:expandedRowIndex inSection:0];
//            DescriptionCell *cell = (DescriptionCell *)[self.tableView cellForRowAtIndexPath:ip];
//            [cell.colorHeaderRow setBackgroundColor:[UIColor lightGrayColor]];
            NSLog(@"open row %d on %d of expended %d",rowToAdd,row,expandedRowIndex);
        }
        if (openDesc == YES) {
            openDesc = NO;
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    [tableView endUpdates];
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row]; 
    NSInteger dataIndex = [self dataIndexForRowIndex:row];
    NSLog(@"rowHeight :%d",row);
    if (dataIndex==0) {
        return (!openDesc ? 225 : 225+descHeight);
    } else if (dataIndex==1) {
        return 35;
    } else {
        if (expandedRowIndex != -1 && row == expandedRowIndex + 1) {
            if (dataIndex==2 || dataIndex==3) {
                DescriptionCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"RowCell"];
                if (cell == nil) {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DescriptionCell" owner:nil options:nil];
                    cell = [nib objectAtIndex:3];
                }
                if (dataIndex==2) {
                    CGSize expectedConSize  = [[[self.dataInfo objectForKey:@"shop_contact_ios"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0] constrainedToSize:CGSizeMake(cell.rowInfoTextView.frame.size.width, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
                    newCFrame = cell.rowInfoTextView.frame;
                    newCFrame.size.height = expectedConSize.height;
                    CGFloat contactHeight = (expectedConSize.height>30 ? expectedConSize.height-10 : 0);
                    return 30+contactHeight;
                } else {
                    CGSize expectedConSize  = [[self.dataInfo valueForKey:@"shop_terms_policy"] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15.0] constrainedToSize:CGSizeMake(cell.rowInfoTextView.frame.size.width, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
                    newCFrame = cell.rowInfoTextView.frame;
                    newCFrame.size.height = expectedConSize.height;
                    CGFloat contactHeight = (expectedConSize.height>30 ? expectedConSize.height-10 : 0);
                    return 30+contactHeight;
                }
                
            }  else if (dataIndex==4 || dataIndex==5) {
                return  250;
            }
            else return 70;
        }        
        return 35;
    }
}

- (NSInteger)dataIndexForRowIndex:(NSInteger)row
{
    if (expandedRowIndex != -1 && expandedRowIndex <= row) {
        if (expandedRowIndex == row)
            return row;
        else
            return row - 1;
    } else
        return row;
}

- (void)cellInfo:(DescriptionCell *)cell
{
    [cell.shopLabel setText:[self.dataInfo objectForKey:@"shop_name"]];
    [cell.catLabel setText:[self.dataInfo objectForKey:@"shop_category"]];
    [cell.shopLogo setImageWithURL:[NSURL URLWithString:[self.dataInfo objectForKey:@"shop_logo"]] placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
    CGSize expectedLabelSize  = [[self.dataInfo valueForKey:@"shop_description"] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0] constrainedToSize:CGSizeMake(cell.descLabel.frame.size.width, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    CGRect newFrame = cell.descLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    descHeight = (expectedLabelSize.height>55 ? expectedLabelSize.height-55 : 0);
    if (openDesc) {
        NSLog(@"here");
        [cell.descLabel setFrame:newFrame];
        [cell.descLabel setText:[self.dataInfo objectForKey:@"shop_description"]];
    } else {
        [cell.descLabel setFrame:CGRectMake(10, 168, 300, 55)];
        [cell.descLabel setText:[self.dataInfo objectForKey:@"shop_description"]];
    }
}

- (void)cellPromotion:(DescriptionCell *)cell
{
    [cell.shopPLabel1 setText:[self.dataInfo objectForKey:@"shop_name"]];
    [cell.shopPLabel2 setText:[self.dataInfo objectForKey:@"shop_name"]];
    [cell.titlePLabel1 setText:[[[self.dataInfo objectForKey:@"shop_promotion"] objectAtIndex:0] objectForKey:@"product_name"]];
    [cell.titlePLabel2 setText:[[[self.dataInfo objectForKey:@"shop_promotion"] objectAtIndex:1] objectForKey:@"product_name"]];
    [cell.datePLabel1 setText:[[[self.dataInfo objectForKey:@"shop_promotion"] objectAtIndex:0] objectForKey:@"create_date"]];
    [cell.datePLabel2 setText:[[[self.dataInfo objectForKey:@"shop_promotion"] objectAtIndex:1] objectForKey:@"create_date"]];
    [cell.descPLabel1 setText:[[[self.dataInfo objectForKey:@"shop_promotion"] objectAtIndex:0] objectForKey:@"product_description"]];
    [cell.descPLabel2 setText:[[[self.dataInfo objectForKey:@"shop_promotion"] objectAtIndex:1] objectForKey:@"product_description"]];
    [cell.catPLabel1 setText:[[[self.dataInfo objectForKey:@"shop_promotion"] objectAtIndex:0] objectForKey:@"category_name"]];
    [cell.catPLabel2 setText:[[[self.dataInfo objectForKey:@"shop_promotion"] objectAtIndex:1] objectForKey:@"category_name"]];
    [cell.colorLabel1 setBackgroundColor:[UIColor colorWithHex:[[[self.dataInfo objectForKey:@"shop_promotion"] objectAtIndex:0] objectForKey:@"product_color"]]];
    [cell.colorLabel2 setBackgroundColor:[UIColor colorWithHex:[[[self.dataInfo objectForKey:@"shop_promotion"] objectAtIndex:1] objectForKey:@"product_color"]]];
    [cell.pImage1 setImageWithURL:[NSURL URLWithString:[[[self.dataInfo objectForKey:@"shop_promotion"] objectAtIndex:0] objectForKey:@"product_image"]] placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
    [cell.pImage2 setImageWithURL:[NSURL URLWithString:[[[self.dataInfo objectForKey:@"shop_promotion"] objectAtIndex:1] objectForKey:@"product_image"]] placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
}

- (void)cellProduct:(DescriptionCell *)cell
{
    [cell.productImage1 setImageWithURL:[NSURL URLWithString:[[[self.dataInfo objectForKey:@"shop_products"] objectAtIndex:0] objectForKey:@"product_image"]] placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
    [cell.productImage2 setImageWithURL:[NSURL URLWithString:[[[self.dataInfo objectForKey:@"shop_products"] objectAtIndex:1] objectForKey:@"product_image"]] placeholderImage:[UIImage imageNamed:@"default_icon.png"]];
    [cell.proLabel1 setText:[[[self.dataInfo objectForKey:@"shop_products"] objectAtIndex:0] objectForKey:@"product_name"]];
    [cell.proLabel2 setText:[[[self.dataInfo objectForKey:@"shop_products"] objectAtIndex:1] objectForKey:@"product_name"]];
    [cell.shopLabel1 setText:[self.dataInfo objectForKey:@"shop_name"]];
    [cell.shopLabel2 setText:[self.dataInfo objectForKey:@"shop_name"]];
    [cell.visitShopButton setTag:[[self.dataInfo objectForKey:@"shop_id"] intValue]];
    [cell.visitShopButton addTarget:self action:@selector(visitShop:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)visitShop:(id)sender {
    NSLog(@"SHOP_ID :%d", [sender tag]);
    //[self performSelector:@selector(gotoVisitShop:) withObject:sender afterDelay:0.1];
    [self gotoVisitShop:sender];
}
- (void)gotoVisitShop:(id)sender {
    ProductShopViewController *gotoShop = [[ProductShopViewController alloc] init];
    //detailViewController.catAllArray = [[NSMutableArray alloc] initWithArray:[[MJModel sharedInstance] getFullListOfShopsFor:[[_tableData objectAtIndex:[sender tag] ]valueForKey:@"category_id"] andPage:@"1"]];
    AppDelegate *mydelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [mydelegate.shopNavController pushViewController:gotoShop animated:YES];
    [gotoShop release];
}

- (void)shareImageOnFB { NSLog(@"Share FB");}
- (void)shareImageOnTwitter { NSLog(@"Share Twitter");}
- (void)shareImageOnEmail { NSLog(@"Share Email");}

- (void)dealloc
{
    [self.tableView release];
    [headerName release];
    [_dataInfo release];
    [super dealloc];
}

@end
