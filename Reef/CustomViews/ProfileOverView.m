//
//  ProfileOverView.m
//  reef
//
//  Created by iOSDevStar on 8/5/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "ProfileOverView.h"
#import "Global.h"

@implementation ProfileOverView

- (void)awakeFromNib {
}

- (void) adjustUI {
    self.m_userImageView.layer.cornerRadius = self.m_userImageView.frame.size.height / 2.f;
    self.m_userImageView.layer.borderColor = GREEN_COLOR.CGColor;
    self.m_userImageView.layer.borderWidth = 0.f;
    self.m_userImageView.clipsToBounds = YES;
    
    self.m_btnCircleSubscribe.layer.cornerRadius = self.m_btnCircleSubscribe.frame.size.height / 2.f;
    self.m_btnCircleSubscribe.layer.borderColor = RED_COLOR.CGColor;
    self.m_btnCircleSubscribe.layer.borderWidth = 0.f;
    self.m_btnCircleSubscribe.clipsToBounds = YES;
    
    [self.m_btnCircleSubscribe setTitleColor:NAVI_COLOR forState:UIControlStateNormal];
    [self.m_btnCircleSubscribe setBackgroundColor:[UIColor lightGrayColor]];
}

- (IBAction)actionShowFollowers:(id)sender {
    if (self.delegate)
        [self.delegate actionShowFollowers:self];
}

- (IBAction)actionShowFollowings:(id)sender {
    if (self.delegate)
        [self.delegate actionShowFollowings:self];
}

- (IBAction)actionFollow:(id)sender {
    if (self.delegate)
        [self.delegate actionFollowUser:self];
}

- (IBAction)actionProfile:(id)sender {
    if (self.delegate)
        [self.delegate actionViewProfile:self];
}

- (IBAction)actionReport:(id)sender {
    if (self.delegate)
        [self.delegate actionReportUser:self];
}

- (IBAction)actionClickCircleSubscribe:(id)sender {
    if (self.delegate)
        [self.delegate actionFollowUser:self];
}

@end
