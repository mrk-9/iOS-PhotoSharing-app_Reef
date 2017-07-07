//
//  AppDelegate.h
//  Reef
//
//  Created by iOSDevStar on 12/18/15.
//  Copyright © 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, assign) bool m_bLogin;
@property (nonatomic, assign) bool m_bRegisterSuccess;

-(void)AlertWithCancel_btn:(NSString*)AlertMessage;
- (void) AlertSuccess:(NSString *) AlertMessage;
- (void) AlertFailure:(NSString *) AlertMessage;

@end

