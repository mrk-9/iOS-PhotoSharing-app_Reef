//
//  PostGridSubView.h
//  Reef
//
//  Created by iOSDevStar on 12/26/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol PostGridSubViewDelegate;
@class CircleProgressView;

@interface PostGridSubView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic, strong) id<PostGridSubViewDelegate> delegate;

@property (nonatomic, assign) bool m_bSelected;

@property (nonatomic, strong) NSDictionary* m_dictArticleInfo;

@property (nonatomic, assign) int m_nIndex;
@property (nonatomic, strong) NSString *m_strResourceURL;
@property (nonatomic, strong) NSString *m_strResourceLocalPath;

@property (weak, nonatomic) IBOutlet UIImageView *m_postImageView;

@property (weak, nonatomic) IBOutlet UIView *m_viewLoading;
@property (weak, nonatomic) IBOutlet CircleProgressView *m_progressView;
@property (weak, nonatomic) IBOutlet UIButton *m_btnShowFullScreen;
- (IBAction)actionShowFullScreen:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *m_btnRefresh;
- (IBAction)actionRefresh:(id)sender;

- (void) downloadResourceFromServer;

@end

@protocol PostGridSubViewDelegate<NSObject>
- (void) actionShowFullScreenInGridView:(PostGridSubView *) subView withIndex:(int) nIndex;
@end