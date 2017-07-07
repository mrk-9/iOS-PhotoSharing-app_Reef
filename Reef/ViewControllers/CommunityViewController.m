//
//  CommunityViewController.m
//  Reef
//
//  Created by iOSDevStar on 12/25/15.
//  Copyright © 2015 iOSDevStar. All rights reserved.
//

#import "CommunityViewController.h"
#import "Global.h"
#import "UserProfileViewController.h"

@interface CommunityViewController ()

@end

@implementation CommunityViewController

@synthesize m_arrData;
@synthesize m_arrResult;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Community";

    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    self.menuTableView.scrollEnabled = NO;
    [self.menuTableView setFrame:CGRectMake(0,
                                              0,
                                              CGRectGetWidth(self.view.bounds),
                                              80.f)];

    fScrollHeight = 0.f;
    
    nSelectedRadius = 10;
    
    bShowPhotoBrowser = false;
    
    m_arrResult = [[NSMutableArray alloc] init];
    m_arrData = [[NSMutableArray alloc] init];

    self.m_lblWarning.hidden = YES;
    
    FAKFontAwesome *iconReload = [FAKFontAwesome refreshIconWithSize:NAVI_ICON_SIZE];
    [iconReload addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
    UIImage *imgReload = [iconReload imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgReload style:UIBarButtonItemStylePlain target:self action:@selector(reloadAllSubViews)];

    FAKFontAwesome *iconSetting = [FAKFontAwesome cogIconWithSize:NAVI_ICON_SIZE];
    [iconSetting addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
    UIImage *imgSetting = [iconSetting imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgSetting style:UIBarButtonItemStylePlain target:self action:@selector(onSettings)];
    
    bLoad = false;
    
    self.m_scrollView.delegate = self;
    self.m_scrollView.userInteractionEnabled = YES;
    
    arrayViewsForList = [[NSMutableArray alloc] init];
    
    bLoad = false;
    __weak CommunityViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [self.m_scrollView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadBelowMore];
    }];

    bPossibleLoadNext = false;
    nOffset = 0;
    strLastIndex = @"0";
    
    [self getArticlesList];
}

- (void) reloadAllSubViews
{
    [m_arrData removeAllObjects];
    [m_arrResult removeAllObjects];
    
    nOffset = 0;
    bPossibleLoadNext = false;
    strLastIndex = @"0";
    nPrevLoadCnt = 0;
    
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

- (void) getArticlesList
{
    self.m_lblWarning.text = @"";
    
    [m_arrData removeAllObjects];
    
    [[GlobalPool sharedObject] showLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
    
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strLatitude forHTTPHeaderField:@"Latitude"];
    
//    nSelectedRadius = 10000;
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"community/get_community_posts"];
    NSDictionary* params = @{@"radius":[NSString stringWithFormat:@"%d", nSelectedRadius], @"offset":[NSString stringWithFormat:@"%d", nOffset], @"end":strLastIndex};
    [manager POST: strRequestLink
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              [self.m_scrollView.infiniteScrollingView stopAnimating];
              
              [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
              
              [m_arrData  removeAllObjects];
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  m_arrData = [[responseObject valueForKey:@"posts"] mutableCopy];
                  
                  [m_arrResult addObjectsFromArray:m_arrData];
                  
                  self.m_scrollView.hidden = NO;

                  if (m_arrResult.count == 0)
                  {
                      self.m_scrollView.hidden = YES;
                      self.m_lblWarning.hidden = NO;
                      self.m_lblWarning.text = @"Please choose proper radius!";
                  }
                  
                  if (m_arrData.count >= MAX_COMMUNITY_PER_PAGE)
                  {
                      nOffset++;
                      strLastIndex = [responseObject valueForKey:@"last_index"];
                      bPossibleLoadNext = true;
                  }
                  else
                      bPossibleLoadNext = false;
                  
                  [self addPhotosByGridMode];
              }
              else
              {
                  if (m_arrResult.count == 0)
                  {
                      self.m_lblWarning.hidden = NO;
                      self.m_scrollView.hidden = YES;
                      self.m_lblWarning.text = [responseObject valueForKey:@"message"];
                  }
                  else
                  {
                      self.m_lblWarning.hidden = YES;
                      [g_Delegate AlertWithCancel_btn:[responseObject valueForKey:@"message"]];
                  }
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              [self.m_scrollView.infiniteScrollingView stopAnimating];
              
              [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
  
              if (m_arrResult.count == 0)
              {
                  self.m_scrollView.hidden = YES;
                  self.m_lblWarning.hidden = NO;
                  self.m_lblWarning.text = SOMETHING_WRONG;
              }
              else
              {
                  self.m_lblWarning.hidden = YES;
                  [g_Delegate AlertWithCancel_btn:SOMETHING_WRONG];
              }
          }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) onSettings
{
    //choose radius
    [self.menuTableView reloadData];
    
    [self showDropDownView];
}
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
    
    fScrollHeight = 0.f;
    
    nPrevLoadCnt = 0;
}

- (void) addPhotosByGridMode
{
    [[GlobalPool sharedObject] showLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
    
    float fImageViewWidth = self.view.frame.size.width / 3;
    
    [self removeAllPhotos];
    
    fScrollHeight += fImageViewWidth;
    
    for (int nIdx = nPrevLoadCnt; nIdx < m_arrResult.count; nIdx++)
    {
        int nCol = nIdx % 3;
        int nRow = nIdx / 3;
        
        NSDictionary* dictArticleInfo = [self.m_arrResult objectAtIndex:nIdx];
        
        float fRealSize = fImageViewWidth - 10.f;
        PostGridSubView *postView = [[[NSBundle mainBundle] loadNibNamed:@"PostGridSubView" owner:self options:nil] objectAtIndex:0];
        postView.frame = CGRectMake(0, 0, fRealSize, fRealSize);
        
        postView.delegate = self;
        postView.m_nIndex = nIdx;
        
        postView.m_postImageView.frame = CGRectMake(0, 0, fRealSize, fRealSize);
        postView.m_viewLoading.frame = CGRectMake(0, 0, fRealSize, fRealSize);
        postView.m_progressView.frame = CGRectMake(0, 0, fRealSize / 2.f, fRealSize / 2.f);
        postView.m_btnRefresh.frame = CGRectMake(0, 0, fRealSize / 2.f, fRealSize / 2.f);
        
        postView.m_progressView.center = CGPointMake(fRealSize / 2.f, fRealSize / 2.f);
        postView.m_btnRefresh.center = CGPointMake(fRealSize / 2.f, fRealSize / 2.f);
        
        postView.m_progressView.timeLimit = 100;
        postView.m_progressView.elapsedTime = 0;
        
        postView.center = CGPointMake((2 * nCol + 1) * fImageViewWidth / 2.f, 1 + (2 * nRow + 1) * fImageViewWidth / 2 + 10.f);
        
        postView.m_postImageView.hidden = NO;
        
        postView.m_strResourceURL = [NSString stringWithFormat:@"%@%@", IMAGEFOLDERPATH, [dictArticleInfo valueForKey:@"post_image"]];
        
        [postView downloadResourceFromServer];
        
        postView.layer.cornerRadius = fRealSize / 2.f;
        postView.layer.borderColor = GREEN_COLOR.CGColor;
        postView.layer.borderWidth = 2.f;
        postView.clipsToBounds = YES;
        
        [self.m_scrollView addSubview:postView];
        [arrayViewsForList addObject:postView];
        
        if (nIdx != 0 && nIdx % 3 == 0)
            fScrollHeight += fImageViewWidth;
        
    }
    
    nPrevLoadCnt = (int)self.m_arrResult.count;
    
    self.m_scrollView.scrollEnabled = YES;
    
    if (fScrollHeight < self.m_scrollView.frame.size.height)
        [self.m_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.m_scrollView.frame.size.height + 15.f)];
    else
        [self.m_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, fScrollHeight + 11)];
    
    [self performSelector:@selector(hideLoadingHubView) withObject:nil afterDelay:1.f];
}

- (void) hideLoadingHubView
{
    [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) actionShowFullScreenInGridView:(PostGridSubView *) subView withIndex:(int) nIndex
{
    bShowPhotoBrowser = true;
    
    [self.browserView showFromIndex:subView.m_nIndex];
}

#pragma mark tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LMMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    if (!cell) {
        cell = [[LMMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menuCell"];
    }

    cell.sliderRadius.value = (float)nSelectedRadius;
    cell.m_lblCurRadius.text = [NSString stringWithFormat:@"%d Miles", nSelectedRadius];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Dropdown menu delegate
#pragma mark - DROPDOWN VIEW

- (void)showDropDownView
{
    // Init dropdown view
    if (!dropdownView) {
        dropdownView = [LMDropdownView dropdownView];
        dropdownView.delegate = self;
        
        // Customize Dropdown style
        dropdownView.closedScale = 0.85;
        dropdownView.blurRadius = 5;
        dropdownView.blackMaskAlpha = 0.5;
        dropdownView.animationDuration = 0.5;
        dropdownView.animationBounceHeight = 20;
        //        dropdownView.contentBackgroundColor = [UIColor colorWithRed:40.0/255 green:196.0/255 blue:80.0/255 alpha:1];
    }
    
    // Show/hide dropdown view
    if ([dropdownView isOpen]) {
        [dropdownView hide];
    }
    else {
        [dropdownView showFromNavigationController:self.navigationController withContentView:self.menuTableView];
    }
}

- (void)dropdownViewWillShow:(LMDropdownView *)dropdownView
{
    NSLog(@"Dropdown view will show");
}

- (void)dropdownViewDidShow:(LMDropdownView *)dropdownView
{
    NSLog(@"Dropdown view did show");
}

- (void)dropdownViewWillHide:(LMDropdownView *)dropdownView
{
    NSLog(@"Dropdown view will hide");
}

- (void)dropdownViewDidHide:(LMDropdownView *)dropdownView
{
    NSLog(@"Dropdown view did hide");
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    LMMenuCell* curCell = (LMMenuCell *)[self.menuTableView cellForRowAtIndexPath:indexPath];
    
    if ((int)(curCell.sliderRadius.value) == nSelectedRadius)
        return;
    
    nSelectedRadius = (int)(curCell.sliderRadius.value);

    nPrevLoadCnt = 0;
    strLastIndex = @"0";
    bPossibleLoadNext = false;
    nOffset = 0;
    
    [self getArticlesList];
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
    
    NSString* strOriginalText = [[dictArticleInfo valueForKey:@"post_title"] stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    
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
    NSDictionary* dictArticleInfo = [self.m_arrResult objectAtIndex:index];
    
    if ([[dictArticleInfo valueForKey:@"username"] isEqualToString:[GlobalPool sharedObject].m_strCurUsername])
    {
        NSLog(@"clicked your avatar");
        return;
    }
    else
    {
        NSLog(@"user image view tag = %d", (int)index);
        [photoBrowser hideDisplayDetailView];
        
        NSLog(@"Dismiss the photo browser here");
        [self.browserView hideWithCompletion:^(BOOL finished){
            NSLog(@"Dismissed!");
            
            bShowPhotoBrowser = false;
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
            
            UserProfileViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"userprofileview"];
            viewCon.m_strUserName = [dictArticleInfo valueForKey:@"username"];
            viewCon.m_strUserID = [dictArticleInfo valueForKey:@"id"];
            
            [self.navigationController pushViewController:viewCon animated:YES];
        }];
    }
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
