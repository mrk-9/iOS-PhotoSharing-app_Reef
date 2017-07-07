//
//  FilterViewController.h
//  Reef
//
//  Created by iOSDevStar on 12/25/15.
//  Copyright © 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterViewController : UIViewController<UIGestureRecognizerDelegate>
{
    NSArray* arrayFilterNames;
    NSMutableArray* arraySubViews;
    
    UIImage* selImage;
    UIImage* filterImage;
    
    int nFilterIdx;
    
    NSTimer* timerFilter;
}

@property (nonatomic, strong) UIImage* m_imgPost;

@property (weak, nonatomic) IBOutlet UIView *m_viewImageCanvas;
@property (weak, nonatomic) IBOutlet UIImageView *m_postImageView;

@property (weak, nonatomic) IBOutlet UIScrollView *m_filterScrollView;

@end
