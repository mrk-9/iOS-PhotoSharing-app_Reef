//
//  PrivacyViewController.m
//  reef
//
//  Created by iOSDevStar on 9/2/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "PrivacyViewController.h"
#import "Global.h"

@interface PrivacyViewController ()

@end

@implementation PrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Privacy Policy";
    
    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronCircleLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:GREEN_COLOR];
    UIImage *imgBack = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];
    
    self.m_webView.delegate = self;
    
    NSString *filePath=[[NSBundle mainBundle] pathForResource:@"privacy" ofType:@"html" inDirectory:nil];
    [self.m_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[GlobalPool sharedObject] showLoadingView:self.view];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[GlobalPool sharedObject] hideLoadingView:self.view];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[GlobalPool sharedObject] hideLoadingView:self.view];
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

@end
