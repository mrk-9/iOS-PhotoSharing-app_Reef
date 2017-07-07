//
//  MenuTabViewController.h
//  reef
//
//  Created by iOSDevStar on 6/19/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTabViewController : UIViewController
{
    UINavigationController* curNavCon;
}
@property (weak, nonatomic) IBOutlet UIView *m_subView;

@property (weak, nonatomic) IBOutlet UIView *m_viewIndicator;
@property (weak, nonatomic) IBOutlet UIView *m_view1;
@property (weak, nonatomic) IBOutlet UIView *m_view2;
@property (weak, nonatomic) IBOutlet UIView *m_view3;
@property (weak, nonatomic) IBOutlet UIView *m_view4;
@property (weak, nonatomic) IBOutlet UIView *m_view5;

@property (weak, nonatomic) IBOutlet UIImageView *m_tabIcon1;
@property (weak, nonatomic) IBOutlet UIImageView *m_tabIcon2;
@property (weak, nonatomic) IBOutlet UIImageView *m_tabIcon3;
@property (weak, nonatomic) IBOutlet UIImageView *m_tabIcon4;
@property (weak, nonatomic) IBOutlet UIImageView *m_tabIcon5;

@property (weak, nonatomic) IBOutlet UIView *m_viewTab;

- (IBAction)actionChoose1:(id)sender;
- (IBAction)actionChoose2:(id)sender;
- (IBAction)actionChoose3:(id)sender;
- (IBAction)actionChoose4:(id)sender;
- (IBAction)actionChoose5:(id)sender;

- (void) gotoHomeScreen;

- (void) hideMenuTabView;
- (void) showMenuTabView;

@property (nonatomic, assign) int m_nCurInvitationAmount;
@property (nonatomic, assign) int m_nCurMessageAmount;
@property (nonatomic, assign) int m_nCurRequestAmount;

- (void) setBadgeForHomeIcon:(int) nBadge;
- (void) setBadgeForMessageIcon:(int) nBadge;
- (void) setBadgeForRequestIcon:(int) nBadge;

@end
