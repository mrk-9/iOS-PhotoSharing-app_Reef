//
//  FeedViewController.h
//  reef
//
//  Created by iOSDevStar on 8/15/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostSubView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MessageUI.h>
#import "AGPhotoBrowserView.h"
#import "PostGridSubView.h"
#import "FeedSubView.h"

@interface FeedViewController : UIViewController<UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, PostSubViewDelegate, UIAlertViewDelegate, UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate, UIScrollViewDelegate, AGPhotoBrowserDelegate, AGPhotoBrowserDataSource, AGPhotoBrowerViewDelegate, PostGridSubViewDelegate, FeedSubViewDelegate>
{
    bool bStartTimer;
    NSTimer* timerAutoScroll;
    int nAutoScrollIndex;
    
    NSDate* startDate;
    bool bEOFLoading;

    float fScrollCurPos;
    
    int nOffset;
    bool bPossibleLoadNext;
    
    NSMutableArray* arrayViewsForList;

    PostSubView* curSelectedCell;
    float fScrollHeight;
    int nPrevLoadCnt;

    bool bLikeAction;
    
    bool bFullScreenViewMode;
    
    bool bShowPhotoBrowser;
}

@property (weak, nonatomic) IBOutlet UILabel *m_lblWarning;

@property (nonatomic, strong) AGPhotoBrowserView *browserView;

@property (nonatomic, strong) NSMutableArray* m_arrData;
@property (nonatomic, strong) NSMutableArray* m_arrResult;

@property (weak, nonatomic) IBOutlet UITableView *m_tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *m_scrollView;

@end
