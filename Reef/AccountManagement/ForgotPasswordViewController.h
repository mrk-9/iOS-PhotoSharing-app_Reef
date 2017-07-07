//
//  ForgotPasswordViewController.h
//  reef
//
//  Created by iOSDevStar on 8/24/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *m_forgotEmailView;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgForgotEmail;
@property (weak, nonatomic) IBOutlet UITextField *m_txtForgotEmail;

@property (weak, nonatomic) IBOutlet UIButton *m_btnForgotDone;

- (IBAction)actionForgot:(id)sender;

@end
