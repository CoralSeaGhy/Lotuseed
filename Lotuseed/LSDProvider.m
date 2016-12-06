//
//  LSDProvider.m
//  Lotuseed
//
//  Created by beyond on 12-6-1.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import "LSDProvider.h"
#import "LSDUtils.h"
#import "LSDConstants.h"
#import "LSDProfile.h"
#import "Lotuseed.h"

//static NSString* defaultWebViewUserAgent = nil;

static int eventExtinfoFlag = 0x00; //自定义事件动态扩展数据标记位
static BOOL canGetLocInfo = SDK_CAN_GET_LOC;

@implementation LSDProvider

/*
+ (void)initDefaultWebViewUserAgent
{
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    if (userAgent) {
        defaultWebViewUserAgent = [[NSString alloc] initWithString:userAgent];
    }
    [webView release];
}

+ (NSString*)getDefaultWebViewUserAgent
{
    return defaultWebViewUserAgent;
}
*/
/* removed by eagle on 20130926 */

+ (void)setDeviceInfoPosted:(BOOL)flag
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:(flag==YES ? @"1" : @"0") forKey:@"lotuseed_devinfo"];
    [defaults synchronize];
}

+ (BOOL)getDeviceInfoPosted
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *v = [defaults objectForKey:@"lotuseed_devinfo"];
    if (v && [v isEqualToString:@"1"]) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (void)markCurrentSessionID:(NSString*)ID withTimestamp:(NSDate*)timestamp
{
    if (ID && ID.length>0 && timestamp) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:ID forKey:@"lotuseed_sessionid"];
        [defaults setObject:timestamp forKey:@"lotuseed_lastactive"];
        [defaults synchronize];
    }
}

+ (void)readLastSessionID:(NSString**)ID andTimestamp:(NSDate**)timestamp
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (ID) {
        *ID = [defaults objectForKey:@"lotuseed_sessionid"];
    }
    
    if (timestamp) {
        *timestamp = [defaults objectForKey:@"lotuseed_lastactive"];
    }
}

+ (void)removeLastSessionID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"lotuseed_sessionid"]) {
        [defaults removeObjectForKey:@"lotuseed_sessionid"];
    }
    
    if ([defaults objectForKey:@"lotuseed_lastactive"]) {
        [defaults removeObjectForKey:@"lotuseed_lastactive"];
    }
    
    [defaults synchronize];
}

//Set实时发送统计数据标志
+ (void)setRealTimeMode:(BOOL)mode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:(mode==YES ? @"1" : @"0") forKey:@"lotuseed_realtime"];
    [defaults synchronize];
}

//Get实时发送统计数据标志
+ (BOOL)getRealTimeMode
{
    if ([Lotuseed debugMode]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *mode = [defaults objectForKey:@"lotuseed_realtime"];
        if (!mode) {
            return YES;
        }
        else {
            return ([mode intValue] == 0) ? NO : YES;
        }
    }
    else {
        return false;
    }
}

//Set在线参数配置最新更新时间
+ (void)setOnlineConfigCurrUpdateTime:(NSDate*)timestamp
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:timestamp forKey:@"lotuseed_paramupd"];
    [defaults synchronize];
}

//Get在线参数配置最新更新时间
+ (NSDate*)getOnlineConfigLastUpdateTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"lotuseed_paramupd"];
}

//Set在线参数配置本地缓存版本号
+ (void)setOnlineConfigParamVer:(int)verCode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:verCode] forKey:@"lotuseed_paramver"];
    [defaults synchronize];
}

+ (int)getOnlineConfigParamVer
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *v = [defaults objectForKey:@"lotuseed_paramver"];
    if (v) {
        return [v intValue];
    }
    else {
        return 0;
    }
}

+ (NSString*)getOnlineConfigParam:(NSString*)key
{
    if (!key) return nil;
    
    NSString *filePath = [LSDUtils getFileFullPathInDocument:LOTUSEED_ONLINE_CONFIG_FILE];
    NSArray *arr = [NSArray arrayWithContentsOfFile:filePath];
    if (arr) {
        for (int i=0; i<arr.count; i++) {
            NSDictionary *dic = [arr objectAtIndex:i];
            
            NSString *key2 = [dic objectForKey:@"k"];
            NSString *value = [dic objectForKey:@"v"];
            NSString *isFile = [dic objectForKey:@"f"];
            
            int fileFlag = [isFile intValue];
            if (fileFlag != 0) {
                // 判断本地缓存文件是否存在，不存在则先下载
                // TODO...
            }
            
            if ([key2 isEqualToString:key]) {
                return value;
            }
        }
    }
    return nil;
}

+ (void)saveOnlineConfigParam:(NSArray*)params
{
    if (params) {
        NSString *filePath = [LSDUtils getFileFullPathInDocument:LOTUSEED_ONLINE_CONFIG_FILE];
        [params writeToFile:filePath atomically:YES];
    }
}

//Get应用覆盖更新标志(仅一次有效)
+ (BOOL)getAppReplaceFlag
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *flag = [defaults objectForKey:@"lotuseed_replaced"];
    
    if (!flag) {
        NSDate *createDate = [LSDProfile getAppCreateTime];
        if (createDate) {
            if (fabs([createDate timeIntervalSinceDate:[NSDate dateWithTimeIntervalSinceNow:0]]) > 24*60*60) { //24h
                [defaults setObject:@"1" forKey:@"lotuseed_replaced"];
                return YES;
            }
        }
    }
    
    return NO;
}

+ (void)setEventExtinfoFlag:(int)flag
{
    eventExtinfoFlag = flag;
}

+ (int)getEventExtinfoFlag
{
    return eventExtinfoFlag;
}

+ (void)setGetLocationPermission:(BOOL) flag
{
    canGetLocInfo = flag;
}

+ (BOOL)getGetLocationPermission
{
    if ([LSDProfile isForceLocation] == NO) {
        return canGetLocInfo;
    }
    return YES;
}

@end
