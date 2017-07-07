//
//  ViewController.h
//  Reef
//
//  Created by iOSDevStar on 12/18/15.
//  Copyright © 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITextFieldDelegate>
{
    bool bAutoLogin;
    bool bLogin;
}

@property (nonatomic, assign) BOOL animated;

@property (weak, nonatomic) IBOutlet UIView *m_loginView;

@property (weak, nonatomic) IBOutlet UIView *m_loginEmailView;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgLoginEmail;
@property (weak, nonatomic) IBOutlet UITextField *m_txtLoginEmail;

@property (weak, nonatomic) IBOutlet UIView *m_loginPassView;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgLoginPass;
@property (weak, nonatomic) IBOutlet UITextField *m_txtLoginPass;

@property (weak, nonatomic) IBOutlet UIButton *m_btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *m_btnForgot;

- (IBAction)actionLogin:(id)sender;
- (IBAction)actionGotoForgot:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *m_btnSignup;
- (IBAction)actionSignup:(id)sender;

@end

