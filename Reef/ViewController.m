//
//  ViewController.m
//  Reef
//
//  Created by iOSDevStar on 12/18/15.
//  Copyright © 2015 iOSDevStar. All rights reserved.
//

#import "ViewController.h"
#import "Global.h"
#import "MenuTabViewController.h"
#import "ForgotPasswordViewController.h"
#import "SingUpViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor darkGrayColor];
    shadow.shadowOffset = CGSizeMake(.0f, .0f);
    self.navigationController.navigationBar.barTintColor = NAVI_COLOR;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIFont fontWithName:MAIN_BOLD_FONT_NAME size:NAVI_FONT_SIZE], NSFontAttributeName,
                                                                   [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                   shadow, NSShadowAttributeName,
                                                                   nil];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBarHidden = YES;
    
    FAKFontAwesome *iconBack = [FAKFontAwesome chevronCircleLeftIconWithSize:NAVI_ICON_SIZE];
    [iconBack addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR];
    UIImage *imgBack = [iconBack imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    
    UIBarButtonItem* naviBackItem = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];
    self.navigationItem.leftBarButtonItem = naviBackItem;
    
    FAKFontAwesome *iconEmail = [FAKFontAwesome envelopeOIconWithSize:NAVI_ICON_SIZE];
    [iconEmail addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR];
    UIImage *imgEmail = [iconEmail imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    
    FAKFontAwesome *iconPassword = [FAKFontAwesome keyIconWithSize:NAVI_ICON_SIZE];
    [iconPassword addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR];
    UIImage *imgPassword = [iconPassword imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    
    FAKFontAwesome *iconQuestion = [FAKFontAwesome questionCircleIconWithSize:NAVI_ICON_SIZE];
    [iconQuestion addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR];
    UIImage *imgQuestion = [iconQuestion imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    
    self.m_loginView.hidden = NO;
    
    //login view
    self.m_imgLoginEmail.image = imgEmail;
    self.m_imgLoginPass.image = imgPassword;
    [self.m_btnForgot setImage:imgQuestion forState:UIControlStateNormal];
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_loginEmailView radius:self.m_loginEmailView.frame.size.height / 2.f backgroundcolor:[UIColor whiteColor] borderColor:[[UIColor clearColor] colorWithAlphaComponent:1.f] borderWidth:0.f];
    
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_loginPassView radius:self.m_loginPassView.frame.size.height / 2.f backgroundcolor:[UIColor whiteColor] borderColor:[[UIColor clearColor] colorWithAlphaComponent:1.f] borderWidth:0.f];
    
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_btnLogin radius:self.m_btnLogin.frame.size.height / 2.f backgroundcolor:[UIColor whiteColor] borderColor:[UIColor clearColor] borderWidth:0.f];
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_btnSignup radius:self.m_btnLogin.frame.size.height / 2.f backgroundcolor:BLUE_COLOR borderColor:[UIColor clearColor] borderWidth:0.f];
    
    self.m_txtLoginEmail.delegate = self;
    self.m_txtLoginPass.delegate = self;
    
    g_Delegate.m_bRegisterSuccess = false;
    
}

- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    self.m_txtLoginEmail.text = @"";
    self.m_txtLoginPass.text = @"";
    
    if (g_Delegate.m_bRegisterSuccess)
    {
        g_Delegate.m_bRegisterSuccess = false;
        
        NSDictionary* dictLoginInfo = [[GlobalPool sharedObject] getLoginInfo];
        [self doLogin:[dictLoginInfo valueForKey:@"email"] withPass:[dictLoginInfo valueForKey:@"pass"]];
        
        return;
    }
    
    [self performSelector:@selector(checkAutoLogin) withObject:nil afterDelay:1.f];
}

- (IBAction)actionLogin:(id)sender {
    if (self.m_txtLoginEmail.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please input email address!"];
        return;
    }
    
    if (![[GlobalPool sharedObject] validateEmail:self.m_txtLoginEmail.text])
    {
        [g_Delegate AlertWithCancel_btn:@"Please input valid email address!"];
        return;
    }
    
    if (self.m_txtLoginPass.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please input password!"];
        return;
    }
    
    [self.m_txtLoginEmail resignFirstResponder];
    [self.m_txtLoginPass resignFirstResponder];
    
    [self doLogin:self.m_txtLoginEmail.text withPass:self.m_txtLoginPass.text];
}

- (void) checkAutoLogin
{
    if ([[GlobalPool sharedObject] getLoginInfo])
    {
        NSDictionary* dictLoginInfo = [[GlobalPool sharedObject] getLoginInfo];
        [self doLogin:[dictLoginInfo valueForKey:@"email"] withPass:[dictLoginInfo valueForKey:@"pass"]];
    }
}

- (void) doLogin:(NSString *) strEmail withPass:(NSString *) strPass
{
    self.m_txtLoginEmail.text = strEmail;
    self.m_txtLoginPass.text = strPass;
    
    [[GlobalPool sharedObject] showLoadingView:self.view];
    
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSDictionary *params = @ {@"email":strEmail, @"password":strPass, @"device_id":[GlobalPool sharedObject].m_strDeviceToken, @"device_type":@"ios", @"latitude":[GlobalPool sharedObject].m_strLatitude, @"longitude":[GlobalPool sharedObject].m_strLongitude, @"country":[GlobalPool sharedObject].m_strCountry, @"city":[GlobalPool sharedObject].m_strCity};
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"account/login"];
    [manager POST: strRequestLink
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              [[GlobalPool sharedObject] hideLoadingView:self.view];
              
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  [GlobalPool sharedObject].m_strAccessToken = [responseObject valueForKey:@"Access-Token"];
                  [GlobalPool sharedObject].m_strCurUsername = [[responseObject valueForKey:@"userinfo"] valueForKey:@"username"];
                  [GlobalPool sharedObject].m_strCurUserID = [[responseObject valueForKey:@"userinfo"] valueForKey:@"id"];
                  
                  NSMutableDictionary* dictLoginInfo = [[NSMutableDictionary alloc] init];
                  [dictLoginInfo setValue:strEmail forKey:@"email"];
                  [dictLoginInfo setValue:strPass forKey:@"pass"];
                  [dictLoginInfo setValue:@"email" forKey:@"loginmode"];
                  [dictLoginInfo setValue:[[responseObject valueForKey:@"userinfo"] valueForKey:@"avatar"] forKey:@"avatar"];
                  [dictLoginInfo setValue:[[responseObject valueForKey:@"userinfo"] valueForKey:@"id"] forKey:@"id"];
                  [dictLoginInfo setValue:[[responseObject valueForKey:@"userinfo"] valueForKey:@"phone"] forKey:@"phone"];
                  [dictLoginInfo setValue:[[responseObject valueForKey:@"userinfo"] valueForKey:@"code_index"] forKey:@"code_index"];
                  
                  [[GlobalPool sharedObject] saveLoginInfo:dictLoginInfo];
                  
                  [self gotoHomeView];
              }
              else
              {
                  [g_Delegate AlertWithCancel_btn:[responseObject valueForKey:@"message"]];
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              
              [[GlobalPool sharedObject] hideLoadingView:self.view];
              
              [g_Delegate AlertWithCancel_btn:SOMETHING_WRONG];
          }];
    
}

- (IBAction)actionRegister:(id)sender {
    
}

- (IBAction)actionGotoForgot:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ForgotPasswordViewController* viewCon = [storyboard instantiateViewControllerWithIdentifier:@"forgotpassview"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
    
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

- (void) viewWillDisappear:(BOOL)animated
{
    [self.m_txtLoginEmail resignFirstResponder];
    [self.m_txtLoginPass resignFirstResponder];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.m_txtLoginEmail resignFirstResponder];
    [self.m_txtLoginPass resignFirstResponder];
}

-(void)keyboardWillShow {
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGRect rectScreen = [[UIScreen mainScreen] bounds];
    
    if (textField == self.m_txtLoginEmail) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, -60, rectScreen.size.width, rectScreen.size.height);
        }];
        self.animated = YES;
    }
    
    if (textField == self.m_txtLoginPass) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, -90, rectScreen.size.width, rectScreen.size.height);
        }];
        self.animated = YES;
    }
    
    return YES;
}

- (void) showLoadingView
{
    MBProgressHUD *progressHUB = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressHUB];
    progressHUB.tag = LOADING_OTHER_HUB_TAG + 1;
    
    [progressHUB show:YES];
    
}

- (void) hideLoadingView
{
    MBProgressHUD* progressHUB = (MBProgressHUD *)[self.view viewWithTag:LOADING_OTHER_HUB_TAG + 1];
    if (progressHUB)
    {
        [progressHUB hide:YES];
        [progressHUB removeFromSuperview];
        progressHUB = nil;
    }
}

-(void)keyboardWillHide {
    CGRect rectScreen = [[UIScreen mainScreen] bounds];
    
    // Animate the current view back to its original position
    if (self.animated) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, 0, rectScreen.size.width, rectScreen.size.height);
        }];
        self.animated = NO;
    }
}

- (void) gotoHomeView
{
    g_Delegate.m_bLogin = true;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    MenuTabViewController *homeView = [storyboard instantiateViewControllerWithIdentifier:@"menutabview"];
    
    /*
     dispatch_async(dispatch_get_main_queue(), ^ {
     [self presentViewController:homeView animated:YES completion:nil];
     });
     */
    [self.navigationController pushViewController:homeView animated:YES];
    
}

- (IBAction)actionSignup:(id)sender {
    g_Delegate.m_bRegisterSuccess = false;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    SingUpViewController* viewCon = [storyboard instantiateViewControllerWithIdentifier:@"signupview"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
    
}

@end
