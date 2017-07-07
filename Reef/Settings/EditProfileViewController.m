//
//  EditProfileViewController.m
//  reef
//
//  Created by iOSDevStar on 9/2/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "EditProfileViewController.h"
#import "Global.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Edit Profile";
    
    selectedImage = nil;
    
    FAKFontAwesome *iconUserName = [FAKFontAwesome userIconWithSize:NAVI_ICON_SIZE];
    [iconUserName addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR];
    UIImage *imgUsername = [iconUserName imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.m_imgFullnameIcon.image = imgUsername;
    
    FAKFontAwesome *iconEmail = [FAKFontAwesome envelopeOIconWithSize:NAVI_ICON_SIZE];
    [iconEmail addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR];
    UIImage *imgEmail = [iconEmail imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.m_imgEmailIcon.image = imgEmail;

    FAKFontAwesome *iconPassword = [FAKFontAwesome keyIconWithSize:NAVI_ICON_SIZE];
    [iconPassword addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR];
    UIImage *imgPassword = [iconPassword imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.m_imgPassIcon.image = imgPassword;

    FAKFontAwesome *iconPhone = [FAKFontAwesome mobilePhoneIconWithSize:NAVI_ICON_SIZE];
    [iconPhone addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR];
    UIImage *imgPhone = [iconPhone imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.m_imgPhoneNumber.image = imgPhone;

    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_viewFullname radius:self.m_viewFullname.frame.size.height / 2.f backgroundcolor:[UIColor whiteColor] borderColor:[DARK_GRAY_COLOR colorWithAlphaComponent:1.f] borderWidth:0.f];
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_viewEmailAddress radius:self.m_viewEmailAddress.frame.size.height / 2.f backgroundcolor:[UIColor whiteColor] borderColor:[DARK_GRAY_COLOR colorWithAlphaComponent:1.f] borderWidth:0.f];
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_viewPhoneNumber radius:self.m_viewEmailAddress.frame.size.height / 2.f backgroundcolor:[UIColor whiteColor] borderColor:[DARK_GRAY_COLOR colorWithAlphaComponent:1.f] borderWidth:0.f];
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_viewPass radius:self.m_viewPass.frame.size.height / 2.f backgroundcolor:[UIColor whiteColor] borderColor:[DARK_GRAY_COLOR colorWithAlphaComponent:1.f] borderWidth:0.f];

    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronCircleLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
    UIImage *imgBack = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];

    FAKFontAwesome *naviIconCheck = [FAKFontAwesome checkCircleIconWithSize:NAVI_ICON_SIZE];
    [naviIconCheck addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
    UIImage *imgCheck = [naviIconCheck imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgCheck style:UIBarButtonItemStylePlain target:self action:@selector(onUpdateProfile)];

    NSDictionary* dictLoginInfo = [[GlobalPool sharedObject] getLoginInfo];

    NSString* strProfilePic = [NSString stringWithFormat:@"%@%@", AVATARFOLDERPATH, [[[GlobalPool sharedObject] getLoginInfo] valueForKey:@"avatar"]];
    
    UIImage* imageAvatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strProfilePic]]];
    selectedImage = imageAvatar;
    
    if (selectedImage)
        self.m_imgView.image = imageAvatar;
    
    self.m_txtEmail.text = [dictLoginInfo valueForKey:@"email"];
    self.m_txtPassword.text = [dictLoginInfo valueForKey:@"pass"];
    self.m_txtFullname.text = [GlobalPool sharedObject].m_strCurUsername;
    nSelectedCodeIdx = (int)[[dictLoginInfo valueForKey:@"code_index"] longLongValue];
    
    NSString* strCountryCode = [[GlobalPool sharedObject].m_arrPrefixDialingCodes objectAtIndex:nSelectedCodeIdx];
    [self.m_btnCountryCode setTitle:strCountryCode forState:UIControlStateNormal];
    self.m_txtPhoneNumber.text = [[dictLoginInfo valueForKey:@"phone"] substringFromIndex:strCountryCode.length];

    self.m_txtAboutMe.delegate = self;
    self.m_txtEmail.delegate = self;
    self.m_txtFullname.delegate = self;
    self.m_txtPassword.delegate = self;
    self.m_txtPhoneNumber.delegate = self;
    
    self.m_txtEmail.enabled = NO;
    self.m_txtPassword.enabled = NO;
    
    self.m_imgView.userInteractionEnabled = true;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGestureUserImageView)];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture setDelegate:self];
    [self.m_imgView addGestureRecognizer:tapGesture];

    self.m_imgView.layer.cornerRadius = self.m_imgView.frame.size.height / 2.f;
    self.m_imgView.clipsToBounds = YES;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) onUpdateProfile
{
    [self.m_txtEmail resignFirstResponder];
    [self.m_txtAboutMe resignFirstResponder];
    [self.m_txtFullname resignFirstResponder];
    [self.m_txtPassword resignFirstResponder];
    [self.m_txtPhoneNumber resignFirstResponder];

    if (!selectedImage)
    {
        [g_Delegate AlertWithCancel_btn:@"Please choose your photo!"];
        return;
    }
    
    if (self.m_txtFullname.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please input full name!"];
        return;
    }

    if (self.m_txtEmail.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please input email address!"];
        return;
    }
    
    if (nSelectedCodeIdx == -1)
    {
        [g_Delegate AlertWithCancel_btn:@"Please choose country code!"];
        return;
    }
    
    if (self.m_txtPhoneNumber.text.length == 0)
    {
        [g_Delegate AlertFailure:@"Please input phone number!"];
        return;
    }

    [[GlobalPool sharedObject] showLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
    
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];
    
    selectedImage = [self imageWithImage:selectedImage scaledToSize:CGSizeMake(120.f, 120.f)];
    
    NSData *imageData = UIImageJPEGRepresentation(selectedImage, 0.9f);

    NSDictionary *params = @ {@"username":self.m_txtFullname.text, @"phone":[NSString stringWithFormat:@"%@%@", [[GlobalPool sharedObject].m_arrPrefixDialingCodes objectAtIndex:nSelectedCodeIdx], self.m_txtPhoneNumber.text], @"code_index":[NSString stringWithFormat:@"%d", nSelectedCodeIdx]};
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"account/update_profile"];
    [manager POST: strRequestLink
       parameters:params
        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData name:@"avatar" fileName:@"avatar.jpg" mimeType:@"image/jpeg"];}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
              
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  [GlobalPool sharedObject].m_strCurUsername = self.m_txtFullname.text;
                  
                  NSMutableDictionary* dictLoginInfo = [[[GlobalPool sharedObject] getLoginInfo] mutableCopy];
                  [dictLoginInfo setValue:[[responseObject valueForKey:@"info"] valueForKey:@"avatar"] forKey:@"avatar"];
                  [dictLoginInfo setValue:[[responseObject valueForKey:@"info"] valueForKey:@"code_index"] forKey:@"code_index"];
                  [dictLoginInfo setValue:[[responseObject valueForKey:@"info"] valueForKey:@"phone"] forKey:@"phone"];
                  
                  [[GlobalPool sharedObject] saveLoginInfo:dictLoginInfo];
                  
                  [GlobalPool sharedObject].m_updatedProfileInfo = @{@"avatar":[[responseObject valueForKey:@"info"] valueForKey:@"avatar"]};

                  UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:APP_FULL_NAME message:@"Updated profile successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                  alertView.tag = 100;
                  [alertView show];

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

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100)
    {
        [self backToMainView];
    }
}

- (void) tapGestureUserImageView
{
    DBCameraViewController *cameraController = [DBCameraViewController initWithDelegate:self];
    [cameraController setForceQuadCrop:YES];
    
    DBCameraContainerViewController *container = [[DBCameraContainerViewController alloc] initWithDelegate:self];
    [container setCameraViewController:cameraController];
    [container setFullScreenMode];
    
    DemoNavigationController *nav = [[DemoNavigationController alloc] initWithRootViewController:container];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.m_txtEmail resignFirstResponder];
    [self.m_txtAboutMe resignFirstResponder];
    [self.m_txtFullname resignFirstResponder];
    [self.m_txtPassword resignFirstResponder];
    [self.m_txtPhoneNumber resignFirstResponder];
}

#pragma mark - DBCameraViewControllerDelegate

- (void) dismissCamera:(id)cameraViewController{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [cameraViewController restoreFullScreenMode];
}

- (void) camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata
{
    [cameraViewController restoreFullScreenMode];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    
    selectedImage = image;
    self.m_imgView.image = selectedImage;
}

- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardWillShow {
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
{
    CGRect rectScreen = [[UIScreen mainScreen] bounds];
    
    float fNaviHeight = 44.f;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.f)
        fNaviHeight += 20.f;
    
    if (textView == self.m_txtAboutMe) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, -80, rectScreen.size.width, rectScreen.size.height - fNaviHeight);
        }];
        self.animated = YES;
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGRect rectScreen = [[UIScreen mainScreen] bounds];
    
    if (textField == self.m_txtFullname) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, 0, rectScreen.size.width, rectScreen.size.height);
        }];
        self.animated = YES;
    }

    if (textField == self.m_txtPhoneNumber) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, -30, rectScreen.size.width, rectScreen.size.height);
        }];
        self.animated = YES;
    }

    if (textField == self.m_txtPassword) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, -60, rectScreen.size.width, rectScreen.size.height);
        }];
        self.animated = YES;
    }
    
    return YES;
}

-(void)keyboardWillHide {
    CGRect rectScreen = [[UIScreen mainScreen] bounds];
    
    float fNaviHeight = 44.f;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.f)
        fNaviHeight += 20.f;
    
    // Animate the current view back to its original position
    if (self.animated) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, fNaviHeight, rectScreen.size.width, rectScreen.size.height - fNaviHeight);
        }];
        self.animated = NO;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:POST_TEXT_PLACEHOLDER]) {
        textView.text = @"";
        textView.textColor = [UIColor darkGrayColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = POST_TEXT_PLACEHOLDER;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
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

- (IBAction)actionChooseCountryCode:(id)sender {
    [ActionSheetStringPicker showPickerWithTitle:@"Choose your country" rows:[GlobalPool sharedObject].m_arrCountryNames initialSelection:nSelectedCodeIdx >= 0 ? nSelectedCodeIdx : 0 target:self successAction:@selector(itemWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
}

- (void)itemWasSelected:(NSNumber *)selectedIndex element:(id)element {
    nSelectedCodeIdx = (int)[selectedIndex integerValue];
    
    [self.m_btnCountryCode setTitle:[[GlobalPool sharedObject].m_arrPrefixDialingCodes objectAtIndex:nSelectedCodeIdx] forState:UIControlStateNormal];
}

- (void)actionPickerCancelled:(id)sender {
    NSLog(@"Delegate has been informed that ActionSheetPicker was cancelled");
}

@end
