//
//  ProfilePostView.h
//  reef
//
//  Created by iOSDevStar on 8/5/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol ProfilePostViewDelegate;
@class CircleProgressView;

@interface ProfilePostView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic, assign) int m_nIndex;

@property (nonatomic, strong) id<ProfilePostViewDelegate> delegate;

@property (nonatomic, strong) NSDictionary* m_dictArticleInfo;

@property (nonatomic, retain) MPMoviePlayerController *movie;

@property (nonatomic, strong) NSString *m_strResourceURL;
@property (nonatomic, strong) NSString *m_strResourceLocalPath;
@property (weak, nonatomic) IBOutlet UIButton *m_btnViewPhoto;
- (IBAction)actionViewPhoto:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *m_viewUserInfo;
@property (weak, nonatomic) IBOutlet UIImageView *m_userImageView;
@property (weak, nonatomic) IBOutlet UILabel *m_lblUserName;
@property (weak, nonatomic) IBOutlet UIImageView *m_iconClock;
@property (weak, nonatomic) IBOutlet UILabel *m_lblTime;

@property (weak, nonatomic) IBOutlet UIImageView *m_postImageView;
@property (weak, nonatomic) IBOutlet UILabel *m_lblPostText;

@property (weak, nonatomic) IBOutlet UIView *m_viewLoading;
@property (weak, nonatomic) IBOutlet CircleProgressView *m_progressView;

@property (weak, nonatomic) IBOutlet UIButton *m_btnRefresh;
- (IBAction)actionRefresh:(id)sender;

- (void) downloadResourceFromServer;
@property (weak, nonatomic) IBOutlet UIButton *m_btnDelete;
- (IBAction)actionDeletePost:(id)sender;


@end

@protocol ProfilePostViewDelegate<NSObject>

- (void) onDeletePost:(ProfilePostView *) subView;
- (void) onViewPhoto:(ProfilePostView *) subView;

@end