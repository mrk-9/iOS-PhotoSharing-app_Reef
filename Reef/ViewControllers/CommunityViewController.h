//
//  CommunityViewController.h
//  Reef
//
//  Created by iOSDevStar on 12/25/15.
//  Copyright © 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostGridSubView.h"
#import "AGPhotoBrowserView.h"
#import "LMDropdownView.h"
#import "LMMenuCell.h"

@interface CommunityViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, PostGridSubViewDelegate, AGPhotoBrowserDelegate, AGPhotoBrowserDataSource, AGPhotoBrowerViewDelegate, LMDropdownViewDelegate>
{
    bool bLoad;
    
    float fScrollHeight;
    
    NSMutableArray* arrayViewsForList;
    
    int nOffset;
    NSString* strLastIndex;
    
    bool bPossibleLoadNext;
    
    int nPrevLoadCnt;
    
    NSMutableDictionary* dictUserProfileInfo;
    
    bool bShowPhotoBrowser;

    int nSelectedRadius;
    
    LMDropdownView *dropdownView;
}

@property (weak, nonatomic) IBOutlet UILabel *m_lblWarning;

@property (weak, nonatomic) IBOutlet UIScrollView *m_scrollView;

@property (strong, nonatomic) IBOutlet UITableView *menuTableView;

@property (nonatomic, strong) AGPhotoBrowserView *browserView;

@property (nonatomic, strong) NSMutableArray* m_arrData;
@property (nonatomic, strong) NSMutableArray* m_arrResult;

@end
