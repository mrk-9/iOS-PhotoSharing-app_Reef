//
//  PBJCaptureViewController.m
//  PBJVision
//
//  Created by Patrick Piemonte on 7/23/13.
//  Copyright (c) 2013-present, Patrick Piemonte, http://patrickpiemonte.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "PBJCaptureViewController.h"
#import "PBJStrobeView.h"
#import "PBJFocusView.h"

#import "PBJVision.h"
#import "PBJVisionUtilities.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <GLKit/GLKit.h>

#import "ExtendedHitButton.h"
#import "Global.h"
#import "CaptureManagerViewController.h"
#import "PostViewController.h"
#import "FilterViewController.h"

@interface PBJCaptureViewController () <
    UIGestureRecognizerDelegate,
    PBJVisionDelegate,
    UIAlertViewDelegate>
{
    UIButton *_doneButton;
    UIButton *_flashButton;
    UIButton *_closeButton;
    UIButton *_flipButton;
    UIButton *_focusButton;
    UIButton *_frameRateButton;
    UIButton *_onionButton;
    UIButton *_refreshButton;
    UIView *_captureDock;
    UIView* viewCaptureButton;
    
    UIView* viewTimlineForVideo;
    UIView* viewCurrentTimeline;
    NSMutableArray* arrayTimelineViews;
    bool bAlreadyLimited;
    float fPrevTimeline;
    
    UIView *_previewView;
    AVCaptureVideoPreviewLayer *_previewLayer;
    PBJFocusView *_focusView;
    GLKViewController *_effectsViewController;
    
    UILabel *_instructionLabel;
    UIView *_gestureView;
    UILongPressGestureRecognizer *_longPressGestureRecognizer;
    UILongPressGestureRecognizer *_longPressGestureRecognizerForPhoto;
    UITapGestureRecognizer *_focusTapGestureRecognizer;
    UITapGestureRecognizer *_doubleTapGestureRecognizer;
    UITapGestureRecognizer *_photoTapGestureRecognizer;
    
    BOOL _recording;

    ALAssetsLibrary *_assetLibrary;
    __block NSDictionary *_currentVideo;
    __block NSDictionary *_currentPhoto;
}

@end

@implementation PBJCaptureViewController

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - init

- (void)dealloc
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    _longPressGestureRecognizer.delegate = nil;
    _focusTapGestureRecognizer.delegate = nil;
    _photoTapGestureRecognizer.delegate = nil;
    
    _previewView = nil;
}

#pragma mark - view lifecycle
- (void) backToMainView
{
    [[GlobalPool sharedObject].m_curCaptureManagerViewCon backToMainView];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:38.f / 255.f green:39.f / 255.f blue:43.f / 255.f alpha:1.f];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    _assetLibrary = [[ALAssetsLibrary alloc] init];
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);

    // elapsed time and red dot
    FAKFontAwesome *closeIcon = [FAKFontAwesome timesCircleIconWithSize:NAVI_ICON_SIZE];
    [closeIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imgClose = [closeIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    
    _closeButton = [ExtendedHitButton extendedHitButton];
    [_closeButton setImage:imgClose forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(backToMainView) forControlEvents:UIControlEventTouchUpInside];
    CGRect closeFrame = _closeButton.frame;
    closeFrame.origin = CGPointMake(20.0f, 20.f);
    closeFrame.size = imgClose.size;
    _closeButton.frame = closeFrame;
    [self.view addSubview:_closeButton];

    // done button
    if (self.m_nCaptureMode == VIDEO_CAPTURE_MODE)
    {
        _doneButton = [ExtendedHitButton extendedHitButton];
        _doneButton.frame = CGRectMake(viewWidth - 24.0f - 20.0f, 20.f, 24.0f, 24.0f);
        FAKFontAwesome *checkIcon = [FAKFontAwesome checkCircleIconWithSize:NAVI_ICON_SIZE];
        [checkIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        UIImage *buttonImage = [checkIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
        FAKFontAwesome *checkIcon_Sel = [FAKFontAwesome checkCircleIconWithSize:NAVI_ICON_SIZE];
        [checkIcon_Sel addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
        UIImage *buttonImage_Sel = [checkIcon_Sel imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];

        [_doneButton setImage:buttonImage forState:UIControlStateNormal];
        [_doneButton setImage:buttonImage_Sel forState:UIControlStateHighlighted];
        [_doneButton addTarget:self action:@selector(_handleDoneButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_doneButton];
    }

    // preview and AV layer
    _previewView = [[UIView alloc] initWithFrame:CGRectZero];
    _previewView.backgroundColor = [UIColor colorWithRed:38.f / 255.f green:39.f / 255.f blue:43.f / 255.f alpha:1.f];
    CGRect previewFrame = CGRectMake(0, 64.0f, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame));
    _previewView.frame = previewFrame;
    _previewLayer = [[PBJVision sharedInstance] previewLayer];
    _previewLayer.frame = _previewView.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_previewView.layer addSublayer:_previewLayer];
    
    // onion skin
    _effectsViewController = [[GLKViewController alloc] init];
    _effectsViewController.preferredFramesPerSecond = 60;
    
    GLKView *view = (GLKView *)_effectsViewController.view;
    CGRect viewFrame = _previewView.bounds;
    view.frame = viewFrame;
    view.context = [[PBJVision sharedInstance] context];
    view.contentScaleFactor = [[UIScreen mainScreen] scale];
    view.alpha = 0.5f;
    view.hidden = YES;
    [[PBJVision sharedInstance] setPresentationFrame:_previewView.frame];
 //   [_previewView addSubview:_effectsViewController.view];
    
    //timeline for video
    bAlreadyLimited = false;
    arrayTimelineViews = [[NSMutableArray alloc] init];
    viewTimlineForVideo = [[UIView alloc] initWithFrame:CGRectMake(0, 64.f + CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame), 5.f)];
    viewTimlineForVideo.backgroundColor = [UIColor clearColor];
    [self.view addSubview:viewTimlineForVideo];
    
    // focus view
    _focusView = [[PBJFocusView alloc] initWithFrame:CGRectZero];

    // instruction label
    _instructionLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    _instructionLabel.textAlignment = NSTextAlignmentCenter;
    _instructionLabel.font = [UIFont fontWithName:MAIN_FONT_NAME size:15.0f];
    _instructionLabel.textColor = [UIColor whiteColor];
    _instructionLabel.backgroundColor = [UIColor colorWithRed:38.f / 255.f green:39.f / 255.f blue:43.f / 255.f alpha:1.f];
    _instructionLabel.text = NSLocalizedString(@"Touch and hold to record", @"Instruction message for capturing video.");
    [_instructionLabel sizeToFit];
    CGPoint labelCenter = _previewView.center;
    labelCenter.y += ((CGRectGetHeight(_previewView.frame) * 0.5f) + 35.0f);
    _instructionLabel.center = labelCenter;
//    [self.view addSubview:_instructionLabel];
    
    // touch to record
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPressGestureRecognizer:)];
    _longPressGestureRecognizer.delegate = self;
    _longPressGestureRecognizer.minimumPressDuration = 0.05f;
    _longPressGestureRecognizer.allowableMovement = 10.0f;

    _longPressGestureRecognizerForPhoto = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPressGestureRecognizerForPhoto:)];
    _longPressGestureRecognizerForPhoto.delegate = self;
    _longPressGestureRecognizerForPhoto.minimumPressDuration = 0.05f;
    _longPressGestureRecognizerForPhoto.allowableMovement = 10.0f;

    // tap to focus
    _focusTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleFocusTapGesterRecognizer:)];
    _focusTapGestureRecognizer.delegate = self;
    _focusTapGestureRecognizer.numberOfTapsRequired = 1;
    _focusTapGestureRecognizer.enabled = YES;
    [_previewView addGestureRecognizer:_focusTapGestureRecognizer];

    _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleDoubleTapGesture:)];
    _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [_previewView addGestureRecognizer:_doubleTapGestureRecognizer];
    
    [_focusTapGestureRecognizer requireGestureRecognizerToFail:_doubleTapGestureRecognizer];

    // gesture view to record
    float fCaptureButtonHeight = (self.view.frame.size.height - 64.f - CGRectGetWidth(self.view.frame)) / 3 * 2.f;
    if (fCaptureButtonHeight > 100.f)
        fCaptureButtonHeight = 100.f;
    
    float fCaptureButtonY = 44.f + CGRectGetWidth(self.view.frame) + fCaptureButtonHeight / 2.f;

    viewCaptureButton = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2.f - fCaptureButtonHeight / 2.f, fCaptureButtonY, fCaptureButtonHeight, fCaptureButtonHeight)];
    if (self.m_nCaptureMode == PHOTO_CAPTURE_MODE)
        viewCaptureButton.backgroundColor = GREEN_COLOR;
    else
        viewCaptureButton.backgroundColor = RED_COLOR;
    viewCaptureButton.layer.cornerRadius = fCaptureButtonHeight / 2.f;
    viewCaptureButton.layer.borderColor = [UIColor whiteColor].CGColor;
    viewCaptureButton.layer.borderWidth = 5.f;
    viewCaptureButton.clipsToBounds = YES;
    [self.view addSubview:viewCaptureButton];
    
    if (self.m_nCaptureMode == PHOTO_CAPTURE_MODE)
        [viewCaptureButton addGestureRecognizer:_longPressGestureRecognizerForPhoto];
    else
        [viewCaptureButton addGestureRecognizer:_longPressGestureRecognizer];

    // bottom dock
    _captureDock = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 64.0f - MENU_TAB_HEIGHT, CGRectGetWidth(self.view.bounds), 64.0f)];
    _captureDock.backgroundColor = [UIColor clearColor];
    _captureDock.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    [self.view addSubview:_captureDock];
    
    // flip button
    float fSettingButtonHeight = 32.f;
    _flipButton = [ExtendedHitButton extendedHitButton];
    UIImage *flipImage = [UIImage imageNamed:@"SwitchCamera"];
    [_flipButton setImage:flipImage forState:UIControlStateNormal];
    _flipButton.frame = CGRectMake(30.f, fCaptureButtonY + fCaptureButtonHeight / 2.f - fSettingButtonHeight / 2.f, fSettingButtonHeight, fSettingButtonHeight);
    [_flipButton addTarget:self action:@selector(_handleFlipButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flipButton];

    _flashButton = [ExtendedHitButton extendedHitButton];
    UIImage *flashImage = [UIImage imageNamed:@"SwitchFlash_off"];
    [_flashButton setImage:flashImage forState:UIControlStateNormal];
    _flashButton.frame = CGRectMake(self.view.frame.size.width - 30.f - fSettingButtonHeight, fCaptureButtonY + fCaptureButtonHeight / 2.f - fSettingButtonHeight / 2.f, fSettingButtonHeight, fSettingButtonHeight);
    [_flashButton addTarget:self action:@selector(_handleFlashButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashButton];

    // focus mode button
    _focusButton = [ExtendedHitButton extendedHitButton];
    UIImage *focusImage = [UIImage imageNamed:@"capture_focus_button"];
    [_focusButton setImage:focusImage forState:UIControlStateNormal];
    [_focusButton setImage:[UIImage imageNamed:@"capture_focus_button_active"] forState:UIControlStateSelected];
    CGRect focusFrame = _focusButton.frame;
    focusFrame.origin = CGPointMake((CGRectGetWidth(self.view.bounds) * 0.5f) - (focusImage.size.width * 0.5f), 16.0f);
    focusFrame.size = focusImage.size;
    _focusButton.frame = focusFrame;
    [_focusButton addTarget:self action:@selector(_handleFocusButton:) forControlEvents:UIControlEventTouchUpInside];
    [_captureDock addSubview:_focusButton];
    
    if ([[PBJVision sharedInstance] supportsVideoFrameRate:120]) {
        // set faster frame rate
    }
    
    // onion button
    _onionButton = [ExtendedHitButton extendedHitButton];
    UIImage *onionImage = [UIImage imageNamed:@"capture_onion"];
    [_onionButton setImage:onionImage forState:UIControlStateNormal];
    [_onionButton setImage:[UIImage imageNamed:@"capture_onion_selected"] forState:UIControlStateSelected];
    CGRect onionFrame = _onionButton.frame;
    onionFrame.origin = CGPointMake(CGRectGetWidth(self.view.bounds) - onionImage.size.width - 20.0f, 16.0f);
    onionFrame.size = onionImage.size;
    _onionButton.frame = onionFrame;
    _onionButton.imageView.frame = _onionButton.bounds;
    [_onionButton addTarget:self action:@selector(_handleOnionSkinningButton:) forControlEvents:UIControlEventTouchUpInside];
    [_captureDock addSubview:_onionButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = YES;

    // iOS 6 support
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    [self _resetCapture];
    [[PBJVision sharedInstance] startPreview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[PBJVision sharedInstance] stopPreview];

    self.navigationController.navigationBarHidden = NO;

    // iOS 6 support
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void) refreshTimelines
{
    
}

#pragma mark - private start/stop helper methods

- (void)_startCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _instructionLabel.alpha = 0;
        _instructionLabel.transform = CGAffineTransformMakeTranslation(0, 10.0f);
    } completion:^(BOOL finished) {
    }];
    [[PBJVision sharedInstance] startVideoCapture];
}

- (void)_pauseCapture
{
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _instructionLabel.alpha = 1;
        _instructionLabel.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
    }];

    [[PBJVision sharedInstance] pauseVideoCapture];
    _effectsViewController.view.hidden = !_onionButton.selected;
}

- (void)_resumeCapture
{
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _instructionLabel.alpha = 0;
        _instructionLabel.transform = CGAffineTransformMakeTranslation(0, 10.0f);
    } completion:^(BOOL finished) {
    }];
    
    [[PBJVision sharedInstance] resumeVideoCapture];
    _effectsViewController.view.hidden = YES;
}

- (void)_endCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[PBJVision sharedInstance] endVideoCapture];
    _effectsViewController.view.hidden = YES;
}

- (void)_resetCapture
{
    _longPressGestureRecognizer.enabled = YES;

    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;

    if ([vision isCameraDeviceAvailable:PBJCameraDeviceBack]) {
        vision.cameraDevice = PBJCameraDeviceBack;
        _flipButton.hidden = NO;
    } else {
        vision.cameraDevice = PBJCameraDeviceFront;
        _flipButton.hidden = YES;
    }
    
    if (self.m_nCaptureMode == VIDEO_CAPTURE_MODE)
        vision.cameraMode = PBJCameraModeVideo;
    else
        vision.cameraMode = PBJCameraModePhoto; // PHOTO: uncomment to test photo capture
    vision.cameraOrientation = PBJCameraOrientationPortrait;
    vision.focusMode = PBJFocusModeContinuousAutoFocus;
    vision.outputFormat = PBJOutputFormatSquare;
    vision.videoRenderingEnabled = YES;
    vision.additionalCompressionProperties = @{AVVideoProfileLevelKey : AVVideoProfileLevelH264Baseline30}; // AVVideoProfileLevelKey requires specific captureSessionPreset
    
    // specify a maximum duration with the following property
    // vision.maximumCaptureDuration = CMTimeMakeWithSeconds(5, 600); // ~ 5 seconds
}

#pragma mark - UIButton
- (void) _handleFlashButton:(UIButton *) button
{
    switch ([PBJVision sharedInstance].torchMode) {
        case AVCaptureTorchModeOff:
            [PBJVision sharedInstance].torchMode = AVCaptureTorchModeOn;
            break;
            
        case AVCaptureTorchModeOn:
            [PBJVision sharedInstance].torchMode = AVCaptureTorchModeAuto;
            break;
            
        case AVCaptureTorchModeAuto:
            [PBJVision sharedInstance].torchMode = AVCaptureTorchModeOff;
            break;
            
        default:
            break;
    }

}

- (void)updateFlashButtonByTochMode:(AVCaptureTorchMode)touchMode {
    switch (touchMode) {
        case AVCaptureTorchModeOff:
            [_flashButton setImage:[UIImage imageNamed:@"SwitchFlash_off"] forState:UIControlStateNormal];
            break;
            
        case AVCaptureTorchModeOn:
            [_flashButton setImage:[UIImage imageNamed:@"SwitchFlash_on"] forState:UIControlStateNormal];
            break;
            
        case AVCaptureTorchModeAuto:
            [_flashButton setImage:[UIImage imageNamed:@"SwitchFlash_auto"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == CameraTorchModeObservationContext) {
        [self updateFlashButtonByTochMode:(AVCaptureTorchMode)[change[@"new"] intValue]];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void) _handleDoubleTapGesture:(UITapGestureRecognizer *) sender
{
    [self _handleFlipButton:_flipButton];
}

- (void)_handleFlipButton:(UIButton *)button
{
    PBJVision *vision = [PBJVision sharedInstance];
    vision.cameraDevice = vision.cameraDevice == PBJCameraDeviceBack ? PBJCameraDeviceFront : PBJCameraDeviceBack;
}

- (void)_handleFocusButton:(UIButton *)button
{
    _focusButton.selected = !_focusButton.selected;
    
    if (_focusButton.selected) {
        _focusTapGestureRecognizer.enabled = YES;
        _gestureView.hidden = YES;

    } else {
        if (_focusView && [_focusView superview]) {
            [_focusView stopAnimation];
        }
        _focusTapGestureRecognizer.enabled = NO;
        _gestureView.hidden = NO;
    }
    
    [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _instructionLabel.alpha = 0;
    } completion:^(BOOL finished) {
        _instructionLabel.text = _focusButton.selected ? NSLocalizedString(@"Touch to focus", @"Touch to focus") :
                                                         NSLocalizedString(@"Touch and hold to record", @"Touch and hold to record");
        [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _instructionLabel.alpha = 1;
        } completion:^(BOOL finished1) {
        }];
    }];
}

- (void)_handleFrameRateChangeButton:(UIButton *)button
{
}

- (void)_handleOnionSkinningButton:(UIButton *)button
{
    _onionButton.selected = !_onionButton.selected;
    
    if (_recording) {
        _effectsViewController.view.hidden = !_onionButton.selected;
    }
}

- (void)_handleDoneButton:(UIButton *)button
{
    // resets long press
    _longPressGestureRecognizer.enabled = NO;
    _longPressGestureRecognizer.enabled = YES;

    [[GlobalPool sharedObject] showLoadingView:self.view];

    [self _endCapture];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self _resetCapture];
}

#pragma mark - UIGestureRecognizer
- (void)_handleLongPressGestureRecognizerForPhoto:(UIGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            viewCaptureButton.alpha = 0.3f;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            viewCaptureButton.alpha = 1.f;
            [[PBJVision sharedInstance] freezePreview];
            [[GlobalPool sharedObject] showLoadingView:self.view];
            [[PBJVision sharedInstance] capturePhoto];
            break;
        }
        default:
            break;
    }
}

- (void)_handleLongPressGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    // PHOTO: uncomment to test photo capture
//    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
//        [[PBJVision sharedInstance] capturePhoto];
//        return;
//    }

    if (self.m_nCaptureMode == VIDEO_CAPTURE_MODE && bAlreadyLimited)
        return;
    
    switch (gestureRecognizer.state) {
      case UIGestureRecognizerStateBegan:
        {
            viewCaptureButton.alpha = 0.3f;
            if (!_recording)
            {
                [self _startCapture];
                
                fPrevTimeline = 0.f;
                
                viewCurrentTimeline = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, VIDEO_TIMELINE_HEIGHT)];
                viewCurrentTimeline.layer.borderColor = [UIColor colorWithRed:38.f / 255.f green:39.f / 255.f blue:43.f / 255.f alpha:1.f].CGColor;
                viewCurrentTimeline.layer.borderWidth = 1.f;
                viewCurrentTimeline.clipsToBounds = YES;
                viewCurrentTimeline.backgroundColor = [UIColor whiteColor];
                
                [viewTimlineForVideo addSubview:viewCurrentTimeline];
            }
            else
            {
                UIView* lastTimelineView = (UIView *)[arrayTimelineViews lastObject];
                viewCurrentTimeline = [[UIView alloc] initWithFrame:CGRectMake(lastTimelineView.frame.origin.x + lastTimelineView.frame.size.width, 0, 0, VIDEO_TIMELINE_HEIGHT)];
                viewCurrentTimeline.layer.borderColor = [UIColor colorWithRed:38.f / 255.f green:39.f / 255.f blue:43.f / 255.f alpha:1.f].CGColor;
                viewCurrentTimeline.layer.borderWidth = 1.f;
                viewCurrentTimeline.clipsToBounds = YES;
                viewCurrentTimeline.backgroundColor = [UIColor whiteColor];
                
                [viewTimlineForVideo addSubview:viewCurrentTimeline];
                
                [self _resumeCapture];
            }
            
            break;
        }
      case UIGestureRecognizerStateEnded:
      case UIGestureRecognizerStateCancelled:
      case UIGestureRecognizerStateFailed:
        {
            viewCaptureButton.alpha = 1.f;
            [self stopRecording];
            break;
        }
      default:
        break;
    }
}

- (void) stopRecording
{
    viewCaptureButton.alpha = 1.f;
    [self _pauseCapture];
    
    [[PBJVision sharedInstance] capturePhoto];
    
    [arrayTimelineViews addObject:viewCurrentTimeline];
}

- (void)_handleFocusTapGesterRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:_previewView];

    // auto focus is occuring, display focus view
    CGPoint point = tapPoint;
    
    CGRect focusFrame = _focusView.frame;
#if defined(__LP64__) && __LP64__
    focusFrame.origin.x = rint(point.x - (focusFrame.size.width * 0.5));
    focusFrame.origin.y = rint(point.y - (focusFrame.size.height * 0.5));
#else
    focusFrame.origin.x = rintf(point.x - (focusFrame.size.width * 0.5f));
    focusFrame.origin.y = rintf(point.y - (focusFrame.size.height * 0.5f));
#endif
    [_focusView setFrame:focusFrame];
    
    [_previewView addSubview:_focusView];
    [_focusView startAnimation];

    CGPoint adjustPoint = [PBJVisionUtilities convertToPointOfInterestFromViewCoordinates:tapPoint inFrame:_previewView.frame];
    [[PBJVision sharedInstance] focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:adjustPoint];
}

#pragma mark - PBJVisionDelegate

// session

- (void)visionSessionWillStart:(PBJVision *)vision
{
}

- (void)visionSessionDidStart:(PBJVision *)vision
{
    if (![_previewView superview]) {
        [self.view addSubview:_previewView];
        [self.view bringSubviewToFront:_gestureView];
    }
}

- (void)visionSessionDidStop:(PBJVision *)vision
{
}

// preview

- (void)visionSessionDidStartPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did start");
    
    if ([[PBJVision sharedInstance] cameraHasTorch]) {
        [[PBJVision sharedInstance] addObserver:self forKeyPath:@"torchMode" options:NSKeyValueObservingOptionNew context:CameraTorchModeObservationContext];
    }
    else {
        _flashButton.hidden = YES;
    }

}

- (void)visionSessionDidStopPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did stop");
    [_previewView removeFromSuperview];
}

// device

- (void)visionCameraDeviceWillChange:(PBJVision *)vision
{
    NSLog(@"Camera device will change");
}

- (void)visionCameraDeviceDidChange:(PBJVision *)vision
{
    NSLog(@"Camera device did change");
}

// mode

- (void)visionCameraModeWillChange:(PBJVision *)vision
{
    NSLog(@"Camera mode will change");
}

- (void)visionCameraModeDidChange:(PBJVision *)vision
{
    NSLog(@"Camera mode did change");
}

// format

- (void)visionOutputFormatWillChange:(PBJVision *)vision
{
    NSLog(@"Output format will change");
}

- (void)visionOutputFormatDidChange:(PBJVision *)vision
{
    NSLog(@"Output format did change");
}

- (void)vision:(PBJVision *)vision didChangeCleanAperture:(CGRect)cleanAperture
{
}

// focus / exposure

- (void)visionWillStartFocus:(PBJVision *)vision
{
}

- (void)visionDidStopFocus:(PBJVision *)vision
{
    if (_focusView && [_focusView superview]) {
        [_focusView stopAnimation];
    }
}

- (void)visionWillChangeExposure:(PBJVision *)vision
{
}

- (void)visionDidChangeExposure:(PBJVision *)vision
{
    if (_focusView && [_focusView superview]) {
        [_focusView stopAnimation];
    }
}

// flash

- (void)visionDidChangeFlashMode:(PBJVision *)vision
{
    NSLog(@"Flash mode did change");
}

// photo

- (void)visionWillCapturePhoto:(PBJVision *)vision
{
}

- (void)visionDidCapturePhoto:(PBJVision *)vision
{
}

- (void)vision:(PBJVision *)vision capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error
{
    if (self.m_nCaptureMode != PHOTO_CAPTURE_MODE)
        return;
    
    if (error) {
        // handle error properly
        [vision unfreezePreview];
        
        [[GlobalPool sharedObject] hideLoadingView:self.view];
        
        [g_Delegate AlertFailure:@"Encounted an error in photo capture, Please try again!"];
        
        return;
    }
    _currentPhoto = photoDict;

    // save to library
    UIImage *img = [_currentPhoto[PBJVisionPhotoImageKey] fixOrientation];//[[UIImage imageWithData:photoData] fixOrientation];
    img = [[GlobalPool sharedObject] scaleAndCropImage:img toSize:CGSizeMake(640, 640)];

    [vision unfreezePreview];
    
    [[GlobalPool sharedObject] hideLoadingView:self.view];
    
    /*
    [GlobalPool sharedObject].m_bEditFromInbox = false;
    
    CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:img delegate:nil];
    [self.navigationController pushViewController:editor animated:YES];
     */
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];

    /*
    PostViewController* viewCon = [storyboard instantiateViewControllerWithIdentifier:@"postview"];
    viewCon.m_imgFinal = img;
     */
    
    FilterViewController* viewCon = [storyboard instantiateViewControllerWithIdentifier:@"filterview"];
    viewCon.m_imgPost = img;
    
    [self.navigationController pushViewController:viewCon animated:YES];

    return;
    /*
    NSDictionary *metadata = _currentPhoto[PBJVisionPhotoMetadataKey];
   [_assetLibrary writeImageDataToSavedPhotosAlbum:photoData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error1) {
        if (error1 || !assetURL) {
            // handle error properly
            return;
        }
       
        NSString *albumName = @"PBJVision";
        __block BOOL albumFound = NO;
        [_assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                albumFound = YES;
                [_assetLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                    [group addAsset:asset];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photo Saved!" message: @"Saved to the camera roll."
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
                    [alert show];
                } failureBlock:nil];
            }
            if (!group && !albumFound) {
                __weak ALAssetsLibrary *blockSafeLibrary = _assetLibrary;
                [_assetLibrary addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group1) {
                    [blockSafeLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        [group1 addAsset:asset];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Photo Saved!" message: @"Saved to the camera roll."
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
                        [alert show];
                    } failureBlock:nil];
                } failureBlock:nil];
            }
        } failureBlock:nil];
    }];
    
    _currentPhoto = nil;
     */
}

// video capture

- (void)visionDidStartVideoCapture:(PBJVision *)vision
{
    _recording = YES;
}

- (void)visionDidPauseVideoCapture:(PBJVision *)vision
{
}

- (void)visionDidResumeVideoCapture:(PBJVision *)vision
{
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    if (self.m_nCaptureMode != VIDEO_CAPTURE_MODE)
        return;

    _recording = NO;

    [[GlobalPool sharedObject] hideLoadingView:self.view];

    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        NSLog(@"recording session cancelled");
        [[GlobalPool sharedObject] hideLoadingView:self.view];

        [g_Delegate AlertFailure:@"Recording session cancelled, Please try again!"];

        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);

        [g_Delegate AlertFailure:@"Encounted an error in video capture, Please try again!"];
        
        return;
    }

    _currentVideo = videoDict;

    /*
    CLVideoEditor *editor = [[CLVideoEditor alloc] initWithImage:[UIImage imageNamed:@"transparent.png"] delegate:nil];
    NSString *videoPath = [_currentVideo  objectForKey:PBJVisionVideoPathKey];
    
    [GlobalPool sharedObject].m_strVideoPath = videoPath;
    [GlobalPool sharedObject].m_bEditFromInbox = false;

    [self.navigationController pushViewController:editor animated:YES];
     */

    return;
    
    // added by Lee (Saved captured video to album)
//    NSString *videoPath = [_currentVideo  objectForKey:PBJVisionVideoPathKey];
    /*
    [_assetLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:videoPath] completionBlock:^(NSURL *assetURL, NSError *error1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Video Saved!" message: @"Saved to the camera roll."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }];
     */
}

// progress

- (void)vision:(PBJVision *)vision didCaptureVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
//    NSLog(@"captured audio (%f) seconds", vision.capturedAudioSeconds);
}

- (void)vision:(PBJVision *)vision didCaptureAudioSample:(CMSampleBufferRef)sampleBuffer
{
//    NSLog(@"captured video (%f) seconds", vision.capturedVideoSeconds);
    
    float fCurrentWidth = viewCurrentTimeline.frame.size.width;
    float fStep = CGRectGetWidth(self.view.frame) / MAX_VIDEO_RECORD_TIME * (vision.capturedVideoSeconds - fPrevTimeline);
    NSLog(@"prev = %f, step width = %f, total = %f", fPrevTimeline, fStep, fCurrentWidth);
    viewCurrentTimeline.frame = CGRectMake(viewCurrentTimeline.frame.origin.x, 0, fCurrentWidth + fStep, VIDEO_TIMELINE_HEIGHT);
    fPrevTimeline = vision.capturedVideoSeconds;
    
    if (viewCurrentTimeline.frame.origin.x + viewCurrentTimeline.frame.size.width >= self.view.frame.size.width)
    {
        bAlreadyLimited = true;
        [self stopRecording];
    }
}

@end
