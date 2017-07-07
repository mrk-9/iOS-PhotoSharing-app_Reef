//
//  AGPhotoBrowserOverlayView.m
//  AGPhotoBrowser
//
//  Created by Hellrider on 7/28/13.
//  Copyright (c) 2013 Andrea Giavatto. All rights reserved.
//

#import "AGPhotoBrowserOverlayView.h"
#import "Global.h"
#import <QuartzCore/QuartzCore.h>

@interface AGPhotoBrowserOverlayView () {
	BOOL _animated;
    
    CAGradientLayer *_gradientLayer;
}

@property (nonatomic, strong) UIView *sharingView;
@property (nonatomic, assign, readwrite) BOOL descriptionExpanded;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong, readwrite) UIImageView* userImageView;
@property (nonatomic, strong, readwrite) UIImageView* clockImageView;
@property (nonatomic, strong, readwrite) UILabel *timeInfoLabel;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, readwrite) UILabel *descriptionLabel;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UIButton *seeMoreButton;
@property (nonatomic, strong, readwrite) UIButton *actionButton;

@property (nonatomic, assign, readwrite, getter = isVisible) BOOL visible;

@end


@implementation AGPhotoBrowserOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setupView];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    
    // -- Gradient layer
    _gradientLayer.frame = self.bounds;
    // -- Sharing view
    self.sharingView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    //user imageview
    self.userImageView.frame = CGRectMake(20, 10, 36, 36);
    self.userImageView.layer.cornerRadius = CGRectGetHeight(self.userImageView.frame) / 2.f;
    self.userImageView.clipsToBounds = YES;
    
    self.userImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapGestureAvatar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotUserProfileGesture:)];
    tapGestureAvatar.numberOfTouchesRequired = 1;
    [self.userImageView addGestureRecognizer:tapGestureAvatar];

	// -- Title
    self.titleLabel.frame = CGRectMake(62.f, 18.f, CGRectGetWidth(self.bounds) - 62.f - 100.f, 20.f);
    
    self.titleLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapGestureTitle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotUserProfileGesture:)];
    tapGestureTitle.numberOfTouchesRequired = 1;
    [self.titleLabel addGestureRecognizer:tapGestureTitle];

    // -- clock icon
    self.clockImageView.frame = CGRectMake(CGRectGetWidth(self.bounds) - 40.f, 18.f, 20, 20);
    // -- timeinfo label
    self.timeInfoLabel.frame = CGRectMake(CGRectGetWidth(self.bounds) - 70.f, 18.f, 60.f, 20.f);
	// -- Separator
    self.separatorView.frame = CGRectMake(20, CGRectGetMinY(self.userImageView.frame) + CGRectGetHeight(self.userImageView.frame) + 10.f, CGRectGetWidth(self.bounds) - 40.f, 1);
    // -- Action
    self.actionButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 55 - 5, CGRectGetHeight(self.bounds) - 32 - 5, 55, 32);
    // -- See more
	self.seeMoreButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(self.actionButton.frame) - 60 - 5, CGRectGetMinY(self.separatorView.frame) + CGRectGetHeight(self.separatorView.frame) + 5, 60, 20);
    // -- Description
    CGSize descriptionSize = [self p_sizeForDescriptionLabel];
    CGFloat descriptionHeight = 20;
    
	if (self.descriptionExpanded) {
		descriptionHeight = descriptionSize.height;
	}
    self.descriptionLabel.frame = CGRectMake(20, CGRectGetMinY(self.separatorView.frame) + CGRectGetHeight(self.separatorView.frame) + 5, descriptionSize.width, descriptionHeight);
    
    // -- Controls visibility
	if ([self.descriptionLabel.text length]) {
        self.descriptionLabel.hidden = NO;
        if (self.descriptionExpanded) {
            self.seeMoreButton.hidden = YES;
        } else {
            CGSize descriptionTextSize;
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
                descriptionTextSize = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font  constrainedToSize:CGSizeMake(descriptionSize.width, MAXFLOAT)];
            } else {
                NSDictionary *textAttributes = @{NSFontAttributeName : self.descriptionLabel.font};
                CGRect descriptionBoundingRect = [self.descriptionLabel.text boundingRectWithSize:CGSizeMake(descriptionSize.width, MAXFLOAT)
                                                                                          options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:textAttributes
                                                                                          context:nil];
                descriptionTextSize = CGSizeMake(ceil(CGRectGetWidth(descriptionBoundingRect)), ceil(CGRectGetHeight(descriptionBoundingRect)));
            }
            if (descriptionTextSize.height > CGRectGetHeight(self.descriptionLabel.frame)) {
                self.seeMoreButton.hidden = NO;
            } else {
                self.seeMoreButton.hidden = YES;
            }
        }
    } else {
        self.descriptionLabel.hidden = YES;
        self.seeMoreButton.hidden = YES;
    }
	
    if ([_photoTitle length]) {
		self.titleLabel.hidden = NO;
		self.separatorView.hidden = NO;
	} else {
		self.titleLabel.hidden = YES;
		self.separatorView.hidden = YES;
	}
    
    if (![_photoDescription length] && ![_photoTitle length]) {
        _gradientLayer.hidden = YES;
    } else {
        _gradientLayer.hidden = NO;
    }
}

- (void)setupView
{
	self.alpha = 0;
	self.userInteractionEnabled = YES;
    
    [self.sharingView addSubview:self.userImageView];
    [self.sharingView addSubview:self.clockImageView];
    [self.sharingView addSubview:self.timeInfoLabel];
	[self.sharingView addSubview:self.titleLabel];
	[self.sharingView addSubview:self.separatorView];
	[self.sharingView addSubview:self.descriptionLabel];
	[self.sharingView addSubview:self.seeMoreButton];
	[self.sharingView addSubview:self.actionButton];
	
	[self addSubview:self.sharingView];
}


#pragma mark - Public methods

- (void)setOverlayVisible:(BOOL)visible animated:(BOOL)animated
{
    self.visible = visible;
    _animated = animated;
}

- (void)resetOverlayView
{
    self.descriptionExpanded = NO;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    CGRect frame = self.superview.frame;
    CGRect overlayFrame = CGRectZero;
    if (UIDeviceOrientationIsPortrait(orientation) || !UIDeviceOrientationIsLandscape(orientation)) {
        overlayFrame = CGRectMake(0, CGRectGetHeight(frame) - AGPhotoBrowserOverlayInitialHeight, CGRectGetWidth(frame), AGPhotoBrowserOverlayInitialHeight);
    } else if (orientation == UIDeviceOrientationLandscapeLeft) {
        overlayFrame = CGRectMake(0, 0, AGPhotoBrowserOverlayInitialHeight, CGRectGetHeight(frame));
    } else {
        overlayFrame = CGRectMake(CGRectGetWidth(frame) - AGPhotoBrowserOverlayInitialHeight, 0, AGPhotoBrowserOverlayInitialHeight, CGRectGetHeight(frame));
    }
    
    [UIView animateWithDuration:0.15
                     animations:^(){
                         self.frame = overlayFrame;
                     }];
}


#pragma mark - Private methods
#pragma mark -

- (CGSize)p_sizeForDescriptionLabel
{
    CGFloat newDescriptionWidth;
    if (self.descriptionExpanded) {
        newDescriptionWidth = CGRectGetWidth(self.bounds) - 20 - CGRectGetWidth(self.actionButton.frame) - 10; // H:|-(==20)-[_descriptionLabel]-(==5)-[_actionButton]-(==5)-|
    } else {
        newDescriptionWidth = CGRectGetWidth(self.bounds) - 20 - 5 - CGRectGetWidth(self.seeMoreButton.frame) - CGRectGetWidth(self.actionButton.frame) - 5; // H:|-(==20)-[_descriptionLabel]-(==5)-[_seeMoreButton][_actionButton]-(==5)-|
    }
    
    CGSize descriptionSize;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        descriptionSize = [self.photoDescription sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(newDescriptionWidth, MAXFLOAT)];
    } else {
        NSDictionary *textAttributes = @{NSFontAttributeName : self.descriptionLabel.font};
        CGRect descriptionBoundingRect = [self.photoDescription boundingRectWithSize:CGSizeMake(newDescriptionWidth, MAXFLOAT)
                                                                        options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:textAttributes
                                                                        context:nil];
        descriptionSize = CGSizeMake(ceil(CGRectGetWidth(descriptionBoundingRect)), ceil(CGRectGetHeight(descriptionBoundingRect)));
    }
    
    return descriptionSize;
}

#pragma mark - Buttons

- (void)p_actionButtonTapped:(UIButton *)sender
{
	if ([_delegate respondsToSelector:@selector(sharingView:didTapOnActionButton:)]) {
		[_delegate sharingView:self didTapOnActionButton:sender];
	}
}

- (void)p_seeMoreButtonTapped:(UIButton *)sender
{
	if ([_delegate respondsToSelector:@selector(sharingView:didTapOnSeeMoreButton:)]) {
		[_delegate sharingView:self didTapOnSeeMoreButton:sender];
	}
    
    self.descriptionExpanded = YES;
    
    CGSize newDescriptionSize = [self p_sizeForDescriptionLabel];
    
    CGRect currentOverlayFrame = self.frame;
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsPortrait(orientation) || !UIDeviceOrientationIsLandscape(orientation)) {
        int newSharingHeight = CGRectGetHeight(currentOverlayFrame) - 20 + newDescriptionSize.height;
        currentOverlayFrame.size.height = newSharingHeight;
        currentOverlayFrame.origin.y -= (newSharingHeight - CGRectGetHeight(self.bounds));
    } else if (orientation == UIDeviceOrientationLandscapeLeft) {
        int newSharingWidth = CGRectGetWidth(currentOverlayFrame) - 20 + newDescriptionSize.height;
        currentOverlayFrame.size.width = newSharingWidth;
    } else {
        int newSharingWidth = CGRectGetWidth(currentOverlayFrame) - 20 + newDescriptionSize.height;
        currentOverlayFrame.origin.x -= (newSharingWidth - CGRectGetWidth(currentOverlayFrame));
        currentOverlayFrame.size.width = newSharingWidth;
    }
    
    [UIView animateWithDuration:AGPhotoBrowserAnimationDuration
                     animations:^(){
                         self.frame = currentOverlayFrame;
                     }];
    
    [self.sharingView addGestureRecognizer:self.tapGesture];
}


#pragma mark - Recognizers

- (void)p_tapGestureTapped:(UITapGestureRecognizer *)recognizer
{
	[self resetOverlayView];
}

- (void) gotUserProfileGesture:(UITapGestureRecognizer *) recognizer
{
    [self.delegate tappedUserInfo:self];
}

#pragma mark - Setters

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
    
    [self setNeedsLayout];
}

- (void)setVisible:(BOOL)visible
{
	_visible = visible;
	
	CGFloat newAlpha = _visible ? 1. : 0.;
	
	NSTimeInterval animationDuration = _animated ? AGPhotoBrowserAnimationDuration : 0;
	
	[UIView animateWithDuration:animationDuration
					 animations:^(){
						 self.alpha = newAlpha;
						 self.actionButton.alpha = newAlpha;
					 }];
}

- (void) setDefaultAvatarImage
{
    self.userImageView.image = [UIImage imageNamed:@"people-blank.png"];
}

- (void) setAvatarImage:(NSString *) strAvatarImageUrl
{
    [[GlobalPool sharedObject] loadProfileImageFromServer:strAvatarImageUrl imageView:self.userImageView withResult:^(UIImage *image)
    {
    }];
}

- (void)setPhotoTitle:(NSString *)photoTitle
{
	_photoTitle = photoTitle;
	
    if (_photoTitle) {
        self.titleLabel.text = _photoTitle;
    } else {
		self.descriptionLabel.text = @"";
	}
    
    [self setNeedsLayout];
}

- (void)setPhotoDescription:(NSString *)photoDescription
{
	_photoDescription = photoDescription;
	
	if ([_photoDescription length]) {
		self.descriptionLabel.text = _photoDescription;
	} else {
		self.descriptionLabel.text = @"";
	}
    
    [self setNeedsLayout];
}

- (void)setTimeInfo:(NSString *)timeInfo
{
    _timeInfo = timeInfo;
    
    if (_timeInfo) {
        self.timeInfoLabel.text = _timeInfo;
    } else {
        self.timeInfoLabel.text = @"";
    }
    
    [self setNeedsLayout];
}

#pragma mark - Getters

- (UIView *)sharingView
{
	if (!_sharingView) {
		_sharingView = [[UIView alloc] initWithFrame:CGRectZero];
        _gradientLayer = [CAGradientLayer layer];
		_gradientLayer.frame = self.bounds;
		_gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
		[_sharingView.layer insertSublayer:_gradientLayer atIndex:0];
	}
	
	return _sharingView;
}

- (UIImageView *) clockImageView
{
    if (!_clockImageView) {
        _clockImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _clockImageView.backgroundColor = [UIColor clearColor];
        _clockImageView.image = [UIImage imageNamed:@"icon_time.png"];
    }
    
    return _clockImageView;
}

- (UIImageView *) userImageView
{
    if (!_userImageView) {
        _userImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _userImageView.backgroundColor = [UIColor clearColor];
    }
    
    return _userImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor colorWithWhite:0.9 alpha:0.9];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    
    return _titleLabel;
}

- (UILabel *)timeInfoLabel
{
	if (!_timeInfoLabel) {
		_timeInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_timeInfoLabel.textColor = [UIColor colorWithWhite:0.9 alpha:0.9];
		_timeInfoLabel.font = [UIFont systemFontOfSize:14];
		_timeInfoLabel.backgroundColor = [UIColor clearColor];
	}
	
	return _timeInfoLabel;
}

- (UIView *)separatorView
{
	if (!_separatorView) {
		_separatorView = [[UIView alloc] initWithFrame:CGRectZero];
		_separatorView.backgroundColor = [UIColor lightGrayColor];
        _separatorView.hidden = YES;
	}
	
	return _separatorView;
}

- (UILabel *)descriptionLabel
{
	if (!_descriptionLabel) {
		_descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_descriptionLabel.textColor = [UIColor colorWithWhite:0.9 alpha:0.9];
		_descriptionLabel.font = [UIFont systemFontOfSize:13];
		_descriptionLabel.backgroundColor = [UIColor clearColor];
		_descriptionLabel.numberOfLines = 0;
	}
	
	return _descriptionLabel;
}

- (UIButton *)seeMoreButton
{
	if (!_seeMoreButton) {
		_seeMoreButton = [[UIButton alloc] initWithFrame:CGRectZero];
		[_seeMoreButton setTitle:NSLocalizedString(@"See More", @"Title for See more button") forState:UIControlStateNormal];
		[_seeMoreButton setBackgroundColor:[UIColor clearColor]];
		[_seeMoreButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		_seeMoreButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        _seeMoreButton.hidden = YES;
		
		[_seeMoreButton addTarget:self action:@selector(p_seeMoreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	return _seeMoreButton;
}

- (UIButton *)actionButton
{
	if (!_actionButton) {
		_actionButton = [[UIButton alloc] initWithFrame:CGRectZero];
		[_actionButton setTitle:NSLocalizedString(@"● ● ●", @"Title for Action button") forState:UIControlStateNormal];
		[_actionButton setBackgroundColor:[UIColor clearColor]];
		[_actionButton setTitleColor:[UIColor colorWithWhite:0.9 alpha:0.9] forState:UIControlStateNormal];
		[_actionButton setTitleColor:[UIColor colorWithWhite:0.9 alpha:0.9] forState:UIControlStateHighlighted];
		[_actionButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        
		[_actionButton addTarget:self action:@selector(p_actionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	return _actionButton;
}

- (UITapGestureRecognizer *)tapGesture
{
	if (!_tapGesture) {
		_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_tapGestureTapped:)];
		_tapGesture.numberOfTouchesRequired = 1;
	}
	
	return _tapGesture;
}

@end
