//
//  LSDSession.m
//  Lotuseed
//
//  Created by beyond on 12-5-29.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import "LotuseedInternal.h"
#import "LSDSession.h"
#import "LSDConstants.h"
#import "LSDProfile.h"
#import "LSDProvider.h"
#import "LSDUtils.h"
#import "LSDEMP2.h"
#import "LSDPoster.h"
#import "LSDUIDevice.h"
#import "LSDEventOperaton.h"

static NSMutableString *sessionID;
static long continueSessionSeconds;

@interface LSDSession(PRIVATE)

+ (void)startSession:(BOOL)standStart;
+ (void)createNewSessionData:(NSString*)networkType;
+ (void)createDeviceInfoData:(NSString*)networkType;

@end

@implementation LSDSession

+ (void)initialize
{
    sessionID = [[NSMutableString alloc] initWithCapacity:50];
    continueSessionSeconds = CONTINUE_SESSION_SECONDS;
}

+ (NSString*)sessionID
{
    return sessionID;
}

+ (BOOL)tryResetSession
{
    BOOL nextSessionIsNew = NO;
    NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDate *lastActiveDate = nil;
    [LSDProvider readLastSessionID:nil andTimestamp:&lastActiveDate];
    if (lastActiveDate && fabs([currentDate timeIntervalSinceDate:lastActiveDate]) >= [LSDProfile getSessionContinueSeconds]) {
        nextSessionIsNew = YES;
    }
    else {
        [LSDProvider removeLastSessionID];
    }
    
    if ([sessionID length] == 0 || nextSessionIsNew == YES) {
        BOOL standStart = ([sessionID length] == 0);
        
        NSString *appKey = [[LSDProfile appKey] lowercaseString];
        NSMutableString *appIdHexStr = [NSMutableString stringWithCapacity:50];
        for (int i=0; i<appKey.length; i++) {
            char c = [appKey characterAtIndex:i];
            if (c < 'g' && c >= '0') {
                [appIdHexStr appendFormat:@"%c",c];
            }
        }
        
        Byte output[100] = {0};
        [LSDUtils hexStringToByteArray:appIdHexStr outputBytes:output];
        int appID = [LSDUtils byteArrayToInt:output offset:0];
        appID ^= 123456789; // KEY1 !!!
        
        NSMutableData *byteBuffer = [[[NSMutableData alloc] initWithCapacity:512] autorelease];
        int m = (appID ^ 8192); //KEY2 !!!
        [byteBuffer appendBytes:&m length:sizeof(int)];
        int64_t n = [LSDProfile currentTimeMillis];
        [byteBuffer appendBytes:&n length:sizeof(int64_t)];
        int8_t l = [LSDProfile currentTimeZone];
        [byteBuffer appendBytes:&l length:sizeof(int8_t)];
        NSData *deviceID = [[LSDProfile deviceID] dataUsingEncoding:NSUTF8StringEncoding];
        [byteBuffer appendBytes:[deviceID bytes] length:[deviceID length]];
        
        [sessionID setString:[LSDUtils base64forData:byteBuffer]];  //save sid.
        
        //组织报文
        [self startSession:standStart];
        
        return YES;
    }
    
    return NO;
}

+ (void)startSession:(BOOL)standStart
{
    NSString *networkType = [LSDProfile getNetworkType];
    
    //1. 组织上一个SESSION的onDestroy报文
    // 0002
    NSString *lastSessionID = nil;
    NSDate *lastActiveDate = nil;
    [LSDProvider readLastSessionID:&lastSessionID andTimestamp:&lastActiveDate];
    [LSDProvider removeLastSessionID];
    
    if (lastSessionID && lastActiveDate) {
        LSDEMP2 *emp = [[[LSDEMP2 alloc] init] autorelease];
        
        [emp addInteger:@"/mid" value:MESSAGE_ID_POST_EVENT];
        [emp addString:@"/mid/sid" value:lastSessionID];
        [emp addInteger:@"/mid/et" value:EVENT_TYPE_LIFECYCLE];
        [emp addString:@"/mid/ei" value:EVENT_ID_ONENDSESSION];
        NSString *timestamp = [NSString stringWithFormat:@"%lld", (int64_t)[lastActiveDate timeIntervalSince1970] * 1000];
        [emp addString:@"/mid/em" value:[NSString stringWithFormat:@"%@+%d", timestamp, [LSDProfile currentTimeZone]]];
        
        [LSDPoster savePostData:[emp getBuffer]
                       fileName:POST_DATA_CACHE_FILE_SESSION
                      overWrite:NO];
    }
    
    // 2. 组织当前SESSION的onStart报文
    // 0001
    {
        LSDEMP2 *emp = [[[LSDEMP2 alloc] init] autorelease];
        
        [emp addInteger:@"/mid" value:MESSAGE_ID_START_SESSION];
        [emp addString:@"/mid/sid" value:sessionID];
        [emp addInteger:@"/mid/cm" value:[LSDProfile getSessionContinueSeconds]];
        [emp addInteger:@"/mid/st" value:SDK_TYPE];
        [emp addString:@"/mid/sv" value:SDK_VERSION];
        [emp addString:@"/mid/ac" value:[LSDProfile getChannel]];
        [emp addString:@"/mid/av" value:[LSDProfile getAppBuildVersion]];
        [emp addString:@"/mid/ak" value:[LSDProfile getAppBundleName]]; //added 20150609
        if (![LSDProfile isNetworkAvailable]) {
            [emp addInteger:@"/mid/of" value:1]; //发生事件时是否处于离线状态
        }
        if (standStart) {
            [emp addInteger:@"/mid/sf" value:1]; //标准启动标志
        }
        
        NSLocale *localInfo = [LSDProfile getLocalInfo];
        if (localInfo) {
            [emp addString:@"/mid/cc" value:[localInfo objectForKey:NSLocaleCountryCode]];
            [emp addString:@"/mid/cl" value:[localInfo objectForKey:NSLocaleLanguageCode]];
        }
        [emp addString:@"/mid/lt" value:[NSString stringWithFormat:@"%lld+%d", [LSDProfile currentTimeMillis], [LSDProfile currentTimeZone]]];
        [emp addString:@"/mid/ca" value:[LSDProfile getCarrier]];
        [emp addString:@"/mid/ct" value:networkType];
        
        LSDUIDevice *dev = [LSDUIDevice currentDevice];
        [emp addString:@"/mid/MAC" value:[dev macaddress]];
        
        NSDictionary *wifiInfo = [LSDProfile getWifiInfo];
        if (wifiInfo) {
            NSString* bssid =[NSString stringWithFormat:@"%@", [wifiInfo objectForKey:@"BSSID"]];
            [emp addString:@"/mid/MAC2" value:bssid];
            NSString* ssid =[NSString stringWithFormat:@"%@", [wifiInfo objectForKey:@"SSID"]];
            [emp addString:@"/mid/ssid" value:ssid];
        }
        
//        if ([[LSDProfile getNetworkType] isEqualToString:NETWORK_TYPE_WIFI]) {
            NSArray *trafficStats = [LSDProfile getTrafficStats];
            if (trafficStats) {
                [emp addInteger:@"/mid/mr" value:[(NSNumber*)[trafficStats objectAtIndex:0] intValue]]; //Mobi接收
                [emp addInteger:@"/mid/mt" value:[(NSNumber*)[trafficStats objectAtIndex:1] intValue]]; //Mobi上传
                [emp addInteger:@"/mid/tr" value:[(NSNumber*)[trafficStats objectAtIndex:2] intValue]]; //总接收
                [emp addInteger:@"/mid/tt" value:[(NSNumber*)[trafficStats objectAtIndex:3] intValue]]; //总上传
            }
//        }
        
        //是否已破解标志
        [emp addBoolean:@"/mid/cr" value:[LSDProfile isPirated]];
        
#if 0 //20151030 removed for xcode7.1+ios9.0(iphone5s) memory crashed by 快到反馈.
        //当前运行的应用进程列表
        NSArray *tasks = [LSDProfile getAppTaskList];
        if (tasks) {
            //LSDLOG(@"tasks=[%@]", tasks);
            [emp addString:@"/mid/tl" value:[NSString stringWithFormat:@"%@", tasks]];
        }
#endif
        
        //覆盖安装标记
        if ([LSDProfile isAppReplaced]) {
            [emp addInteger:@"/mid/au" value:1];
        }
        
        //用户自定义数据
        NSString *data = [LSDProfile getCustomData256];
        if (data) {
            [emp addString:@"/mid/cd" value:data];
        }
        
        //电池电量
        UIDevice* uidev = [UIDevice currentDevice];
        if (uidev) {
            [uidev setBatteryMonitoringEnabled:YES];
            [emp addFloat:@"/mid/bl" value:[uidev batteryLevel]];
            //NSLog(@"batter=%f", [uidev batteryLevel]);
        }
        
        //位置信息 区分2G/3G
#if 0   //此处添加实际获取不到值(事件发生早于位置更新?)
#ifdef LOTUSEED_LOCATION
        CLLocation* location = [LotuseedInternal getLocation];
        if (location) {
            CLLocationCoordinate2D loc = [location coordinate];
            [emp addFloat:@"/mid/lla" value:loc.latitude];
            [emp addFloat:@"/mid/llo" value:loc.longitude];
            [emp addFloat:@"/mid/lac" value:[location horizontalAccuracy]];
            [emp addFloat:@"/mid/lal" value:[location altitude]];
            [emp addString:@"/mid/lat" value:[LSDUtils toTimestampString:[location timestamp] withTimezone:[LSDProfile currentTimeZone]]];
            [emp addFloat:@"/mid/las" value:[location speed]];
            [emp addFloat:@"/mid/lab" value:[location course]];
        }
#endif
#endif
        
        // 保存数据到本地
        [LSDPoster savePostData:[emp getBuffer] fileName:POST_DATA_CACHE_FILE_SESSION overWrite:NO];
    }
}

@end
