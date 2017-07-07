//
//  UserProfileViewController.h
//  reef
//
//  Created by iOSDevStar on 8/15/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileOverView.h"
#import "ProfilePostView.h"
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import <Accounts/Accounts.h>
#import "AGPhotoBrowserView.h"

@interface UserProfileViewController : UIViewController<UIScrollViewDelegate, ProfileOverViewDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate, ProfilePostViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, AGPhotoBrowserDelegate, AGPhotoBrowserDataSource, AGPhotoBrowerViewDelegate>
{
    bool bLoad;
    
    float fScrollHeight;
    float fOverviewHeight;
    
    NSString* strOverview;
           
    ProfileOverView* profileOverview;
    
    NSMutableArray* arrayViewsForList;
    
    MKMapView* userMapView;
    
    int nOffset;
    bool bPossibleLoadNext;
    
    int nPrevLoadCnt;
    
    ProfilePostView* curSelectedCell;
    
    bool bLikeAction;
    
    bool bLoadMode;

    int nIsFriend;
    
    NSMutableDictionary* dictUserProfileInfo;
    
    bool bShowPhotoBrowser;
}

@property (nonatomic, strong) AGPhotoBrowserView *browserView;

@property (nonatomic, retain) UIDocumentInteractionController *dic;

@property (nonatomic, strong) NSMutableArray* m_arrData;
@property (nonatomic, strong) NSMutableArray* m_arrResult;

@property (nonatomic, strong) NSString* m_strUserName;
@property (nonatomic, strong) NSString* m_strUserID;

@property (weak, nonatomic) IBOutlet UIScrollView *m_scrollView;

@end
