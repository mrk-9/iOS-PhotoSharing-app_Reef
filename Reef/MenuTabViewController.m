//
//  MenuTabViewController.m
//  reef
//
//  Created by iOSDevStar on 6/19/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "MenuTabViewController.h"
#import "FeedViewController.h"
#import "SearchViewController.h"
#import "ProfileViewController.h"
#import "Global.h"
#import "CaptureManagerViewController.h"
#import "CommunityViewController.h"

@interface MenuTabViewController ()
{
    JSBadgeView* homeBadge;
    JSBadgeView* messageBadge;
    JSBadgeView* requestBadge;
}

@end

@implementation MenuTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    FAKFontAwesome *naviBackIcon = [FAKFontAwesome timesCircleIconWithSize:16];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imageClose = [naviBackIcon imageWithSize:CGSizeMake(16, 16)];
    
    FAKFontAwesome *naviBackHighlightIcon = [FAKFontAwesome timesCircleIconWithSize:16];
    [naviBackHighlightIcon addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]];
    UIImage *imageHighlightClose = [naviBackHighlightIcon imageWithSize:CGSizeMake(16, 16)];
    
    [[UISearchBar appearance] setImage:imageClose forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    [[UISearchBar appearance] setImage:imageHighlightClose forSearchBarIcon:UISearchBarIconClear state:UIControlStateHighlighted];
    
    curNavCon = nil;
    
    homeBadge = [[JSBadgeView alloc] initWithParentView:self.m_tabIcon1 alignment:JSBadgeViewAlignmentTopRight];
    homeBadge.badgeText = [NSString stringWithFormat:@"%d", 0];
    homeBadge.hidden = YES;

    messageBadge = [[JSBadgeView alloc] initWithParentView:self.m_tabIcon4 alignment:JSBadgeViewAlignmentTopRight];
    messageBadge.badgeText = [NSString stringWithFormat:@"%d", 0];
    messageBadge.hidden = YES;

    requestBadge = [[JSBadgeView alloc] initWithParentView:self.m_tabIcon5 alignment:JSBadgeViewAlignmentTopRight];
    requestBadge.badgeText = [NSString stringWithFormat:@"%d", 0];
    requestBadge.hidden = YES;

    [self gotoHomeScreen];

    [self performSelector:@selector(loadNotifications) withObject:nil afterDelay:0.3f];
    
    [self showRatingAlertView];
}

- (void) loadNotifications
{
}

- (void) initAllViews
{
    self.m_view1.backgroundColor = [UIColor clearColor];
    self.m_tabIcon1.image = [UIImage imageNamed:@"home_green.png"];
    
    self.m_view2.backgroundColor = [UIColor clearColor];
    self.m_tabIcon2.image = [UIImage imageNamed:@"search_green.png"];

    self.m_view3.backgroundColor = [UIColor clearColor];
    self.m_tabIcon3.image = [UIImage imageNamed:@"camera_green.png"];

    self.m_view4.backgroundColor = [UIColor clearColor];
    self.m_tabIcon4.image = [UIImage imageNamed:@"message_green.png"];

    self.m_view5.backgroundColor = [UIColor clearColor];
    self.m_tabIcon5.image = [UIImage imageNamed:@"community_green.png"];

}

- (void) showRatingAlertView
{
    int nRatingPossible = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"rating"];
    
    long long lCurTime = [[[GlobalPool sharedObject] timeInMiliSeconds:[NSDate date]] longLongValue];
    long long lRatingTime = [((NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:@"rating_date"]) longLongValue];
    
    if ( (nRatingPossible == 0) || (nRatingPossible == 2 && (lCurTime - lRatingTime > RATING_CYCLE * 24 * 3600 * 1000)) )
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Rate Us" message:@"If you enjoy \'reef\', please take a moment to rate it! If not, let us know why in the \'Suggestion / Feedback\' section! Thanks for your support!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Rate", @"Later", @"No, thanks", nil];
        
        [alertView show];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self rateApp];
        
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"rating"];
        [[NSUserDefaults standardUserDefaults] setValue:[[GlobalPool sharedObject] timeInMiliSeconds:[NSDate date]] forKey:@"rating_date"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if (buttonIndex == 1)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"rating"];
        [[NSUserDefaults standardUserDefaults] setValue:[[GlobalPool sharedObject] timeInMiliSeconds:[NSDate date]] forKey:@"rating_date"];
        return;
    }
    else if (buttonIndex == 2)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"rating"];
        [[NSUserDefaults standardUserDefaults] setValue:[[GlobalPool sharedObject] timeInMiliSeconds:[NSDate date]] forKey:@"rating_date"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void) rateApp
{
    NSString *templateReviewURL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=APP_ID";
    NSString *templateReviewURLiOS7 = @"itms-apps://itunes.apple.com/app/idAPP_ID";
    NSString *templateReviewURLiOS8 = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=APP_ID&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software";
    
    //ios7 before
    NSString *reviewURL = [templateReviewURL stringByReplacingOccurrencesOfString:@"APP_ID" withString:ITUNES_APP_ID];
    
    // iOS 7 needs a different templateReviewURL @see https://github.com/arashpayan/appirater/issues/131
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 7.1) {
        reviewURL = [templateReviewURLiOS7 stringByReplacingOccurrencesOfString:@"APP_ID" withString:ITUNES_APP_ID];
    }
    // iOS 8 needs a different templateReviewURL also @see https://github.com/arashpayan/appirater/issues/182
    else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        reviewURL = [templateReviewURLiOS8 stringByReplacingOccurrencesOfString:@"APP_ID" withString:ITUNES_APP_ID];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [GlobalPool sharedObject].m_curMenuTabViewCon = self;
}

- (void) viewWillDisappear:(BOOL)animated
{
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) hideMenuTabView
{
    if (self.m_viewTab.center.y >= self.view.frame.size.height + MENU_TAB_HEIGHT / 2.f)
        return;
    
    [UIView animateWithDuration:INDICATOR_ANIMATION
                          delay:0.f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.m_viewTab.center = CGPointMake(self.m_viewTab.center.x, self.view.frame.size.height + MENU_TAB_HEIGHT / 2.f);
     }
                     completion:^(BOOL finished)
     {
     }];
}

- (void) showMenuTabView
{
    if (self.m_viewTab.center.y <= self.view.frame.size.height - MENU_TAB_HEIGHT / 2.f)
        return;
    
    [UIView animateWithDuration:INDICATOR_ANIMATION
                          delay:0.f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.m_viewTab.center = CGPointMake(self.m_viewTab.center.x, self.view.frame.size.height - MENU_TAB_HEIGHT / 2.f);
     }
                     completion:^(BOOL finished)
     {
     }];
}

- (void) gotoHomeScreen
{
    [self initAllViews];
    
    self.m_view1.backgroundColor = GREEN_COLOR;
    self.m_tabIcon1.image = [UIImage imageNamed:@"home_white.png"];

    if (curNavCon)
    {
        [curNavCon willMoveToParentViewController:nil];
        [curNavCon.view removeFromSuperview];
        curNavCon = nil;
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    FeedViewController *feedMainView = [storyboard instantiateViewControllerWithIdentifier:@"feedview"];
    UINavigationController *navFeedMainViewCon = [[UINavigationController alloc] initWithRootViewController:feedMainView];

    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor darkGrayColor];
    shadow.shadowOffset = CGSizeMake(.0f, .0f);
    navFeedMainViewCon.navigationBar.barTintColor = NAVI_COLOR;
    navFeedMainViewCon.navigationBar.tintColor = [UIColor whiteColor];
    navFeedMainViewCon.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIFont fontWithName:MAIN_BOLD_FONT_NAME size:NAVI_FONT_SIZE], NSFontAttributeName,
                                                                   [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                   shadow, NSShadowAttributeName,
                                                                   nil];
    navFeedMainViewCon.navigationBar.translucent = NO;
    navFeedMainViewCon.navigationBarHidden = NO;

    [self addChildViewController:navFeedMainViewCon];
    [self.m_subView addSubview:navFeedMainViewCon.view];
    [navFeedMainViewCon didMoveToParentViewController:self];
    
    curNavCon = navFeedMainViewCon;

}

- (IBAction)actionChoose1:(id)sender {
    [self gotoHomeScreen];
}

- (IBAction)actionChoose2:(id)sender {
}

- (IBAction)actionChoose3:(id)sender {
    //present taking photo and video view controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    CaptureManagerViewController *feedMainView = [storyboard instantiateViewControllerWithIdentifier:@"captureview"];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:feedMainView animated:YES completion:nil];
    });
}

- (IBAction)actionChoose4:(id)sender {
}

- (IBAction)actionChoose5:(id)sender {
    [self initAllViews];
    
    self.m_view5.backgroundColor = GREEN_COLOR;
    self.m_tabIcon5.image = [UIImage imageNamed:@"community_white.png"];
    
    if (curNavCon)
    {
        [curNavCon willMoveToParentViewController:nil];
        [curNavCon.view removeFromSuperview];
        curNavCon = nil;
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    /*
    ProfileViewController *feedMainView = [storyboard instantiateViewControllerWithIdentifier:@"profileview"];
     */
    CommunityViewController *feedMainView = [storyboard instantiateViewControllerWithIdentifier:@"communityview"];
    
    UINavigationController *navFeedMainViewCon = [[UINavigationController alloc] initWithRootViewController:feedMainView];

    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor darkGrayColor];
    shadow.shadowOffset = CGSizeMake(.0f, .0f);
    navFeedMainViewCon.navigationBar.barTintColor = NAVI_COLOR;
    navFeedMainViewCon.navigationBar.tintColor = [UIColor whiteColor];
    navFeedMainViewCon.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                            [UIFont fontWithName:MAIN_BOLD_FONT_NAME size:NAVI_FONT_SIZE], NSFontAttributeName,
                                                            [UIColor whiteColor], NSForegroundColorAttributeName,
                                                            shadow, NSShadowAttributeName,
                                                            nil];
    navFeedMainViewCon.navigationBar.translucent = NO;
    navFeedMainViewCon.navigationBarHidden = NO;

    [self addChildViewController:navFeedMainViewCon];
    [self.m_subView addSubview:navFeedMainViewCon.view];
    [navFeedMainViewCon didMoveToParentViewController:self];
    
    curNavCon = navFeedMainViewCon;
}

- (void) setBadgeForHomeIcon:(int) nBadge
{
    self.m_nCurInvitationAmount = nBadge;
    
    if (nBadge == 0)
    {
        homeBadge.hidden = YES;
    }
    else
    {
        homeBadge.hidden = NO;
        homeBadge.badgeText = [NSString stringWithFormat:@"%d", nBadge];
    }

    UIViewController* curViewCon = [[curNavCon viewControllers] lastObject];
    if ([curViewCon isKindOfClass:[FeedViewController class]])
    {
        FeedViewController* curFeedViewCon = (FeedViewController *)curViewCon;
    }
}

- (void) setBadgeForMessageIcon:(int) nBadge
{
    self.m_nCurMessageAmount = nBadge;
    
    if (nBadge == 0)
    {
        messageBadge.hidden = YES;
    }
    else
    {
        messageBadge.hidden = NO;
        messageBadge.badgeText = [NSString stringWithFormat:@"%d", nBadge];
    }
}

- (void) setBadgeForRequestIcon:(int)nBadge
{
    self.m_nCurRequestAmount = nBadge;
    
    if (nBadge == 0)
    {
        requestBadge.hidden = YES;
    }
    else
    {
        requestBadge.hidden = NO;
        requestBadge.badgeText = [NSString stringWithFormat:@"%d", nBadge];
    }
    
    UIViewController* curViewCon = [[curNavCon viewControllers] lastObject];
    if ([curViewCon isKindOfClass:[ProfileViewController class]])
    {
        ProfileViewController* curProfileViewCon = (ProfileViewController *)curViewCon;
        [curProfileViewCon addBadgeIntoBarButton:self.m_nCurRequestAmount];
    }

}

@end
