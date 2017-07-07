//
//  SearchViewController.m
//  reef
//
//  Created by iOSDevStar on 8/15/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "SearchViewController.h"
#import "Global.h"
#import "ProfileViewController.h"
#import "UserProfileViewController.h"
@import AddressBook;
@import AddressBookUI;

@interface SearchViewController ()

@property (nonatomic, assign) ABAddressBookRef addressBookRef;

@end

@implementation SearchViewController
@synthesize m_arrData;
@synthesize m_arrResult;
@synthesize m_arrContacts;
@synthesize m_arrFilterdContacts;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self makeCustomNavigationBar];
    
    strSearchText = @"";
    bSearchViewMode = true;
    
    m_arrResult = [[NSMutableArray alloc] init];
    m_arrData = [[NSMutableArray alloc] init];
    m_arrContacts = [[NSMutableArray alloc] init];
    m_arrFilterdContacts = [[NSMutableArray alloc] init];
    
    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronCircleLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
    UIImage *imgBack = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];
    
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.tableFooterView = [[UIView alloc] init];
    
    __weak SearchViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [self.m_tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadBelowMore];
    }];

    nOffset = 0;
    bPossibleLoadNext = false;
    
    [self makeSegmentedControl];
    
    [self loadUsers];
}

- (void) makeSegmentedControl
{
    int viewWidth = self.view.frame.size.width;
    
    NSInteger margin = 20;
    
    mainSegmentedControl = [[DVSwitch alloc] initWithStringsArray:@[@"Reef Users", @"Contacts"]];
    mainSegmentedControl.frame = CGRectMake(margin, 6, viewWidth - margin * 2, 32);
    [self.m_viewSegmentControl addSubview:mainSegmentedControl];
    
    __weak typeof(self) weakSelf = self;
    [mainSegmentedControl setPressedHandler:^(NSUInteger index) {
        if (index == 0)
        {
            [weakSelf loadUsers];
        }
        else
        {
            [weakSelf loadContacts];
        }
    }];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self makeCustomNavigationBar];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[self.navigationController.navigationBar viewWithTag:101] removeFromSuperview];
}

- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) loadContacts
{
    bSearchViewMode = false;
    
    ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getContactsFromAddressBook];
            });
        } else {
            // TODO: Show alert
        }
    });
}

- (NSString *)getMobilePhoneProperty:(ABMultiValueRef)phonesRef
{
    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if(currentPhoneLabel) {
            if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
            
            if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
        }
        if(currentPhoneLabel) {
            CFRelease(currentPhoneLabel);
        }
        if(currentPhoneValue) {
            CFRelease(currentPhoneValue);
        }
    }
    
    return nil;
}

- (void) getContactsFromAddressBook
{
    CFErrorRef error = NULL;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook) {
        NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSMutableArray *mutableContacts = [NSMutableArray arrayWithCapacity:allContacts.count];
        
        NSUInteger i = 0;
        for (i = 0; i<[allContacts count]; i++)
        {
            THContact *contact = [[THContact alloc] init];
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            contact.recordId = ABRecordGetRecordID(contactPerson);
            
            // Get first and last names
            NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            
            // Set Contact properties
            contact.firstName = firstName;
            contact.lastName = lastName;
            
            // Get mobile number
            ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            contact.phone = [self getMobilePhoneProperty:phonesRef];
            if(phonesRef) {
                CFRelease(phonesRef);
            }
            
            // Get image if it exists
            NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
            contact.image = [UIImage imageWithData:imgData];
            if (!contact.image) {
                contact.image = [UIImage imageNamed:@"people-blank.png"];
            }
            
            if (!contact.email && !contact.phone) continue;
            
            [mutableContacts addObject:contact];
        }
        
        if(addressBook) {
            CFRelease(addressBook);
        }
        
        self.m_arrContacts = mutableContacts;
        self.m_arrFilterdContacts = [self.m_arrContacts mutableCopy];
        
        [self.m_tableView reloadData];
    }
    else
    {
        NSLog(@"Error");
        
    }
}

- (void) loadUsers
{
    bSearchViewMode = true;
    
    self.m_searchBar.text = @"";
    self.m_searchBar.showsCancelButton = NO;
    [self.m_searchBar resignFirstResponder];

    strSearchText = @"";
    
    self.m_searchBar.placeholder = @"Search Friends";
    self.m_tableView.hidden = NO;
    
    nOffset = 0;
    bPossibleLoadNext = false;

    [m_arrResult removeAllObjects];
    [self.m_tableView reloadData];
    
    [self getUsersList];
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
    __weak SearchViewController *weakSelf = self;
    
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
    
    NSDictionary *params = @{@"keyword":strSearchText, @"offset":[NSString stringWithFormat:@"%d", nOffset]};
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"friend/search"];
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

- (void) makeCustomNavigationBar
{
    [[self.navigationController.navigationBar viewWithTag:101] removeFromSuperview];
    
    self.m_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(36.f, 0, CGRectGetWidth(self.view.frame) - 40, 44.f)];
    
    self.m_searchBar.backgroundColor = [UIColor clearColor];
    self.m_searchBar.barTintColor = [UIColor clearColor];
    self.m_searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    self.m_searchBar.tintColor = GREEN_COLOR;
    self.m_searchBar.tag = 101;
    self.m_searchBar.placeholder = @"Search Friends";
    
    self.m_searchBar.delegate = self;
    self.m_searchBar.tintColor = [UIColor whiteColor];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:14.f]}];
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    
    [self.m_searchBar setImage:[UIImage imageNamed:@"search_icon.png"]
              forSearchBarIcon:UISearchBarIconSearch
                         state:UIControlStateNormal];
    [self.m_searchBar setImage:[UIImage imageNamed:@"search_clear.png"]
              forSearchBarIcon:UISearchBarIconClear
                         state:UIControlStateNormal];

    self.navigationItem.titleView = self.m_searchBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.m_searchBar.text = @"";
    self.m_searchBar.showsCancelButton = YES;
    
    self.m_searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    strSearchText = self.m_searchBar.text;
//    [self doSearch];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.m_searchBar resignFirstResponder];
    
    //search
    strSearchText = self.m_searchBar.text;
    [self doSearch];
}

//user finished editing the search text
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.m_searchBar resignFirstResponder];
}

- (void)handleSearch:(UISearchBar *)searchBar {
    [self.m_searchBar resignFirstResponder];
}

//user tapped on the cancel button
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    self.m_searchBar.showsCancelButton = NO;
    
    [self.m_searchBar resignFirstResponder];
    
    self.m_searchBar.text = @"";
    
    strSearchText = @"";
    
    if (bSearchViewMode)
    {
        nOffset = 0;
        bPossibleLoadNext = false;
        
        [m_arrResult removeAllObjects];
        [m_arrData removeAllObjects];
        
        [self.m_tableView reloadData];
        [self getUsersList];
    }
    else
    {
        [self.m_arrFilterdContacts removeAllObjects];
        self.m_arrFilterdContacts = [self.m_arrContacts mutableCopy];
        
        [self.m_tableView reloadData];
    }
}

- (void) doSearch
{
    if (bSearchViewMode)
    {
        nOffset = 0;
        bPossibleLoadNext = false;
        nPrevLoadCnt = 0;
        fScrollHeight = 0.f;
        
        [m_arrResult removeAllObjects];
        [m_arrData removeAllObjects];
        
        [self.m_tableView reloadData];
        [self getUsersList];
    }
    else
    {
        [self.m_arrFilterdContacts removeAllObjects];
        
        for (int nIdx = 0; nIdx < self.m_arrContacts.count; nIdx++)
        {
            THContact* contact = [self.m_arrContacts objectAtIndex:nIdx];
            
            NSString* strFullName = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
            
            if ([strFullName rangeOfString:strSearchText].location != NSNotFound)
                [self.m_arrFilterdContacts addObject:contact];
        }
        
        [self.m_tableView reloadData];
    }
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
    if (bSearchViewMode)
        return self.m_arrResult.count;
    else
        return self.m_arrFilterdContacts.count;
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

    cell.m_viewLoading.hidden = YES;
    
    if (bSearchViewMode)
    {
        NSDictionary* dictUserInfo = [self.m_arrResult objectAtIndex:indexPath.row];
        
        cell.m_nIndex = (int)indexPath.row;
        cell.m_dictUserInfo = dictUserInfo;
        cell.delegate = self;
        cell.m_bUserMode = true;

        [[GlobalPool sharedObject] loadProfileImageFromServer:[NSString stringWithFormat:@"%@%@", AVATARFOLDERPATH, [dictUserInfo valueForKey:@"avatar"]] imageView:cell.m_imageView withResult:^(UIImage * image)
         {
             NSLog(@"downloaded image!");
         }];
        
        cell.m_lblName.text = [dictUserInfo valueForKey:@"username"];
        if ([[dictUserInfo valueForKey:@"is_following"] integerValue] == 0)
        {
            [cell.m_btnFollow setTitle:@"Subscribe" forState:UIControlStateNormal];
            [cell changeColorOfButton:DARK_GRAY_COLOR];
        }
        else
        {
            [cell.m_btnFollow setTitle:@"Unsubscribe" forState:UIControlStateNormal];
            [cell changeColorOfButton:GREEN_COLOR];
        }
    }
    else
    {
        cell.m_viewLoading.hidden = NO;
        
        THContact* contact = [self.m_arrFilterdContacts objectAtIndex:indexPath.row];
        cell.m_nIndex = (int)indexPath.row;
        cell.delegate = self;
        cell.m_bUserMode = false;
        
        cell.m_dictUserInfo = @{@"first_name":contact.firstName, @"last_name":contact.lastName, @"phone":[[GlobalPool sharedObject] checkNullValue:contact.phone], @"email":[[GlobalPool sharedObject] checkNullValue:contact.email]};

        cell.m_lblName.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
        cell.m_imageView.image = contact.image;

        [cell.m_btnFollow setTitle:@"..." forState:UIControlStateNormal];
        [cell changeColorOfButton:DARK_GRAY_COLOR];

        [cell checkUserWhetherExistsInApp];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (bSearchViewMode)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
        
        NSDictionary* dictUserInfo = [self.m_arrResult objectAtIndex:indexPath.row];
        
        UserProfileViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"userprofileview"];
        viewCon.m_strUserName = [dictUserInfo valueForKey:@"username"];
        viewCon.m_strUserID = [dictUserInfo valueForKey:@"id"];
        [self.navigationController pushViewController:viewCon animated:YES];
    }
}

- (void) sendInviation:(SearchUserCell *)subView withMode:(bool)bInviationMode withAddress:(NSString *)strAddress
{
    if (bInviationMode)
    {
        //email
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        if (mail == nil)
        {
            [g_Delegate AlertWithCancel_btn:@"Not available to send mail."];
            return;
        }
        
        NSShadow* shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor darkGrayColor];
        shadow.shadowOffset = CGSizeMake(.0f, .0f);
        mail.navigationBar.barTintColor = [UIColor whiteColor];
        mail.navigationBar.tintColor = NAVI_COLOR;
        mail.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [UIFont fontWithName:MAIN_BOLD_FONT_NAME size:20.f], NSFontAttributeName,
                                                  NAVI_COLOR, NSForegroundColorAttributeName,
                                                  shadow, NSShadowAttributeName,
                                                  nil];
        mail.navigationBar.translucent = NO;
        
        mail.mailComposeDelegate = self;
        [mail setSubject:APP_FULL_NAME];
        [mail setToRecipients:[NSArray arrayWithObjects:strAddress, nil]];
        [mail setMessageBody:SHARE_TEXT isHTML:NO];
        
        [self presentViewController:mail animated:YES completion:NULL];

    }
    else
    {
        //sms
        if(![MFMessageComposeViewController canSendText]) {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            return;
        }
        
        NSString *message = SHARE_TEXT;
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        
        NSShadow* shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor darkGrayColor];
        shadow.shadowOffset = CGSizeMake(.0f, .0f);
        messageController.navigationBar.barTintColor = [UIColor whiteColor];
        messageController.navigationBar.tintColor = NAVI_COLOR;
        messageController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                               [UIFont fontWithName:MAIN_BOLD_FONT_NAME size:20.f], NSFontAttributeName,
                                                               NAVI_COLOR, NSForegroundColorAttributeName,
                                                               shadow, NSShadowAttributeName,
                                                               nil];
        messageController.navigationBar.translucent = NO;
        
        messageController.messageComposeDelegate = self;
        [messageController setBody:message];
        [messageController setRecipients:[NSArray arrayWithObjects:strAddress, nil]];
        // Present message view controller on screen
        [self presentViewController:messageController animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Called once the email is sent
    // Remove the email view controller
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) actionFollowUser:(SearchUserCell *) subView withIndex:(int) nIndex
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:nIndex inSection:0];
    curSelectedCell = (SearchUserCell *)[self.m_tableView cellForRowAtIndexPath:indexPath];
    
    nCurSelectedIdx = nIndex;
    
    [self followUser:[[m_arrResult objectAtIndex:nIndex] valueForKey:@"id"]];
}

- (void) actionUnFollowUser:(SearchUserCell *) subView withIndex:(int) nIndex
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:nIndex inSection:0];
    curSelectedCell = (SearchUserCell *)[self.m_tableView cellForRowAtIndexPath:indexPath];
    
    nCurSelectedIdx = nIndex;
    
    [self unFollowUser:[[m_arrResult objectAtIndex:nIndex] valueForKey:@"id"]];
}

- (void) followUser:(NSString *) strSelectedUserId
{
    [[GlobalPool sharedObject] showLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
    
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];
    
    NSDictionary *params = @ {@"user_id":strSelectedUserId};
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"friend/follow"];
    
    [manager POST: strRequestLink
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
              
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  [g_Delegate AlertSuccess:@"Subscribed successfully!"];
                  
                  [curSelectedCell.m_btnFollow setTitle:@"UnSubscribe" forState:UIControlStateNormal];
                  [curSelectedCell changeColorOfButton:GREEN_COLOR];
                  
                  NSMutableDictionary* dictUserInfo = [[m_arrResult objectAtIndex:nCurSelectedIdx] mutableCopy];
                  [dictUserInfo setValue:@"1" forKey:@"is_following"];
                  curSelectedCell.m_dictUserInfo = dictUserInfo;
                  
                  [m_arrResult replaceObjectAtIndex:nCurSelectedIdx withObject:dictUserInfo];
                  
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

- (void) unFollowUser:(NSString *) strSelectedUserId
{
    [[GlobalPool sharedObject] showLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
    
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];
    
    NSDictionary *params = @ {@"user_id":strSelectedUserId};
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"friend/unfollow"];
    
    [manager POST: strRequestLink
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
              
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  [g_Delegate AlertSuccess:@"Unsubscribed successfully!"];
                  
                  [curSelectedCell.m_btnFollow setTitle:@"Subscribe" forState:UIControlStateNormal];
                  [curSelectedCell changeColorOfButton:DARK_GRAY_COLOR];

                  NSMutableDictionary* dictUserInfo = [[m_arrResult objectAtIndex:nCurSelectedIdx] mutableCopy];
                  [dictUserInfo setValue:@"0" forKey:@"is_following"];
                  curSelectedCell.m_dictUserInfo = dictUserInfo;
                  
                  [m_arrResult replaceObjectAtIndex:nCurSelectedIdx withObject:dictUserInfo];
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

- (void) hideLoadingHubView
{
    [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
}

@end
