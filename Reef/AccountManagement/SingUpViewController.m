//
//  SingUpViewController.m
//  reef
//
//  Created by iOSDevStar on 8/24/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "SingUpViewController.h"
#import "Global.h"
#import "PrivacyViewController.h"

@interface SingUpViewController ()

@end

@implementation SingUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    FAKFontAwesome *iconBack = [FAKFontAwesome chevronCircleLeftIconWithSize:NAVI_ICON_SIZE];
    [iconBack addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR];
    UIImage *imgBack = [iconBack imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    
    UIBarButtonItem* naviBackItem = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];
    self.navigationItem.leftBarButtonItem = naviBackItem;

    FAKFontAwesome *iconUserName = [FAKFontAwesome userIconWithSize:NAVI_ICON_SIZE];
    [iconUserName addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR];
    UIImage *imgUsername = [iconUserName imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];

    FAKFontAwesome *iconEmail = [FAKFontAwesome envelopeOIconWithSize:NAVI_ICON_SIZE];
    [iconEmail addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR];
    UIImage *imgEmail = [iconEmail imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];

    FAKFontAwesome *iconPhone = [FAKFontAwesome mobilePhoneIconWithSize:NAVI_ICON_SIZE];
    [iconPhone addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR];
    UIImage *imgPhone = [iconPhone imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];

    FAKFontAwesome *iconPassword = [FAKFontAwesome keyIconWithSize:NAVI_ICON_SIZE];
    [iconPassword addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR];
    UIImage *imgPassword = [iconPassword imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];

    //sign up view
    self.m_imgSignupUsername.image = imgUsername;
    self.m_imgSignupEmail.image = imgEmail;
    self.m_imgSignUpPass.image = imgPassword;
    self.m_imgSignUpConfrimPass.image = imgPassword;
    self.m_imgPhoneNumber.image = imgPhone;
    
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_signupUsernameView radius:self.m_signupEmailView.frame.size.height / 2.f backgroundcolor:[UIColor whiteColor] borderColor:[DARK_GRAY_COLOR colorWithAlphaComponent:1.f] borderWidth:0.f];
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_signupEmailView radius:self.m_signupEmailView.frame.size.height / 2.f backgroundcolor:[UIColor whiteColor] borderColor:[DARK_GRAY_COLOR colorWithAlphaComponent:1.f] borderWidth:0.f];
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_signupPhoneNumberView radius:self.m_signupEmailView.frame.size.height / 2.f backgroundcolor:[UIColor whiteColor] borderColor:[DARK_GRAY_COLOR colorWithAlphaComponent:1.f] borderWidth:0.f];
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_signupPassView radius:self.m_signupPassView.frame.size.height / 2.f backgroundcolor:[UIColor whiteColor] borderColor:[DARK_GRAY_COLOR colorWithAlphaComponent:1.f] borderWidth:0.f];
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_signupConfrimPassView radius:self.m_signupConfrimPassView.frame.size.height / 2.f backgroundcolor:[UIColor whiteColor] borderColor:[DARK_GRAY_COLOR colorWithAlphaComponent:1.f] borderWidth:0.f];
    
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_btnSignupDone radius:self.m_btnSignupDone.frame.size.height / 2.f backgroundcolor:GREEN_COLOR borderColor:[UIColor clearColor] borderWidth:0.f];
    
    self.m_txtSignupUsername.delegate = self;
    self.m_txtSignUpConfrimPass.delegate = self;
    self.m_txtSignupEmail.delegate = self;
    self.m_txtSignUpPass.delegate = self;
    self.m_txtPhoneNumber.delegate = self;
    
    self.m_userImageView.userInteractionEnabled = true;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGestureUserImageView)];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture setDelegate:self];
    [self.m_userImageView addGestureRecognizer:tapGesture];
    
    self.m_userImageView.layer.cornerRadius = self.m_userImageView.frame.size.height / 2.f;
    self.m_userImageView.clipsToBounds = YES;

    nSelectedCodeIdx = -1;
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGRect rectScreen = [[UIScreen mainScreen] bounds];
    
    if (textField == self.m_txtSignupUsername) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, -20, rectScreen.size.width, rectScreen.size.height);
        }];
        self.animated = YES;
    }
    
    if (textField == self.m_txtSignupEmail) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, -50, rectScreen.size.width, rectScreen.size.height);
        }];
        self.animated = YES;
    }

    if (textField == self.m_txtPhoneNumber) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, -80, rectScreen.size.width, rectScreen.size.height);
        }];
        self.animated = YES;
    }

    if (textField == self.m_txtSignUpPass) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, -110, rectScreen.size.width, rectScreen.size.height);
        }];
        self.animated = YES;
    }

    if (textField == self.m_txtSignUpConfrimPass) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, -140, rectScreen.size.width, rectScreen.size.height);
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
    self.m_userImageView.image = selectedImage;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.m_txtSignupUsername resignFirstResponder];
    [self.m_txtSignUpConfrimPass resignFirstResponder];
    [self.m_txtSignupEmail resignFirstResponder];
    [self.m_txtSignUpPass resignFirstResponder];
    [self.m_txtPhoneNumber resignFirstResponder];
}

- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)actionRegister:(id)sender
{
    [self.m_txtSignUpConfrimPass resignFirstResponder];
    [self.m_txtSignupEmail resignFirstResponder];
    [self.m_txtSignUpPass resignFirstResponder];
    [self.m_txtSignupUsername resignFirstResponder];
    [self.m_txtPhoneNumber resignFirstResponder];

    if (!selectedImage)
    {
        [g_Delegate AlertWithCancel_btn:@"Please choose your avatar!"];
        return;
    }
    
    if (self.m_txtSignupUsername.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please input name!"];
        return;
    }
    
    if (self.m_txtSignupEmail.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please input email address!"];
        return;
    }
    
    if (![[GlobalPool sharedObject] validateEmail:self.m_txtSignupEmail.text])
    {
        [g_Delegate AlertWithCancel_btn:@"Please input valid email address!"];
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
    
    if (self.m_txtSignUpPass.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please input password!"];
        return;
    }
    
    if (self.m_txtSignUpConfrimPass.text.length == 0 || ![self.m_txtSignUpConfrimPass.text isEqualToString:self.m_txtSignUpPass.text])
    {
        [g_Delegate AlertWithCancel_btn:@"Please confirm password!"];
        return;
    }
    
    selectedImage = [self imageWithImage:selectedImage scaledToSize:CGSizeMake(120.f, 120.f)];

    NSData* imageData = UIImageJPEGRepresentation(selectedImage, 0.8f);
    
    [[GlobalPool sharedObject] showLoadingView:self.navigationController.view];

    NSString* strUsername = [self.m_txtSignupUsername.text stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSDictionary *params = @ {@"username":strUsername, @"email":self.m_txtSignupEmail.text, @"password":self.m_txtSignUpPass.text, @"latitude":[GlobalPool sharedObject].m_strLatitude, @"longitude":[GlobalPool sharedObject].m_strLongitude, @"country":[GlobalPool sharedObject].m_strCountry, @"city":[GlobalPool sharedObject].m_strCity, @"phone":[NSString stringWithFormat:@"%@%@", [[GlobalPool sharedObject].m_arrPrefixDialingCodes objectAtIndex:nSelectedCodeIdx], self.m_txtPhoneNumber.text], @"code_index":[NSString stringWithFormat:@"%d", nSelectedCodeIdx]};
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"account/signup"];
    [manager POST: strRequestLink
            parameters:params
            constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                        [formData appendPartWithFileData:imageData name:@"avatar" fileName:@"avatar.jpg" mimeType:@"image/jpeg"];}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              [[GlobalPool sharedObject] hideLoadingView:self.navigationController.view];
              
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  NSMutableDictionary* dictLoginInfo = [[NSMutableDictionary alloc] init];
                  [dictLoginInfo setObject:self.m_txtSignupEmail.text forKey:@"email"];
                  [dictLoginInfo setObject:self.m_txtSignUpPass.text forKey:@"pass"];
                  [dictLoginInfo setObject:self.m_txtSignupUsername.text forKey:@"name"];
                  [dictLoginInfo setObject:[[responseObject valueForKey:@"userinfo"] valueForKey:@"avatar"] forKey:@"avatar"];
                  [dictLoginInfo setObject:@"email" forKey:@"loginmode"];
                  
                  [[GlobalPool sharedObject] saveLoginInfo:dictLoginInfo];

                  g_Delegate.m_bRegisterSuccess = true;
                  
                  UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:APP_FULL_NAME message:WELCOME_TEXT delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                  alertView.tag = 100;
                  [alertView show];
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

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)actionPrivacy:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    PrivacyViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"privacyview"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Create New Account";
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
