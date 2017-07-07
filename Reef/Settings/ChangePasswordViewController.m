//
//  ChangePasswordViewController.m
//  reef
//
//  Created by iOSDevStar on 9/2/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "Global.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Change Password";

    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronCircleLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
    UIImage *imgBack = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];

    self.m_txtNewPass.delegate = self;
    self.m_txtOriginalPass.delegate = self;
    
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_viewOriginalPass radius:self.m_viewOriginalPass.frame.size.height / 2.f backgroundcolor:[UIColor whiteColor] borderColor:[DARK_GRAY_COLOR colorWithAlphaComponent:1.f] borderWidth:0.f];
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_viewNewPass radius:self.m_viewNewPass.frame.size.height / 2.f backgroundcolor:[UIColor whiteColor] borderColor:[DARK_GRAY_COLOR colorWithAlphaComponent:1.f] borderWidth:0.f];
    [[GlobalPool sharedObject] makeCornerRadiusControl:self.m_btnSubmit radius:self.m_btnSubmit.frame.size.height / 2.f backgroundcolor:GREEN_COLOR borderColor:[DARK_GRAY_COLOR colorWithAlphaComponent:1.f] borderWidth:0.f];

}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.m_txtNewPass resignFirstResponder];
    [self.m_txtOriginalPass resignFirstResponder];
}

- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)actionSubmit:(id)sender {
    [self.m_txtNewPass resignFirstResponder];
    [self.m_txtOriginalPass resignFirstResponder];

    if (self.m_txtOriginalPass.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please input old password!"];
        return;
    }

    NSDictionary* dictLoginInfo = [[GlobalPool sharedObject] getLoginInfo];
    
    if (![self.m_txtOriginalPass.text isEqualToString:[dictLoginInfo valueForKey:@"pass"]])
    {
        [g_Delegate AlertWithCancel_btn:@"Please input current pasword correctly!"];
        return;
    }
    
    if (self.m_txtNewPass.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please input new password!"];
        return;
    }
    
    [[GlobalPool sharedObject] showLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
    
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *params = @ {@"old_password":self.m_txtOriginalPass.text, @"new_password":self.m_txtNewPass.text};

    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"account/update_password"];
    [manager POST: strRequestLink
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              [[GlobalPool sharedObject] hideLoadingView:[GlobalPool sharedObject].m_curMenuTabViewCon.view];
              
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  NSMutableDictionary* dictLoginInfo = [[[GlobalPool sharedObject] getLoginInfo] mutableCopy];
                  [dictLoginInfo setValue:self.m_txtNewPass.text forKey:@"pass"];
                  [[GlobalPool sharedObject] saveLoginInfo:dictLoginInfo];
                  
                  [g_Delegate AlertSuccess:@"Changed password successfully!"];
                  
                  [self.navigationController popViewControllerAnimated:YES];
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
