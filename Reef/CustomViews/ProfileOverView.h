//
//  ProfileOverView.h
//  reef
//
//  Created by iOSDevStar on 8/5/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileOverViewDelegate;

@interface ProfileOverView : UIView

@property (nonatomic, strong) id<ProfileOverViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *m_userImageView;
@property (weak, nonatomic) IBOutlet UIButton *m_btnCircleSubscribe;
@property (weak, nonatomic) IBOutlet UIView *m_viewLocation;
@property (weak, nonatomic) IBOutlet UILabel *m_lblLocation;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgLocationIcon;

- (IBAction)actionClickCircleSubscribe:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *m_btnActionProfile;
@property (weak, nonatomic) IBOutlet UIButton *m_btnFollow;

- (IBAction)actionFollow:(id)sender;
- (void) adjustUI;

- (IBAction)actionProfile:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *m_lblPosts;
@property (weak, nonatomic) IBOutlet UILabel *m_lblFollowers;
@property (weak, nonatomic) IBOutlet UILabel *m_lblFollowing;

- (IBAction)actionShowFollowers:(id)sender;
- (IBAction)actionShowFollowings:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *m_btnReport;
- (IBAction)actionReport:(id)sender;

@end

@protocol ProfileOverViewDelegate<NSObject>
- (void) actionViewProfile:(ProfileOverView *) subView;
- (void) actionShowFollowers:(ProfileOverView *) subView;
- (void) actionShowFollowings:(ProfileOverView *) subView;
- (void) actionReportUser:(ProfileOverView *) subView;
- (void) actionFollowUser:(ProfileOverView *) subView;
@end