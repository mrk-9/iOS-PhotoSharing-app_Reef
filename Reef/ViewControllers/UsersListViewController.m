//
//  UsersListViewController.m
//  reef
//
//  Created by iOSDevStar on 9/6/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "UsersListViewController.h"
#import "Global.h"
#import "SearchUserCell.h"
#import "ProfileViewController.h"
#import "UserProfileViewController.h"

@interface UsersListViewController ()

@end

@implementation UsersListViewController
@synthesize m_arrData;
@synthesize m_arrResult;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.m_bUserListMode)
        self.navigationItem.title = @"Subscribings";
    else
        self.navigationItem.title = @"Subscribers";
    
    m_arrResult = [[NSMutableArray alloc] init];
    m_arrData = [[NSMutableArray alloc] init];

    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronCircleLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
    UIImage *imgBack = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];

    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.tableFooterView = [[UIView alloc] init];
    
    __weak UsersListViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [self.m_tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadBelowMore];
    }];
    
    nOffset = 0;
    bPossibleLoadNext = false;
    
    [self getUsersList];

}

- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) loadBelowMore
{
    if (!bPossibleLoadNext)
    {
        [self.m_tableView.infiniteScrollingView stopAnimating];
        return;
    }
    
    [self getUsersList];
}

- (void)insertRowAtBottom {
    __weak UsersListViewController *weakSelf = self;
    
    int64_t delayInSeconds = 0.2f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (int nIdx = (int)weakSelf.m_arrData.count - 1; nIdx >= 0; nIdx--)
        {
            [weakSelf.m_tableView beginUpdates];
            [weakSelf.m_arrResult addObject:[weakSelf.m_arrData objectAtIndex:nIdx]];
            [weakSelf.m_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.m_arrResult.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            [weakSelf.m_tableView endUpdates];
        }
        
        [weakSelf.m_tableView.infiniteScrollingView stopAnimating];
    });
}

- (void) getUsersList
{
    [[GlobalPool sharedObject] showLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
    
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];
    
    NSDictionary *params = @{@"user_id":self.m_strUserId, @"offset":[NSString stringWithFormat:@"%d", nOffset]};
    
    NSString* strAPIUrl = @"";
    if (self.m_bUserListMode)
    {
        strAPIUrl = @"friend/following_list";
    }
    else
    {
        strAPIUrl = @"friend/followed_list";
    }
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:strAPIUrl];
    [manager POST: strRequestLink
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              [self.m_tableView.infiniteScrollingView stopAnimating];
              
              [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
              
              [m_arrData  removeAllObjects];
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  m_arrData = [[responseObject valueForKey:@"users"] mutableCopy];
                  if (m_arrData.count >= MAX_USER_AMOUNT_PER_PAGE)
                  {
                      nOffset++;
                      bPossibleLoadNext = true;
                  }
                  else
                      bPossibleLoadNext = false;
                  
                  [self insertRowAtBottom];
              }
              else
              {
                  [g_Delegate AlertWithCancel_btn:[responseObject valueForKey:@"message"]];
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              
              [self.m_tableView.infiniteScrollingView stopAnimating];

              [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
              
              [g_Delegate AlertWithCancel_btn:SOMETHING_WRONG];
          }];
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.m_arrResult.count;
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
    static NSString *CellIdentifier = @"customcell";
    
    SearchUserCell *cell = [tableView
                            dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SearchUserCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    [cell.contentView setUserInteractionEnabled:NO];

    NSDictionary* dictUserInfo = [self.m_arrResult objectAtIndex:indexPath.row];
    
    cell.m_nIndex = (int)indexPath.row;
    cell.m_dictUserInfo = dictUserInfo;
    
    [[GlobalPool sharedObject] loadProfileImageFromServer:[NSString stringWithFormat:@"%@%@", AVATARFOLDERPATH, [dictUserInfo valueForKey:@"avatar"]] imageView:cell.m_imageView withResult:^(UIImage* image)
     {
         NSLog(@"downloaded image");
     }];
    
    cell.m_lblName.frame = CGRectMake(cell.m_lblName.frame.origin.x, cell.m_lblName.frame.origin.y, CGRectGetWidth(self.view.frame) - 20.f - CGRectGetWidth(cell.m_imageView.frame), CGRectGetHeight(cell.m_lblName.frame));
    
    cell.m_lblName.text = [dictUserInfo valueForKey:@"username"];
    cell.m_btnFollow.hidden = YES;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* dictUserInfo = [self.m_arrResult objectAtIndex:indexPath.row];

    if ([[dictUserInfo valueForKey:@"username"] isEqualToString:[GlobalPool sharedObject].m_strCurUsername])
    {
        [[GlobalPool sharedObject].m_curMenuTabViewCon actionChoose5:nil];
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
        
        UserProfileViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"userprofileview"];
        viewCon.m_strUserName = [dictUserInfo valueForKey:@"username"];
        viewCon.m_strUserID = [dictUserInfo valueForKey:@"id"];
        
        [self.navigationController pushViewController:viewCon animated:YES];
    }
}

@end
