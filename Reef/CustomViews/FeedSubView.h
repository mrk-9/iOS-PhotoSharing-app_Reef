//
//  FeedSubView.h
//  reef
//
//  Created by iOSDevStar on 1/4/16.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeedSubViewDelegate;
@class CircleProgressView;

@interface FeedSubView : UITableViewCell

@property (nonatomic, strong) id<FeedSubViewDelegate> delegate;

@property (nonatomic, strong) NSDictionary* m_dictArticleInfo;

@property (nonatomic, assign) int m_nIndex;
@property (nonatomic, strong) NSString *m_strResourceURL;
@property (nonatomic, strong) NSString *m_strResourceLocalPath;

@property (weak, nonatomic) IBOutlet UIImageView *m_userImageView;
@property (weak, nonatomic) IBOutlet UILabel *m_lblUsername;
@property (weak, nonatomic) IBOutlet UILabel *m_lblTime;
@property (weak, nonatomic) IBOutlet UILabel *m_lblPostText;
@property (weak, nonatomic) IBOutlet UIImageView *m_postImageView;
@property (weak, nonatomic) IBOutlet UIView *m_viewLoading;
@property (weak, nonatomic) IBOutlet CircleProgressView *m_progressView;
@property (weak, nonatomic) IBOutlet UIButton *m_btnRefresh;
@property (weak, nonatomic) IBOutlet UILabel *m_lblLocation;

- (IBAction)actionRefresh:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *m_btnAction;
- (IBAction)actionDown:(id)sender;
- (IBAction)actionUp:(id)sender;
- (IBAction)actionCancel:(id)sender;

- (void) downloadResourceFromServer;

@end

@protocol FeedSubViewDelegate<NSObject>

- (void) touchDownView:(FeedSubView *) subView withIndex:(int) nSelectedIndex;
- (void) touchUpView:(FeedSubView *) subView withIndex:(int) nSelectedIndex;

@end
