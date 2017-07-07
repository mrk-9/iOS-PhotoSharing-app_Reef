//
//  LMMenuCell.h
//  LMDropdownViewDemo
//
//  Created by LMinh on 16/07/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMMenuCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISlider *sliderRadius;
@property (weak, nonatomic) IBOutlet UILabel *m_lblCurRadius;

- (IBAction)slideRadiusChanged:(id)sender;

@end
