//
//  PostSubView.h
//  reef
//
//  Created by iOSDevStar on 8/5/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol PostSubViewDelegate;
@class CircleProgressView;
@class THLabel;
@class ResponsiveLabel;

@interface PostSubView : UITableViewCell

@property (nonatomic, retain) MPMoviePlayerController *movie;

@property (nonatomic, assign) int m_nIndex;

@property (nonatomic, strong) NSString *m_strResourceURL;
@property (nonatomic, strong) NSString *m_strResourceLocalPath;

@property (nonatomic, strong) id<PostSubViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *m_postImageView;
@property (weak, nonatomic) IBOutlet UILabel *m_lblPostText;
@property (weak, nonatomic) IBOutlet UIView *m_viewLoading;
@property (weak, nonatomic) IBOutlet CircleProgressView *m_progressView;

@property (weak, nonatomic) IBOutlet UIButton *m_btnRefresh;
- (IBAction)actionRefresh:(id)sender;

- (void) downloadResourceFromServer;
@property (weak, nonatomic) IBOutlet UIButton *m_btnImageTrigger;
- (IBAction)actionViewPhoto:(id)sender;

@end

@protocol PostSubViewDelegate<NSObject>

- (void) onViewPhoto:(PostSubView *) subView;

@end