//
//  SingUpViewController.h
//  reef
//
//  Created by iOSDevStar on 8/24/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"

@interface SingUpViewController : UIViewController<UITextFieldDelegate, DBCameraViewControllerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>
{
    UIImage* selectedImage;
    int nSelectedCodeIdx;
}

@property (nonatomic, assign) BOOL animated;

@property (weak, nonatomic) IBOutlet UIImageView *m_userImageView;

@property (weak, nonatomic) IBOutlet UIView *m_signupUsernameView;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgSignupUsername;
@property (weak, nonatomic) IBOutlet UITextField *m_txtSignupUsername;

@property (weak, nonatomic) IBOutlet UIView *m_signupEmailView;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgSignupEmail;
@property (weak, nonatomic) IBOutlet UITextField *m_txtSignupEmail;

@property (weak, nonatomic) IBOutlet UIView *m_signupPassView;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgSignUpPass;
@property (weak, nonatomic) IBOutlet UITextField *m_txtSignUpPass;

@property (weak, nonatomic) IBOutlet UIView *m_signupConfrimPassView;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgSignUpConfrimPass;
@property (weak, nonatomic) IBOutlet UITextField *m_txtSignUpConfrimPass;

@property (weak, nonatomic) IBOutlet UIView *m_signupPhoneNumberView;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *m_txtPhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *m_btnCountryCode;
- (IBAction)actionChooseCountryCode:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *m_btnSignupDone;

- (IBAction)actionRegister:(id)sender;
- (IBAction)actionPrivacy:(id)sender;

@end
