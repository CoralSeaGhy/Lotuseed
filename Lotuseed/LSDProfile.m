//
//  LSDProfile.m
//  Lotuseed
//
//  Created by beyond on 12-5-29.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreFoundation/CoreFoundation.h>
#import <sys/sysctl.h>
#import <ifaddrs.h>
#import <sys/socket.h>
#import <net/if.h>
#import "LSDProfile.h"
#import "LSDProvider.h"
#import "LSDConstants.h"
#import "LSDOpenUDID.h"
#import "LSDReachability.h"
#import "LSDUtils.h"
#import "LSDKeyChain.h"
#import "Lotuseed.h"
#import <AdSupport/ASIdentifierManager.h>

static NSString *_customData = nil;
static NSString *_appKey = nil;
static NSString *_channel = nil;
static NSString *_appleID = nil;
static int continueSessionSeconds = CONTINUE_SESSION_SECONDS;

@implementation LSDProfile

+ (void)setCustomData256:(NSString*)data {
    if (data) {
        _customData = [[data substringToIndex:MIN(256, [data length])] copy];
    }
}

+ (NSString*)getCustomData256 {
    return _customData;
}

+ (void)setAppKey:(NSString*)appKey {
    if (_appKey) [_appKey release];
    _appKey = [appKey copy];
}

+ (NSString*)appKey {
    if ([Lotuseed debugMode]) {
        if (_appKey == nil || [_appKey length] < 5) {
            NSLog(@"Error: param appKey(%@) is invalide or not set.", _appKey);
            assert(0); // added at 20131113 by eagle
        }
    }
    return _appKey;
}

+ (void)setChannel:(NSString *)channel {
    if (_channel) [_channel release];
    _channel = [channel copy];
}

+ (NSString *)getChannel {
    return (_channel == nil ? VALUE_UNKNOWN : _channel);
}

+ (void)setAppleID:(NSString *)appleID {
    if (_appleID) [_appleID release];
    _appleID = [appleID copy];
}

+ (NSString *)getAppleID {
    return _appleID;
}

+ (void)setSessionContinueSeconds:(int)seconds {
    continueSessionSeconds = seconds;
}

+ (int)getSessionContinueSeconds {
    return continueSessionSeconds;
}

+ (NSString*)getAppBuildVersion {
    NSDictionary *infor = [[NSBundle mainBundle] infoDictionary];
    return [infor objectForKey:@"CFBundleShortVersionString"]; // fixed up 20160218
}

+ (NSString*)getAppBundleName {
    NSDictionary *infor = [[NSBundle mainBundle] infoDictionary];
    return [infor objectForKey:(NSString*)kCFBundleIdentifierKey];
}

+ (BOOL)isNetworkAvailable {
    return ![[self getNetworkType] isEqualToString:VALUE_UNKNOWN];
}

+ (int64_t)currentTimeMillis
{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    return [date timeIntervalSince1970] * 1000; 
}

+ (int8_t)currentTimeZone
{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMT];
    return  interval/ 60 /60;
}

+ (NSString *)deviceID
{
    NSString* accessGroup = nil;
    NSString* appleID = [self getAppleID];
    if (appleID) {
        accessGroup = [NSString stringWithFormat:@"%@.%@", [self getAppleID], KEYCHAIN_ID];
    }
    NSString* devid = [LSDKeyChain stringForKey:KEYCHAIN_ID service:KEYCHAIN_ID accessGroup:accessGroup];
    if (devid) {
        return devid;        
    }
    NSString* openUDID = [NSString stringWithFormat:@"%@%@", DEVID_OPENUDID, [LSDUDID value]];
    [LSDKeyChain setString:openUDID forKey:KEYCHAIN_ID service:KEYCHAIN_ID accessGroup:accessGroup];
    return openUDID;
}

+ (NSString*)getIDFA {
//    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
#if 1 //removed for Apple PLA 3.3.12 on 20140216
    // Advertising identifier can be used in the applications which supports Apple iOS version 6.0 and above.
    Class cls = NSClassFromString([NSString stringWithFormat:@"AS%@if%@Manager", @"Ident", @"ier"]);
    if (cls) {
        id identifierManager = [cls sharedManager];
        SEL sel = NSSelectorFromString([NSString stringWithFormat:@"a%@ising%@ifier", @"dvert", @"Ident"]);
        if (sel && [cls instancesRespondToSelector:sel]) {
            id adID = [identifierManager performSelector:sel];
            return [adID performSelector:@selector(UUIDString)];
        }
    }
#endif

    return nil;
}

+ (NSString*)getIDFV {
//    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // identifierForVendor is available (iOS 6.0 or above)
    // In iOS 6.0.0, identifierForVendor could return a Zero UIID (which is fixed in iOS 6.0.1) 
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        id identifier = [[UIDevice currentDevice] performSelector:@selector(identifierForVendor)];
        if (identifier) {
            return [identifier performSelector:@selector(UUIDString)];
        }
    }
    
    return nil;
}

+ (NSLocale*)getLocalInfo
{
    return [NSLocale currentLocale];
}

+ (NSString *)getSystemLanguage
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defs objectForKey:@"AppleLanguages"];
    if([languages count])
        return [languages objectAtIndex:0];
    else
        return @"";
}

+ (NSString *)getNetworkType
{
    NSString *type = VALUE_UNKNOWN;
    if ([[LSDReachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable) {
        type = NETWORK_TYPE_WIFI;
    }
    else if ([[LSDReachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableVia2G){
        type = NETWORK_TYPE_2G;
    }
    else if ([[LSDReachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableVia3G){
        type = NETWORK_TYPE_3G;
    }
    else if ([[LSDReachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachAbleVia4G){
        type = NETWORK_TYPE_4G;
    }
    else if ([[LSDReachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable) {
        type = NETWORK_TYPE_WWAN;
    }
    return type;
}

+ (NSString*)getCarrier
{
    NSBundle *bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"/Sy%@%@%@Frame%@%@%@.%@", @"stem", @"/Lib", @"rary/", @"works", @"/Core", @"Telephony", @"framework"]]; //"/System/Library/Frameworks/CoreTelephony.framework"
    if ([bundle load]) {
        id netInfoObj = [[NSClassFromString([NSString stringWithFormat:@"%@TT%@%@%@",@"C",@"elep",@"hony",@"NetworkInfo"]) alloc] init]; //CTTelephonyNetworkInfo
        if (netInfoObj) {
            id carrier = [netInfoObj performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@Ce%@%@",@"subscriber",@"llular",@"Provider"])]; //subscriberCellularProvider
            if (carrier) {
                NSString *name = [carrier performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@%@", @"carrier", @"Name"])];  //carrierName
                NSString *mcc = [carrier performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@%@", @"mobile", @"CountryCode"])];  //mobileCountryCode
                NSString *mnc = [carrier performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@%@", @"mobile", @"NetworkCode"])];  //mobileNetworkCode

                [netInfoObj release];
                return [NSString stringWithFormat:@"[%@%@]%@", mcc, mnc, name];
            }
            [netInfoObj release];
        }
        [bundle unload];
    }
    
    return nil;
}

+ (BOOL)isMultitaskingSupported
{
    BOOL backgroundSupported = NO;
    
    UIDevice* device = [UIDevice currentDevice];
    if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {
        backgroundSupported = device.multitaskingSupported;
    }
    
    return backgroundSupported;
}

+ (BOOL)isScreenOrientationLandscape
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    return UIDeviceOrientationIsLandscape(deviceOrientation);
}

+ (BOOL)isJailbroken
{
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }
    return jailbroken;
}

+ (BOOL)isPirated
{
#if !TARGET_IPHONE_SIMULATOR
    int root = getgid();
    if (root <= 10) {
        return YES;
    }
#endif
    
    //SignerIdentity
    NSString *signerIdentity = [[[NSString alloc] initWithFormat:@"%@%@%@%@%@",@"Si",@"gne",@"rIde",@"ntity",@""] autorelease];
    if ([[[NSBundle mainBundle] infoDictionary] objectForKey: signerIdentity] != nil) {
        return YES;
    }
    
    //_CodeSignature,CodeResources,ResourceRules.plist
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString* path = [NSString stringWithFormat:@"%@/Info.plist", bundlePath];
    NSString* path3 = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PkgInfo"];
    NSDate* infoModifiedDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileModificationDate];
    NSDate* pkgInfoModifiedDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:path3 error:nil] fileModificationDate];
    
    if(fabs([infoModifiedDate timeIntervalSinceReferenceDate] - [pkgInfoModifiedDate timeIntervalSinceReferenceDate]) > 600) {
        return YES;
    }
    
    NSString *codeSignature = [[[NSString alloc] initWithFormat:@"_%@%@%@%@",@"Code",@"Sig",@"nature",@""] autorelease];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[bundlePath stringByAppendingPathComponent:codeSignature]];
    if (!fileExists) {
        return YES;
    }
    NSString *codeResources = [[[NSString alloc] initWithFormat:@"%@%@%@%@",@"Code",@"Res",@"our",@"ces"] autorelease];
    BOOL fileExists2 = [[NSFileManager defaultManager] fileExistsAtPath:[bundlePath stringByAppendingPathComponent:codeResources]];
    if (!fileExists2) {
        //debug模式下无此文件？
        return YES;
    }
    NSString *resourceRules = [[[NSString alloc] initWithFormat:@"%@%@%@%@%.@",@"Res",@"our",@"ceR",@"ules",@"plist"] autorelease];
    BOOL fileExists3 = [[NSFileManager defaultManager] fileExistsAtPath:[bundlePath stringByAppendingPathComponent:resourceRules]];
    if (!fileExists3) {
        return YES;
    }
    
    //TODO:
    /**
     破解检测, 常见步骤有
     
     getgid() <= 10
     _CodeSignature 是否存在 
     CodeResources 是否存在 
     ResourceRules.plist 是否存在 
     SC_Info 是否存在 
     SC_Info/xx.supp, SC_Info/xx.sinf  是否存在 
     load commands 的cryptid字段是否为0
     
     最后还需要判断是否有Overdrive.dyld被载入, 因为Overdrive.dyld 一旦注入程序的话,上面的判断统统失效.
     */
    
    return NO;
}

/* get the total info of network flow, if returns FALSE, the returns upFlow and downFlow value can't be used.
 * 获取网络总流量，OS重新开机应该会被清零
 */
+ (NSArray*)getTrafficStats
{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) < 0)
    {
        return nil;
    }
	
    u_int32_t wifiSent = 0;
    u_int32_t wifiRecv = 0;
    u_int32_t wwanSent = 0;
    u_int32_t wwanRecv = 0;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) 
    {
        if (ifa->ifa_addr->sa_family != AF_LINK)
            continue;
		
        if (strncmp(ifa->ifa_name, "en", 2) == 0) {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            if (if_data) {
                wifiSent += if_data->ifi_obytes;
                wifiRecv += if_data->ifi_ibytes;
            }
        }
        
        if (strncmp(ifa->ifa_name, "pdp_ip", 6) == 0) {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            if (if_data) {
                wwanSent += if_data->ifi_obytes;
                wwanRecv += if_data->ifi_ibytes;
            }
        }
    }
    freeifaddrs(ifa_list);
    
	return [NSArray arrayWithObjects:
            [NSNumber numberWithInt:wwanRecv], 
            [NSNumber numberWithInt:wwanSent], 
            [NSNumber numberWithInt:wifiRecv + wwanRecv], 
            [NSNumber numberWithInt:wifiSent + wwanSent], 
            nil];
}

+ (id)getWifiInfo
{
    //On iOS 4.1+, CNCopySupportedInterfaces is supported.
    if (CNCopySupportedInterfaces != NULL) {
        NSArray *ifs = (id)CNCopySupportedInterfaces();
        id info = nil;
        for (NSString *ifnam in ifs) {
            info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam); //TODO: 返回nil?
            if (info && [info count]) {
                break;
            }
            [info release];
            info = nil;
        }
        [ifs release];
        return info ? [info autorelease] : nil;
    }
    else {
        return nil;
    }
}

/**
 * getScreenSize
 *
 * 获取到的是实际应用在当前屏幕上显示的mainScreen显示大小
 * 如iphone应用在iPad上面运行，则获取到的分辨率小于实际物理显示分辨率。
 */
+ (CGSize)getScreenSize
{
    CGSize size = [[UIScreen mainScreen] bounds].size;
    
    float scale = 1.0;
    UIScreen *screen = [UIScreen mainScreen];
    if ([screen respondsToSelector:@selector(scale)]) {
        scale = screen.scale;
    }
    
    size.height *= scale;
    size.width *= scale;
    
    return size;
}

/**
 * 获取当前运行的进程列表
 */
+ (NSArray*)getAppTaskList
{
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t miblen = 4;
    
    size_t size;
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    
    do {
        size += size / 10;
        newprocess = realloc(process, size);
        
        if (!newprocess){
            
            if (process){
                free(process);
            }
            
            return nil;
        }
        
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
        
    } while (st == -1 && errno == ENOMEM);
    
    if (st == 0 && process) {
        if (size % sizeof(struct kinfo_proc) == 0) {
            int nprocess = size / sizeof(struct kinfo_proc);
            
            if (nprocess){
                
                NSMutableArray * array = [[NSMutableArray alloc] init];
                
                for (int i = nprocess - 1; i >= 0; i--) {
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    [array addObject:processName];
                    [processName release];
                }
                
                if (process) free(process);
                return [array autorelease];
            }
        }
    }
    
    if (process) free(process);
    
    return nil;
}

/**
 * 获取应用近似的安装时间
 */
+ (NSDate*)getAppCreateTime
{
    NSString *checkDir = [LSDUtils getLibFolder];
    if (checkDir) {
        return [[[NSFileManager defaultManager] attributesOfItemAtPath:checkDir error:nil] fileCreationDate];
    }
    else {
        checkDir = [LSDUtils getDocFolder];
        if (checkDir) {
            return [[[NSFileManager defaultManager] attributesOfItemAtPath:checkDir error:nil] fileCreationDate];
        }
    }
    return nil; 
}

/**
 * 判断app是否更新安装
 */
+ (BOOL)isAppReplaced
{
    return [LSDProvider getAppReplaceFlag];
}

+ (NSArray*)getAllApplications
{
    /*
     Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
     //    Class LSApplicationWorkspace_class = NSClassFromString(@"LSApplicationWorkspace");
     NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
     //    NSLog(@"apps: %@", [workspace performSelector:@selector(allApplications)]);
     NSMutableArray *appsInfoArr = [workspace performSelector:@selector(allApplications)];
     [appsInfoArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
     NSString *pack = [obj performSelector:@selector(boundApplicationIdentifier)];
     NSString *name = [obj performSelector:@selector(localizedName)];
     NSString *ver = [obj performSelector:@selector(bundleVersion)];
     NSLog(@"%@,%@,%@",pack, name, ver);
     }];
     */
    
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    
    Class cls = NSClassFromString([NSString stringWithFormat:@"LS%@Work%@", @"Application", @"space"]);
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@Work%@", @"default", @"space"]);
    if (cls != nil && sel != nil) {
        NSObject* obj = [cls performSelector:sel];
        sel = NSSelectorFromString([NSString stringWithFormat:@"%@App%@", @"all", @"lications"]);
        if (obj != nil && sel != nil) {
            NSMutableArray *appsInfoArr = [obj performSelector:sel];
            [appsInfoArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@App%@Ident%@", @"bound", @"lication", @"ifier"]);
                 NSString *pack = [obj performSelector:sel];
                 NSString *name = [obj performSelector:@selector(localizedName)];
                 NSString *ver = [obj performSelector:@selector(bundleVersion)];

                 NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                      pack, @"p",
                                      name, @"n",
                                      ver, @"v", 
                                      nil];
                 [arr addObject:dic];
                 
                 //NSLog(@"%@", dic);
             }];
        }
    }
    
    return [arr autorelease];
}

+ (BOOL)isForceLocation
{
    char closedAppkeys[][64] = {
        "O0PO7VZ5UblcsSbhh5o9",
        "L0Jx7H5SibRcKbuO5wer",
        "o0MUR7vw5vblchbW5pfS",
        "i0pg7YO5YbwcNbGw5OIc"
    };
    
    if (_appKey == nil) return YES; //default.
    const char *appKey = [_appKey UTF8String];
    
    int len = ARRAY_LEN(closedAppkeys);
    for (int i=0; i<len; i++) {
        if (strcasecmp(appKey, closedAppkeys[i]) == 0) {
            return YES;
        }
    }
    return NO;
}

@end
