//
//  AGPhotoBrowserView.h
//  AGPhotoBrowser
//
//  Created by Hellrider on 7/28/13.
//  Copyright (c) 2013 Andrea Giavatto. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AGPhotoBrowserDelegate.h"
#import "AGPhotoBrowserDataSource.h"

@protocol AGPhotoBrowerViewDelegate;

@interface AGPhotoBrowserView : UIView
{
    NSTimer* timerAuto;
    bool bStartTimer;
    bool bZoomMode;
    
    int nAutoScrollIndex;
}

@property (nonatomic, weak) id<AGPhotoBrowerViewDelegate> delegateForLoadMore;

@property (nonatomic, weak) id<AGPhotoBrowserDelegate> delegate;
@property (nonatomic, weak) id<AGPhotoBrowserDataSource> dataSource;

@property (nonatomic, strong, readonly) UIButton *doneButton;

@property (nonatomic, strong, readonly) UIImageView* locationImageView;
@property (nonatomic, strong, readonly) UILabel *locationInfoLabel;

- (void)show;
- (void)showFromIndex:(NSInteger)initialIndex;
- (void)hideWithCompletion:( void (^) (BOOL finished) )completionBlock;
- (void) refreshCurrentPhotoView;
- (void) stopScrollViewAnimation;
- (void) hideDisplayDetailView;

@end

@protocol AGPhotoBrowerViewDelegate <NSObject>

- (void) loadMoreRequestInPhotoBrowser;
- (void) updateViewedPhotoTime:(float) fViewedTime atIndex:(int) nIdx;

@end