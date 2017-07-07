//
//  PostViewController.m
//  reef
//
//  Created by iOSDevStar on 8/15/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "PostViewController.h"
#import "Global.h"

@interface PostViewController ()

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Post Photo";
    
    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronCircleLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imgButton = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgButton style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];
    
    self.m_postText.delegate = self;
    self.m_postText.text = POST_TEXT_PLACEHOLDER;
    self.m_postText.textColor = [UIColor lightGrayColor];
    
    self.m_postImageView.image = self.m_imgFinal;

    self.m_postText.contentOffset = CGPointZero;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self makeInterface];
}

- (void) viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self hideKeyboard];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    float fKeyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;

    float fNaviHeight = 44.f;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.f)
        fNaviHeight += 20.f;
    
    CGRect rectScreen = [[UIScreen mainScreen] bounds];
    
    [UIView animateWithDuration:0.3f animations:^ {
        self.view.frame = CGRectMake(0.f, -1 * fKeyboardHeight + fNaviHeight, rectScreen.size.width, rectScreen.size.height - fNaviHeight);
    }];
    self.animated = YES;
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

- (void) makeInterface
{
    float fNaviHeight = 44.f;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.f)
        fNaviHeight += 20.f;

    self.m_postImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame));
    self.m_postText.frame = CGRectMake(0, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - fNaviHeight - CGRectGetHeight(self.m_btnReef.frame) - CGRectGetWidth(self.view.frame));
    
    self.m_postText.scrollEnabled = YES;
}

- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideKeyboard];
}

- (void) hideKeyboard
{
    [self.m_postText resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

/*

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

- (IBAction)actionPost:(id)sender {
    [self hideKeyboard];
    
    if ([self.m_postText.text isEqualToString:POST_TEXT_PLACEHOLDER])
    {
        [g_Delegate AlertWithCancel_btn:@"Please input description!"];
        return;
    }
    
    MRProgressOverlayView *progressView = [MRProgressOverlayView new];
    progressView.mode = MRProgressOverlayViewModeDeterminateCircular;
    [self.view.window addSubview:progressView];
    [progressView show:YES];

    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];
    
    NSData *articleData = nil;
    NSString* strMimeType = @"image/jpeg";
    NSString* strFileName = @"article.jpg";
    NSString* strAlert = @"Photo posted successfully!";

    articleData = UIImageJPEGRepresentation(self.m_imgFinal, 1.f);
    
    NSData *data = [self.m_postText.text dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    goodValue = [goodValue stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    
    NSDictionary *params = @ {@"post_title":goodValue, @"latitude":[GlobalPool sharedObject].m_strLatitude, @"longitude":[GlobalPool sharedObject].m_strLongitude, @"country":[GlobalPool sharedObject].m_strCountry, @"city":[GlobalPool sharedObject].m_strCity};
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"post/create"];
    
    NSError* error = nil;
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:strRequestLink parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:articleData
                                    name:@"avatar"
                                fileName:strFileName
                                mimeType:strMimeType];
    } error:&error];
    
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                             NSLog(@"JSON: %@", responseObject);
                                                                             if ([[responseObject valueForKey:@"success"] boolValue])
                                                                             {
                                                                                 progressView.mode = MRProgressOverlayViewModeCheckmark;
                                                                                 progressView.titleLabelText = strAlert;
                                                                                 /*
                                                                                  UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_FULL_NAME message:strAlert delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                                  alertView.tag = 120;
                                                                                  [alertView show];
                                                                                  */
                                                                                 [self performBlock:^{
                                                                                     [progressView dismiss:YES];

                                                                                     [self dismissViewControllerAnimated:YES completion:nil];

                                                                                 } afterDelay:1.f];
                                                                                 
                                                                             }
                                                                             else
                                                                             {
                                                                                 progressView.mode = MRProgressOverlayViewModeCross;
                                                                                 progressView.titleLabelText = [responseObject valueForKey:@"message"];
                                                                                 
                                                                                 [self performBlock:^{
                                                                                     [progressView dismiss:YES];
                                                                                 } afterDelay:1.f];
                                                                             }
                                                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                             NSLog(@"Error: %@", error);
                                                                             progressView.mode = MRProgressOverlayViewModeCross;
                                                                             progressView.titleLabelText = SOMETHING_WRONG;
                                                                             
                                                                             [self performBlock:^{
                                                                                 [progressView dismiss:YES];
                                                                             } afterDelay:1.f];
                                                                         }];
    
    // 4. Set the progress block of the operation.
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
        float fProgress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        
        [progressView setProgress:fProgress animated:YES];
    }];
    
    // 5. Begin!
    [operation start];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 120)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
