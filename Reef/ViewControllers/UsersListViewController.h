//
//  UsersListViewController.h
//  reef
//
//  Created by iOSDevStar on 9/6/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UsersListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    int nOffset;
    bool bPossibleLoadNext;
}

@property (nonatomic, strong) NSMutableArray* m_arrData;
@property (nonatomic, strong) NSMutableArray* m_arrResult;

@property (nonatomic, strong) NSString * m_strUserId;

@property (weak, nonatomic) IBOutlet UITableView *m_tableView;

@property (nonatomic, assign) bool m_bUserListMode;//true - following, false - follower

@end
