//
//  FilterViewController.m
//  Reef
//
//  Created by iOSDevStar on 12/25/15.
//  Copyright © 2015 iOSDevStar. All rights reserved.
//

#import "FilterViewController.h"
#import "ImageUtil.h"
#import "ColorMatrix.h"
#import "Global.h"
#import "PostViewController.h"

@interface FilterViewController ()

@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Filter Photo";
    
    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronCircleLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imgPrev = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgPrev style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];

    FAKFontAwesome *naviNextIcon = [FAKFontAwesome chevronCircleRightIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imgNext = [naviNextIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgNext style:UIBarButtonItemStylePlain target:self action:@selector(gotoPostView)];

    [self makeInterface];
    
    [self createFiltersScrollView];
}

- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) gotoPostView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    
    PostViewController* viewCon = [storyboard instantiateViewControllerWithIdentifier:@"postview"];
    viewCon.m_imgFinal = self.m_postImageView.image;
    [self.navigationController pushViewController:viewCon animated:YES];
}

- (void) makeInterface
{
    arrayFilterNames = [NSArray arrayWithObjects:@"Normal",@"LOMO",@"Gray",@"Old",@"Gothic",@"Sharp Color",@"Simple",@"Claret red",@"Lemon",@"Romantic",@"Light Halo",@"Blue",@"Dream",@"Night", nil];

    self.m_postImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame));
//    self.m_postImageView.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2.f, CGRectGetHeight(self.m_viewImageCanvas.frame) / 2.f);

    self.m_postImageView.image = self.m_imgPost;
    filterImage = self.m_imgPost;
}

- (void) createFiltersScrollView
{
    for (int nIdx = 0; nIdx < arraySubViews.count; nIdx++)
    {
        UIImageView* v = (UIImageView *)[arraySubViews objectAtIndex:nIdx];
        v.hidden = YES;
        [v removeFromSuperview];
    }
    
    [arraySubViews removeAllObjects];
    
    [self.m_filterScrollView setShowsHorizontalScrollIndicator:NO];
    [self.m_filterScrollView setShowsVerticalScrollIndicator:NO];
    
    nFilterIdx = 0;
    
    if (timerFilter)
    {
        [timerFilter invalidate];
        timerFilter = nil;
    }
    
    timerFilter = [NSTimer scheduledTimerWithTimeInterval:0.001f target:self selector:@selector(makeFilters) userInfo:nil repeats:YES];
    
}

- (IBAction)setImageStyle:(UITapGestureRecognizer *)sender
{
    UIImage *image = [self changeImage:(int)sender.view.tag imageView:nil];
    [self.m_postImageView setImage:image];
}

-(UIImage *)changeImage:(int)index imageView:(UIImageView *)imageView
{
    UIImage *image;
    switch (index) {
        case 0:
        {
            return filterImage;
        }
            break;
        case 1:
        {
            image = [ImageUtil imageWithImage:filterImage withColorMatrix:colormatrix_lomo];
        }
            break;
        case 2:
        {
            image = [ImageUtil imageWithImage:filterImage withColorMatrix:colormatrix_heibai];
        }
            break;
        case 3:
        {
            image = [ImageUtil imageWithImage:filterImage withColorMatrix:colormatrix_huajiu];
        }
            break;
        case 4:
        {
            image = [ImageUtil imageWithImage:filterImage withColorMatrix:colormatrix_gete];
        }
            break;
        case 5:
        {
            image = [ImageUtil imageWithImage:filterImage withColorMatrix:colormatrix_ruise];
        }
            break;
        case 6:
        {
            image = [ImageUtil imageWithImage:filterImage withColorMatrix:colormatrix_danya];
        }
            break;
        case 7:
        {
            image = [ImageUtil imageWithImage:filterImage withColorMatrix:colormatrix_jiuhong];
        }
            break;
        case 8:
        {
            image = [ImageUtil imageWithImage:filterImage withColorMatrix:colormatrix_qingning];
        }
            break;
        case 9:
        {
            image = [ImageUtil imageWithImage:filterImage withColorMatrix:colormatrix_langman];
        }
            break;
        case 10:
        {
            image = [ImageUtil imageWithImage:filterImage withColorMatrix:colormatrix_landiao];
            
        }
            break;
        case 11:
        {
            image = [ImageUtil imageWithImage:filterImage withColorMatrix:colormatrix_menghuan];
            
        }
            break;
        case 12:
        {
            image = [ImageUtil imageWithImage:filterImage withColorMatrix:colormatrix_yese];
            
        }
    }
    return image;
}

- (void) exitTimer
{
    if (timerFilter)
    {
        [timerFilter invalidate];
        timerFilter = nil;
    }
}

- (void) makeFilters
{
    if (nFilterIdx >= 13)
    {
        [self exitTimer];
        return;
    }
    
    float x ;
    {
        x = (10.f + (self.m_filterScrollView.frame.size.height - 10.f)) * nFilterIdx;
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setImageStyle:)];
        recognizer.numberOfTouchesRequired = 1;
        recognizer.numberOfTapsRequired = 1;
        recognizer.delegate = self;
        
        UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10.f + x, 5.f, self.m_filterScrollView.frame.size.height - 10.f, self.m_filterScrollView.frame.size.height - 10.f)];
        [bgImageView setTag:nFilterIdx];
        [bgImageView addGestureRecognizer:recognizer];
        [bgImageView setUserInteractionEnabled:YES];
        bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        UIImage *bgImage = [self changeImage:nFilterIdx imageView:nil];
        [bgImageView setImage:bgImage];
        
        bgImageView.layer.cornerRadius = 5.f;
        bgImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        bgImageView.layer.borderWidth = 1.f;
        bgImageView.clipsToBounds = YES;
        UILabel* lblText = [[UILabel alloc] initWithFrame:CGRectMake(0, bgImageView.frame.size.height - 20.f, bgImageView.frame.size.width, 20.f)];
        lblText.backgroundColor = [UIColor whiteColor];
        lblText.textColor = [UIColor darkGrayColor];
        lblText.textAlignment = NSTextAlignmentCenter;
        lblText.text = [arrayFilterNames objectAtIndex:nFilterIdx];
        lblText.font = [UIFont systemFontOfSize:14.f];
        [bgImageView addSubview:lblText];
        
        [self.m_filterScrollView addSubview:bgImageView];
        [arraySubViews addObject:bgImageView];
    }
    
    self.m_filterScrollView.contentOffset = CGPointMake(0.f, 0.f);
    self.m_filterScrollView.contentSize = CGSizeMake(x + 20.f + (self.m_filterScrollView.frame.size.height - 10.f), self.m_filterScrollView.frame.size.height - 5.f);
    
    nFilterIdx++;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
