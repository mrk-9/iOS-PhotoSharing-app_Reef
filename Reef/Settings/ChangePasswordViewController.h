//
//  ChangePasswordViewController.h
//  reef
//
//  Created by iOSDevStar on 9/2/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *m_viewOriginalPass;
@property (weak, nonatomic) IBOutlet UIView *m_viewNewPass;

@property (weak, nonatomic) IBOutlet UITextField *m_txtOriginalPass;
@property (weak, nonatomic) IBOutlet UITextField *m_txtNewPass;
@property (weak, nonatomic) IBOutlet UIButton *m_btnSubmit;
- (IBAction)actionSubmit:(id)sender;

@end
