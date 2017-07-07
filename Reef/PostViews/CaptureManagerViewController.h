//
//  CaptureManagerViewController.h
//  reef
//
//  Created by iOSDevStar on 8/15/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaptureManagerViewController : UIViewController
{
    UINavigationController* curNavCon;
}

@property (weak, nonatomic) IBOutlet UIView *m_subView;

- (void) backToMainView;

- (void) hideLoadingView;

@end
