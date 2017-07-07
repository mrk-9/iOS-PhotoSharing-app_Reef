//
//  AGPhotoBrowserView.m
//  AGPhotoBrowser
//
//  Created by Hellrider on 7/28/13.
//  Copyright (c) 2013 Andrea Giavatto. All rights reserved.
//

#import "AGPhotoBrowserView.h"

#import <QuartzCore/QuartzCore.h>
#import "AGPhotoBrowserOverlayView.h"
#import "AGPhotoBrowserZoomableView.h"
#import "AGPhotoBrowserCell.h"
#import "AGPhotoBrowserCellProtocol.h"
#import "Global.h"

@interface AGPhotoBrowserView () <
AGPhotoBrowserOverlayViewDelegate,
AGPhotoBrowserCellDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIGestureRecognizerDelegate
> {
	CGPoint _startingPanPoint;
	BOOL _wantedFullscreenLayout;
    BOOL _navigationBarWasHidden;
	CGRect _originalParentViewFrame;
	NSInteger _currentlySelectedIndex;
    
    NSDate* startDate;
    bool bEOFLoading;
    
    BOOL _changingOrientation;
}

@property (nonatomic, strong, readwrite) UIButton *doneButton;
@property (nonatomic, strong, readwrite) UIImageView *locationImageView;
@property (nonatomic, strong, readwrite) UILabel *locationInfoLabel;
@property (nonatomic, strong) UITableView *photoTableView;
@property (nonatomic, strong) AGPhotoBrowserOverlayView *overlayView;

@property (nonatomic, strong) UIWindow *previousWindow;
@property (nonatomic, strong) UIWindow *currentWindow;

@property (nonatomic, assign, readonly) CGFloat cellHeight;

@property (nonatomic, assign, getter = isDisplayingDetailedView) BOOL displayingDetailedView;

@end


static NSString *CellIdentifier = @"AGPhotoBrowserCell";

@implementation AGPhotoBrowserView

const NSInteger AGPhotoBrowserThresholdToCenter = 150;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        // Initialization code
		[self setupView];
    }
    return self;
}

- (void)setupView
{
    timerAuto = nil;
    
	self.userInteractionEnabled = NO;
	self.backgroundColor = [UIColor colorWithWhite:0. alpha:0.];
	_currentlySelectedIndex = NSNotFound;
    _changingOrientation = NO;
	
    bEOFLoading = false;
    startDate = false;
    bStartTimer = false;
    timerAuto = nil;
    bZoomMode = false;
    
	[self addSubview:self.photoTableView];
	[self addSubview:self.doneButton];
    [self addSubview:self.locationImageView];
    [self addSubview:self.locationInfoLabel];
	[self addSubview:self.overlayView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarDidChangeFrame:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) stopScrollViewAnimation
{
    [self.photoTableView.infiniteScrollingView stopAnimating];
}

#pragma mark - Getters
- (UIImageView *) locationImageView
{
    if (!_locationImageView) {
        _locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 25, 22, 22)];
        [_locationImageView setBackgroundColor:[UIColor clearColor]];
        [_locationImageView setImage:[UIImage imageNamed:@"icon_location.png"]];
        _locationImageView.alpha = 0.;
    }
    
    return _locationImageView;
}

- (UILabel *) locationInfoLabel
{
    if (!_locationInfoLabel) {
        _locationInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(44 + 10, 20, CGRectGetWidth([UIScreen mainScreen].bounds) - 44 - 60 - 20, 32)];
        [_locationInfoLabel setText:@"Unknown Location"];
        [_locationInfoLabel setBackgroundColor:[UIColor clearColor]];
        [_locationInfoLabel setTextColor:[UIColor colorWithWhite:0.9 alpha:0.9]];
        [_locationInfoLabel setFont:[UIFont fontWithName:MAIN_BOLD_FONT_NAME size:14.f]];
        _locationInfoLabel.alpha = 0.;
    }
    
    return _locationInfoLabel;
}

- (UIButton *)doneButton
{
	if (!_doneButton) {
		_doneButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 60 - 10, 20, 60, 32)];
		[_doneButton setTitle:NSLocalizedString(@"Done", @"Title for Done button") forState:UIControlStateNormal];
		_doneButton.layer.cornerRadius = 3.0f;
		_doneButton.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.9].CGColor;
		_doneButton.layer.borderWidth = 1.0f;
		[_doneButton setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.5]];
		[_doneButton setTitleColor:[UIColor colorWithWhite:0.9 alpha:0.9] forState:UIControlStateNormal];
		[_doneButton setTitleColor:[UIColor colorWithWhite:0.9 alpha:0.9] forState:UIControlStateHighlighted];
		[_doneButton.titleLabel setFont:[UIFont fontWithName:MAIN_BOLD_FONT_NAME size:14.f]];
		_doneButton.alpha = 0.;
		
		[_doneButton addTarget:self action:@selector(p_doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	return _doneButton;
}

- (UITableView *)photoTableView
{
	if (!_photoTableView) {
		CGRect screenBounds = [[UIScreen mainScreen] bounds];
		_photoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(screenBounds), CGRectGetHeight(screenBounds))];
		_photoTableView.dataSource = self;
		_photoTableView.delegate = self;
		_photoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_photoTableView.backgroundColor = [UIColor clearColor];
		_photoTableView.pagingEnabled = YES;
		_photoTableView.showsVerticalScrollIndicator = NO;
		_photoTableView.showsHorizontalScrollIndicator = NO;
        _photoTableView.scrollEnabled = NO;
		_photoTableView.alpha = 0.;
		
		// -- Rotate table horizontally
		CGAffineTransform rotateTable = CGAffineTransformMakeRotation(0);
		CGPoint origin = _photoTableView.frame.origin;
		_photoTableView.transform = rotateTable;
		CGRect frame = _photoTableView.frame;
		frame.origin = origin;
		_photoTableView.frame = frame;
        
       __weak AGPhotoBrowserView *weakSelf = self;

        // setup pull-to-refresh
        [_photoTableView addInfiniteScrollingWithActionHandler:^{
            if (self.delegateForLoadMore && [self.delegateForLoadMore respondsToSelector:@selector(loadMoreRequestInPhotoBrowser)])
                [weakSelf.delegateForLoadMore loadMoreRequestInPhotoBrowser];
        }];
	}
	
	return _photoTableView;
}

- (AGPhotoBrowserOverlayView *)overlayView
{
	if (!_overlayView) {
		_overlayView = [[AGPhotoBrowserOverlayView alloc] initWithFrame:CGRectZero];
        _overlayView.delegate = self;
	}
	
	return _overlayView;
}

- (void) startAutoScrollTimer
{
    nAutoScrollIndex = (int)_currentlySelectedIndex;
    
    bStartTimer = false;
    if (timerAuto)
    {
        [timerAuto invalidate];
        timerAuto = nil;
    }
    
    bStartTimer = true;
    timerAuto = [NSTimer scheduledTimerWithTimeInterval:AUTO_SCROLL_TIME_INTERVAL target:self selector:@selector(autoScrollTableView) userInfo:nil repeats:YES];
}

- (void) autoScrollTableView
{
    if (!bStartTimer)
        return;
    
    NSLog(@"timer is working");
    
    UITableViewScrollPosition eTableViewPos = UITableViewScrollPositionMiddle;
    
    nAutoScrollIndex++;
    
    if (nAutoScrollIndex >= [_dataSource numberOfPhotosForPhotoBrowser:self])
        nAutoScrollIndex = 0;
    
    if (nAutoScrollIndex == 0)
        eTableViewPos = UITableViewScrollPositionTop;
    else if (nAutoScrollIndex == [_dataSource numberOfPhotosForPhotoBrowser:self] - 1)
        eTableViewPos = UITableViewScrollPositionBottom;

    [_photoTableView setContentOffset:CGPointMake(0, nAutoScrollIndex * CGRectGetHeight(_photoTableView.frame)) animated:YES];

    /*
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:nAutoScrollIndex inSection:0];
    [_photoTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
     */
    
    bZoomMode = false;
}

- (CGFloat)cellHeight
{
    NSLog(@"current window size width = %f, height = %f", self.currentWindow.frame.size.width, self.currentWindow.frame.size.height);

    CGFloat fWidth = CGRectGetWidth(self.currentWindow.frame);
    CGFloat fHeight = CGRectGetHeight(self.currentWindow.frame);
    
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (UIDeviceOrientationIsLandscape(orientation)) {
        return fWidth > fHeight ? fHeight : fWidth;
	}

    return fWidth > fHeight ? fWidth : fHeight;
}


#pragma mark - Setters

- (void)setDisplayingDetailedView:(BOOL)displayingDetailedView
{
	_displayingDetailedView = displayingDetailedView;
	
	CGFloat newAlpha;
	
	if (_displayingDetailedView) {
		[self.overlayView setOverlayVisible:YES animated:YES];
		newAlpha = 1.;
	} else {
		[self.overlayView setOverlayVisible:NO animated:YES];
		newAlpha = 0.;
	}
	
	[UIView animateWithDuration:AGPhotoBrowserAnimationDuration
					 animations:^(){
						 self.doneButton.alpha = newAlpha;
                         self.locationImageView.alpha = newAlpha;
                         self.locationInfoLabel.alpha = newAlpha;
					 }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger number = [_dataSource numberOfPhotosForPhotoBrowser:self];
    
    if (number > 0 && _currentlySelectedIndex == NSNotFound && !self.currentWindow.hidden) {
        // initialize with info for the first photo in photoTable
        [self setupPhotoForIndex:0];
    }
    
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell<AGPhotoBrowserCellProtocol> *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        if ([_dataSource respondsToSelector:@selector(cellForBrowser:withReuseIdentifier:)]) {
            cell = [_dataSource cellForBrowser:self withReuseIdentifier:CellIdentifier];
        } else {
            // -- Provide fallback if the user does not want its own implementation of a cell
            cell = [[AGPhotoBrowserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.delegate = self;
    }

    [self configureCell:cell forRowAtIndexPath:indexPath];
    [self.overlayView resetOverlayView];
    
    return cell;
}

- (void)configureCell:(UITableViewCell<AGPhotoBrowserCellProtocol> *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(resetZoomScale)]) {
        [cell resetZoomScale];
    }

    if ([_dataSource respondsToSelector:@selector(photoBrowser:URLStringForImageAtIndex:)] && [cell respondsToSelector:@selector(setCellImageWithURL:)]) {
        [cell setCellImageWithURL:[_dataSource photoBrowser:self URLStringForImageAtIndex:indexPath.row]];
    } else {
        [cell setCellImage:[_dataSource photoBrowser:self imageAtIndex:indexPath.row]];
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.displayingDetailedView = !self.isDisplayingDetailedView;
    
    if (bZoomMode)
        return;
    
    [self resumePauseAutoTimer];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];

    if (![_dataSource respondsToSelector:@selector(numberOfPhotosForPhotoBrowser:)])
        return;
    
    if ([_dataSource numberOfPhotosForPhotoBrowser:self] <= 0)
        return;
    
    if (!_displayingDetailedView)
        return;

    if ( ([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row) && (!bEOFLoading) ){
        //end of loading
        bEOFLoading = true;
        
        NSLog(@"display INDEX path = %d", (int) indexPath.row);
        
        startDate = [NSDate date];
        
        [self startAutoScrollTimer];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![_dataSource respondsToSelector:@selector(numberOfPhotosForPhotoBrowser:)])
        return;
    
    if ([_dataSource numberOfPhotosForPhotoBrowser:self] <= 0)
        return;

    if (!_displayingDetailedView)
        return;

    if (!bEOFLoading)
        return;

    NSLog(@"end INDEX path = %d", (int) indexPath.row);

    if (startDate)
    {
        if (!bZoomMode && self.delegateForLoadMore && [self.delegateForLoadMore respondsToSelector:@selector(updateViewedPhotoTime:atIndex:)])
        {
            NSTimeInterval timeInterval = -1 * [startDate timeIntervalSinceNow];
            
            NSLog(@"viewed_time = %f", timeInterval);

            startDate = [NSDate date];
            
            [self.delegateForLoadMore updateViewedPhotoTime:timeInterval atIndex:(int)indexPath.row];
        }
    }
    
    /*
    NSTimeInterval timeInterval = [startDate timeIntervalSinceNow];
    
    NSLog(@"disappeared, viewed_time = %f", timeInterval);
     */
}

#pragma mark - AGPhotoBrowserCellDelegate

- (void)didPanOnZoomableViewForCell:(id<AGPhotoBrowserCellProtocol>)cell withRecognizer:(UIPanGestureRecognizer *)recognizer
{
	[self p_imageViewPanned:recognizer];
}

- (void)didDoubleTapOnZoomableViewForCell:(id<AGPhotoBrowserCellProtocol>)cell state:(bool) bStartTap
{
    if (bStartTap)
    {
        self.photoTableView.scrollEnabled = NO;
        
        bStartTimer = false;
        
        NSLog(@"true");
    }
    else
    {
        self.photoTableView.scrollEnabled = NO;

        bStartTimer = true;
        
        NSLog(@"false");
    }
    
    /*
	self.displayingDetailedView = !self.isDisplayingDetailedView;

    if (bZoomMode)
        return;
    
    [self resumePauseAutoTimer];
     */
}

- (void) ViewingPhotoAsZoomMode:(id<AGPhotoBrowserCellProtocol>)cell
{
    bZoomMode = !bZoomMode;
 
    if (bZoomMode)
        bStartTimer = false;
    else if (self.displayingDetailedView)
    {
        bStartTimer = true;
    }
}

- (void) resumePauseAutoTimer
{
    if (self.displayingDetailedView)
    {
        bStartTimer = true;
    }
    else
    {
        bStartTimer = false;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.currentWindow.hidden && !_changingOrientation) {
        [self.overlayView resetOverlayView];
        
        CGPoint targetContentOffset = scrollView.contentOffset;
        
        UITableView *tv = (UITableView*)scrollView;
        NSIndexPath *indexPathOfTopRowAfterScrolling = [tv indexPathForRowAtPoint:targetContentOffset];

        [self setupPhotoForIndex:indexPathOfTopRowAfterScrolling.row];
    }
}

- (void)setupPhotoForIndex:(int)index
{
    _currentlySelectedIndex = index;
	    
    if ([self.dataSource respondsToSelector:@selector(photoBrowser:willDisplayActionButtonAtIndex:)]) {
        self.overlayView.actionButton.hidden = ![self.dataSource photoBrowser:self willDisplayActionButtonAtIndex:_currentlySelectedIndex];
    } else {
        self.overlayView.actionButton.hidden = NO;
    }
    
	if ([_dataSource respondsToSelector:@selector(photoBrowser:titleForImageAtIndex:)]) {
		self.overlayView.photoTitle = [_dataSource photoBrowser:self titleForImageAtIndex:_currentlySelectedIndex];
	} else {
        self.overlayView.photoTitle = @"";
    }
	
	if ([_dataSource respondsToSelector:@selector(photoBrowser:descriptionForImageAtIndex:)]) {
		self.overlayView.photoDescription = [_dataSource photoBrowser:self descriptionForImageAtIndex:_currentlySelectedIndex];
	} else {
        self.overlayView.photoDescription = @"";
    }
    
    if ([_dataSource respondsToSelector:@selector(photoBrowser:URLStringForUserImageAtIndex:)])
    {
        [self.overlayView setAvatarImage:[_dataSource photoBrowser:self URLStringForUserImageAtIndex:_currentlySelectedIndex]];
    }
    else
        [self.overlayView setDefaultAvatarImage];
    
    if ([_dataSource respondsToSelector:@selector(photoBrowser:timeInfoForImageAtIndex:)])
    {
        self.overlayView.timeInfo = [_dataSource photoBrowser:self timeInfoForImageAtIndex:_currentlySelectedIndex];
    }
    else {
        self.overlayView.timeInfo = @"";
    }
    
    if ([_dataSource respondsToSelector:@selector(photoBrowser:locationForUserAtIndex:)])
    {
        self.locationInfoLabel.text = [_dataSource photoBrowser:self locationForUserAtIndex:_currentlySelectedIndex];
    }
    else {
        self.locationInfoLabel.text = @"Unknown Location";
    }

}


#pragma mark - Public methods

- (void)show
{
    self.previousWindow = [[UIApplication sharedApplication] keyWindow];
    
    self.currentWindow = [[UIWindow alloc] initWithFrame:self.previousWindow.bounds];
    self.currentWindow.windowLevel = UIWindowLevelStatusBar;
    self.currentWindow.hidden = NO;
    self.currentWindow.backgroundColor = [UIColor clearColor];
    [self.currentWindow makeKeyAndVisible];
    [self.currentWindow addSubview:self];
	
	[UIView animateWithDuration:AGPhotoBrowserAnimationDuration
					 animations:^(){
						 self.backgroundColor = [UIColor colorWithWhite:0. alpha:1.];
					 }
					 completion:^(BOOL finished){
						 if (finished) {
							 self.userInteractionEnabled = YES;
							 self.displayingDetailedView = YES;
							 self.photoTableView.alpha = 1.;
							 [self.photoTableView reloadData];
						 }
					 }];
}

- (void)showFromIndex:(NSInteger)initialIndex
{
	[self show];
	
	if (initialIndex < [_dataSource numberOfPhotosForPhotoBrowser:self]) {
		[self.photoTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:initialIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	}
}

- (void)hideWithCompletion:( void (^) (BOOL finished) )completionBlock
{
	[UIView animateWithDuration:AGPhotoBrowserAnimationDuration
					 animations:^(){
						 self.photoTableView.alpha = 0.;
						 self.backgroundColor = [UIColor colorWithWhite:0. alpha:0.];
					 }
					 completion:^(BOOL finished){
						 self.userInteractionEnabled = NO;
                         startDate = nil;
                         bEOFLoading = false;
                         
                         bStartTimer = false;
                         if (timerAuto)
                         {
                             [timerAuto invalidate];
                             timerAuto = nil;
                         }

                         [self removeFromSuperview];
                         [self.previousWindow makeKeyAndVisible];
                         self.currentWindow.hidden = YES;
                         self.currentWindow = nil;
						 if(completionBlock) {
							 completionBlock(finished);
						 }
					 }];
}


#pragma mark - AGPhotoBrowserOverlayViewDelegate
- (void)sharingView:(AGPhotoBrowserOverlayView *)sharingView didTapOnActionButton:(UIButton *)actionButton
{
	if ([_delegate respondsToSelector:@selector(photoBrowser:didTapOnActionButton:atIndex:)]) {
		[_delegate photoBrowser:self didTapOnActionButton:actionButton atIndex:_currentlySelectedIndex];
	}
}

- (void) tappedUserInfo:(AGPhotoBrowserOverlayView *)overlayView
{
    if ([_delegate respondsToSelector:@selector(photoBrowser:didTapOnUserInfo:atIndex:)])
        [_delegate photoBrowser:self didTapOnUserInfo:overlayView atIndex:_currentlySelectedIndex];
}

#pragma mark - Recognizers

- (void)p_imageViewPanned:(UIPanGestureRecognizer *)recognizer
{
    
	AGPhotoBrowserZoomableView *imageView = (AGPhotoBrowserZoomableView *)recognizer.view;
	
	if (recognizer.state == UIGestureRecognizerStateBegan) {
        /*
		// -- Disable table view scrolling
		self.photoTableView.scrollEnabled = NO;
		// -- Hide detailed view
		self.displayingDetailedView = NO;
		_startingPanPoint = imageView.center;
		return;
         */
	}
	
	if (recognizer.state == UIGestureRecognizerStateEnded) {
        bStartTimer = true;

        return;
        
		// -- Enable table view scrolling
		self.photoTableView.scrollEnabled = YES;
		// -- Check if user dismissed the view
		CGPoint endingPanPoint = [recognizer translationInView:self];

		UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
		CGPoint translatedPoint;
		
        if (UIDeviceOrientationIsPortrait(orientation) || orientation == UIDeviceOrientationFaceUp) {
            translatedPoint = CGPointMake(_startingPanPoint.x - endingPanPoint.y, _startingPanPoint.y);
        } else if (orientation == UIDeviceOrientationLandscapeLeft) {
            translatedPoint = CGPointMake(_startingPanPoint.x + endingPanPoint.x, _startingPanPoint.y);
        } else {
            translatedPoint = CGPointMake(_startingPanPoint.x - endingPanPoint.x, _startingPanPoint.y);
        }
		
        /*
		imageView.center = translatedPoint;
		int heightDifference = abs(floor(_startingPanPoint.x - translatedPoint.x));
		
		if (heightDifference <= AGPhotoBrowserThresholdToCenter) {
			// -- Back to original center
			[UIView animateWithDuration:AGPhotoBrowserAnimationDuration
							 animations:^(){
								 self.backgroundColor = [UIColor colorWithWhite:0. alpha:1.];
								 imageView.center = self->_startingPanPoint;
							 } completion:^(BOOL finished){
								 // -- show detailed view?
								// self.displayingDetailedView = YES;
							 }];
		} else {
			// -- Animate out!
			typeof(self) weakSelf __weak = self;
			[self hideWithCompletion:^(BOOL finished){
				typeof(weakSelf) strongSelf __strong = weakSelf;
				if (strongSelf) {
					imageView.center = strongSelf->_startingPanPoint;
				}
			}];
		}
         */
	} else {
        /*
		CGPoint middlePanPoint = [recognizer translationInView:self];
		
		UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
		CGPoint translatedPoint;
		
        if (UIDeviceOrientationIsPortrait(orientation) || orientation == UIDeviceOrientationFaceUp) {
            translatedPoint = CGPointMake(_startingPanPoint.x - middlePanPoint.y, _startingPanPoint.y);
        } else if (orientation == UIDeviceOrientationLandscapeLeft) {
            translatedPoint = CGPointMake(_startingPanPoint.x + middlePanPoint.x, _startingPanPoint.y);
        } else {
            translatedPoint = CGPointMake(_startingPanPoint.x - middlePanPoint.x, _startingPanPoint.y);
        }
		
		imageView.center = translatedPoint;
		int heightDifference = abs(floor(_startingPanPoint.x - translatedPoint.x));
		CGFloat ratio = (_startingPanPoint.x - heightDifference)/_startingPanPoint.x;
		self.backgroundColor = [UIColor colorWithWhite:0. alpha:ratio];
         */
	}
}

- (void) refreshCurrentPhotoView
{
    [self stopScrollViewAnimation];
    
    [self.photoTableView reloadData];
    [self.photoTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_currentlySelectedIndex inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
}

#pragma mark - Private methods
- (void) hideDisplayDetailView
{
    self.displayingDetailedView = NO;
}

- (void)p_doneButtonTapped:(UIButton *)sender
{
    bStartTimer = false;
    if (timerAuto)
    {
        [timerAuto invalidate];
        timerAuto = nil;
    }
    
	if ([_delegate respondsToSelector:@selector(photoBrowser:didTapOnDoneButton:)]) {
		self.displayingDetailedView = NO;
        
        //  For getting the cells themselves
        NSIndexPath *firstVisibleIndexPath = [[_photoTableView indexPathsForVisibleRows] objectAtIndex:0];

        if (startDate)
        {
            NSTimeInterval timeInterval = -1 * [startDate timeIntervalSinceNow];
            
            NSLog(@"final index row = %d, viewed_time = %f", (int)firstVisibleIndexPath.row, timeInterval);
            
            if (self.delegateForLoadMore && [self.delegateForLoadMore respondsToSelector:@selector(updateViewedPhotoTime:atIndex:)])
                [self.delegateForLoadMore updateViewedPhotoTime:timeInterval atIndex:(int)firstVisibleIndexPath.row];
        }
        
        startDate = nil;
        bEOFLoading = false;

        [_delegate photoBrowser:self didTapOnDoneButton:sender];
	}
}


#pragma mark - Orientation change

- (void)statusBarDidChangeFrame:(NSNotification *)notification
{
    // -- Get the device orientation
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (UIDeviceOrientationIsPortrait(orientation) || orientation == UIDeviceOrientationFaceUp) {
		_changingOrientation = YES;
		
		CGFloat angleTable = UIInterfaceOrientationAngleOfOrientation(orientation);
		CGFloat angleOverlay = UIInterfaceOrientationAngleOfOrientationForOverlay(orientation);
		CGAffineTransform tableTransform = CGAffineTransformMakeRotation(angleTable);
		CGAffineTransform overlayTransform = CGAffineTransformMakeRotation(angleOverlay);
		
		CGRect tableFrame = [UIScreen mainScreen].bounds;
		CGRect overlayFrame = CGRectZero;
		CGRect doneFrame = CGRectZero;
		
		// -- Update table
//		[self setTransform:tableTransform andFrame:tableFrame forView:self.photoTableView];
        
        NSLog(@"table view width = %f, height = %f", self.photoTableView.frame.size.width, self.photoTableView.frame.size.height);
        
		if (UIDeviceOrientationIsPortrait(orientation) || orientation == UIDeviceOrientationFaceUp) {
			overlayFrame = CGRectMake(0, CGRectGetHeight(tableFrame) - AGPhotoBrowserOverlayInitialHeight, CGRectGetWidth(tableFrame), AGPhotoBrowserOverlayInitialHeight);
			doneFrame = CGRectMake(CGRectGetWidth(tableFrame) - 60 - 10, 15, 60, 32);
		} else if (orientation == UIDeviceOrientationLandscapeLeft) {
			overlayFrame = CGRectMake(0, 0, AGPhotoBrowserOverlayInitialHeight, CGRectGetHeight(tableFrame));
			doneFrame = CGRectMake(CGRectGetWidth(tableFrame) - 32 - 15, CGRectGetHeight(tableFrame) - 10 - 60, 32, 60);
		} else {
			overlayFrame = CGRectMake(CGRectGetWidth(tableFrame) - AGPhotoBrowserOverlayInitialHeight, 0, AGPhotoBrowserOverlayInitialHeight, CGRectGetHeight(tableFrame));
			doneFrame = CGRectMake(15, 10, 32, 60);
		}
		// -- Update overlay
//		[self setTransform:overlayTransform andFrame:overlayFrame forView:self.overlayView];
		if (self.overlayView.descriptionExpanded) {
			[self.overlayView resetOverlayView];
		}
		// -- Update done button
//		[self setTransform:overlayTransform andFrame:doneFrame forView:self.doneButton];
		
		[self.photoTableView reloadData];
		[self.photoTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_currentlySelectedIndex inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];

		_changingOrientation = NO;
	}
}

- (void)setTransform:(CGAffineTransform)transform andFrame:(CGRect)frame forView:(UIView *)view
{
	if (!CGAffineTransformEqualToTransform(view.transform, transform)) {
        view.transform = transform;
    }
    if (!CGRectEqualToRect(view.frame, frame)) {
        view.frame = frame;
    }
}

CGFloat UIInterfaceOrientationAngleOfOrientation(UIDeviceOrientation orientation)
{
    CGFloat angle;
    
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            angle = 0;
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = 0;//M_PI_2;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = 0;//-M_PI_2;
            break;
        default:
            angle = 0;
            break;
    }
    
    return angle;
}

CGFloat UIInterfaceOrientationAngleOfOrientationForOverlay(UIDeviceOrientation orientation)
{
    CGFloat angle;
    
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            angle = 0;
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        default:
            angle = 0;
            break;
    }
    
    return angle;
}

@end
