//
//  AGPhotoBrowserCell.m
//  AGPhotoBrowser
//
//  Created by Hellrider on 1/5/14.
//  Copyright (c) 2014 Andrea Giavatto. All rights reserved.
//

#import "AGPhotoBrowserCell.h"
#import "AGPhotoBrowserZoomableView.h"
#import "Global.h"

@interface AGPhotoBrowserCell () <AGPhotoBrowserZoomableViewDelegate>

@property (nonatomic, strong) AGPhotoBrowserZoomableView *zoomableView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation AGPhotoBrowserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		[self setupCell];
	}
	
	return self;
}

- (void)updateConstraints
{
	[self.contentView removeConstraints:self.contentView.constraints];
	
    NSDictionary *constrainedViews = NSDictionaryOfVariableBindings(_zoomableView);

    NSMutableArray *constraints = [NSMutableArray array];

    int nWidth = (int)CGRectGetWidth([UIScreen mainScreen].bounds);
    int nHeight = (int)CGRectGetHeight([UIScreen mainScreen].bounds);
    
    int nFinalWidth = 0, nFinalHeight = 0;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsLandscape(orientation)) {
        nFinalWidth =  nWidth > nHeight ? nWidth : nHeight;
        nFinalHeight = nWidth > nHeight ? nHeight : nWidth;
    }
    else
    {
        nFinalWidth =  nWidth > nHeight ? nHeight : nWidth;
        nFinalHeight = nWidth > nHeight ? nWidth : nHeight;
    }

    [_zoomableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [constraints addObject:[NSString stringWithFormat:@"H:|-0-[_zoomableView(==%d)]-0-|", nFinalWidth]];
    [constraints addObject:[NSString stringWithFormat:@"V:|-0-[_zoomableView(==%d)]-0-|", nFinalHeight]];

    for (NSString *string in constraints) {
        [self.contentView addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:string
                                   options:0 metrics:nil
                                   views:constrainedViews]];
    }

    /*
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_zoomableView]|"
																			 options:0
																			 metrics:@{}
																			   views:constrainedViews]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_zoomableView]|"
																			 options:0
																			 metrics:@{}
																			   views:constrainedViews]];
	*/
    
	[super updateConstraints];
}

- (void)setFrame:(CGRect)frame
{
    // -- Force the right frame
    CGRect correctFrame = frame;
    
    NSLog(@"width = %f, height = %f", [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation) || orientation == UIDeviceOrientationFaceUp) {
        if (UIDeviceOrientationIsPortrait(orientation) || orientation == UIDeviceOrientationFaceUp) {
            correctFrame.size.width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
            correctFrame.size.height = CGRectGetHeight([[UIScreen mainScreen] bounds]);
        } else {
            correctFrame.size.width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
            correctFrame.size.height = CGRectGetHeight([[UIScreen mainScreen] bounds]);
        }
    }
    
    [super setFrame:correctFrame];
}


#pragma mark - Getters

- (AGPhotoBrowserZoomableView *)zoomableView
{
	if (!_zoomableView) {
		_zoomableView = [[AGPhotoBrowserZoomableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_zoomableView.userInteractionEnabled = YES;
        _zoomableView.zoomableDelegate = self;
        _zoomableView.scrollEnabled = NO;
        
		[_zoomableView addGestureRecognizer:self.panGesture];
        
		CGAffineTransform transform = CGAffineTransformMakeRotation(0);
		CGPoint origin = _zoomableView.frame.origin;
		_zoomableView.transform = transform;
        CGRect frame = _zoomableView.frame;
        frame.origin = origin;
        _zoomableView.frame = frame;
	}
	
	return _zoomableView;
}

- (UIPanGestureRecognizer *)panGesture
{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_imageViewPanned:)];
		_panGesture.delegate = self;
		_panGesture.maximumNumberOfTouches = 1;
		_panGesture.minimumNumberOfTouches = 1;
    }
    
    return _panGesture;
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.panGesture) {
        UIView *imageView = [gestureRecognizer view];
        CGPoint translation = [gestureRecognizer translationInView:[imageView superview]];
        
        // -- Check for horizontal gesture
        if (fabsf(translation.x) > fabsf(translation.y)) {
            return YES;
        }
    }
	
    return NO;
}


#pragma mark - Setters

- (void)setCellImage:(UIImage *)cellImage
{
	[self.zoomableView setImage:cellImage];
	
	[self setNeedsUpdateConstraints];
}

- (void) setCellImageWithURL:(NSString *) strUrl
{
    [[GlobalPool sharedObject] loadPostPhotoFromServer:strUrl imageView:[self.zoomableView getImageView]];
}

#pragma mark - Public methods

- (void)resetZoomScale
{
	[self.zoomableView setZoomScale:1.];
}


#pragma mark - Private methods

- (void)setupCell
{
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.contentView addSubview:self.zoomableView];
}

- (void)p_imageViewPanned:(UIPanGestureRecognizer *)recognizer
{
	[self.delegate didPanOnZoomableViewForCell:self withRecognizer:recognizer];
}


#pragma mark - AGPhotoBrowserZoomableViewDelegate

- (void)didDoubleTapZoomableView:(AGPhotoBrowserZoomableView *)zoomableView state:(bool) bStartTap
{
	[self.delegate didDoubleTapOnZoomableViewForCell:self state:bStartTap];
}

- (void)ViewingPhotoAsZoomMode:(AGPhotoBrowserZoomableView *)zommableView
{
    [self.delegate ViewingPhotoAsZoomMode:self];
}

@end
