//
//  LMMenuCell.m
//  LMDropdownViewDemo
//
//  Created by LMinh on 16/07/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import "LMMenuCell.h"
#import "Global.h"

@implementation LMMenuCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.sliderRadius setThumbTintColor:NAVI_COLOR];
    [self.sliderRadius setMaximumTrackTintColor:[UIColor lightGrayColor]];
    [self.sliderRadius setMinimumTrackTintColor:NAVI_COLOR];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
    }
    else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (IBAction)slideRadiusChanged:(id)sender {
    int nCurRadius = ((UISlider *)sender).value;
    
    self.m_lblCurRadius.text = [NSString stringWithFormat:@"%d Miles", nCurRadius];
}

@end
