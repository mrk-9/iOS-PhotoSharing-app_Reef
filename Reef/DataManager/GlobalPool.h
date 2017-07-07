//
//  GlobalPool.h
//  Reef
//
//  Created by iOSDevStar on 12/18/15.
//  Copyright © 2015 iOSDevStar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class MenuTabViewController;
@class CaptureManagerViewController;

@interface GlobalPool : NSObject<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

-(id) init;
+ (GlobalPool *)sharedObject;

@property (nonatomic, assign) bool m_bLogin;

@property (nonatomic, strong) NSString* m_strDeviceToken;
@property (nonatomic, strong) NSString* m_strAccessToken;

@property (nonatomic, strong) NSString* m_strLatitude;
@property (nonatomic, strong) NSString* m_strLongitude;

@property (nonatomic, strong) NSArray *m_arrCountryNames;
@property (nonatomic, strong) NSArray *m_arrPrefixDialingCodes;

@property (nonatomic, strong) NSString* m_strCountry;
@property (nonatomic, strong) NSString* m_strCity;

@property (nonatomic, strong) NSString* m_strCurUsername;
@property (nonatomic, strong) NSString* m_strCurUserID;

@property (nonatomic, strong) NSDictionary* m_updatedProfileInfo;

@property (nonatomic, strong) MenuTabViewController* m_curMenuTabViewCon;
@property (nonatomic, strong) CaptureManagerViewController* m_curCaptureManagerViewCon;

- (void) enableLocationUpdate;

- (UIViewController *) getTopViewController;

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
- (NSString *) makeAPIURLString:(NSString *)strActionName;

- (NSDictionary* ) getLoginInfo;
- (void) saveLoginInfo:(NSDictionary *) dictInfo;

-(NSString*) countElapsedTime:(NSString*) oldTime;
- (NSString *) getElapsedTime:(NSDate *) oldDate;

- (void) updateDeviceTokenRequest;
- (void) updateCurrentLocationRequest;
- (void) updatePhotoViewedTimeRequest:(float) fViewedTime atIndex:(NSString *) strPostId;

-(UIImage*) scaleAndCropImage:(UIImage *) imgSource toSize:(CGSize)newSize;

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font;

-(BOOL)validateEmail:(NSString*)email;
- (NSString *)urlEncodeWithString: (NSString*)string;

- (void) showLoadingView:(UIView *) pBaseView;
- (void) hideLoadingView:(UIView *) pBaseView;

- (void) makeRadiusView:(UIView *) targetView withRadius:(float) fRadius withBorderColor:(UIColor *) clrBorder withBorderSize:(float) fBorderSize;
- (NSString *) convertSimpleNum:(NSString *)strOriginalNum;

- (void) makeShadowEffect:(UIView *) targetView radius:(float) fRadius color:(UIColor *) shadowColor corner:(float) fCornerRadius;
- (void) makeBoxShadowEffect:(UIView *) targetView radius:(float) fRadius color:(UIColor *) shadowColor corner:(float) fCornerRadius;
- (void) makeCornerRadiusControl:(UIView *) targetView radius:(float) fRadius backgroundcolor:(UIColor *) bgColor borderColor:(UIColor *) borderColor borderWidth:(float) fBorderWidth;

- (NSString *) timeInMiliSeconds:(NSDate *) date;
- (NSDate *) getDateFromMilliSec:(long long) lMilliSeconds;

-(NSString *)DateToString:(NSDate *)date withFormat:(NSString *)format;
- (NSDate *) StringToDate:(NSString *) strDate withFormat:(NSString *)format;
- (NSString *) convertDateString:(NSString *) strOriginalDate withNewFormat:(NSString *) format;

- (CGFloat) getHeightOfText:(NSString *)strText fontType:(UIFont *) font width:(float) fWidth;

- (NSString *) checkNullValue:(NSString *) strInputValue;
- (bool) checkDataAvailabilty:(id) pObj;

- (NSString *) makeSimplifiedNumber:(long) lNum;

//download image from server
- (void) loadProfileImageFromServer:(NSString *) strPhoto imageView:(UIImageView *)imageViewTaget withResult:(void(^)(UIImage* imgLoaded))blockWithCompletion;
- (void) loadPostPhotoFromServer:(NSString *) strPhoto imageView:(UIImageView *) imageViewTarget;

@end
