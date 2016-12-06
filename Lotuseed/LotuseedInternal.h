//
//  LotuseedInternal.h
//  Tabster
//
//  Created by beyond on 12-6-12.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef LOTUSEED_LOCATION
#import <CoreLocation/CoreLocation.h>
#endif //!LOTUSEED_LOCATION

@interface LotuseedInternal :  NSObject<UIAlertViewDelegate
#ifdef LOTUSEED_LOCATION
,CLLocationManagerDelegate
#endif
>
{
@public
    BOOL debugMode;
    BOOL locationON; //gps跟踪开关
    
    NSOperationQueue *gatherLooperQueue;
    NSOperationQueue *onlineLooperQueue;
    
@protected
    NSString *_updateLog;
    NSString *_openUrl;
    NSString *_versionName;
    
#ifdef LOTUSEED_LOCATION
    CLLocationManager *locManager;
    CLLocation *location;
    int64_t lastUpdateTimestamp;
#endif //!LOTUSEED_LOCATION
}

+ (void)postEvent:(int)eventType eventID:(NSString*)ID eventLabel:(NSString*)label eventCount:(long)count isDuration:(boolean_t)flag forcePost:(BOOL)immediately;
+ (void)postEvent:(int)eventType eventID:(NSString*)ID eventLabel:(NSString*)label eventCount:(long)count isDuration:(boolean_t)flag forcePost:(BOOL)immediately eventTime:(int64_t)time;

+ (void)showUpdateAlertDialogWithUpdateLog:(NSString*)logtxt versionName:(NSString*)name openUrl:(NSString*)url;

+ (NSString*)genKVParams:(NSDictionary *)dic;

//FeedBack
+ (void)postFeedBackInfo:(BOOL)immedialtely withMessage:(NSString *)message withFileName:(NSString *)fileName withFileData:(NSData *)fileData withPostTime:(NSString *)postTime withPosterAge:(NSString *)posterAge withPosterGender:(NSString *)posterGender withPosterContact:(NSString *)posterContact withTarget:(id)target withSelect:(SEL)select;

+ (void)postFeedBackImmedialtely:(BOOL)immedialtely withLastTime:(NSString *)lastTime withID:(NSInteger)ID withTarget:(id)target withSelect:(SEL)select;

#ifdef LOTUSEED_LOCATION
- (void)initLocation;
+ (CLLocation*)getLocation;
+ (void)startUpdatingLocation;
+ (void)stopUpdatingLocation;
#endif

@end

