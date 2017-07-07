//
//  SettingsViewController.m
//  reef
//
//  Created by iOSDevStar on 9/2/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "SettingsViewController.h"
#import "Global.h"
#import "ChangePasswordViewController.h"
#import "PrivacyViewController.h"
#import "MenuTabViewController.h"
#import "ProfileViewController.h"
#import "EditProfileViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Settings";
    
    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronCircleLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
    UIImage *imgBack = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];

    FAKFontAwesome *iconNext = [FAKFontAwesome angleRightIconWithSize:NAVI_ICON_SIZE];
    [iconNext addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR];
    UIImage *imgNext = [iconNext imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    
    self.m_imgIndicator1.image = imgNext;
    self.m_imgIndicator2.image = imgNext;
    self.m_imgIndicator3.image = imgNext;
    self.m_imgIndicator4.image = imgNext;
    self.m_imgIndicator5.image = imgNext;
    self.m_imgIndicator6.image = imgNext;
    self.m_imgIndicator7.image = imgNext;
    self.m_imgIndicator8.image = imgNext;
    
    self.m_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 524.f);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionSuggestion:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    ProfileViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"profileview"];
    [self.navigationController pushViewController:viewCon animated:YES];
    
    return;

    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    if (picker == nil)
    {
        [g_Delegate AlertWithCancel_btn:@"Not available to send mail."];
        return;
    }
    
    picker.mailComposeDelegate = self;
    
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor darkGrayColor];
    shadow.shadowOffset = CGSizeMake(.0f, .0f);
    picker.navigationBar.barTintColor = [UIColor whiteColor];
    picker.navigationBar.tintColor = NAVI_COLOR;
    picker.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                            [UIFont fontWithName:MAIN_BOLD_FONT_NAME size:20.f], NSFontAttributeName,
                                                            NAVI_COLOR, NSForegroundColorAttributeName,
                                                            shadow, NSShadowAttributeName,
                                                            nil];
    picker.navigationBar.translucent = NO;
    
    // Set the subject of email
    [picker setSubject:@"Suggestion / Feedback"];
    
    [picker setToRecipients:[NSArray arrayWithObjects:@"reefservices@gmail.com", nil]];

    NSString *emailBody = [NSString stringWithFormat:@"iOS Version : %@\r\nDevice Model : %@\r\nFrom \"reef\" App", [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] model]];
    [picker setMessageBody:emailBody isHTML:NO];

    // Show email view
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:picker animated:YES completion:nil];
    });
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

- (IBAction)actionShare:(id)sender {
    UIAlertController *inviteAlert=[UIAlertController alertControllerWithTitle:@"Invite Friends" message:@"Send invitation via" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *viaFB=[UIAlertAction actionWithTitle:@"Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction *Action){
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controller setInitialText:SHARE_TEXT];
        //        [controller setInitialText:@"Testing"];
        [controller addURL:[NSURL URLWithString:APP_STORE_LINK]];
        [controller addImage:[UIImage imageNamed:@"app_icon.png"]];
        [self presentViewController:controller animated:YES completion:Nil];
        
    }];
    
    UIAlertAction *viaTwitter=[UIAlertAction actionWithTitle:@"Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction *Action){
        
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:SHARE_TEXT];
        [self presentViewController:tweetSheet animated:YES completion:nil];
        
    }];
    
    UIAlertAction *viaEmail=[UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *Action){
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
        [mail setMessageBody:SHARE_TEXT isHTML:NO];
        
        [mail addAttachmentData:UIImageJPEGRepresentation([UIImage imageNamed:@"app_icon.png"], 1.0) mimeType:@"image/png" fileName:@"Icon.png"];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }];
    
    UIAlertAction *viaMessage=[UIAlertAction actionWithTitle:@"Message" style:UIAlertActionStyleDefault handler:^(UIAlertAction *Action){
        
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
        
        // Present message view controller on screen
        [self presentViewController:messageController animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *Action){
        
    }];
    
    [inviteAlert addAction:viaEmail];
    [inviteAlert addAction:viaFB];
    [inviteAlert addAction:viaMessage];
    [inviteAlert addAction:viaTwitter];
    [inviteAlert addAction:cancelAction];
    
    [self presentViewController:inviteAlert animated:YES completion:nil];
}

- (IBAction)actionPrivacy:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    PrivacyViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"privacyview"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
}

- (IBAction)actionRateUs:(id)sender {
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

- (IBAction)actionChangePassword:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    ChangePasswordViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"changepassview"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
}

- (IBAction)actionRemoveTempFiles:(id)sender {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:APP_FULL_NAME message:@"Are you sure to remove temporary files right now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alertView.tag = 200;
    [alertView show];
}

- (IBAction)actionLogout:(id)sender {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:APP_FULL_NAME message:@"Are you sure to log out right now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alertView.tag = 100;
    [alertView show];
}

- (IBAction)actionEditProfile:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    EditProfileViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"editprofileview"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100)
    {
        if (buttonIndex == 1)
        {
            [self doLogout];
        }
    }
    
    if (alertView.tag == 200)
    {
        if (buttonIndex == 1)
        {
            [self removeAllTempFiles];
        }
    }

}

- (void) removeAllTempFiles
{
    [self showLoadingView];
    
    NSString *extensionJPG = @"jpg";
    NSString *extensionMOV = @"mov";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        
        if ([[filename pathExtension] isEqualToString:extensionJPG] || [[filename pathExtension] isEqualToString:extensionMOV]) {
            
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
    }
    
    [self performSelector:@selector(hideLoadingView) withObject:nil afterDelay:3.f];
}

- (void) showLoadingView
{
    [[GlobalPool sharedObject] showLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
}

- (void) hideLoadingView
{
    [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
}

- (void) doLogout
{
    [[GlobalPool sharedObject] showLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];

    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"account/logout"];
    [manager POST: strRequestLink
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
              
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  [[GlobalPool sharedObject] saveLoginInfo:nil];
                  
                  /*
                  [[FacebookUtility sharedObject] logoutFromFacebook];
                  [[UserDefaultHelper sharedObject] setFacebookLoginRequest:nil];
                  [[UserDefaultHelper sharedObject] setFacebookUserDetail:nil];
                   */
                  
                  g_Delegate.m_bLogin = false;

                  [[GlobalPool sharedObject].m_curMenuTabViewCon.navigationController popToRootViewControllerAnimated:YES];
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

@end
