//
//  ShareCell.m
//  myjam
//
//  Created by Mohd Hafiz on 6/7/13.
//  Copyright (c) 2013 me-tech. All rights reserved.
//

#import "ShareCell.h"

@implementation ShareCell

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ShareCell" owner:nil options:nil];
        self = [nib objectAtIndex:0];
    }
    
    postLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    postLabel.font = [UIFont systemFontOfSize:13];
    postLabel.backgroundColor = [UIColor clearColor];
    postLabel.numberOfLines = 3;
    
    timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    postTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    return self;
}

- (void)setupCell:(NSDictionary *)data
{
    [avatar setImageWithURL:[NSURL URLWithString:[data objectForKey:@"avatar_url"]]
                     placeholderImage:[UIImage imageNamed:@"blank_avatar"]
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                if (!error) {
                                    
                                }else{
                                    NSLog(@"error retrieve image: %@",error);
                                }
                                
                            }];
    
    
    postLabel.frame = CGRectMake(78, 20, 200, 48);
    
    NSMutableString *fullText = [NSMutableString stringWithFormat:@"%@ ",[data objectForKey:@"user_name"]];
    if ([[data objectForKey:@"post_type"] isEqualToString:@"DEFAULT"]) {
        [fullText appendString:@"says"];
    }
    else{
        [fullText appendString:@"shared a photo"];
    }
    
    [self setBoldText:[data objectForKey:@"user_name"] withFullText:fullText boldPostfix:@"" andTime:[data objectForKey:@"datetime"]];
    
    postTextLabel.frame = CGRectMake(20, 68 + 10, 280, 21);
    [postTextLabel setFont:[UIFont systemFontOfSize:12]];
    [postTextLabel setBackgroundColor:[UIColor clearColor]];
    [postTextLabel setText:[data objectForKey:@"post_text"]];
    postTextLabel.numberOfLines = 3;
    [postTextLabel sizeToFit];
    
    [self addSubview:postLabel];
    [self addSubview:timeLabel];
    [self addSubview:postTextLabel];
    
    // resize inner view and add border
    innerView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    innerView.layer.borderWidth = 1.0f;
    innerView.frame = CGRectMake(0, 10, 300, 48 + postTextLabel.frame.size.height + 21 + 10);
    
    if ([[data objectForKey:@"post_type"] isEqualToString:@"PHOTO"])
    {
        [postImageView setHidden:NO];
        [self setupPostImage:[data objectForKey:@"post_photo"]];
        postImageView.frame = CGRectMake(20, innerView.frame.size.height + 10, postImageView.frame.size.width, postImageView.frame.size.height);
        [self addSubview:postImageView];
        
        innerView.frame = CGRectMake(0, 10, 300, innerView.frame.size.height + postImageView.frame.size.height + 10);
//        [postImageView release];
    }else{
        [postImageView setHidden:YES];
    }

}

- (void)setupPostImage:(NSString *)imgURL
{
    [postImageView setImageWithURL:[NSURL URLWithString:imgURL]
           placeholderImage:[UIImage imageNamed:@"default_icon"]
                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                      if (!error) {
                          
                      }else{
                          NSLog(@"error retrieve image: %@",error);
                      }
                      
                  }];
}

-(void)setBoldText:(NSString *)prefix withFullText:(NSString *)text boldPostfix:(NSString *)postfix andTime:(NSString *)timeText{
    
    [postLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:prefix options:NSCaseInsensitiveSearch];
        
        UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:14];
        CTFontRef font = CTFontCreateWithName((CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)font range:boldRange];
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor colorWithHex:@"#D22042"].CGColor range:boldRange];
            
            
            CFRelease(font);
        }
        
        return mutableAttributedString;
    }];
    
    
    [postLabel sizeToFit];
    
    timeLabel.frame = CGRectMake(78, postLabel.frame.origin.y + postLabel.frame.size.height+2, 160, 21);
    [timeLabel setTextColor:[UIColor darkGrayColor]];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setFont:[UIFont systemFontOfSize:10]];
    [timeLabel setText:timeText];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
