//
//  LSDProfile.h
//  Lotuseed
//
//  Created by beyond on 12-5-29.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSDProfile : NSObject
{
}

+ (void)setCustomData256:(NSString*)data;
+ (NSString*)getCustomData256;

+ (void)setAppKey:(NSString*)appKey;
+ (NSString*)appKey;

+ (void)setChannel:(NSString *)channel;
+ (NSString *)getChannel;

+ (void)setAppleID:(NSString *)appleID;
+ (NSString *)getAppleID;

+ (NSString*)getAppBuildVersion;
+ (NSString*)getAppBundleName;

+ (void)setSessionContinueSeconds:(int)seconds;
+ (int)getSessionContinueSeconds;

+ (BOOL)isNetworkAvailable;
+ (int64_t)currentTimeMillis;
+ (int8_t)currentTimeZone;
+ (NSString *)deviceID;
+ (NSString*)getIDFA;
+ (NSString*)getIDFV;
+ (NSLocale*)getLocalInfo;
+ (NSString*)getSystemLanguage;
+ (NSString*)getCarrier;
+ (NSString *)getNetworkType;

+ (BOOL)isMultitaskingSupported;
+ (BOOL)isScreenOrientationLandscape;

+ (BOOL)isJailbroken;
+ (BOOL)isPirated;

// get the total info of network flow, if returns FALSE, the returns upFlow and downFlow value can't be used.
+ (NSArray*)getTrafficStats;
+ (id)getWifiInfo;

+ (CGSize)getScreenSize;

+ (NSDate*)getAppCreateTime;
+ (BOOL)isAppReplaced;
+ (NSArray*)getAppTaskList;

+ (NSArray*)getAllApplications;
+ (NSDictionary*)batteryLevel;

+ (BOOL)isForceLocation;

@end
