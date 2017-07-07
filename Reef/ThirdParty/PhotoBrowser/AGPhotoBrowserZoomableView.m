//
//  AGPhotoBrowserZoomableView.m
//  AGPhotoBrowser
//
//  Created by Dimitris-Sotiris Tsolis on 24/11/13.
//  Copyright (c) 2013 Andrea Giavatto. All rights reserved.
//

#import "AGPhotoBrowserZoomableView.h"


@interface AGPhotoBrowserZoomableView ()

@property (nonatomic, strong, readwrite) UIImageView *imageView;

@end

@implementation AGPhotoBrowserZoomableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.translatesAutoresizingMaskIntoConstraints = NO;
        self.delegate = self;
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.frame = frame;
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.minimumZoomScale = 1.0f;
        self.maximumZoomScale = 5.0f;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGesture];

        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(doubleTapped:)];
        doubleTap.numberOfTapsRequired = 2;
//        [self addGestureRecognizer:doubleTap];
        
//        [tapGesture requireGestureRecognizerToFail:doubleTap];

        [self addSubview:self.imageView];
    }
    return self;
}


#pragma mark - Public methods
- (UIImageView *) getImageView
{
    return self.imageView;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}


#pragma mark - Touch handling
- (void) handleTapGesture:(UITapGestureRecognizer *) gesturer
{
    if (gesturer.state == UIGestureRecognizerStateBegan)
    {
    }
    else if (gesturer.state == UIGestureRecognizerStateEnded)
    {
        if ([self.zoomableDelegate respondsToSelector:@selector(didDoubleTapZoomableView:state:)]) {
            [self.zoomableDelegate didDoubleTapZoomableView:self state:false];
        }
    }
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self.zoomableDelegate respondsToSelector:@selector(didDoubleTapZoomableView:state:)]) {
        [self.zoomableDelegate didDoubleTapZoomableView:self state:true];
    }

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.zoomableDelegate respondsToSelector:@selector(didDoubleTapZoomableView:state:)]) {
        [self.zoomableDelegate didDoubleTapZoomableView:self state:false];
    }

}

#pragma mark - Recognizer

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer
{
    return;
    
    if (self.zoomScale > 1.0f) {
        [UIView animateWithDuration:0.35 animations:^{
            self.zoomScale = 1.0f;
        }];
    } else {
        [UIView animateWithDuration:0.35 animations:^{
            CGPoint point = [recognizer locationInView:self];
            [self zoomToRect:CGRectMake(point.x, point.y, 0, 0) animated:YES];
        }];
    }
    
    if ([self.zoomableDelegate respondsToSelector:@selector(ViewingPhotoAsZoomMode:)])
        [self.zoomableDelegate ViewingPhotoAsZoomMode:self];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
