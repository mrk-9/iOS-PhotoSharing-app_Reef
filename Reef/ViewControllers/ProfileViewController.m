//
//  ProfileViewController.m
//  reef
//
//  Created by iOSDevStar on 8/15/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "ProfileViewController.h"
#import "Global.h"
#import "MenuTabViewController.h"
#import "EditProfileViewController.h"
#import "SettingsViewController.h"
#import "UsersListViewController.h"
#import "UserProfileViewController.h"
#import "UIBarButtonItem+Badge.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController
@synthesize m_arrData;
@synthesize m_arrResult;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Manage My Posts";
    
    bShowPhotoBrowser = false;

    fScrollHeight = 0.f;
    fOverviewHeight = 0.f;
    
    bCheckedFullScreen = false;
    
    m_arrResult = [[NSMutableArray alloc] init];
    m_arrData = [[NSMutableArray alloc] init];

    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronCircleLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
    UIImage *imgBack = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];

    FAKFontAwesome *iconDelete = [FAKFontAwesome trashIconWithSize:NAVI_ICON_SIZE];
    [iconDelete addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
    UIImage *imgDelete = [iconDelete imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgDelete style:UIBarButtonItemStylePlain target:self action:@selector(onDeletePosts)];

    bLoad = false;
    
    self.m_scrollView.delegate = self;
    self.m_scrollView.userInteractionEnabled = YES;
    
    arrayViewsForList = [[NSMutableArray alloc] init];
    
    nPrevLoadCnt = 0;
    
    bLoadMode = false;
    __weak ProfileViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [self.m_scrollView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadBelowMore];
    }];

    [GlobalPool sharedObject].m_updatedProfileInfo = nil;
}

- (void) onDeletePosts
{
    int nSelectedPhotos = 0;
    for (int nIdx = 0; nIdx < arrayViewsForList.count; nIdx++) {
        PostGridSubView* subView = (PostGridSubView *)[arrayViewsForList objectAtIndex:nIdx];
        if (!subView.m_bSelected)
            continue;
        
        nSelectedPhotos++;
    }

    if (nSelectedPhotos == 0)
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:APP_FULL_NAME message:@"Please select posts to delete!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertView.tag = 200;
        
        [alertView show];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:APP_FULL_NAME message:@"Are you sure to delete selected posts?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertView.tag = 100;
        
        [alertView show];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100)
    {
        if (buttonIndex == 1)
        {
            [[GlobalPool sharedObject] showLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];

            [self performSelector:@selector(sendDeleteRequests) withObject:nil afterDelay:0.3f];
        }
    }
}

- (void) sendDeleteRequests
{
    // Create a dispatch group
    dispatch_group_t group = dispatch_group_create();
    
    for (int nIdx = 0; nIdx < arrayViewsForList.count; nIdx++) {
        PostGridSubView* subView = (PostGridSubView *)[arrayViewsForList objectAtIndex:nIdx];
        if (!subView.m_bSelected)
            continue;
        
        // Enter the group for each request we create
        dispatch_group_enter(group);
        
        NSDictionary* dictArticleInfo = [self.m_arrResult objectAtIndex:subView.m_nIndex];
        
        //send request
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
        [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];
        
        NSDictionary *params = @ {@"selected_id":[dictArticleInfo valueForKey:@"id"]};
        
        NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"post/delete"];
        
        [manager POST: strRequestLink
           parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"JSON: %@", responseObject);
                  
                  if ([[responseObject valueForKey:@"success"] boolValue])
                  {
                      [m_arrResult removeObjectAtIndex:subView.m_nIndex];
                  }
                  else
                  {
                  }
                  
                  dispatch_group_leave(group);
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error: %@", error);
                  
                  //                  [g_Delegate AlertWithCancel_btn:SOMETHING_WRONG];
                  dispatch_group_leave(group);
              }];
        
    }
    
    // Here we wait for all the requests to finish
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // Do whatever you need to do when all requests are finished
        [self performSelector:@selector(resetPhotoGridViews) withObject:nil afterDelay:0.3f];
    });
}

- (void) resetPhotoGridViews
{
    [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
    
    [g_Delegate AlertSuccess:@"Deleted successfully!"];
    
    [self addPhotosByListMode];
    
}

- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (void) actionFollowUser:(ProfileOverView *)subView
{
    
}

- (void) actionReportUser:(ProfileOverView *)subView
{
    
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
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"account/view_profile"];
    NSDictionary* params = @{@"user_id":[GlobalPool sharedObject].m_strCurUserID, @"offset":[NSString stringWithFormat:@"%d", nOffset]};
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
    
    [self addProfileOverView];
}

- (void) addBadgeIntoBarButton:(int) nBadge
{
    self.navigationItem.leftBarButtonItem.badgeBGColor = [UIColor redColor];
    self.navigationItem.leftBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d", nBadge];
}

- (void) viewWillAppear:(BOOL)animated
{
    if (bLoad && [GlobalPool sharedObject].m_updatedProfileInfo)
    {
        [[GlobalPool sharedObject] loadProfileImageFromServer:[NSString stringWithFormat:@"%@%@", AVATARFOLDERPATH, [[GlobalPool sharedObject].m_updatedProfileInfo valueForKey:@"avatar"]] imageView:profileOverview.m_userImageView withResult:^(UIImage * image)
        {
            NSLog(@"downloaded image");
        }];

        NSMutableDictionary* dictUserInfo = [[[GlobalPool sharedObject] getLoginInfo] mutableCopy];
        [dictUserInfo setValue:[[GlobalPool sharedObject].m_updatedProfileInfo valueForKey:@"avatar"] forKey:@"avatar"];

        [[GlobalPool sharedObject] saveLoginInfo:dictUserInfo];
    }

    bLoad = false;
    nOffset = 0;
    
    [self removeAllPhotos];

    [m_arrData removeAllObjects];
    [m_arrResult removeAllObjects];
    
    [self getArticlesList];

}

- (void) onSettings
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    SettingsViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"settingsview"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
}

- (void) actionShowFollowers:(ProfileOverView *)subView
{
    NSDictionary* dictLoginInfo = [[GlobalPool sharedObject] getLoginInfo];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    UsersListViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"userlistview"];
    viewCon.m_bUserListMode = false;
    viewCon.m_strUserId = [dictLoginInfo valueForKey:@"id"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
}

- (void) actionShowFollowings:(ProfileOverView *)subView
{
    NSDictionary* dictLoginInfo = [[GlobalPool sharedObject] getLoginInfo];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    UsersListViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"userlistview"];
    viewCon.m_bUserListMode = true;
    viewCon.m_strUserId = [dictLoginInfo valueForKey:@"id"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
}

- (void) actionViewByList:(ProfileOverView *) subView
{
    bLoadMode = true;
    [self addPhotosByListMode];
}

- (void) actionViewProfile:(ProfileOverView *)subView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    EditProfileViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"editprofileview"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
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
        PostGridSubView* postView = (PostGridSubView *)[arrayViewsForList objectAtIndex:nIdx];
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
    if (profileOverview)
    {
        profileOverview.hidden = YES;
        [profileOverview removeFromSuperview];
        profileOverview = nil;
    }
    
    NSString* strFollowingCnt = [dictUserProfileInfo valueForKey:@"following"];
    NSString* strFollowerCnt = [dictUserProfileInfo valueForKey:@"followed"];
    NSString* strPostCnt = [dictUserProfileInfo valueForKey:@"posts"];
    
    NSString* strUserProfilePic = [dictUserProfileInfo valueForKey:@"avatar"];
    
    [GlobalPool sharedObject].m_updatedProfileInfo = @{@"avatar":strUserProfilePic};

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
    
    profileOverview.m_userImageView.frame = CGRectMake((CGRectGetWidth(self.view.frame) - fAvatarImageHeight) / 2.f, 20.f, fAvatarImageHeight, fAvatarImageHeight);
    profileOverview.m_btnCircleSubscribe.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 20.f - fAvatarImageHeight, 20.f, fAvatarImageHeight, fAvatarImageHeight);
    profileOverview.m_btnCircleSubscribe.hidden = YES;
    [profileOverview adjustUI];
    
    profileOverview.m_btnReport.hidden = YES;
    
    profileOverview.frame = CGRectMake(0, 0, self.view.frame.size.width, fOverviewHeight);
    profileOverview.backgroundColor = [UIColor clearColor];
    
    [self.m_scrollView addSubview:profileOverview];
    profileOverview.userInteractionEnabled = YES;
    
    fScrollHeight = fOverviewHeight;

    [[GlobalPool sharedObject] loadProfileImageFromServer:[NSString stringWithFormat:@"%@%@", AVATARFOLDERPATH, strUserProfilePic] imageView:profileOverview.m_userImageView withResult:^(UIImage* image)
    {
        NSLog(@"downloaded image");
    }];

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
}

- (void) hideLoadingHubView
{
    [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
}

- (void) addPhotosByListMode
{
    [[GlobalPool sharedObject] showLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];

    [self removeAllPhotos];

    float fImageViewWidth = self.view.frame.size.width / 3;
    
    fScrollHeight += fImageViewWidth;

     for (int nIdx = nPrevLoadCnt; nIdx < m_arrResult.count; nIdx++)
    {
        int nCol = nIdx % 3;
        int nRow = nIdx / 3;

        NSDictionary* dictArticleInfo = [self.m_arrResult objectAtIndex:nIdx];

        NSString* strPostText = [dictArticleInfo valueForKey:@"post_title"];
        NSString* strOriginalText = [strPostText stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
        
        NSData *data = [strOriginalText dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];

        float fPostTextHeight = [[GlobalPool sharedObject] getHeightOfText:goodValue fontType:[UIFont fontWithName:MAIN_BOLD_FONT_NAME size:16.f] width:CGRectGetWidth(self.view.frame) - 20.f] + 20.f;
        
        float fSubViewHeight = fPostTextHeight + fImageViewWidth;

        PostGridSubView *postView = [[[NSBundle mainBundle] loadNibNamed:@"PostGridSubView" owner:self options:nil] objectAtIndex:0];
        postView.frame = CGRectMake(0, 0, fImageViewWidth, fImageViewWidth);
        postView.center = CGPointMake(self.view.frame.size.width / 2.f, fScrollHeight + fSubViewHeight  / 2.f);

        postView.delegate = self;
        postView.m_dictArticleInfo = dictArticleInfo;
        postView.m_nIndex = nIdx;
        
        postView.m_postImageView.frame = CGRectMake(0, 0, fImageViewWidth, fImageViewWidth);

        postView.m_viewLoading.frame = CGRectMake(0, 0, fImageViewWidth, fImageViewWidth);
        postView.m_progressView.frame = CGRectMake(0, 0, fImageViewWidth / 2.f, fImageViewWidth / 2.f);
        postView.m_btnRefresh.frame = CGRectMake(0, 0, fImageViewWidth / 2.f, fImageViewWidth / 2.f);
        
        postView.m_progressView.center = CGPointMake(fImageViewWidth / 2.f, fImageViewWidth / 2.f);
        postView.m_btnRefresh.center = CGPointMake(fImageViewWidth / 2.f, fImageViewWidth / 2.f);
        
        postView.m_progressView.timeLimit = 100;
        postView.m_progressView.elapsedTime = 0;
        
        postView.m_postImageView.hidden = NO;
        
        postView.m_strResourceURL = [NSString stringWithFormat:@"%@%@", IMAGEFOLDERPATH, [dictArticleInfo valueForKey:@"post_image"]];
        
        postView.center = CGPointMake((2 * nCol + 1) * fImageViewWidth / 2.f, 1 + fOverviewHeight + (2 * nRow + 1) * fImageViewWidth / 2);

        [postView downloadResourceFromServer];

        [self.m_scrollView addSubview:postView];
        [arrayViewsForList addObject:postView];
        
        [[GlobalPool sharedObject] makeRadiusView:postView withRadius:0.f withBorderColor:[UIColor clearColor] withBorderSize:0.f];

        if (nIdx != 0 && nIdx % 3 == 0)
            fScrollHeight += fImageViewWidth;

    }
    
    nPrevLoadCnt = (int)self.m_arrResult.count;

    self.m_scrollView.scrollEnabled = YES;
    [self.m_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, fScrollHeight + 1)];

    if (fScrollHeight < CGRectGetHeight(self.m_scrollView.frame))
        [self.m_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, CGRectGetHeight(self.m_scrollView.frame) + 60.f)];
        

    [self performSelector:@selector(hideLoadingHubView) withObject:nil afterDelay:1.f];
}

#pragma mark PostGribSubView Delegate
- (void) actionShowFullScreenInGridView:(PostGridSubView *)subView withIndex:(int)nIndex
{
    if (subView.m_bSelected)
        [[GlobalPool sharedObject] makeRadiusView:subView withRadius:0.f withBorderColor:NAVI_COLOR withBorderSize:2.f];
    else
        [[GlobalPool sharedObject] makeRadiusView:subView withRadius:0.f withBorderColor:[UIColor clearColor] withBorderSize:0.f];
}

#pragma mark ProfilePostView Delegate
- (void) onDeletePost:(ProfilePostView *)subView
{
    NSDictionary* dictArticleInfo = [self.m_arrResult objectAtIndex:subView.m_nIndex];
    
    [[GlobalPool sharedObject] showLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
    
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];
    
    NSDictionary *params = @ {@"selected_id":[dictArticleInfo valueForKey:@"id"]};
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"post/delete"];
    
    [manager POST: strRequestLink
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
              
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  [g_Delegate AlertSuccess:@"Deleted successfully!"];
                  
                  [m_arrResult removeObjectAtIndex:subView.m_nIndex];
                  
                  [self addPhotosByListMode];
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
