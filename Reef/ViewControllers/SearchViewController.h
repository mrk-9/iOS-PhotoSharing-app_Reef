//
//  SearchViewController.h
//  reef
//
//  Created by iOSDevStar on 8/15/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchUserCell.h"
#import "DVSwitch.h"
@import MessageUI;

@class HMSegmentedControl;

@interface SearchViewController : UIViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SearchUserCellDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
{
    DVSwitch *mainSegmentedControl;

    NSString* strSearchText;
    
    int nOffset;
    bool bPossibleLoadNext;
    
    int nRequestMode;
    int nCurSelectedIdx;
    SearchUserCell* curSelectedCell;
    
    bool bLoad;
    
    float fScrollHeight;
    int nPrevLoadCnt;

    bool bSearchViewMode;
}

@property (weak, nonatomic) IBOutlet UIView *m_viewSegmentControl;

@property (nonatomic, strong) NSMutableArray* m_arrData;
@property (nonatomic, strong) NSMutableArray* m_arrResult;
@property (nonatomic, strong) NSMutableArray* m_arrContacts;
@property (nonatomic, strong) NSMutableArray* m_arrFilterdContacts;

@property (nonatomic, strong) UISearchBar* m_searchBar;

@property (weak, nonatomic) IBOutlet UITableView *m_tableView;

@end
