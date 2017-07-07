//
//  FeedViewController.m
//  reef
//
//  Created by iOSDevStar on 8/15/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "FeedViewController.h"
#import "Global.h"
#import "UIBarButtonItem+Badge.h"
#import "UserProfileViewController.h"
#import "MenuTabViewController.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"

@interface FeedViewController ()
@end

@implementation FeedViewController
@synthesize m_arrData;
@synthesize m_arrResult;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = APP_FULL_NAME;

    bShowPhotoBrowser = false;
    bStartTimer = false;
    timerAutoScroll = nil;
    nAutoScrollIndex = 0;
    
    bEOFLoading = false;
    
    FAKFontAwesome *iconReload = [FAKFontAwesome refreshIconWithSize:NAVI_ICON_SIZE];
    [iconReload addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
    UIImage *imgReload = [iconReload imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    UIBarButtonItem* barButtonReload = [[UIBarButtonItem alloc] initWithImage:imgReload style:UIBarButtonItemStylePlain target:self action:@selector(reloadAllSubViews)];

    FAKFontAwesome *iconSetting = [FAKFontAwesome cogIconWithSize:NAVI_ICON_SIZE];
    [iconSetting addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
    UIImage *imgSetting = [iconSetting imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    UIBarButtonItem* barButtonSetting = [[UIBarButtonItem alloc] initWithImage:imgSetting style:UIBarButtonItemStylePlain target:self action:@selector(onSettings)];

    //self.navigationItem.rightBarButtonItems = @[barButtonSetting, barButtonReload];
    self.navigationItem.rightBarButtonItem = barButtonSetting;
    
    FAKFontAwesome *iconSearch = [FAKFontAwesome searchIconWithSize:NAVI_ICON_SIZE];
    [iconSearch addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
    UIImage *imgSearach = [iconSearch imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgSearach style:UIBarButtonItemStylePlain target:self action:@selector(gotoSearchUser)];

    m_arrResult = [[NSMutableArray alloc] init];
    m_arrData = [[NSMutableArray alloc] init];
    arrayViewsForList = [[NSMutableArray alloc] init];
    
    self.m_scrollView.hidden = YES;
    self.m_tableView.hidden = NO;
    self.m_tableView.pagingEnabled = YES;
    self.m_tableView.scrollEnabled = NO;
    
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.tableFooterView = [[UIView alloc] init];
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.m_tableView.bounds.size.width, 0.01f)];
    
    self.m_tableView.contentInset = UIEdgeInsetsZero;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.m_lblWarning.hidden = YES;

    bPossibleLoadNext = false;
    nOffset = 0;

    __weak FeedViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [self.m_tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf tableViewScrollToBottomAnimated:YES];
        [weakSelf performSelector:@selector(loadBelowMore) withObject:nil afterDelay:0.3f];
    }];
    
    bFullScreenViewMode = false;
    
    fScrollCurPos = 0.f;
}

- (void)tableViewScrollToBottomAnimated:(BOOL)animated {
    CGSize csz = self.m_tableView.contentSize;
    CGSize bsz = self.m_tableView.bounds.size;
    if (self.m_tableView.contentOffset.y + bsz.height > csz.height) {
        [self.m_tableView setContentOffset:CGPointMake(self.m_tableView.contentOffset.x,
                                         csz.height - bsz.height)
                    animated:YES];
    }
    /*
    NSInteger numberOfRows = [self.m_tableView numberOfRowsInSection:0];
    if (numberOfRows) {
        [self.m_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
     */
}

- (void) onSettings
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    SettingsViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"settingsview"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
}

- (void) startAutoScrollTimer
{
    bStartTimer = true;
    if (timerAutoScroll)
    {
        [timerAutoScroll invalidate];
        timerAutoScroll = nil;
    }
    
    timerAutoScroll = [NSTimer scheduledTimerWithTimeInterval:AUTO_SCROLL_TIME_INTERVAL target:self selector:@selector(autoScrollTimerProc) userInfo:nil repeats:YES];
}

- (void) stopAutoScrollTimer
{
    bStartTimer = false;
    
    if (timerAutoScroll)
    {
        [timerAutoScroll invalidate];
        timerAutoScroll = nil;
    }
}

- (void) autoScrollTimerProc
{
    if (!bStartTimer)
        return;
    
    NSLog(@"timer is working");
    
    UITableViewScrollPosition eTableViewPos = UITableViewScrollPositionMiddle;
    
    nAutoScrollIndex++;

    NSTimeInterval timeInterval = -1 * [startDate timeIntervalSinceNow];
    
    startDate = [NSDate date];

    NSLog(@"submitted viewtime - index : %d, time : %f", (nAutoScrollIndex - 1), timeInterval);
    
    [self updateViewedPhotoTime:timeInterval atIndex:nAutoScrollIndex - 1];
    
    if (nAutoScrollIndex >= self.m_arrResult.count)
        nAutoScrollIndex = 0;
    
    if (nAutoScrollIndex == 0)
        eTableViewPos = UITableViewScrollPositionTop;
    else if (nAutoScrollIndex == self.m_arrResult.count - 1)
    {
        eTableViewPos = UITableViewScrollPositionBottom;
        
        [self loadBelowMore];
    }
    
    [self.m_tableView setContentOffset:CGPointMake(0, nAutoScrollIndex * CGRectGetHeight(self.m_tableView.frame)) animated:YES];
    /*
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:nAutoScrollIndex inSection:0];
    [self.m_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:eTableViewPos animated:YES];
     */
}

- (void) gotoSearchUser
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    SearchViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"searchview"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) makeBackNavigationItem
{
    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronCircleLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
    UIImage *imgBack = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self action:@selector(onBackPreviousViewCon)];

}

- (void) onBackPreviousViewCon
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    fScrollCurPos = scrollView.contentOffset.y;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    /*
    if (fScrollCurPos < (int)scrollView.contentOffset.y) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
    else if (fScrollCurPos > (int)scrollView.contentOffset.y) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
     */
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self stopAutoScrollTimer];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    
    [m_arrData removeAllObjects];
    [m_arrResult removeAllObjects];
    
    [self.m_tableView setContentOffset:CGPointZero
                              animated:YES];
    
    [self.m_tableView reloadData];
    
    nOffset = 0;
    bPossibleLoadNext = false;
    
    startDate = [NSDate date];
    [self getArticlesList];

}

- (void) loadBelowMore
{
    if (!bPossibleLoadNext)
    {
        [self.m_tableView.infiniteScrollingView stopAnimating];
        
        return;
    }
    
    [self stopAutoScrollTimer];
    
    [self getArticlesList];
}

- (void) loadMoreRequestInPhotoBrowser
{
    [self loadBelowMore];
}

- (void)insertRowAtBottom {
    __weak FeedViewController *weakSelf = self;
    
    int64_t delayInSeconds = 0.2f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (int nIdx = 0; nIdx < (int)weakSelf.m_arrData.count; nIdx++)
        {
            [weakSelf.m_tableView beginUpdates];
            [weakSelf.m_arrResult addObject:[weakSelf.m_arrData objectAtIndex:nIdx]];
            /*
            [weakSelf.m_tableView insertSections:[NSIndexSet indexSetWithIndex:weakSelf.m_arrResult.count-1] withRowAnimation:UITableViewRowAnimationTop];
             */
            [weakSelf.m_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.m_arrResult.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            [weakSelf.m_tableView endUpdates];
        }
        
        [weakSelf.m_tableView.infiniteScrollingView stopAnimating];
        
    });
}

- (void) getArticlesList
{
    self.m_lblWarning.text = @"";

    [[GlobalPool sharedObject] showLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
    
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];
    
    NSDictionary *params = nil;
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"post/list"];
    params = @{@"offset":[NSString stringWithFormat:@"%d", nOffset]};
    
    [manager POST: strRequestLink
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             
             [self.m_tableView.infiniteScrollingView stopAnimating];
             
             [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
             
             [m_arrData  removeAllObjects];
             if ([[responseObject valueForKey:@"success"] boolValue])
             {
                 m_arrData = [[responseObject valueForKey:@"posts"] mutableCopy];
                 if (m_arrData.count > 0)
                 {
                     nOffset = (int)[[[m_arrData lastObject] valueForKey:@"post_index"] longLongValue];
                     bPossibleLoadNext = true;
                 }
                 else
                     bPossibleLoadNext = false;
                 
//                 [m_arrResult addObjectsFromArray:m_arrData];

                 self.m_tableView.hidden = NO;

                 if (m_arrData.count == 0 && m_arrResult.count == 0)
                 {
                     self.m_tableView.hidden = YES;
                     self.m_lblWarning.hidden = NO;
                     self.m_lblWarning.text = @"Please post your photo!";
                 }

                 [self insertRowAtBottom];
                 
                 [self stopAutoScrollTimer];
                 
                 nAutoScrollIndex = 0;
                 [self startAutoScrollTimer];
                 
                 //[self addPhotosByListMode];
                 
                 bShowPhotoBrowser = true;
                 
//                 [self.browserView showFromIndex:0];

             }
             else
             {
                 if (m_arrResult.count == 0)
                 {
                     self.m_tableView.hidden = YES;
                     self.m_lblWarning.hidden = NO;
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
             
             [self.m_tableView.infiniteScrollingView stopAnimating];

             [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
             
             if (m_arrResult.count == 0)
             {
                 self.m_tableView.hidden = YES;
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
        
        postView.center = CGPointMake((2 * nCol + 1) * fImageViewWidth / 2.f, 1 + (2 * nRow + 1) * fImageViewWidth / 2);
        
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

- (void) hideLoadingHubView
{
    [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
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
    
    fScrollHeight = 0;
    
    nPrevLoadCnt = 0;
}

#pragma mark PostGribSubView Delegate
- (void) actionShowFullScreenInGridView:(PostGridSubView *)subView withIndex:(int)nIndex
{
    [self.browserView showFromIndex:nIndex];
}

- (void) reloadAllSubViews
{
    [m_arrData removeAllObjects];
    [m_arrResult removeAllObjects];
    
    [self.m_tableView reloadData];
//    [self removeAllPhotos];
    
    nOffset = 0;
    nPrevLoadCnt = 0;
    fScrollHeight = 0.f;
    bPossibleLoadNext = false;
    
    [self getArticlesList];
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

- (void) tapGestureUserImageView:(UITapGestureRecognizer *) sender
{
    UIImageView* userImageView = (UIImageView *)sender.view;
    int nTag = (int)userImageView.tag;
    
    NSLog(@"user image view tag = %d", nTag);
    NSDictionary* dictArticleInfo = [self.m_arrResult objectAtIndex:nTag];
    
    if ([[dictArticleInfo valueForKey:@"username"] isEqualToString:[GlobalPool sharedObject].m_strCurUsername])
    {
        [[GlobalPool sharedObject].m_curMenuTabViewCon actionChoose5:nil];
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
        
        UserProfileViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"userprofileview"];
        viewCon.m_strUserName = [dictArticleInfo valueForKey:@"username"];
        viewCon.m_strUserID = [dictArticleInfo valueForKey:@"user_id"];
        
        [self.navigationController pushViewController:viewCon animated:YES];
    }
}

/*
-(void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass: [UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView* castView = (UITableViewHeaderFooterView*) view;
        
        NSDictionary* dictArticleInfo = [self.m_arrResult objectAtIndex:section];

        UIView* content = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.f)];
        content.backgroundColor = [UIColor whiteColor];
        
        float fImageSize = 32.f;
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.f, 6.f, fImageSize, fImageSize)];
        imageView.image = [UIImage imageNamed:@"people-blank.png"];
        imageView.layer.cornerRadius = fImageSize / 2.f;
        imageView.layer.borderColor = GREEN_COLOR.CGColor;
        imageView.layer.borderWidth = 0.f;
        imageView.clipsToBounds = YES;
        imageView.tag = section;

        imageView.userInteractionEnabled = true;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGestureUserImageView:)];
        tapGesture.numberOfTapsRequired = 1;
        [tapGesture setDelegate:self];
        [imageView addGestureRecognizer:tapGesture];

        [[GlobalPool sharedObject] loadProfileImageFromServer:[NSString stringWithFormat:@"%@%@", AVATARFOLDERPATH, [dictArticleInfo valueForKey:@"avatar"]] imageView:imageView withResult:^(UIImage * image)
         {
             NSLog(@"downloaded image");
         }];

        UILabel* lblTime = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 100.f, 40.f)];
        lblTime.backgroundColor = [UIColor clearColor];
        lblTime.text = [[GlobalPool sharedObject] getElapsedTime:[[NSDate date] dateByAddingTimeInterval:-1 * [[dictArticleInfo valueForKey:@"created"] floatValue]]];
        lblTime.textColor = DARK_GRAY_COLOR;
        lblTime.font = [UIFont fontWithName:MAIN_FONT_NAME size:12.f];
        [lblTime sizeToFit];
        lblTime.center = CGPointMake(self.view.frame.size.width - 5.f - lblTime.frame.size.width / 2.f, 22.f);

        UIImageView* imgClock = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16.f, 16.f)];
        imgClock.image = [UIImage imageNamed:@"icon_time.png"];
        imgClock.center = CGPointMake(lblTime.center.x - 5.f - lblTime.frame.size.width / 2.f - 8.f, 22.f);

        [content addSubview:imageView];
        [content addSubview:lblTime];
        [content addSubview:imgClock];

        UILabel* lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(42.f, 2.f, 180.f, 40.f)];
        lblTitle.backgroundColor = [UIColor clearColor];
        
        lblTitle.text = [dictArticleInfo valueForKey:@"username"];
        lblTitle.textColor = DARK_GRAY_COLOR;
        lblTitle.font = [UIFont fontWithName:MAIN_FONT_NAME size:16.f];

        [content addSubview:lblTitle];
        
        [castView.contentView addSubview:content];
    }
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.f;//44.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.m_arrResult.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CGRectGetHeight(self.m_tableView.frame);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"customcell";
    
    FeedSubView *cell = [tableView
                         dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        /*
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PostSubView" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
         */
        cell = [[FeedSubView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [cell.contentView setUserInteractionEnabled:NO];

    NSDictionary* dictArticleInfo = [self.m_arrResult objectAtIndex:indexPath.row];
    
    cell.m_nIndex = (int)indexPath.section;
    cell.delegate = self;
    
    NSString* strPostText = [dictArticleInfo valueForKey:@"post_title"];
    NSString* strOriginalText = [strPostText stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    
    NSData *data = [strOriginalText dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];

    float fPostTextHeight = [[GlobalPool sharedObject] getHeightOfText:goodValue fontType:[UIFont fontWithName:MAIN_BOLD_FONT_NAME size:16.f] width:self.view.frame.size.width - 20.f] + 20.f;
    float fTableViewWidth = self.view.frame.size.width;
    float fTableViewHeight = self.m_tableView.frame.size.height;
    float fCenterX = (fTableViewHeight - fTableViewWidth) / 2.f;

    if (fPostTextHeight >= fCenterX)
        fPostTextHeight = fCenterX - 10.f;

    [[GlobalPool sharedObject] loadProfileImageFromServer:[NSString stringWithFormat:@"%@%@", AVATARFOLDERPATH, [dictArticleInfo valueForKey:@"avatar"]] imageView:cell.m_userImageView withResult:^(UIImage * image)
     {
         NSLog(@"downloaded image");
     }];
    
    cell.m_lblUsername.text = [dictArticleInfo valueForKey:@"username"];
    cell.m_lblTime.text = [[GlobalPool sharedObject] getElapsedTime:[[NSDate date] dateByAddingTimeInterval:-1 * [[dictArticleInfo valueForKey:@"created"] floatValue]]];

    NSString* strCountry = [dictArticleInfo valueForKey:@"country"];
    NSString* strCity = [dictArticleInfo valueForKey:@"city"];
    
    if (strCountry.length == 0 && strCity.length == 0)
        cell.m_lblLocation.text = @"Unknown Location";
    else
        cell.m_lblLocation.text = [NSString stringWithFormat:@"%@, %@", strCountry, strCity];

    cell.m_postImageView.frame = CGRectMake(0, fCenterX, fTableViewWidth, fTableViewWidth);
    cell.m_viewLoading.frame = CGRectMake(0, fCenterX, fTableViewWidth, fTableViewWidth);
    cell.m_progressView.center = CGPointMake(fTableViewWidth / 2.f, fTableViewWidth / 2.f);
    cell.m_btnRefresh.center = CGPointMake(fTableViewWidth / 2.f, fTableViewWidth / 2.f);
    cell.m_postImageView.tag = indexPath.row;
    cell.m_postImageView.hidden = NO;
    
    cell.m_lblPostText.frame = CGRectMake(10.f, fTableViewHeight - 5.f - fPostTextHeight, fTableViewWidth - 20.f, fPostTextHeight);
    [cell.m_lblPostText setText:goodValue];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.m_strResourceURL = [NSString stringWithFormat:@"%@%@", IMAGEFOLDERPATH, [dictArticleInfo valueForKey:@"post_image"]];
    
    [cell downloadResourceFromServer];
    
    return cell;
}

- (BOOL)isIndexPathVisible:(NSIndexPath*)indexPath
{
    NSArray *visiblePaths = [self.m_tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *currentIndex in visiblePaths)
    {
        NSComparisonResult result = [currentIndex compare:currentIndex];
        
        if(result == NSOrderedSame)
        {
            NSLog(@"Visible");
            return YES;
        }
    }
    
    return NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark FeedSubViewDelegate
- (void) touchDownView:(FeedSubView *) subView withIndex:(int) nSelectedIndex
{
    [self stopAutoScrollTimer];
}

- (void) touchUpView:(FeedSubView *) subView withIndex:(int) nSelectedIndex
{
    [self startAutoScrollTimer];
    [self autoScrollTimerProc];
}

#pragma mark PostSubView Delegate
- (void) onViewPhoto:(PostSubView *)subView
{
    bShowPhotoBrowser = true;
    
    [self.browserView showFromIndex:subView.m_nIndex];
}

#pragma mark PhotoBrowserView Delegate
#pragma mark - Getters
#pragma mark - AGPhotoBrowser datasource

- (void) updateViewedPhotoTime:(float)fViewedTime atIndex:(int)nIdx
{
    NSDictionary* dictArticleInfo = [self.m_arrResult objectAtIndex:nIdx];

    [[GlobalPool sharedObject] updatePhotoViewedTimeRequest:fViewedTime atIndex:[dictArticleInfo valueForKey:@"post_index"]];
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
