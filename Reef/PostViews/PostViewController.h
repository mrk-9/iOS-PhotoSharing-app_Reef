//
//  PostViewController.h
//  reef
//
//  Created by iOSDevStar on 8/15/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostViewController : UIViewController<UITextViewDelegate, UIDocumentInteractionControllerDelegate>

@property (nonatomic, retain) UIDocumentInteractionController *dic;

@property (nonatomic, assign) BOOL animated;

@property (nonatomic, strong) UIImage* m_imgFinal;

@property (weak, nonatomic) IBOutlet UIImageView *m_postImageView;
@property (weak, nonatomic) IBOutlet UITextView *m_postText;

- (IBAction)actionPost:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *m_btnReef;

@end
