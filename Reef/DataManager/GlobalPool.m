//
//  GlobalPool.m
//  Reef
//
//  Created by iOSDevStar on 12/18/15.
//  Copyright © 2015 iOSDevStar. All rights reserved.
//


#import "GlobalPool.h"
#import "Global.h"

@implementation GlobalPool

@synthesize m_strDeviceToken;
@synthesize m_strLatitude;
@synthesize m_strLongitude;
@synthesize m_strCountry;
@synthesize m_strCity;

-(id) init
{
    if((self = [super init]))
    {
        m_strDeviceToken = TEST_DEVICE_TOKEN;
        
        m_strLongitude = DEFAULT_LONGITUDE;
        m_strLatitude = DEFAULT_LATITUDE;
        
        m_strCountry = DEFAULT_COUNTRY;
        m_strCity = DEFAULT_CITY;
        
        self.m_arrCountryNames = [[NSArray alloc] initWithObjects:@"Afghanistan", @"Albania",@"Algeria",@"American Samoa",@"Andorra",@"Angola",@"Anguilla",@"Antarctica",@"Antigua and Barbuda",@"Argentina",@"Armenia",@"Aruba",@"Australia",@"Austria",@"Azerbaijan",@"Bahamas",@"Bahrain",@"Bangladesh",@"Barbados",@"Belarus",@"Belgium",@"Belize",@"Benin",@"Bermuda",@"Bhutan",@"Bolivia",@"Bosnia and Herzegovina",@"Botswana"@"Brazil",@"British Virgin Islands",@"Brunei",@"Bulgaria",@"Burkina Faso",@"Burma (Myanmar)",@"Burundi",@"Cambodia",@"Cameroon",@"Canada",@"Cape Verde",@"Cayman Islands",@"Central African Republic",@"Chad",@"Chile",@"China",@"Christmas Island",@"Cocos (Keeling) Islands",@"Colombia",@"Comoros",@"Cook Islands",@"Costa Rica",@"Croatia",@"Cuba",@"Cyprus",@"Czech Republic",@"Democratic Republic of the Congo",@"Denmark",@"Djibouti",@"Dominica",@"Dominican Republic",@"Ecuador",@"Egypt",@"El Salvador",@"Equatorial Guinea",@"Eritrea",@"Estonia",@"Ethiopia",@"Falkland Islands",@"Faroe Islands",@"Fiji",@"Finland",@"France",@"French Polynesia",@"Gabon",@"Gambia",@"Gaza Strip",@"Georgia",@"Germany",@"Ghana",@"Gibraltar",@"Greece",@"Greenland",@"Grenada",@"Guam",@"Guatemala",@"Guinea",@"Guinea-Bissau",@"Guyana",@"Haiti",@"Holy See (Vatican City)",@"Honduras",@"Hong Kong",@"Hungary",@"Iceland",@"India",@"Indonesia",@"Iran",@"Iraq",@"Ireland",@"Isle of Man",@"Israel",@"Italy",@"Ivory Coast",@"Jamaica",@"Japan",@"Jordan",@"Kazakhstan",@"Kenya",@"Kiribati",@"Kosovo",@"Kuwait",@"Kyrgyzstan",@"Laos",@"Latvia",@"Lebanon",@"Lesotho",@"Liberia",@"Libya",@"Liechtenstein",@"Lithuania",@"Luxembourg",@"Macau",@"Macedonia",@"Madagascar",@"Malawi",@"Malaysia",@"Maldives",@"Mali",@"Malta",@"MarshallIslands",@"Mauritania",@"Mauritius",@"Mayotte",@"Mexico",@"Micronesia",@"Moldova",@"Monaco",@"Mongolia",@"Montenegro",@"Montserrat",@"Morocco",@"Mozambique",@"Namibia",@"Nauru",@"Nepal",@"Netherlands",@"Netherlands Antilles",@"New Caledonia",@"New Zealand",@"Nicaragua",@"Niger",@"Nigeria",@"Niue",@"Norfolk Island",@"North Korea ",@"Northern Mariana Islands",@"Norway",@"Oman",@"Pakistan",@"Palau",@"Panama",@"Papua New Guinea",@"Paraguay",@"Peru",@"Philippines",@"Pitcairn Islands",@"Poland",@"Portugal",@"Puerto Rico",@"Qatar",@"Republic of the Congo",@"Romania",@"Russia",@"Rwanda",@"Saint Barthelemy",@"Saint Helena",@"Saint Kitts and Nevis",@"Saint Lucia",@"Saint Martin",@"Saint Pierre and Miquelon",@"Saint Vincent and the Grenadines",@"Samoa",@"San Marino",@"Sao Tome and Principe",@"Saudi Arabia",@"Senegal",@"Serbia",@"Seychelles",@"Sierra Leone",@"Singapore",@"Slovakia",@"Slovenia",@"Solomon Islands",@"Somalia",@"South Africa",@"South Korea",@"Spain",@"Sri Lanka",@"Sudan",@"Suriname",@"Swaziland",@"Sweden",@"Switzerland",@"Syria",@"Taiwan",@"Tajikistan",@"Tanzania",@"Thailand",@"Timor-Leste",@"Togo",@"Tokelau",@"Tonga",@"Trinidad and Tobago",@"Tunisia",@"Turkey",@"Turkmenistan",@"Turks and Caicos Islands",@"Tuvalu",@"Uganda",@"Ukraine",@"United Arab Emirates",@"United Kingdom",@"United States",@"Uruguay",@"US Virgin Islands",@"Uzbekistan",@"Vanuatu",@"Venezuela",@"Vietnam",@"Wallis and Futuna",@"West Bank",@"Yemen",@"Zambia",@"Zimbabwe",nil];
        
        self.m_arrPrefixDialingCodes = [[NSArray alloc] initWithObjects:@"+93",@"+335",@"+213",@"+1684",@"+376",@"+376",@"+244",@"+1264",@"+672",@"+1268",@"+54", @"+374",@"+297", @"+61",@"+43", @"+994",@"+1242",@"+973",@"+880",@"+1246"@"+375",@"+32",@"+501",@"+229",@"+1441",@"+975",@"+591",@"+387",@"+267"@"+55",@"+1284",@"+673",@"+359",@"+226",@"+95",@"+257",@"+855",@"+237",@"+1",@"+238",@"+1345",@"+236",@"+235",@"+56",@"+86",@"+61",@"+61",@"+57",@"+269",@"+682",@"+506",@"+385",@"+53",@"+357",@"+420",@"+243",@"+45",@"+253",@"+1767",@"+1809",@"+593",@"+20",@"+503",@"+240",@"+291",@"+372",@"+251",@"+500",@"+298",@"+679",@"+358",@"+33",@"+689",@"+241",@"+220",@"+970",@"+995",@"+49",@"+233",@"+350",@"+30",@"+299",@"+1473",@"+1671",@"+502",@"+224",@"+245",@"+592",@"+509",@"+39",@"+504",@"+852",@"+36",@"+354",@"+91",@"+62",@"+98",@"+964",@"+353",@"+44",@"+972",@"+39",@"+225",@"+1876",@"+81",@"+962",@"+7",@"+254",@"+686",@"+381",@"+965",@"+996",@"+856",@"+371",@"+961",@"+266",@"+231",@"+218",@"+423",@"+370",@"+352",@"+853",@"+389",@"+261",@"+265",@"+60",@"+960",@"+223",@"+356",@"+692",@"+222",@"+230",@"+262",@"+52",@"+691",@"+373",@"+377",@"+976",@"+382",@"+1664",@"+212",@"+258",@"+264",@"+674",@"+977",@"+31",@"+599",@"+687",@"+64",@"+505",@"+227",@"+234",@"+683",@"+672",@"+850",@"+1670",@"+47",@"+968",@"+92",@"+680",@"+507",@"+675",@"+595",@"+51",@"+63",@"+870",@"+48",@"+351",@"+1",@"+974",@"+242",@"+40",@"+7",@"+250",@"+590",@"+290",@"+1869",@"+1758",@"+1599",@"+508",@"+1784",@"+685",@"+378",@"+239",@"+966",@"+221",@"+381",@"+248",@"+232",@"+65",@"+421",@"+386",@"+677",@"+252",@"+27",@"+82",@"+34",@"+94",@"+249",@"+597",@"+268",@"+46",@"+41",@"+963",@"+886",@"+992",@"+255",@"+66",@"+670",@"+228",@"+690",@"+676",@"+1868",@"+216",@"+90",@"+993",@"+1649",@"+688",@"+256",@"+380",@"+971",@"+44",@"+1",@"+598",@"+1340",@"+998",@"+678",@"+58",@"+84",@"+681",@"970",@"+967",@"+260",@"+263", nil];

    }
    
    return self;
}

+ (GlobalPool *)sharedObject
{
    static GlobalPool *objUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objUtility = [[GlobalPool alloc] init];
    });
    return objUtility;
}

- (void) enableLocationUpdate
{
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [locationManager requestWhenInUseAuthorization];
        }
    }
    
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    m_strLongitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
    m_strLatitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    
    __block NSDictionary *addressDictionary;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             if (placemarks && placemarks.count > 0)
             {
                 CLPlacemark *placemark = placemarks[0];
                 
                 addressDictionary = placemark.addressDictionary;
                 
                 NSUserDefaults *userDef=[[NSUserDefaults standardUserDefaults] init];
                 [userDef setObject:[addressDictionary objectForKey:@"City"] forKey:@"userCity"];
                 [userDef setObject:[addressDictionary objectForKey:@"Country"] forKey:@"userCountry"];
                 [userDef synchronize];
                 
                 NSString *country = [[NSString alloc]initWithString:placemark.country];
                 NSString *city = [[NSString alloc]initWithString:placemark.locality];

                 if ([m_strCountry isEqualToString:country] && [m_strCity isEqualToString:city])
                     return;
                 
                 self.m_strCountry = country;
                 self.m_strCity = city;

                 NSLog(@"country = %@, city = %@", self.m_strCountry, self.m_strCity);

                 [[GlobalPool sharedObject] updateCurrentLocationRequest];

             }
         }
         else
         {
             m_strCity = DEFAULT_CITY;
             m_strCountry = DEFAULT_COUNTRY;
             
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
             return;
         }
         /*---- For more results
          placemark.region);
          placemark.country);
          placemark.locality);
          placemark.name);
          placemark.ocean);
          placemark.postalCode);
          placemark.subLocality);
          placemark.location);
          ------*/
     }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    m_strLongitude = DEFAULT_LONGITUDE;
    m_strLatitude = DEFAULT_LATITUDE;

    m_strCity = DEFAULT_CITY;
    m_strCountry = DEFAULT_COUNTRY;
}

- (void) updateCurrentLocationRequest
{
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];

    NSDictionary *params = @ {@"latitude":[GlobalPool sharedObject].m_strLatitude, @"longitude":[GlobalPool sharedObject].m_strLongitude, @"country":[GlobalPool sharedObject].m_strCountry, @"city":[GlobalPool sharedObject].m_strCity};
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"account/update_location"];
    [manager POST: strRequestLink
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  NSLog(@"updated location");
              }
              else
              {
                  NSLog(@"failed to update location");
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }];
    
}

- (void) updatePhotoViewedTimeRequest:(float) fViewedTime atIndex:(NSString *) strPostId
{
    //send request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strAccessToken forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[GlobalPool sharedObject].m_strDeviceToken forHTTPHeaderField:@"Device-Id"];
    
    NSDictionary *params = @ {@"selected_id":strPostId, @"viewed_time":[NSNumber numberWithFloat:fViewedTime]};
    
    NSString* strRequestLink = [[GlobalPool sharedObject] makeAPIURLString:@"community/update_photoviewtime"];
    [manager POST: strRequestLink
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              if ([[responseObject valueForKey:@"success"] boolValue])
              {
                  NSLog(@"updated viewed_time");
              }
              else
              {
                  NSLog(@"failed to update viewed_time");
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }];

}

- (UIViewController *) getTopViewController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (void) updateDeviceTokenRequest
{
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSString *) timeInMiliSeconds:(NSDate *) date
{
    NSString * timeInMS = [NSString stringWithFormat:@"%lld", [@(floor([date timeIntervalSince1970] * 1000)) longLongValue]];
    return timeInMS;
}

- (NSDate *) getDateFromMilliSec:(long long) lMilliSeconds
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(lMilliSeconds / 1000)];
    
    return date;
}

-(NSString *)DateToString:(NSDate *)date withFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString * strdate = [formatter stringFromDate:date];
    return strdate;
}

- (NSDate *) StringToDate:(NSString *) strDate withFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];//2013-07-15:10:00:00
    NSDate* date = [formatter dateFromString:strDate];
    
    return date;
}

- (NSString *) convertDateString:(NSString *) strOriginalDate withNewFormat:(NSString *) format
{
    NSDate* dateObj = [self StringToDate:strOriginalDate withFormat:REEF_TIME_FORMAT];
    NSString* strNewDate = [self DateToString:dateObj withFormat:format];
    
    return strNewDate;
}

- (NSDictionary* ) getLoginInfo
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"grabtutor"];
}

- (void) saveLoginInfo:(NSDictionary *)dictInfo
{
    [[NSUserDefaults standardUserDefaults] setValue:dictInfo forKey:@"grabtutor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(UIImage*) scaleAndCropImage:(UIImage *) imgSource toSize:(CGSize)newSize
{
    float ratio = imgSource.size.width / imgSource.size.height;
    
    UIGraphicsBeginImageContext(newSize);
    
    if (ratio > 1) {
        CGFloat newWidth = ratio * newSize.width;
        CGFloat newHeight = newSize.height;
        CGFloat leftMargin = (newWidth - newHeight) / 2;
        [imgSource drawInRect:CGRectMake(-leftMargin, 0, newWidth, newHeight)];
    }
    else {
        CGFloat newWidth = newSize.width;
        CGFloat newHeight = newSize.height / ratio;
        CGFloat topMargin = (newHeight - newWidth) / 2;
        [imgSource drawInRect:CGRectMake(0, -topMargin, newSize.width, newSize.height/ratio)];
    }
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (NSString *) convertSimpleNum:(NSString *)strOriginalNum
{
    NSString* strSimpleNum = strOriginalNum;
    
    long lOrigin = [strOriginalNum longLongValue];
    if (lOrigin > 1000)
    {
        int nSimple = (int)(lOrigin / 1000);
        strSimpleNum = [NSString stringWithFormat:@"%dK", nSimple];
    }
    else if (lOrigin > 1000000)
    {
        int nSimple = (int)(lOrigin / 1000000);
        strSimpleNum = [NSString stringWithFormat:@"%dM", nSimple];
    }
    
    return strSimpleNum;
}

-(NSString*) countElapsedTime:(NSString*) oldTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EDT"]];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:oldTime];
    
    NSDate *now = [NSDate date];
    double deltaSeconds = fabs([dateFromString timeIntervalSinceDate:now]);
    double deltaMinutes = deltaSeconds / 60.0f;
    
    if(deltaMinutes<=420.0)
    {
        NSLog(@"Latest post..");
    }
    
    return [dateFromString timeAgoSimple];
}

- (NSString *) getElapsedTime:(NSDate *) oldDate
{
    NSDate *now = [NSDate date];
    double deltaSeconds = fabs([oldDate timeIntervalSinceDate:now]);
    double deltaMinutes = deltaSeconds / 60.0f;
    
    if(deltaMinutes<=420.0)
    {
        NSLog(@"Latest post..");
    }
    
    return [oldDate timeAgoSimple];
}

- (NSString *) makeAPIURLString:(NSString *)strActionName
{
    NSString* strUrl = [NSString stringWithFormat:@"%@%@", SERVICEPATH, strActionName];
    return  strUrl;
}

- (CGFloat) getHeightOfText:(NSString *)strText fontType:(UIFont *) font width:(float) fWidth
{
    CGFloat height = 0.0f;
    
    if (strText.length == 0)
        return 0.f;
    
    CGFloat commentlabelWidth = fWidth - 10.f;
    CGRect rect = [strText boundingRectWithSize:(CGSize){commentlabelWidth, MAXFLOAT}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:font}
                                        context:nil];
    height = rect.size.height;
    return height;
}

- (NSString *)urlEncodeWithString: (NSString*)string
{
    CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(
                                                                    NULL,
                                                                    (CFStringRef)string,
                                                                    NULL,
                                                                    (CFStringRef)@"!*'\"();+$,%#[]% ",
                                                                    kCFStringEncodingUTF8 );
    return (NSString *)CFBridgingRelease(urlString);
}

- (NSString *) checkNullValue:(NSString *) strInputValue
{
    if (strInputValue == nil || [strInputValue isKindOfClass:[NSNull class]])
        return @"";
    else
        return strInputValue;
}

- (bool) checkDataAvailabilty:(id) pObj
{
    if ([pObj isKindOfClass:[NSNull class]])
        return false;
    
    if (pObj == nil)
        return false;
    
    return true;
}

- (NSString *) makeSimplifiedNumber:(long) lNum
{
    NSString* strRet = [NSString stringWithFormat:@"%ld", lNum];
    
    float fPositive = (float)lNum / 1000.f;
    long lRemindNum = lNum % 1000;
    if (fPositive >= 1.f)
    {
        if (lRemindNum < 100)
            strRet = [NSString stringWithFormat:@"%ldK", (long)fPositive];
        else
            strRet = [NSString stringWithFormat:@"%.1fK", fPositive];
        
        fPositive = (float)lNum / 1000000.f;
        lRemindNum = lNum % 1000000;
        if (fPositive >= 1.f)
        {
            if (lRemindNum < 100000)
                strRet = [NSString stringWithFormat:@"%ldM", (long)fPositive];
            else
                strRet = [NSString stringWithFormat:@"%.1fM", fPositive];
        }
    }
    
    return strRet;
}

- (void) makeRadiusView:(UIView *) targetView withRadius:(float) fRadius withBorderColor:(UIColor *) clrBorder withBorderSize:(float) fBorderSize
{
    targetView.layer.borderColor = clrBorder.CGColor;
    targetView.layer.borderWidth = fBorderSize;
    targetView.layer.cornerRadius = fRadius;
    targetView.clipsToBounds = YES;
}

- (void) makeShadowEffect:(UIView *) targetView radius:(float) fRadius color:(UIColor *) shadowColor corner:(float) fCornerRadius
{
    targetView.layer.shadowRadius = fRadius;
    targetView.layer.masksToBounds = NO;
    [[targetView layer] setShadowColor:shadowColor.CGColor];
    [[targetView layer] setShadowOffset:CGSizeMake(0,0)];
    [[targetView layer] setShadowOpacity:1];
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRoundedRect:targetView.bounds cornerRadius:fCornerRadius];
    [[targetView layer] setShadowPath:[path1 CGPath]];
    
}

- (void) makeBoxShadowEffect:(UIView *) targetView radius:(float) fRadius color:(UIColor *) shadowColor corner:(float) fCornerRadius
{
    targetView.layer.shadowRadius = fRadius;
    targetView.layer.masksToBounds = NO;
    [[targetView layer] setShadowColor:shadowColor.CGColor];
    [[targetView layer] setShadowOffset:CGSizeMake(fRadius - 1,fRadius)];
    [[targetView layer] setShadowOpacity:1];
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRoundedRect:targetView.bounds cornerRadius:fCornerRadius];
    [[targetView layer] setShadowPath:[path1 CGPath]];
}

- (void) makeCornerRadiusControl:(UIView *) targetView radius:(float) fRadius backgroundcolor:(UIColor *) bgColor borderColor:(UIColor *) borderColor borderWidth:(float) fBorderWidth
{
    targetView.backgroundColor = bgColor;
    targetView.layer.cornerRadius = fRadius;
    targetView.layer.borderColor = borderColor.CGColor;
    targetView.layer.borderWidth = fBorderWidth;
    targetView.clipsToBounds = YES;
    
}

- (void) showLoadingView:(UIView *) pBaseView
{
    MBProgressHUD *progressHUB = [[MBProgressHUD alloc] initWithView:pBaseView];
    [pBaseView addSubview:progressHUB];
    progressHUB.tag = LOADING_HUB_TAG;
    progressHUB.dimBackground = YES;
//    progressHUB.color = [NAVI_COLOR colorWithAlphaComponent:0.9f];
    [progressHUB show:YES];
    
}

- (void) hideLoadingView:(UIView *) pBaseView
{
    MBProgressHUD* progressHUB = (MBProgressHUD *)[pBaseView viewWithTag:LOADING_HUB_TAG];
    if (progressHUB)
    {
        [progressHUB hide:YES];
        [progressHUB removeFromSuperview];
        progressHUB = nil;
    }
}

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font
{
    CGSize stringSize = [string sizeWithAttributes:@{NSFontAttributeName:font}];
    return stringSize.width;
}

-(BOOL)validateEmail:(NSString*)email
{
    if( (0 != [email rangeOfString:@"@"].length) &&  (0 != [email rangeOfString:@"."].length) )
    {
        NSMutableCharacterSet *invalidCharSet = [[[NSCharacterSet alphanumericCharacterSet] invertedSet]mutableCopy];
        [invalidCharSet removeCharactersInString:@"_-"];
        
        NSRange range1 = [email rangeOfString:@"@" options:NSCaseInsensitiveSearch];
        
        // If username part contains any character other than "."  "_" "-"
        NSString *usernamePart = [email substringToIndex:range1.location];
        NSArray *stringsArray1 = [usernamePart componentsSeparatedByString:@"."];
        for (NSString *string in stringsArray1)
        {
            NSRange rangeOfInavlidChars=[string rangeOfCharacterFromSet: invalidCharSet];
            if(rangeOfInavlidChars.length !=0 || [string isEqualToString:@""])
                return NO;
        }
        
        NSString *domainPart = [email substringFromIndex:range1.location+1];
        NSArray *stringsArray2 = [domainPart componentsSeparatedByString:@"."];
        
        for (NSString *string in stringsArray2)
        {
            NSRange rangeOfInavlidChars=[string rangeOfCharacterFromSet:invalidCharSet];
            if(rangeOfInavlidChars.length !=0 || [string isEqualToString:@""])
                return NO;
        }
        
        return YES;
    }
    else
        return NO;
}

- (void) loadProfileImageFromServer:(NSString *) strPhoto imageView:(UIImageView *)imageViewTaget withResult:(void(^)(UIImage* imgLoaded))blockWithCompletion
{
    imageViewTaget.image = [UIImage imageNamed:@"people-blank.png"];
    
    if ([strPhoto isKindOfClass:[NSNull class]]) return;
    if (strPhoto == nil || [strPhoto isEqualToString:@""]) return;
    
    __weak UIImageView* curImageView = imageViewTaget;
    
    [curImageView setImageWithURL:[NSURL URLWithString:strPhoto] placeholderImage:[UIImage imageNamed:@"people-blank.png"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         if (image)
         {
             curImageView.image = image;
             blockWithCompletion(image);
         }
         else
         {
             blockWithCompletion(image);
         }
         
     } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

- (void) loadPostPhotoFromServer:(NSString *)strPhoto imageView:(UIImageView *)imageViewTarget
{
    __weak UIImageView* curImageView = imageViewTarget;

    [imageViewTarget setImageWithURL:[NSURL URLWithString:strPhoto] placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         if (image)
         {
             curImageView.image = image;
         }
     } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

@end
