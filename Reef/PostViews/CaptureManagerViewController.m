//
//  CaptureManagerViewController.m
//  reef
//
//  Created by iOSDevStar on 8/15/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "CaptureManagerViewController.h"
#import "PBJCaptureViewController.h"
#import "Global.h"

@interface CaptureManagerViewController ()

@end

@implementation CaptureManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    curNavCon = nil;
    
    [self addPhotoCaptureViewCon];

    [GlobalPool sharedObject].m_curCaptureManagerViewCon = self;
}

- (void) viewWillAppear:(BOOL)animated
{
//    g_Delegate.m_statusBarBgView.backgroundColor = CAPTURE_VIEW_BG_COLOR;
}

- (void) backToMainView
{
    [GlobalPool sharedObject].m_curCaptureManagerViewCon = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showLoadingView
{
    [[GlobalPool sharedObject] showLoadingView:self.view];
}

- (void) hideLoadingView
{
    [[GlobalPool sharedObject] hideLoadingView:self.view];
}

- (void) addPhotoCaptureViewCon
{
    if (curNavCon)
    {
        [curNavCon willMoveToParentViewController:nil];
        [curNavCon.view removeFromSuperview];
        curNavCon = nil;
    }

    PBJCaptureViewController *viewCon = [[PBJCaptureViewController alloc] init];
    viewCon.m_parentObj = self;
    viewCon.m_nCaptureMode = PHOTO_CAPTURE_MODE;
    UINavigationController *naviViewCon = [[UINavigationController alloc] initWithRootViewController:viewCon];
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor darkGrayColor];
    shadow.shadowOffset = CGSizeMake(.0f, .0f);
    naviViewCon.navigationBar.barTintColor = NAVI_COLOR;
    naviViewCon.navigationBar.tintColor = [UIColor whiteColor];
    naviViewCon.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIFont fontWithName:MAIN_BOLD_FONT_NAME size:NAVI_FONT_SIZE], NSFontAttributeName,
                                                                   [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                   shadow, NSShadowAttributeName,
                                                                   nil];
    naviViewCon.navigationBar.translucent = NO;
    naviViewCon.navigationBarHidden = YES;
    
    [self addChildViewController:naviViewCon];
    [self.m_subView addSubview:naviViewCon.view];
    [naviViewCon didMoveToParentViewController:self];
    
    curNavCon = naviViewCon;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
