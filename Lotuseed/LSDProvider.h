//
//  LSDProvider.h
//  Lotuseed
//
//  Created by beyond on 12-6-1.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSDProvider : NSObject
{
    
}

//+ (void)initDefaultWebViewUserAgent;
//+ (NSString*)getDefaultWebViewUserAgent;

+ (void)setDeviceInfoPosted:(BOOL)flag;
+ (BOOL) getDeviceInfoPosted;

+ (void)markCurrentSessionID:(NSString*)ID withTimestamp:(NSDate*)timestamp;
+ (void)readLastSessionID:(NSString**)ID andTimestamp:(NSDate**)timestamp;
+ (void)removeLastSessionID;

+ (void)setRealTimeMode:(BOOL)mode;
+ (BOOL)getRealTimeMode;
+ (void)setOnlineConfigCurrUpdateTime:(NSDate*)timestamp;
+ (NSDate*)getOnlineConfigLastUpdateTime;
+ (void)setOnlineConfigParamVer:(int)verCode;
+ (int)getOnlineConfigParamVer;

+ (BOOL)getAppReplaceFlag;

+ (NSString*)getOnlineConfigParam:(NSString*)key;
+ (void)saveOnlineConfigParam:(NSArray*)params;

+ (void)setEventExtinfoFlag:(int)flag;
+ (int)getEventExtinfoFlag;

+ (void)setGetLocationPermission:(BOOL) flag;
+ (BOOL)getGetLocationPermission;

@end
