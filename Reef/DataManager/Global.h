//
//  Global.h
//  Reef
//
//  Created by iOSDevStar on 12/18/15.
//  Copyright © 2015 iOSDevStar. All rights reserved.
//

#ifndef REEF_Global_h
#define REEF_Global_h

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "UIImage+fixOrientation.h"
#import "UIImage+Utility.h"
#import "AppDelegate.h"
#import "FontAwesomeKit.h"
#import "NSDate+TimeAgo.h"
#import <QuartzCore/QuartzCore.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "AFNetworking.h"
#import "CircleProgressView.h"
#import "NSDate+TimeAgo.h"
#import "JSBadgeView.h"
#import "GlobalPool.h"
#import "KxMenu.h"
#import "MRProgressOverlayView.h"
#import "ActionSheetStringPicker.h"
#import "ActionSheetDatePicker.h"
#import "SVPullToRefresh.h"
#import "MenuTabViewController.h"
#import "DBCameraViewController.h"
#import "DBCameraContainerViewController.h"
#import "DBCameraLibraryViewController.h"
#import "CustomCamera.h"
#import "DBCameraGridView.h"
#import "DemoNavigationController.h"
#import "THContact.h"
#import "BDVCountryNameAndCode.h"

#define APP_FULL_NAME           @"Reef"

#define APP_VERSION             @"1.00"
#define ITUNES_APP_ID           @"1038319355"

#define DOCUMENTS_PATH          [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define STORYBOARD_NAME          @"Main"//(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? @"Main":@"Main_iPad")

#define MENU_TAB_HEIGHT         50.f

#define CELL_MARGIN                     3.f
#define ANSWER_CELL_TOP_INFO_HEIGHT     49.f
#define CELL_TOP_INFO_HEIGHT            44.f
#define CELL_TAG_VIEW_HEIGHT            32.f
#define CELL_ACTION_VIEW_HEIGHT         48.f
#define CELL_FRIEND_ACTION_VIEW_HEIGHT  48.f

#define PROFILE_OVERVIEW_INFO_HEIGHT        105.f
#define PROFILE_OVERVIEW_ACTION_HEIGHT      44.f

#define PHOTO_CAPTURE_MODE      444
#define VIDEO_CAPTURE_MODE      445
#define VIDEO_TIMELINE_HEIGHT   7.f
#define MAX_VIDEO_RECORD_TIME   30.f

#define NAVI_BUTTON_OFFSET      -8.f

#define ICON_SIZE               32
#define NAVI_ICON_SIZE          24
#define TAB_ICON_SIZE           24
#define FB_ICON_SIZE            26

#define NOTIFICATION_NAME       @"reefnotification"
#define NOTIFICATION_KEY        @"filterindex"

#define NAVI_FONT_SIZE          24.f
#define MAX_TAG_AMOUNT          6

#define INDICATOR_ANIMATION     0.2f

#define DARK_GRAY_COLOR         [UIColor colorWithRed:95.f/255.f green:95.f/255.f blue:95.f/255.f alpha:1.0f]
#define GRAY_COLOR              [UIColor colorWithRed:95.f/255.f green:95.f/255.f blue:95.f/255.f alpha:1.0f]
#define NAVI_COLOR              [UIColor colorWithRed:0.f/255.f green:119.f/255.f blue:255.f/255.f alpha:1.0f]
#define GREEN_COLOR             [UIColor colorWithRed:0.f/255.f green:119.f/255.f blue:255.f/255.f alpha:1.0f]
#define RED_COLOR               [UIColor colorWithRed:200.f/255.f green:78.f/255.f blue:78.f/255.f alpha:1.0f]
#define PINK_COLOR              [UIColor colorWithRed:181.f/255.f green:19.f/255.f blue:147.f/255.f alpha:1.0f]
#define BLUE_COLOR              [UIColor colorWithRed:21.f/255.f green:95.f/255.f blue:175.f/255.f alpha:1.0f]

#define BOX_SHADOW_COLOR        [UIColor colorWithRed:200.f / 255.f green:200.f / 255.f blue:200.f / 255.f alpha:1.f]
#define DISABLE_COLOR           [UIColor grayColor]
#define CAPTURE_VIEW_BG_COLOR   [UIColor colorWithRed:38.f / 255.f green:39.f / 255.f blue:43.f / 255.f alpha:1.f]

#define MAIN_FONT_NAME          @"Calibri"
#define MAIN_BOLD_FONT_NAME     @"Calibri-Bold"

#define RATING_CYCLE            1 //days

#define TAB_BAR_AMOUNTS         4
#define MINIMUM_VIDEO_LENGHT    5

#define MAX_USER_AMOUNT_PER_PAGE        20
#define MAX_FEED_ARTICLE_PER_PAGE       20
#define MAX_COMMUNITY_PER_PAGE          21

#define MAX_TITLE               50
#define MAX_DESCRITPION         500

#define CAT_SUB_VIEW_HEIGHT     115.f

#define SHARE_TEXT              @"reef is amazing photo sharing app. Please download from app store and enjoy! \r\nhttps://itunes.apple.com/us/app/reef/id1038319355?ls=1&mt=8"

#define APP_STORE_LINK          @"https://itunes.apple.com/us/app/reef/id1038319355?ls=1&mt=8"

#define SUCCESS_STRING          @"Success"
#define FAILTURE_STRING         @"Failure"

#define NET_CONNECTION_ERROR    @"The Network connection appears to be offline!"
#define SOMETHING_WRONG         @"Internet connection is failed. Please try later!"
#define WELCOME_TEXT            @"Welcome to reef. You have registered successfully. Now you can use our app. Please enjoy with all!"

#define g_Delegate              ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define POST_TEXT_PLACEHOLDER   @"Please input something..."

#define TEST_DEVICE_TOKEN       @"1234567890"
#define DEVICE_MODEL            @"iOS"

#define AUTO_SCROLL_TIME_INTERVAL               3.f

#define DEFAULT_LONGITUDE       @"nolocation"
#define DEFAULT_LATITUDE        @"nolocation"

#define DEFAULT_COUNTRY         @"nocountry"
#define DEFAULT_CITY            @"nocity"

#define REEF_TIME_FORMAT        @"dd MMM yyyy"

#define FRIEND_VIEW_MODE        890
#define POST_VIEW_MODE          891
#define LIKE_VIEW_MODE          892

#define LOADING_HUB_TAG         2000
#define LOADING_OTHER_HUB_TAG   2010

#define IMAGEFOLDERPATH         @"http://159.203.115.54/reef/images/photo/"
#define AVATARFOLDERPATH        @"http://159.203.115.54/reef/images/avatar/"
#define SERVICEPATH             @"http://159.203.115.54/reef/"

/*
#define IMAGEFOLDERPATH         @"http://192.168.1.13/reef/images/photo/"
#define AVATARFOLDERPATH        @"http://192.168.1.13/reef/images/avatar/"
#define SERVICEPATH             @"http://192.168.1.13/reef/"
 */

#endif
