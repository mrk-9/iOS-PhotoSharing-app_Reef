//
//  EditProfileViewController.h
//  reef
//
//  Created by iOSDevStar on 9/2/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"

@interface EditProfileViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, DBCameraViewControllerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>
{
    UIImage *selectedImage;
    
    int nSelectedCodeIdx;
}

@property (nonatomic, assign) BOOL animated;

@property (weak, nonatomic) IBOutlet UIImageView *m_imgView;

@property (weak, nonatomic) IBOutlet UIView *m_viewFullname;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgFullnameIcon;
@property (weak, nonatomic) IBOutlet UITextField *m_txtFullname;

@property (weak, nonatomic) IBOutlet UIView *m_viewEmailAddress;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgEmailIcon;
@property (weak, nonatomic) IBOutlet UITextField *m_txtEmail;

@property (weak, nonatomic) IBOutlet UIView *m_viewPass;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgPassIcon;
@property (weak, nonatomic) IBOutlet UITextField *m_txtPassword;

@property (weak, nonatomic) IBOutlet UIView *m_viewPhoneNumber;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *m_txtPhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *m_btnCountryCode;
- (IBAction)actionChooseCountryCode:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *m_viewAboutMe;
@property (weak, nonatomic) IBOutlet UITextView *m_txtAboutMe;

@end
