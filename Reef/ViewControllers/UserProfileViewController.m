//
//  UserProfileViewController.m
//  reef
//
//  Created by iOSDevStar on 8/15/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "UserProfileViewController.h"
#import "Global.h"
#import "MenuTabViewController.h"
#import "EditProfileViewController.h"
#import "SettingsViewController.h"
#import "UsersListViewController.h"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController
@synthesize m_arrData;
@synthesize m_arrResult;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = [self.m_strUserName stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    
    bShowPhotoBrowser = false;
    
    nIsFriend = 0;
    
    fScrollHeight = 0.f;
    fOverviewHeight = 0.f;
    
    m_arrResult = [[NSMutableArray alloc] init];
    m_arrData = [[NSMutableArray alloc] init];

    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronCircleLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
    UIImage *imgBack = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];

    bLoad = false;
    
    self.m_scrollView.delegate = self;
    self.m_scrollView.userInteractionEnabled = YES;
    
    arrayViewsForList = [[NSMutableArray alloc] init];
    
    nPrevLoadCnt = 0;
    
    bLoadMode = false;
    __weak UserProfileViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [self.m_scrollView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadBelowMore];
    }];

    [self getArticlesList];
}

- (void) loadBelowMore
{
    if (!bPossibleLoadNext)
    {
        [self.m_scrollView.infiniteScrollingView stopAnimating];
        
        if (bShowPhotoBrowser)
            [self.browserView stopScrollViewAnimation];

        return;
    }
    
    [self getArticlesList];
}

- (void) loadMoreRequestInPhotoBrowser
{
    [self loadBelowMore];
}

- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) getArticlesList
{
    [m_arrData removeAllObjects];
    
    [[GlobalPool sharedObject] showLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
    
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strLatitude forHTTPHeaderField:@"Latitude"];
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"account/view_profile"];
    NSDictionary* params = @{@"user_id":self.m_strUserID, @"offset":[NSString stringWithFormat:@"%d", nOffset]};
    [manager POST: strRequestLink
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [self.m_scrollView.infiniteScrollingView stopAnimating];

             [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
             
             [m_arrData  removeAllObjects];
             if ([[responseObject valueForKey:@"success"] boolValue])
             {
                 dictUserProfileInfo = [[responseObject valueForKey:@"result"] mutableCopy];
                 nIsFriend = (int)[[responseObject valueForKey:@"is_friend"] integerValue];
                 
                 [self loadUserProfileInfo];

                 m_arrData = [[responseObject valueForKey:@"posts"] mutableCopy];
                 
                 [m_arrResult addObjectsFromArray:m_arrData];
                 
                 if (m_arrData.count > 0)
                 {
                     nOffset = (int)[[[m_arrData lastObject] valueForKey:@"post_index"] longLongValue];
                     
                     bPossibleLoadNext = true;
                 }
                 else
                     bPossibleLoadNext = false;

                 [self addPhotosByListMode];
             }
             else
             {
                 [g_Delegate AlertWithCancel_btn:[responseObject valueForKey:@"message"]];
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [self.m_scrollView.infiniteScrollingView stopAnimating];

             [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
             
             [g_Delegate AlertWithCancel_btn:SOMETHING_WRONG];
         }];
    
}

- (void) loadUserProfileInfo
{
    if (bLoad)
        return;
    
    bLoad = true;
    
    FAKFontAwesome *naviReportIcon = [FAKFontAwesome flagIconWithSize:NAVI_ICON_SIZE];
    [naviReportIcon addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
    UIImage *imgReport = [naviReportIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    UIBarButtonItem* reportItem = [[UIBarButtonItem alloc] initWithImage:imgReport style:UIBarButtonItemStylePlain target:self action:@selector(reportUser)];

    self.navigationItem.rightBarButtonItem = reportItem;
    
    [self addProfileOverView];
}

- (void) reportUser
{
    [[GlobalPool sharedObject] showLoadingView:self.navigationController.view];
    
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];
    
    NSDictionary* dictInfo = [dictUserProfileInfo valueForKey:@"info"];
    
    NSString* strUserId = [dictInfo valueForKey:@"id"];
    
    NSDictionary *params = @ {@"id":strUserId};
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"account/report"];
    [manager POST: strRequestLink
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              [[GlobalPool sharedObject] hideLoadingView:self.navigationController.view];
              
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  [g_Delegate AlertWithCancel_btn:@"Reported successfully. Thank you!"];
              }
              else
              {
                  [g_Delegate AlertWithCancel_btn:[responseObject valueForKey:@"message"]];
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              
              [[GlobalPool sharedObject] hideLoadingView:self.navigationController.view];
              
              [g_Delegate AlertWithCancel_btn:SOMETHING_WRONG];
          }];
}

- (void) viewWillAppear:(BOOL)animated
{
}

- (void) onSettings
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    SettingsViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"settingsview"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
}

- (void) actionShowFollowers:(ProfileOverView *)subView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    UsersListViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"userlistview"];
    viewCon.m_bUserListMode = false;
    viewCon.m_strUserId = [dictUserProfileInfo valueForKey:@"id"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
}

- (void) actionShowFollowings:(ProfileOverView *)subView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    UsersListViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"userlistview"];
    viewCon.m_bUserListMode = true;
    viewCon.m_strUserId = [dictUserProfileInfo valueForKey:@"id"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
}

- (void) actionViewByList:(ProfileOverView *) subView
{
    bLoadMode = true;
    
    [self addPhotosByListMode];
}

- (void) actionFollowUser:(ProfileOverView *) subView
{
    __block int nFollowingCnt = (int)[[dictUserProfileInfo valueForKey:@"following"] integerValue];
    __block int nFollowerCnt = (int)[[dictUserProfileInfo valueForKey:@"followed"] integerValue];
    
    [[GlobalPool sharedObject] showLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
    
    bool bFollowRequest = false;
    NSString* strApi = @"";
    
    //follow Request
    if (nIsFriend == 1)
    {
        //unfollow
        bFollowRequest = false;
        strApi = @"friend/unfollow";
    }
    else
    {
        //follow
        bFollowRequest = true;
        strApi = @"friend/follow";
    }
    
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];
    
    NSDictionary *params = @ {@"user_id":self.m_strUserID};
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:strApi];
    
    [manager POST: strRequestLink
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
              
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  if (bFollowRequest)
                  {
                      [g_Delegate AlertSuccess:@"Subscribed successfully!"];
                      
                      nFollowerCnt++;
                      profileOverview.m_lblFollowers.text = [[GlobalPool sharedObject] convertSimpleNum:[NSString stringWithFormat:@"%d", nFollowingCnt]];
                      
                      [dictUserProfileInfo setValue:[NSString stringWithFormat:@"%d", nFollowingCnt] forKey:@"followed"];
                      
                      [profileOverview.m_btnFollow setTitle:@"Unsubscribe" forState:UIControlStateNormal];
                      [profileOverview.m_btnCircleSubscribe setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                      [profileOverview.m_btnCircleSubscribe setBackgroundColor:NAVI_COLOR];
                      [profileOverview.m_btnCircleSubscribe setTitle:@"Unsubscribe" forState:UIControlStateNormal];

                      nIsFriend = 1;
                  }
                  else
                  {
                      [g_Delegate AlertSuccess:@"Unsubscribed successfully!"];
                      
                      nFollowerCnt--;
                      profileOverview.m_lblFollowers.text = [[GlobalPool sharedObject] convertSimpleNum:[NSString stringWithFormat:@"%d", nFollowingCnt]];
                      
                      [dictUserProfileInfo setValue:[NSString stringWithFormat:@"%d", nFollowingCnt] forKey:@"followed"];
                      
                      [profileOverview.m_btnFollow setTitle:@"Subscribe" forState:UIControlStateNormal];
                      [profileOverview.m_btnCircleSubscribe setTitleColor:NAVI_COLOR forState:UIControlStateNormal];
                      [profileOverview.m_btnCircleSubscribe setBackgroundColor:[UIColor lightGrayColor]];
                      [profileOverview.m_btnCircleSubscribe setTitle:@"Subscribe" forState:UIControlStateNormal];

                      nIsFriend = 0;
                  }
                  
              }
              else
              {
                  [g_Delegate AlertWithCancel_btn:[responseObject valueForKey:@"message"]];
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              
              [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
              
              [g_Delegate AlertWithCancel_btn:SOMETHING_WRONG];
          }];
}

- (void) actionSendRequest:(ProfileOverView *) subView
{
    //send photo/video request
    [[GlobalPool sharedObject] showLoadingView:self.navigationController.view];
    
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strLongitude forHTTPHeaderField:@"Longitude"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strLatitude forHTTPHeaderField:@"Latitude"];
    
    NSDictionary* dictInfo = [dictUserProfileInfo valueForKey:@"info"];
    
    NSString* strUserId = [dictInfo valueForKey:@"id"];
    
    NSDictionary *params = @ {@"id":strUserId};
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"request-article"];
    [manager POST: strRequestLink
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              [[GlobalPool sharedObject] hideLoadingView:self.navigationController.view];
              
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  [g_Delegate AlertWithCancel_btn:@"Sent request successfully."];
              }
              else
              {
                  [g_Delegate AlertWithCancel_btn:[responseObject valueForKey:@"message"]];
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              
              [[GlobalPool sharedObject] hideLoadingView:self.navigationController.view];
              
              [g_Delegate AlertWithCancel_btn:SOMETHING_WRONG];
          }];
}

- (void) actionViewProfile:(ProfileOverView *)subView
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) tapGestureForImage:(UITapGestureRecognizer *) sender
{
    NSLog(@"tap");
}

- (void) removeAllPhotos
{
    for (int nIdx = 0; nIdx < arrayViewsForList.count; nIdx++)
    {
        ProfilePostView* postView = (ProfilePostView *)[arrayViewsForList objectAtIndex:nIdx];
        postView.hidden = YES;
        [postView removeFromSuperview];
    }
    
    [arrayViewsForList removeAllObjects];
    
    [[AFHTTPRequestOperationManager manager].operationQueue cancelAllOperations];
    
    fScrollHeight = fOverviewHeight;

    nPrevLoadCnt = 0;
    
}

- (void) addProfileOverView
{
    NSString* strFollowingCnt = [dictUserProfileInfo valueForKey:@"following"];
    NSString* strFollowerCnt = [dictUserProfileInfo valueForKey:@"followed"];
    NSString* strPostCnt = [dictUserProfileInfo valueForKey:@"posts"];
    
    NSString* strUserProfilePic = [dictUserProfileInfo valueForKey:@"avatar"];
    
    float fAvatarImageHeight = (CGRectGetWidth(self.view.frame) - 10.f) / 3.f;
    
    fOverviewHeight = fAvatarImageHeight + 20.f + 10.f + 30.f + 10.f;//PROFILE_OVERVIEW_INFO_HEIGHT;
    
    profileOverview = [[[NSBundle mainBundle] loadNibNamed:@"ProfileOverView" owner:self options:nil] objectAtIndex:0];
    profileOverview.delegate = self;
    profileOverview.frame = CGRectMake(0, 0, self.view.frame.size.width, fOverviewHeight);
    profileOverview.backgroundColor = [UIColor clearColor];
    
    [self.m_scrollView addSubview:profileOverview];
    profileOverview.userInteractionEnabled = YES;
    profileOverview.m_btnReport.hidden = YES;

    fScrollHeight = fOverviewHeight;
    
    profileOverview.m_userImageView.frame = CGRectMake(20.f, 20.f, fAvatarImageHeight, fAvatarImageHeight);
    profileOverview.m_btnCircleSubscribe.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 20.f - fAvatarImageHeight, 20.f, fAvatarImageHeight, fAvatarImageHeight);
    [profileOverview adjustUI];
    
    [[GlobalPool sharedObject] loadProfileImageFromServer:[NSString stringWithFormat:@"%@%@", AVATARFOLDERPATH, strUserProfilePic] imageView:profileOverview.m_userImageView withResult:^(UIImage* image)
     {
         NSLog(@"downloaded image");
     }];
    
    if (nIsFriend == 1)
    {
        [profileOverview.m_btnCircleSubscribe setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [profileOverview.m_btnCircleSubscribe setBackgroundColor:NAVI_COLOR];
        [profileOverview.m_btnCircleSubscribe setTitle:@"Unsubscribe" forState:UIControlStateNormal];
    }
    else
    {
        [profileOverview.m_btnCircleSubscribe setTitleColor:NAVI_COLOR forState:UIControlStateNormal];
        [profileOverview.m_btnCircleSubscribe setBackgroundColor:[UIColor lightGrayColor]];
        [profileOverview.m_btnCircleSubscribe setTitle:@"Subscribe" forState:UIControlStateNormal];
    }
    
    NSString* strCountry = [dictUserProfileInfo valueForKey:@"country"];
    NSString* strCity = [dictUserProfileInfo valueForKey:@"city"];

    if (strCountry.length == 0 && strCity.length == 0)
        profileOverview.m_lblLocation.text = @"Unknown Location";
    else
        profileOverview.m_lblLocation.text = [NSString stringWithFormat:@"%@, %@", strCountry, strCity];

    [profileOverview.m_lblLocation sizeToFit];

    float fPadding = 6.f;
    float fMaxWidth = CGRectGetWidth(self.view.frame) - CGRectGetWidth(profileOverview.m_imgLocationIcon.frame) -  fPadding - 10.f;
    
    float fLocationLabelWidth = CGRectGetWidth(profileOverview.m_lblLocation.frame);
    if (fLocationLabelWidth >= fMaxWidth)
        fLocationLabelWidth = fMaxWidth;
    
    float fTempX = (CGRectGetWidth(self.view.frame) - CGRectGetWidth(profileOverview.m_imgLocationIcon.frame) - fPadding - fLocationLabelWidth) / 2.f - 10.f;
    
    profileOverview.m_imgLocationIcon.center = CGPointMake(fTempX + CGRectGetWidth(profileOverview.m_imgLocationIcon.frame) / 2.f, profileOverview.m_imgLocationIcon.center.y);
    
    profileOverview.m_lblLocation.frame = CGRectMake(0, 0, fLocationLabelWidth, CGRectGetHeight(profileOverview.m_lblLocation.frame));
    profileOverview.m_lblLocation.center = CGPointMake(fTempX + CGRectGetWidth(profileOverview.m_imgLocationIcon.frame) + fPadding + fLocationLabelWidth / 2.f, profileOverview.m_imgLocationIcon.center.y);

    profileOverview.m_lblFollowers.text = [[GlobalPool sharedObject] convertSimpleNum:strFollowerCnt];
    profileOverview.m_lblFollowing.text = [[GlobalPool sharedObject] convertSimpleNum:strFollowingCnt];
    profileOverview.m_lblPosts.text = [[GlobalPool sharedObject] convertSimpleNum:strPostCnt];
    
    profileOverview.m_btnActionProfile.hidden = YES;
    profileOverview.m_btnFollow.hidden = NO;
    
}

- (NSString *) getLikeString:(int) nLikeCnt
{
    NSString *strLike = nil;
    
    if (nLikeCnt == 0)
        strLike = @"0 like";
    else if (nLikeCnt == 1)
        strLike = @"1 like";
    else
        strLike = [NSString stringWithFormat:@"%d likes", nLikeCnt];
    
    return strLike;
}

- (void) hideLoadingHubView
{
    [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
}

- (void) addPhotosByListMode
{
    [[GlobalPool sharedObject] showLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];

    [self removeAllPhotos];
    
    float fImageViewWidth = self.view.frame.size.width;
    
    for (int nIdx = nPrevLoadCnt; nIdx < m_arrResult.count; nIdx++)
    {
        NSDictionary* dictArticleInfo = [self.m_arrResult objectAtIndex:nIdx];

        NSString* strPostText = [dictArticleInfo valueForKey:@"post_title"];
        NSString* strOriginalText = [strPostText stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
        
        NSData *data = [strOriginalText dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];

        float fPostTextHeight = [[GlobalPool sharedObject] getHeightOfText:goodValue fontType:[UIFont fontWithName:MAIN_BOLD_FONT_NAME size:16.f] width:self.view.frame.size.width - 20.f] + 24.f;
        
        float fSubViewHeight = fPostTextHeight + fImageViewWidth;
        
        ProfilePostView *postView = [[[NSBundle mainBundle] loadNibNamed:@"ProfilePostView" owner:self options:nil] objectAtIndex:0];
        postView.frame = CGRectMake(0, 0, fImageViewWidth, fSubViewHeight);
        postView.center = CGPointMake(self.view.frame.size.width / 2.f, fScrollHeight + fSubViewHeight  / 2.f);

        postView.m_lblPostText.frame = CGRectMake(10.f, fImageViewWidth, fImageViewWidth - 20.f, fPostTextHeight);
        [postView.m_lblPostText setText:goodValue];

        postView.m_userImageView.image = [UIImage imageNamed:@"people-blank.png"];
        [[GlobalPool sharedObject] loadProfileImageFromServer:[NSString stringWithFormat:@"%@%@", AVATARFOLDERPATH, [dictArticleInfo valueForKey:@"avatar"]] imageView:postView.m_userImageView withResult:^(UIImage* image)
         {
             NSLog(@"downloaded image");
         }];
        
        postView.m_nIndex = nIdx;
        postView.delegate = self;
        postView.m_dictArticleInfo = dictArticleInfo;
        postView.m_btnDelete.hidden = YES;
        
        postView.m_lblUserName.text = [[GlobalPool sharedObject] checkNullValue:[dictArticleInfo valueForKey:@"username"]];
        postView.m_lblUserName.frame = CGRectMake(postView.m_lblUserName.frame.origin.x, postView.m_lblUserName.frame.origin.y, self.view.frame.size.width - 120.f, postView.m_lblUserName.frame.size.height);
        postView.m_lblTime.text = [[GlobalPool sharedObject] getElapsedTime:[[NSDate date] dateByAddingTimeInterval:-1 * [[dictArticleInfo valueForKey:@"created"] floatValue]]];
        [postView.m_lblTime sizeToFit];
        postView.m_lblTime.center = CGPointMake(fImageViewWidth - 5.f - postView.m_lblTime.frame.size.width / 2, postView.m_userImageView.center.y);
        postView.m_iconClock.center = CGPointMake(postView.m_lblTime.frame.origin.x - 5.f - postView.m_iconClock.frame.size.width / 2, postView.m_userImageView.center.y);
        
        postView.m_postImageView.frame = CGRectMake(0, 0, fImageViewWidth, fImageViewWidth);
        postView.m_btnViewPhoto.frame = CGRectMake(0, 0, fImageViewWidth, fImageViewWidth);
        postView.m_viewLoading.frame = CGRectMake(0, 0, fImageViewWidth, fImageViewWidth);
        postView.m_progressView.frame = CGRectMake(0, 0, fImageViewWidth / 2.f, fImageViewWidth / 2.f);
        postView.m_btnRefresh.frame = CGRectMake(0, 0, fImageViewWidth / 2.f, fImageViewWidth / 2.f);
        postView.m_btnDelete.frame = CGRectMake(fImageViewWidth - 20.f - 44.f, fImageViewWidth - 20.f - 44.f, 44.f, 44.f);
        postView.m_progressView.center = CGPointMake(fImageViewWidth / 2.f, fImageViewWidth / 2.f);
        postView.m_btnRefresh.center = CGPointMake(fImageViewWidth / 2.f, fImageViewWidth / 2.f);
        
        postView.m_progressView.timeLimit = 100;
        postView.m_progressView.elapsedTime = 0;
        
        postView.m_postImageView.hidden = NO;
        
        postView.m_strResourceURL = [NSString stringWithFormat:@"%@%@", IMAGEFOLDERPATH, [dictArticleInfo valueForKey:@"post_image"]];
        
        [postView downloadResourceFromServer];
        
        [self.m_scrollView addSubview:postView];
        [arrayViewsForList addObject:postView];
        
        fScrollHeight += fSubViewHeight;
    }
    
    nPrevLoadCnt = (int)self.m_arrResult.count;
    
    self.m_scrollView.scrollEnabled = YES;
    [self.m_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, fScrollHeight)];
    
    [self performSelector:@selector(hideLoadingHubView) withObject:nil afterDelay:1.f];
}

- (void) actionReportUser:(ProfileOverView *)subView
{
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) reportArticle
{
    [[GlobalPool sharedObject] showLoadingView:self.navigationController.view];
    
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];
    
    NSDictionary *params = @ {@"id":self.m_strUserID};
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"account/report"];
    [manager POST: strRequestLink
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              [[GlobalPool sharedObject] hideLoadingView:self.navigationController.view];
              
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  [g_Delegate AlertWithCancel_btn:@"Reported successfully. Thank you!"];
              }
              else
              {
                  [g_Delegate AlertWithCancel_btn:[responseObject valueForKey:@"message"]];
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              
              [[GlobalPool sharedObject] hideLoadingView:self.navigationController.view];
              
              [g_Delegate AlertWithCancel_btn:SOMETHING_WRONG];
          }];
}

#pragma mark ProfilePostView Delegate
- (void) onDeletePost:(ProfilePostView *)subView
{
}

- (void) onViewPhoto:(ProfilePostView *)subView
{
    bShowPhotoBrowser = true;
    
    [self.browserView showFromIndex:subView.m_nIndex];
}

#pragma mark PhotoBrowserView Delegate
#pragma mark - Getters
#pragma mark - AGPhotoBrowser datasource

- (void) updateViewedPhotoTime:(float)fViewedTime atIndex:(int)nIdx
{
    
}

- (NSInteger)numberOfPhotosForPhotoBrowser:(AGPhotoBrowserView *)photoBrowser
{
    return self.m_arrResult.count;
}

- (NSString *) photoBrowser:(AGPhotoBrowserView *)photoBrowser URLStringForImageAtIndex:(NSInteger)index
{
    NSDictionary* dictArticleInfo = [self.m_arrResult objectAtIndex:index];
    
    return [NSString stringWithFormat:@"%@%@", IMAGEFOLDERPATH, [dictArticleInfo valueForKey:@"post_image"]];
}

- (UIImage *)photoBrowser:(AGPhotoBrowserView *)photoBrowser imageAtIndex:(NSInteger)index
{
    return nil;
}

- (NSString *) photoBrowser:(AGPhotoBrowserView *)photoBrowser timeInfoForImageAtIndex:(NSInteger)index
{
    NSDictionary* dictArticleInfo = [self.m_arrResult objectAtIndex:index];
    
    return [[GlobalPool sharedObject] getElapsedTime:[[NSDate date] dateByAddingTimeInterval:-1 * [[dictArticleInfo valueForKey:@"created"] floatValue]]];
}

- (NSString *) photoBrowser:(AGPhotoBrowserView *)photoBrowser URLStringForUserImageAtIndex:(NSInteger)index
{
    NSDictionary* dictArticleInfo = [self.m_arrResult objectAtIndex:index];
    
    return [NSString stringWithFormat:@"%@%@", AVATARFOLDERPATH, [dictArticleInfo valueForKey:@"avatar"]];
}

- (NSString *)photoBrowser:(AGPhotoBrowserView *)photoBrowser titleForImageAtIndex:(NSInteger)index
{
    NSDictionary* dictArticleInfo = [self.m_arrResult objectAtIndex:index];
    
    return [dictArticleInfo valueForKey:@"username"];
}

- (NSString *)photoBrowser:(AGPhotoBrowserView *)photoBrowser descriptionForImageAtIndex:(NSInteger)index
{
    NSDictionary* dictArticleInfo = [self.m_arrResult objectAtIndex:index];
    
    NSString* strPostText = [dictArticleInfo valueForKey:@"post_title"];
    NSString* strOriginalText = [strPostText stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    
    NSData *data = [strOriginalText dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];

    return goodValue;
}

- (NSString *)photoBrowser:(AGPhotoBrowserView *)photoBrowser locationForUserAtIndex:(NSInteger)index
{
    NSDictionary* dictArticleInfo = [self.m_arrResult objectAtIndex:index];
    
    NSString* strCountry = [dictArticleInfo valueForKey:@"country"];
    NSString* strCity = [dictArticleInfo valueForKey:@"city"];
    
    if (strCountry.length == 0 && strCity.length == 0)
        return @"Unknown Location";
    else
        return [NSString stringWithFormat:@"%@, %@", strCountry, strCity];
}

- (BOOL)photoBrowser:(AGPhotoBrowserView *)photoBrowser willDisplayActionButtonAtIndex:(NSInteger)index
{
    // -- For testing purposes only
    /*
     if (index % 2) {
     return YES;
     }
     */
    return NO;
}


#pragma mark - AGPhotoBrowser delegate
- (void) photoBrowser:(AGPhotoBrowserView *)photoBrowser didTapOnUserInfo:(UIView *)actionView atIndex:(NSInteger)index
{
}

- (void)photoBrowser:(AGPhotoBrowserView *)photoBrowser didTapOnDoneButton:(UIButton *)doneButton
{
    // -- Dismiss
    NSLog(@"Dismiss the photo browser here");
    [self.browserView hideWithCompletion:^(BOOL finished){
        NSLog(@"Dismissed!");
        
        bShowPhotoBrowser = false;
    }];
}

- (void)photoBrowser:(AGPhotoBrowserView *)photoBrowser didTapOnActionButton:(UIButton *)actionButton atIndex:(NSInteger)index
{
    NSLog(@"Action button tapped at index %d!", (int)index);
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@""
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                          destructiveButtonTitle:NSLocalizedString(@"Delete", @"Delete button")
                                               otherButtonTitles:NSLocalizedString(@"Share", @"Share button"), nil];
    [action showInView:self.view];
}
- (AGPhotoBrowserView *)browserView
{
    if (!_browserView) {
        _browserView = [[AGPhotoBrowserView alloc] initWithFrame:CGRectZero];
        _browserView.delegate = self;
        _browserView.dataSource = self;
        _browserView.delegateForLoadMore = self;
    }
    
    return _browserView;
}

@end
