//
//  SettingsViewController.h
//  reef
//
//  Created by iOSDevStar on 9/2/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

@interface SettingsViewController : UIViewController<UIAlertViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *m_scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *m_imgIndicator1;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgIndicator2;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgIndicator3;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgIndicator4;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgIndicator5;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgIndicator6;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgIndicator7;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgIndicator8;

- (IBAction)actionSuggestion:(id)sender;
- (IBAction)actionShare:(id)sender;
- (IBAction)actionPrivacy:(id)sender;
- (IBAction)actionRateUs:(id)sender;
- (IBAction)actionChangePassword:(id)sender;
- (IBAction)actionRemoveTempFiles:(id)sender;
- (IBAction)actionLogout:(id)sender;
- (IBAction)actionEditProfile:(id)sender;

@end
