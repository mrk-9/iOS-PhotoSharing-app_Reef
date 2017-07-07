//
//  ForgotPasswordViewController.m
//  reef
//
//  Created by iOSDevStar on 8/24/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "Global.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    FAKFontAwesome *iconBack = [FAKFontAwesome chevronCircleLeftIconWithSize:NAVI_ICON_SIZE];
    [iconBack addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR];
    UIImage *imgBack = [iconBack imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    
    UIBarButtonItem* naviBackItem = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];
    self.navigationItem.leftBarButtonItem = naviBackItem;
    
    FAKFontAwesome *iconEmail = [FAKFontAwesome envelopeOIconWithSize:NAVI_ICON_SIZE];
    [iconEmail addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR];
    UIImage *imgEmail = [iconEmail imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    
    //forgot pass view
    self.m_imgForgotEmail.image = imgEmail;
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_forgotEmailView radius:self.m_forgotEmailView.frame.size.height / 2.f backgroundcolor:[UIColor whiteColor] borderColor:[DARK_GRAY_COLOR colorWithAlphaComponent:1.f] borderWidth:0.f];
    
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_btnForgotDone radius:self.m_btnForgotDone.frame.size.height / 2.f backgroundcolor:GREEN_COLOR borderColor:[UIColor clearColor] borderWidth:0.f];
    
    self.m_txtForgotEmail.delegate = self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.m_txtForgotEmail resignFirstResponder];
}

- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Forgot a Password";
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

- (IBAction)actionForgot:(id)sender
{
    if (self.m_txtForgotEmail.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please input email address!"];
        return;
    }
    
    if (![[GlobalPool sharedObject] validateEmail:self.m_txtForgotEmail.text])
    {
        [g_Delegate AlertWithCancel_btn:@"Please input valid email address!"];
        return;
    }
    
    [self.m_txtForgotEmail resignFirstResponder];
    
    [[GlobalPool sharedObject] showLoadingView:self.navigationController.view];
    
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];

    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSDictionary *params = @ {@"email":self.m_txtForgotEmail.text};
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"account/forgot_password"];
    [manager POST: strRequestLink
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              [[GlobalPool sharedObject] hideLoadingView:self.navigationController.view];
              
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  [g_Delegate AlertSuccess:@"Submitted successfully!"];
                  [self.navigationController popViewControllerAnimated:YES];
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

@end
