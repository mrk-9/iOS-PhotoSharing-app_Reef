//
//  SearchUserCell.h
//  reef
//
//  Created by iOSDevStar on 8/5/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchUserCellDelegate;

@interface SearchUserCell : UITableViewCell

@property (nonatomic, strong) id<SearchUserCellDelegate> delegate;

@property (nonatomic, assign) bool m_bUserMode;
@property (nonatomic, assign) bool m_bInvitationMode; //true - email, false - phone sms

@property (weak, nonatomic) IBOutlet UIImageView *m_imageView;
@property (weak, nonatomic) IBOutlet UILabel *m_lblName;
@property (weak, nonatomic) IBOutlet UIButton *m_btnFollow;

@property (nonatomic, assign) int m_nIndex;

@property (nonatomic, strong) NSDictionary* m_dictUserInfo;
- (IBAction)actionFollow:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *m_viewLoading;

- (void) changeColorOfButton:(UIColor *) clrButton;

- (void) checkUserWhetherExistsInApp;

@end

@protocol SearchUserCellDelegate <NSObject>

- (void) actionFollowUser:(SearchUserCell *) subView withIndex:(int) nIndex;
- (void) actionUnFollowUser:(SearchUserCell *) subView withIndex:(int) nIndex;
- (void) sendInviation:(SearchUserCell *) subView withMode:(bool) bInviationMode withAddress:(NSString *) strAddress;

@end