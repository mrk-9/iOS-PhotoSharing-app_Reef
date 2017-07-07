//
//  SearchUserCell.m
//  reef
//
//  Created by iOSDevStar on 8/5/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "SearchUserCell.h"
#import "Global.h"

@implementation SearchUserCell

- (void)awakeFromNib {
    // Initialization code
    self.m_imageView.layer.cornerRadius = self.m_imageView.frame.size.height / 2.f;
    self.m_imageView.layer.borderColor = GREEN_COLOR.CGColor;
    self.m_imageView.layer.borderWidth = 0.f;
    self.m_imageView.clipsToBounds = YES;
    
    self.m_btnFollow.layer.cornerRadius = 3.f;
    self.m_btnFollow.layer.borderColor = DARK_GRAY_COLOR.CGColor;
    self.m_btnFollow.layer.borderWidth = 1.f;
    self.m_btnFollow.clipsToBounds = YES;
    
    self.m_bInvitationMode = false;
    
    self.m_btnFollow.enabled = YES;
    
    self.m_viewLoading.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)actionFollow:(id)sender {
    if (self.m_bUserMode)
    {
        if ([[self.m_dictUserInfo valueForKey:@"is_following"] isEqualToString:@"0"])
            [self.delegate actionFollowUser:self withIndex:self.m_nIndex];
        else
            [self.delegate actionUnFollowUser:self withIndex:self.m_nIndex];
    }
    else
    {
        NSString* strAddress = @"";
        if (self.m_bInvitationMode)
            strAddress = [self.m_dictUserInfo valueForKey:@"email"];
        else
            strAddress = [self.m_dictUserInfo valueForKey:@"phone"];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendInviation:withMode:withAddress:)])
            [self.delegate sendInviation:self withMode:self.m_bInvitationMode withAddress:strAddress];
    }
}

- (void) changeColorOfButton:(UIColor *)clrButton
{
    self.m_btnFollow.layer.cornerRadius = 3.f;
    self.m_btnFollow.layer.borderColor = clrButton.CGColor;
    self.m_btnFollow.layer.borderWidth = 1.f;
    self.m_btnFollow.clipsToBounds = YES;
    
    [self.m_btnFollow setTitleColor:clrButton forState:UIControlStateNormal];
}

- (void) checkUserWhetherExistsInApp
{
    self.m_viewLoading.hidden = NO;
    
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];
    
    
    NSString* strSearchMode = @"";
    NSString* strKeyword = @"";
    
    if (((NSString *)[self.m_dictUserInfo valueForKey:@"email"]).length != 0)
    {
        self.m_bInvitationMode = true;
        strSearchMode = @"email";
        strKeyword = [self.m_dictUserInfo valueForKey:@"email"];
    }
    else
    {
        self.m_bInvitationMode = false;

        strSearchMode = @"phone";
        strKeyword = [self.m_dictUserInfo valueForKey:@"phone"];
        strKeyword = [strKeyword stringByReplacingOccurrencesOfString:@"(" withString:@""];
        strKeyword = [strKeyword stringByReplacingOccurrencesOfString:@")" withString:@""];
        strKeyword = [strKeyword stringByReplacingOccurrencesOfString:@"-" withString:@""];
        strKeyword = [strKeyword stringByReplacingOccurrencesOfString:@" " withString:@""];
        strKeyword = [NSString stringWithFormat:@"+%@", strKeyword];
    }
    
    NSDictionary *params = @ {@"search_mode":strSearchMode, @"keyword":strKeyword};
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"account/check_userexists"];
    
    [manager POST: strRequestLink
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);

              self.m_viewLoading.hidden = YES;
              
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  [self changeColorOfButton:NAVI_COLOR];
                  [self.m_btnFollow setTitle:@"Joined" forState:UIControlStateNormal];
                  self.m_btnFollow.enabled = NO;
              }
              else
              {
                  [self changeColorOfButton:DARK_GRAY_COLOR];
                  [self.m_btnFollow setTitle:@"Invite" forState:UIControlStateNormal];
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              
              [self changeColorOfButton:DARK_GRAY_COLOR];
              [self.m_btnFollow setTitle:@"Invite" forState:UIControlStateNormal];
              
              self.m_viewLoading.hidden = YES;
          }];

}

@end
