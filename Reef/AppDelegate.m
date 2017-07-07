//
//  AppDelegate.m
//  Reef
//
//  Created by iOSDevStar on 12/18/15.
//  Copyright © 2015 iOSDevStar. All rights reserved.
//

#import "AppDelegate.h"
#import "Global.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.m_bLogin = false;

    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    [[GlobalPool sharedObject] enableLocationUpdate];
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"My token is: %@", newToken);
    
    //    [[NSUserDefaults standardUserDefaults] setValue:newToken forKey:@"devicetoken"];
    [GlobalPool sharedObject].m_strDeviceToken = newToken;
    
    [[NSUserDefaults standardUserDefaults] setObject:newToken forKey:@"deviceid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
    [GlobalPool sharedObject].m_strDeviceToken = TEST_DEVICE_TOKEN;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)AlertWithCancel_btn:(NSString*)AlertMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:APP_FULL_NAME message:AlertMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        alertView.tag = 100;
        [alertView show];
    });
}

- (void) AlertSuccess:(NSString *) AlertMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:SUCCESS_STRING message:AlertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertView.tag = 100;
        [alertView show];
    });
}

- (void) AlertFailure:(NSString *) AlertMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:FAILTURE_STRING message:AlertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertView.tag = 100;
        [alertView show];
    });
}

@end
