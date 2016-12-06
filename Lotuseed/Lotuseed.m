
//  Lotuseed.m
//  Lotuseed
//
//  Created by beyond on 12-5-22.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#include <signal.h>
#include <execinfo.h>
#import <objc/runtime.h>
#import "Lotuseed.h"
#import "LotuseedInternal.h"
#import "LSDVersion.h"
#import "LSDConstants.h"
#import "LSDEventOperaton.h"
#import "LSDUpdateOperation.h"
#import "LSDSession.h"
#import "LSDProfile.h"
#import "LSDProvider.h"
#import "LSDUtils.h"
#import "LSDUIDevice.h"
#import "LSDOnlineConfigOperation.h"

#ifdef LOTUSEED_FEED
#import "LSDFeedBackOperation.h"
#import "LSDFeedBackHistoryOperation.h"
#import "LSDHistoryFeedBackViewController.h"
#import "LSDFeedBackVO.h"
#endif

#ifdef LOTUSEED_AUTO
#import "LSDMonitoring.h"
#endif

#ifdef LOTUSEED_TRACK
#import "LSDTrack.h"
#endif

#ifdef LOTUSEED_LOCATION
#import "LSDOnlineLocationOperation.h"
#import <CoreLocation/CoreLocation.h>
#endif

#ifdef LOTUSEED_ONPV
//onpv params
static NSString *lastPVName = @"";
static int64_t lastOnResumeTime = 0L;
#endif

//global params
static LotuseedInternal *lotuseedInternalSingleton = nil;
static NSUncaughtExceptionHandler *oldUncaughtExceptionHandler = nil;

//update params
static NSString *lotuseedUpdateAlertDialogTitle = nil;
static NSString *lotuseedUpdateYesButtonCaption = nil;
static NSString *lotuseedUpdateNoButtonCaption = nil;
static BOOL isAppUpdating = NO;


@implementation LotuseedInternal

+ (void)showUpdateAlertDialogWithUpdateLog:(NSString*)logtxt versionName:(NSString*)name openUrl:(NSString*)url
{
    isAppUpdating = YES;
    
    lotuseedInternalSingleton->_updateLog = [logtxt retain];
    lotuseedInternalSingleton->_versionName = [name retain];
    lotuseedInternalSingleton->_openUrl = [url retain];
    
    [self performSelectorOnMainThread:@selector(showUpdateAlertDialogOnMainThread) withObject:nil waitUntilDone:YES];
}

+ (void)showUpdateAlertDialogOnMainThread
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    UIAlertView* dialog = [[UIAlertView alloc] init];
    [dialog setDelegate:lotuseedInternalSingleton];
    [dialog setTitle:lotuseedUpdateAlertDialogTitle];
    [dialog setMessage:lotuseedInternalSingleton->_updateLog];
    [dialog addButtonWithTitle:lotuseedUpdateYesButtonCaption];
    [dialog addButtonWithTitle:lotuseedUpdateNoButtonCaption];
    [dialog show];
    [dialog release];
    
    [pool release];
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_openUrl]];
    }
    
    //release
    [_updateLog release];
    [_openUrl release];
    [_versionName release];
    
    isAppUpdating = NO;
}

#ifdef LOTUSEED_LOCATION
//协议中的方法，作用是每当位置发生更新时会调用的委托方法
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [location release];
    location = [newLocation copy];
        
    lastUpdateTimestamp = [LSDProfile currentTimeMillis];
    [manager stopUpdatingLocation];
}
#endif

- (id)init
{
    if (self = [super init]) {
        debugMode = DEBUG_MODE_DEFAULT;
        
        // event queue thread 单线程处理!
        gatherLooperQueue = [[NSOperationQueue alloc] init];
        [gatherLooperQueue setMaxConcurrentOperationCount:1];
        
        // online queue thread 单线程处理!
        onlineLooperQueue = [[NSOperationQueue alloc] init];
        [onlineLooperQueue setMaxConcurrentOperationCount:1];
        
        locationON = SDK_CAN_GET_LOC; //默认打开
        
#ifdef LOTUSEED_AUTO
        [LSDMonitoring shareInstance];
#endif
    }
    return self;
}

- (void)dealloc
{
#ifdef LOTUSEED_LOCATION
    if (locManager) {
        [locManager stopUpdatingLocation];
        [locManager release];
    }
    if (location) {
        [location release];
    }
#endif
    
    [gatherLooperQueue dealloc];
    gatherLooperQueue = nil;
    
    [onlineLooperQueue dealloc];
    onlineLooperQueue = nil;
    
    [super dealloc];
}

+ (void)postEvent:(int)eventType eventID:(NSString*)ID eventLabel:(NSString*)label eventCount:(long)count isDuration:(boolean_t)flag forcePost:(BOOL)immediately
{
    [self postEvent:eventType eventID:ID eventLabel:label eventCount:count isDuration:flag forcePost:immediately eventTime:[LSDProfile currentTimeMillis]];
}

+ (void)postEvent:(int)eventType eventID:(NSString*)ID eventLabel:(NSString*)label eventCount:(long)count isDuration:(boolean_t)flag forcePost:(BOOL)immediately eventTime:(int64_t)time
{
    @try {
        //
#ifdef LOTUSEED_LOCATION
        [LotuseedInternal startUpdatingLocation];
#endif
        
        LSDEventOperaton *operation = [[LSDEventOperaton alloc] initWithEventType:eventType eventID:ID eventLabel:label eventCount:count isDuration:flag forcePost:immediately eventTime:time];
    	[lotuseedInternalSingleton->gatherLooperQueue addOperation:operation];
    	[operation release];
    }
    @catch (NSException *exception) {
        LSDLOG(@"Exception: %@", exception);
    }
}

+ (void)postGatherEvent:(BOOL)immediately
{
    LSDGatherOperation *operation = [[LSDGatherOperation alloc] initWithMessageID:-1 forcePost:immediately];
    [lotuseedInternalSingleton->gatherLooperQueue addOperation:operation];
    [operation release];
}

#ifdef LOTUSEED_FEED
+ (void)postFeedBackInfo:(BOOL)immedialtely withMessage:(NSString *)message withFileName:(NSString *)fileName withFileData:(NSData *)fileData withPostTime:(NSString *)postTime withPosterAge:(NSString *)posterAge withPosterGender:(NSString *)posterGender withPosterContact:(NSString *)posterContact withTarget:(id)target withSelect:(SEL)select
{
    LSDFeedBackOperation *operation = [[LSDFeedBackOperation alloc] initWithMessageID:1 withMessage:message withFileName:fileName withFileData:fileData withPostTime:postTime withPosterAge:posterAge withPosterGender:posterGender withPosterContact:posterContact];
    [operation setSelector:select toTarget:target];
    [lotuseedInternalSingleton->onlineLooperQueue addOperation:operation];
    [operation release];
}

+ (void)postFeedBackImmedialtely:(BOOL)immedialtely withLastTime:(NSString *)lastTime withID:(NSInteger)ID withTarget:(id)target withSelect:(SEL)select
{
    LSDFeedBackHistoryOperation *operation = [[LSDFeedBackHistoryOperation alloc] initWithMessageID:1 withLastTime:lastTime withID:ID];
    [operation setSelector:select toTarget:target];
    [lotuseedInternalSingleton->onlineLooperQueue addOperation:operation];
    [operation release];
}
#endif

+ (NSString*)genKVParams:(NSDictionary *)dic
{
	NSArray *keys;
	int i, count;
    id key, value;
    NSMutableString *label = [NSMutableString stringWithCapacity:50];
    
    keys = [dic allKeys];
    count = (int)[keys count];
    for (i = 0; i < count; i++) {
    	key = [keys objectAtIndex: i];
    	value = [dic objectForKey: key];
    	[label appendFormat:@"%@%@%@%@",key, EVENT_TYPE_CUSTOM_KV_SEPARATOR, value, EVENT_TYPE_CUSTOM_KV_SEPARATOR];
    }
    
    return label;
}

#ifdef LOTUSEED_LOCATION
- (void)initLocation
{
    if (locationON) {
        locManager = [[CLLocationManager alloc]init];
        location = nil;
        lastUpdateTimestamp = 0L;
        
        //设置代理
        locManager.delegate = self;
        //设置位置经度
        locManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; //精确度100m以内
        //设置距离筛选器
        locManager.distanceFilter = 100.0f;
    }
}

+ (void)startUpdatingLocation
{
    //开始定位服务
    if (lotuseedInternalSingleton
        && lotuseedInternalSingleton->locationON
        && lotuseedInternalSingleton->locManager)
    {
        int64_t currentTimestamp = [LSDProfile currentTimeMillis];
        if (currentTimestamp - lotuseedInternalSingleton->lastUpdateTimestamp > 5000) //5秒
        {
            float version = [[[UIDevice currentDevice] systemVersion] floatValue];
            if (version >= 4.0f) { //>=iOS4.0
                if (version >= 8.0f) { //>=iOS8.0 {
                    if([lotuseedInternalSingleton->locManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                        [lotuseedInternalSingleton->locManager requestWhenInUseAuthorization]; //使用中授权
                    }
                    if([lotuseedInternalSingleton->locManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                        [lotuseedInternalSingleton->locManager requestAlwaysAuthorization]; // 永久授权
                    }
                }
                if ([CLLocationManager locationServicesEnabled]) {
                    [lotuseedInternalSingleton->locManager startUpdatingLocation];
                }
            }
            else { //<iOS4.0
                [lotuseedInternalSingleton->locManager startUpdatingLocation];
            }
        }
    }
}
+ (void)stopUpdatingLocation
{
    if (lotuseedInternalSingleton && lotuseedInternalSingleton->locManager) {
        //停止定位服务
        [lotuseedInternalSingleton->locManager stopUpdatingLocation];
    }
}
+ (CLLocation*)getLocation
{
    return lotuseedInternalSingleton ? lotuseedInternalSingleton->location : nil;
}
#endif

@end


@implementation Lotuseed

+ (void)applicationDidBecomeActive:(UIApplication*)application
{    
#ifdef LOTUSEED_LOCATION
    [LotuseedInternal startUpdatingLocation];
#endif
    //发送缓存数据
    [LotuseedInternal postGatherEvent:NO];
}

+ (void)applicationWillResignActive:(UIApplication*)application
{
    //mark last active timestamp
    [LSDProvider markCurrentSessionID:[LSDSession sessionID] withTimestamp:[NSDate dateWithTimeIntervalSinceNow:0]];
}

+ (void)applicationWillTerminate:(UIApplication*)application
{
    //mark last active timestamp
    [LSDProvider markCurrentSessionID:[LSDSession sessionID] withTimestamp:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    if (lotuseedInternalSingleton) {
        [lotuseedInternalSingleton->gatherLooperQueue cancelAllOperations];
        [lotuseedInternalSingleton->onlineLooperQueue cancelAllOperations];
        
//        [lotuseedInternalSingleton->gatherLooperQueue waitUntilAllOperationsAreFinished];
//        [lotuseedInternalSingleton->onlineLooperQueue waitUntilAllOperationsAreFinished];
        
        [NSThread sleepForTimeInterval:0.2]; //等待线程被cancel
        
        [lotuseedInternalSingleton release];
        lotuseedInternalSingleton = nil;
    }
}

+ (void)applicationWillEnterForeground:(UIApplication*)application
{
    //check update
    if (!isAppUpdating) {
        NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
        NSDate *lastActiveDate = nil;
        [LSDProvider readLastSessionID:nil andTimestamp:&lastActiveDate];
        
        if (lastActiveDate && fabs([currentDate timeIntervalSinceDate:lastActiveDate]) > APPLICATION_UPDATE_INTERVAL
            && (lotuseedUpdateAlertDialogTitle || lotuseedUpdateYesButtonCaption || lotuseedUpdateNoButtonCaption)) {
            [Lotuseed checkUpdate:lotuseedUpdateAlertDialogTitle updateButtonCaption:lotuseedUpdateYesButtonCaption cancelButtonCaption:lotuseedUpdateNoButtonCaption];
        }
    }
}

#pragma mark - BackgroundTask
+ (void)applicationDidEnterBackground:(UIApplication *)application {
    
    __block UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        //在限定时间内没有结束，在时间结束之前调用(ios6一般为10分钟,ios7一般为3分钟)
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    //DO TASK
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //提交缓存数据
        [Lotuseed forcePost];
        
        UIApplication *app = [UIApplication sharedApplication];
        
        float timeinterval;
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        //ios6.0后台任务执行时间一般为10分钟 ios7.0后台执行任务一般为3分钟
        if (version >= 7.0) {
            timeinterval = 180.0 - app.backgroundTimeRemaining;
        } else {
            timeinterval = 600.0 - app.backgroundTimeRemaining;
        }
        //判断后台执行任务超过10s直接组织提交当前的SESSION的onDestoy报文
        if (timeinterval > [LSDProfile getSessionContinueSeconds]) {
            [LotuseedInternal postEvent:EVENT_TYPE_LIFECYCLE eventID:EVENT_ID_ONENDSESSION eventLabel:nil eventCount:1 isDuration:false forcePost:YES];
            //删除上一个SessionID。
            [LSDProvider removeLastSessionID];
        }
        
        //END BACKGROUNDTASK
        [app endBackgroundTask:bgTask];
        
    });
    
}

#ifdef LOTUSEED_FEED
#pragma mark - Feedback
//在程序开始运行时 请求数据 判断是否有新的回复信息
+ (void)applicationDidFinishLaunching {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    //得到完整的文件名
    NSString *filename = [plistPath1 stringByAppendingPathComponent:@"historyFeed.plist"];
    NSArray *historyData = [NSArray arrayWithContentsOfFile:filename];
    if (historyData != nil && historyData.count != 0) {
        
        NSMutableArray *dataArr = [NSMutableArray arrayWithArray:[LSDFeedBackVO LSDFeedBackVOListWithArray:historyData reply:YES]];
        
        if (dataArr.count > 1) {
            for (int i = 0; i < dataArr.count - 1; i++) {
                for (int j = 0; j < dataArr.count - i - 1; j++) {
                    LSDFeedBackVO *vo1 = dataArr[j];
                    LSDFeedBackVO *vo2 = dataArr[j + 1];
                    if (vo1.revertTime > vo2.revertTime) {
                        [dataArr exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
                    }
                }
            }
        }
        LSDFeedBackVO *vo = [dataArr lastObject];
        NSString *time = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
        [LotuseedInternal postFeedBackImmedialtely:NO withLastTime:time withID:vo.ID withTarget:self withSelect:@selector(updateNews:)];
        
    } else {
        NSString *time = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
        [LotuseedInternal postFeedBackImmedialtely:NO withLastTime:time withID:0 withTarget:self withSelect:@selector(updateNews:)];
    }
    
}

//请求成功回调
+ (void)updateNews:(NSDictionary *)info {
    NSArray *dataArr = [info objectForKey:@"msg"];
    if (dataArr && dataArr.count != 0) {
        [LSDMonitoring shareInstance].ifHaveNewReply = YES;
    } else {
        [LSDMonitoring shareInstance].ifHaveNewReply = NO;
    }
}
#endif

#ifdef LOTUSEED_AUTO
+ (void)applicationDidGetTouch:(id)something{
        [LSDMonitoring viewControllerChanged];//点击跳转按钮触发
}

#endif

+ (void)initialize
{
    if (!lotuseedInternalSingleton) {
        //初始化内部类
        lotuseedInternalSingleton = [[LotuseedInternal alloc] init];

        //前后台消息管理
        UIApplication *app = [UIApplication sharedApplication];
        BOOL backgroundSupported = [LSDProfile isMultitaskingSupported];
        
        if (backgroundSupported) {
            [[NSNotificationCenter defaultCenter ] addObserver:self
                                                      selector:@selector(applicationWillEnterForeground:)
                                                          name:UIApplicationWillEnterForegroundNotification
                                                        object:app];
        }
        [[NSNotificationCenter defaultCenter ] addObserver:self
                                                  selector:@selector(applicationDidBecomeActive:)
                                                      name:UIApplicationDidBecomeActiveNotification
                                                    object:app];
        
        [[NSNotificationCenter defaultCenter ] addObserver:self
                                                  selector:@selector(applicationWillResignActive:)
                                                      name:UIApplicationWillResignActiveNotification
                                                    object:app];
        
        [[NSNotificationCenter defaultCenter ] addObserver:self
                                                  selector:@selector(applicationWillTerminate:)
                                                      name:UIApplicationWillTerminateNotification
                                                    object:app];
        
        [[NSNotificationCenter defaultCenter ] addObserver:self
                                                  selector:@selector(applicationDidEnterBackground:)
                                                      name:UIApplicationDidEnterBackgroundNotification
                                                    object:app];
#pragma mark - FeedBack
#ifdef LOTUSEED_FEED
        //注册通知 在程序开始运行时 请求数据 判断是否有新的回复信息
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
#endif
#ifdef LOTUSEED_AUTO
        [[NSNotificationCenter defaultCenter ] addObserver:self
                                                  selector:@selector(applicationDidGetTouch:)
                                                      name:UITouchPhaseBegan
                                                    object:nil];
//        [[NSNotificationCenter defaultCenter ] addObserver:self
//                                                  selector:@selector(obtainMonitorValue:)
//                                                      name:@"Invoke"
//                                                    object:nil];
#endif
    }
}

#pragma mark basics

/**
 * 开启Lotuseed统计功能
 */
+ (void)initWithCustomData256:(NSString *)data {
    @try {
        if (lotuseedInternalSingleton) {
            [LSDProfile setCustomData256:data];
        }
    }
    @catch (NSException *exception) {
        LSDLOG(@"Exception: %@", exception);
    }
}

+ (void)startWithAppKey:(NSString *)appKey {
    [self startWithAppKey: appKey
                channelID: nil];
}

+ (void)startWithAppKey:(NSString *)appKey channelID:(NSString *)cid {
    [self startWithAppKey: appKey
                channelID: cid
                  appleID: nil];
}

+ (void)startWithAppKey:(NSString *)appKey channelID:(NSString *)cid appleID:(NSString*)aid
{
    [self startWithAppKey: appKey
                channelID: cid
                  appleID: aid
                 location: SDK_CAN_GET_LOC];
}

+ (void)startWithAppKey:(NSString *)appKey channelID:(NSString *)cid appleID:(NSString*)aid location:(BOOL)onoff
{
	if (appKey == nil || [appKey length] < 5) {
		LSDLOG(@"Error: param appKey(%@) is invalide.", appKey);
		assert(0); //added at 20131113 by eagle
		return;
	}
	
    @synchronized(self) {
    	@try {
        	if (lotuseedInternalSingleton) {
        	    [LSDProfile setAppKey:appKey];
        	    [LSDProfile setChannel:cid];
        	    [LSDProfile setAppleID:aid];
                
                /*
        	    // UIWebView only UI thread can access
        	    [LSDProvider initDefaultWebViewUserAgent];
        	    */
                /* removed by eagle on 20130926 */
                
        	    // post start session
        	    [LotuseedInternal postGatherEvent:NO];
        	    
#ifdef LOTUSEED_TRACK
        	    // app tracking
        	    [LSDTrack startTracking:appKey];
#endif
        	}
            
            //设备GPS获取开关
            [LSDProvider setGetLocationPermission:onoff];
#ifdef LOTUSEED_LOCATION
            lotuseedInternalSingleton->locationON = [LSDProvider getGetLocationPermission];
            
            if (lotuseedInternalSingleton->locationON) {
                [lotuseedInternalSingleton initLocation];
            }
#endif

        }
        @catch (NSException *exception) {
        	LSDLOG(@"Exception: %@", exception);
    	}
    }
}

/**
 * 是否设置Lotuseed SDK为DEBUG模式
 * 默认为NO
 */
+ (void)setDebugMode:(BOOL)mode {
    if (lotuseedInternalSingleton) {
        lotuseedInternalSingleton->debugMode = mode;
    }
}

+ (BOOL)debugMode {
    return lotuseedInternalSingleton ? lotuseedInternalSingleton->debugMode : NO;
}

/**
 * 是否通过Lotuseed捕捉和提交错误日志
 * 默认为YES
 */
#define MAX_BACK_TRACE_STACK_SIZE 32
static int lotuseed_signal_error = 0;
static void stacktrace(int sig, siginfo_t *info, void *context)
{
    void* callstack[MAX_BACK_TRACE_STACK_SIZE];
    int i, frames = backtrace(callstack, MAX_BACK_TRACE_STACK_SIZE);
    char** strs = backtrace_symbols(callstack, frames);
    
    NSMutableString *mstr = [[NSMutableString alloc] initWithCapacity:256];
    [mstr appendString:@"Stack:\n"];
    
    for (i = 0; i< MAX_BACK_TRACE_STACK_SIZE && i < frames; ++i) {
        [mstr appendFormat:@"%s\n", strs[i]];
    }
    
    if (lotuseed_signal_error == 0) {
        //实测发现当发生signal错误时，stacktrace函数好像会被不停的回调！
        [LotuseedInternal postEvent:EVENT_TYPE_LOG eventID:EVENT_ID_ONCRASHLOG eventLabel:mstr eventCount:1 isDuration:false forcePost:NO];
        lotuseed_signal_error = 1;
    }
    [mstr release];
}

static void MyUncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSMutableString *mstr = [[NSMutableString alloc] initWithCapacity:256];
    [mstr appendString:@"name:\n"];
    [mstr appendString:name];
    [mstr appendString:@"\n"];
    [mstr appendString:@"reason:\n"];
    [mstr appendString:reason];
    [mstr appendString:@"\n"];
    [mstr appendString:@"stack:\n"];
    [mstr appendString:[arr componentsJoinedByString:@"\n"]];  //TODO:需行数限制?
    
    [LotuseedInternal postEvent:EVENT_TYPE_LOG eventID:EVENT_ID_ONCRASHLOG eventLabel:mstr eventCount:1 isDuration:false forcePost:NO];
    [mstr release];
}

+ (void)setCrashReportEnabled:(BOOL)value {
    if (value) {
        oldUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
        
        struct sigaction mySigAction;
        mySigAction.sa_sigaction = stacktrace;
        mySigAction.sa_flags = SA_SIGINFO;
        
        sigemptyset(&mySigAction.sa_mask);
        sigaction(SIGQUIT, &mySigAction, NULL);
        sigaction(SIGILL , &mySigAction, NULL);
        sigaction(SIGTRAP, &mySigAction, NULL);
        sigaction(SIGABRT, &mySigAction, NULL);
        sigaction(SIGEMT , &mySigAction, NULL);
        sigaction(SIGFPE , &mySigAction, NULL);
        sigaction(SIGBUS , &mySigAction, NULL);
        sigaction(SIGSEGV, &mySigAction, NULL);
        sigaction(SIGSYS , &mySigAction, NULL);
        sigaction(SIGPIPE, &mySigAction, NULL);
        sigaction(SIGALRM, &mySigAction, NULL);
        sigaction(SIGXCPU, &mySigAction, NULL);
        sigaction(SIGXFSZ, &mySigAction, NULL);
        
        NSSetUncaughtExceptionHandler(&MyUncaughtExceptionHandler);
    }
    else {
        if (oldUncaughtExceptionHandler) {
            NSSetUncaughtExceptionHandler(oldUncaughtExceptionHandler);
            oldUncaughtExceptionHandler = nil;
        }
    }
}

/**
 * 设置Session非活动时长，单位：秒
 */
+ (void)setSessionContinueSeconds:(int)seconds {
    [LSDProfile setSessionContinueSeconds:seconds];
}

/**
 * 跟踪记录PageView访问时长
 */
#ifdef LOTUSEED_ONPV
+ (void)onPageViewBegin:(NSString *)pageName {
    lastOnResumeTime = [LSDProfile currentTimeMillis];
}

+ (void)onPageViewEnd:(NSString *)pageName {
    int64_t eventTime = [LSDProfile currentTimeMillis];
    
    if (lastPVName != nil && lastPVName.length > 0) {
        // P
        [LotuseedInternal postEvent:EVENT_TYPE_LIFECYCLE eventID:EVENT_ID_ONPAUSE eventLabel:lastPVName eventCount:1 isDuration:false forcePost:NO eventTime:eventTime];
    }
    else {
        //default R&P
        [LotuseedInternal postEvent:EVENT_TYPE_LIFECYCLE eventID:EVENT_ID_ONRESUME eventLabel:pageName eventCount:1 isDuration:false forcePost:NO eventTime:lastOnResumeTime];
        [LotuseedInternal postEvent:EVENT_TYPE_LIFECYCLE eventID:EVENT_ID_ONPAUSE eventLabel:pageName eventCount:1 isDuration:false forcePost:NO eventTime:eventTime];
    }
    lastPVName = @"";
    lastOnResumeTime = eventTime;
}

+ (void)onPV:(NSString *)pageName {
    int64_t eventTime = [LSDProfile currentTimeMillis];
    
    if (lastPVName != nil && lastPVName.length > 0) {
        //last P
        [LotuseedInternal postEvent:EVENT_TYPE_LIFECYCLE eventID:EVENT_ID_ONPAUSE eventLabel:lastPVName eventCount:1 isDuration:false forcePost:NO eventTime:eventTime];
    }
    
    //R
    [LotuseedInternal postEvent:EVENT_TYPE_LIFECYCLE eventID:EVENT_ID_ONRESUME eventLabel:pageName eventCount:1 isDuration:false forcePost:NO eventTime:eventTime];
    
    lastPVName = (pageName == nil) ? @"" : [pageName retain];
}
#else //!
+ (void)onPageViewBegin:(NSString *)pageName {
    [LotuseedInternal postEvent:EVENT_TYPE_LIFECYCLE eventID:EVENT_ID_ONRESUME eventLabel:pageName eventCount:1 isDuration:false forcePost:NO];
}

+ (void)onPageViewEnd:(NSString *)pageName {
    [LotuseedInternal postEvent:EVENT_TYPE_LIFECYCLE eventID:EVENT_ID_ONPAUSE eventLabel:pageName eventCount:1 isDuration:false forcePost:NO];
}
#endif

/**
 * 设置自定义事件动态扩展数据标记位
 * @param flag
 */
+ (void)setEventExtinfoFlag:(int)flag
{
    [LSDProvider setEventExtinfoFlag:flag];
}

/**
 * 获取自定义事件动态扩展数据标记位
 * @return
 */
+ (int)getEventExtinfoFlag
{
    return [LSDProvider getEventExtinfoFlag];
}

#pragma mark custom event

/**
 * 统计事件累计次数
 */
+ (void)onEvent:(NSString *)eventID {
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:@"" eventCount:1 isDuration:false forcePost:NO];
}

+ (void)onEvent:(NSString *)eventID withCount:(long)count {
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:@"" eventCount:count isDuration:false forcePost:NO];
}

+ (void)onEvent:(NSString *)eventID label:(NSString *)label {
    NSLog(@"label:%@",label);
    NSLog(@"eventID:%@",eventID);
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:label eventCount:1 isDuration:false forcePost:NO];
}

+ (void)onEvent:(NSString *)eventID label:(NSString *)label withCount:(long)count {
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:label eventCount:count isDuration:false forcePost:NO];
}

+ (void)onEvent:(NSString *)eventID attributes:(NSDictionary *)dic {
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:[LotuseedInternal genKVParams: dic] eventCount:1 isDuration:false forcePost:NO];
}

+ (void)onEvent:(NSString *)eventID attributes:(NSDictionary *)dic withCount:(long)count {
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:[LotuseedInternal genKVParams: dic] eventCount:count isDuration:false forcePost:NO];
}

+ (void)onEvent:(NSString *)eventID postData:(BOOL)immediately {
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:@"" eventCount:1 isDuration:false forcePost:immediately];
}

+ (void)onEvent:(NSString *)eventID withCount:(long)count postData:(BOOL)immediately {
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:@"" eventCount:count isDuration:false forcePost:immediately];
}

+ (void)onEvent:(NSString *)eventID label:(NSString *)label postData:(BOOL)immediately {
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:label eventCount:1 isDuration:false forcePost:immediately];
}

+ (void)onEvent:(NSString *)eventID label:(NSString *)label withCount:(long)count postData:(BOOL)immediately {
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:label eventCount:count isDuration:false forcePost:immediately];
}

+ (void)onEvent:(NSString *)eventID attributes:(NSDictionary *)dic postData:(BOOL)immediately {
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:[LotuseedInternal genKVParams: dic] eventCount:1 isDuration:false forcePost:immediately];
}

+ (void)onEvent:(NSString *)eventID attributes:(NSDictionary *)dic withCount:(long)count postData:(BOOL)immediately {
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:[LotuseedInternal genKVParams: dic] eventCount:count isDuration:false forcePost:immediately];
}


/**
 * 统计事件累计时长
 */
+ (void)onEvent:(NSString *)eventID withDuration:(long)duration {
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:@"" eventCount:duration isDuration:true forcePost:NO];
}

+ (void)onEvent:(NSString *)eventID label:(NSString *)label withDuration:(long)duration {
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:label eventCount:duration isDuration:true forcePost:NO];
}

+ (void)onEvent:(NSString *)eventID attributes:(NSDictionary *)dic withDuration:(long)duration {
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:[LotuseedInternal genKVParams: dic] eventCount:duration isDuration:true forcePost:NO];
}

+ (void)onEvent:(NSString *)eventID withDuration:(long)duration postData:(BOOL)immediately {
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:@"" eventCount:duration isDuration:true forcePost:immediately];
}

+ (void)onEvent:(NSString *)eventID label:(NSString *)label withDuration:(long)duration postData:(BOOL)immediately {
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:label eventCount:duration isDuration:true forcePost:immediately];
}

+ (void)onEvent:(NSString *)eventID attributes:(NSDictionary *)dic withDuration:(long)duration postData:(BOOL)immediately {
    [LotuseedInternal postEvent:EVENT_TYPE_CUSTOM eventID:eventID eventLabel:[LotuseedInternal genKVParams: dic] eventCount:duration isDuration:true forcePost:immediately];
}

/**
 * 设置用户自定义事件分组
 */
+ (void)setEventGroup:(NSString *)property value:(NSString *)value{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic setObject:value forKey:property];
    
    [Lotuseed setEventGroup:dic];
}

+ (void)setEventGroup:(NSDictionary *)dic{
    [Lotuseed onEvent:EVENT_GROUP_KEY attributes:dic postData:YES];
}

#pragma mark special event

/**
 * 记录特殊事件
 */

+ (void)onRegistration:(NSString*)accountId {
    [Lotuseed onEvent:@"Registration" label:accountId postData:YES];
}

+ (void)onRegistration:(NSString*)accountId gender:(LSGAGender)gender age:(int)age {
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
    [dic setValue:accountId forKey:@"ID"];
    if (gender != kGenderUnknown) {
        [dic setValue:((gender == kGenderMale) ? @"M" : @"F") forKey:@"g"];
    }
    if (age >= 0) {
        NSString *v = [NSString stringWithFormat:@"%d", age];
        [dic setValue:v forKey:@"a"];
    }
    [Lotuseed onEvent:@"Registration" attributes:dic postData:YES];
}

+ (void)onLogin:(NSString*)accountId {
    [Lotuseed onEvent:@"Login" label:accountId postData:YES];
}

+ (void)onLogin:(NSString*)accountId type:(NSString*)accountType
{
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
    [dic setValue:accountId forKey:@"ID"];
    [dic setValue:accountType forKey:@"t"];
    [Lotuseed onEvent:@"Login" attributes:dic postData:YES];
}

+ (void)onLogout:(NSString*)accountId {
    [Lotuseed onEvent:@"Logout" label:accountId postData:YES];
}

+ (void)onOrder:(NSString*)accountId orderId:(NSString*)orderId amount:(double)number {
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
    [dic setValue:orderId forKey:@"ID"];
    [dic setValue:[NSString stringWithFormat:@"%f", number] forKey:@"a"];
    [dic setValue:accountId forKey:@"u"];
    [Lotuseed onEvent:@"Order" attributes:dic postData:YES];
}

#pragma mark log report

/**
 * 记录自定义日志
 */
+ (void)onCustomLog:(NSString *)logmsg {
    [LotuseedInternal postEvent:EVENT_TYPE_LOG eventID:EVENT_ID_ONCUSTOMLOG eventLabel:logmsg eventCount:1 isDuration:false forcePost:NO];
}


#pragma mark check update

+ (BOOL)isUpdating
{
    return isAppUpdating;
}

+ (void)checkUpdate
{
    @try {
    	if (![LSDProfile isNetworkAvailable]) {
    	    return;
    	}
    	
    	NSString* strLanguage = [LSDProfile getSystemLanguage];
    	if ([strLanguage isEqualToString:@"zh-Hans"]) {
    	    [self checkUpdate:@"检测到新版本" updateButtonCaption:@"立即更新" cancelButtonCaption:@"暂不升级"];
    	}
    	else if ([strLanguage isEqualToString:@"zh-Hant"]) {
    	    [self checkUpdate:@"檢測到新版本" updateButtonCaption:@"立即更新" cancelButtonCaption:@"暫不升級"];
    	}
    	else {
    	    [self checkUpdate:@"Application has new version" updateButtonCaption:@"Update" cancelButtonCaption:@"Cancel"];
    	}    
    }
    @catch (NSException *exception) {
        LSDLOG(@"Exception: %@", exception);
    }
}

+ (void)checkUpdate:(NSString*)title updateButtonCaption:(NSString*)update cancelButtonCaption:(NSString*)cancel
{
    @try {
    	if (!lotuseedUpdateAlertDialogTitle) {
    	    lotuseedUpdateAlertDialogTitle = [title retain];
    	}
    	if (!lotuseedUpdateYesButtonCaption) {
    	    lotuseedUpdateYesButtonCaption = [update retain];
    	}
    	if (!lotuseedUpdateNoButtonCaption) {
    	    lotuseedUpdateNoButtonCaption = [cancel retain];
    	}
    	
    	if (![LSDProfile isNetworkAvailable]) {
    	    return;
    	}
    	
    	//发送缓存数据
    	[LotuseedInternal postGatherEvent:NO];
    	
    	//尝试应用更新
    	LSDUpdateOperation *operation = [[LSDUpdateOperation alloc] initWithMessageID:MESSAGE_ID_APP_UPDATE];
    	[lotuseedInternalSingleton->onlineLooperQueue addOperation:operation];
    	[operation release];
    }
    @catch (NSException *exception) {
        LSDLOG(@"Exception: %@", exception);
    }
}

+ (void)checkUpdateWithDelegate:(id)delegate didFinishSelector:(SEL)selector
{
    @try {
    	if (!delegate || !selector) {
    	    LSDLOG(@"%@ Error: delegate or selector is nil.", SDK_LOG_TAG);
    	    return;
    	}
    	
    	//尝试应用更新
    	LSDUpdateOperation *operation = [[LSDUpdateOperation alloc] initWithMessageID:MESSAGE_ID_APP_UPDATE];
    	[operation setSelector:selector toTarget:delegate];
    	[lotuseedInternalSingleton->onlineLooperQueue addOperation:operation];
    	[operation release];
    }
    @catch (NSException *exception) {
        LSDLOG(@"Exception: %@", exception);
    }
}

#pragma mark online config

+ (void)updateOnlineConfig
{
    @try {
    	NSDate* currentTime = [NSDate dateWithTimeIntervalSinceNow:0];
    	NSDate* lastTryUpdateTime = [LSDProvider getOnlineConfigLastUpdateTime];
    	if (!lastTryUpdateTime || 
    	    (lastTryUpdateTime && fabs([currentTime timeIntervalSinceDate:lastTryUpdateTime]) > ONLINE_CONFIG_UPDATE_INTERVAL)) {
    	    
    	    [LSDProvider setOnlineConfigCurrUpdateTime:currentTime];
    	    
    	    //尝试参数更新
    	    LSDOnlineConfigOperation *operation = [[LSDOnlineConfigOperation alloc] init];
    	    [lotuseedInternalSingleton->onlineLooperQueue addOperation:operation];
    	    [operation release];
    	}
    }
    @catch (NSException *exception) {
        LSDLOG(@"Exception: %@", exception);
    }
}

+ (NSString *)getConfigParams:(NSString*)key withDefaultValue:(NSString *)value
{
    NSString* v = [LSDProvider getOnlineConfigParam:key];
    return v ? v : value;
}

#pragma mark utils

/**
 * 强制提交缓存数据
 */
+ (void)forcePost {
    [LotuseedInternal postGatherEvent:YES];
}

/**
 * 获取设备唯一识别串
 */
+ (NSString*)getDeviceID {
    return [LSDProfile deviceID];
}

#pragma mark exports

/**
 * 获取SD版本号
 * @return
 */
+ (NSString*) getSDKVersion
{
    return SDK_VERSION;
}

/**
 * 获取设备标识串
 * @return
 */
+ (NSString*) exportDeviceID
{
    return [LSDProfile deviceID];
}

/**
 * 获取APPKEY
 * @return
 */
+ (NSString*) exportAppKey
{
    return [LSDProfile appKey];
}

/**
 * 获取渠道编号
 * @return
 */
+ (NSString*) exportChannel
{
    return [LSDProfile getChannel];
}

/**
 * 获取APP版本号
 * @return
 */
+ (NSString*) getAppVersionCode
{
    return [LSDProfile getAppBuildVersion];
}

/**
 * 获取APP版本名称
 * @return
 */
+ (NSString*) exportAppVersionName
{
    return [LSDProfile getAppBundleName];
}

/**
 * 获取APP Bundle名称
 * @return
 */
+ (NSString*) exportAppBundleName
{
    return [LSDProfile getAppBundleName];
}

/**
 * 获取IDFA
 */
+ (NSString*) exportIDFA
{
    return [LSDProfile getIDFA];
}

/**
 * 获取IDFV
 */
+ (NSString*) exportIDFV
{
    return [LSDProfile getIDFV];
}

/**
 * 获取运营商
 * @return
 */
+ (NSString*) exportCarrier
{
    return [LSDProfile getCarrier];
}

/**
 * 获取当前网络类型
 *
 * @param context
 * @return
 */
+ (NSString*) exportNetworkType
{
    return [LSDProfile getNetworkType];
}

/**
 * 获取屏幕分辨率 hxw
 * @return
 */
+ (NSString*) exportDisplayMetrics
{
    CGSize size = [LSDProfile getScreenSize];
    return [NSString stringWithFormat:@"%fx%f", size.height, size.width];
}

/**
 * 判断是否越狱
 * @return
 */
+ (BOOL) isJailbroken
{
    return [LSDProfile isJailbroken];
}

/**
 * 获取设备品牌
 * @return
 */
+ (NSString*) exportDeviceBrand
{
    LSDUIDevice *lsddev = [LSDUIDevice currentDevice];
    return [lsddev platform];
}

/**
 * 获取设备机型
 * @return
 */
+ (NSString*) exportDeviceModel
{
    LSDUIDevice *lsddev = [LSDUIDevice currentDevice];
    return [lsddev hwmodel];
}

/**
 * 获取系统总内存，单位Kb
 * 示例：MemTotal:          94096 kB
 *
 * @return
 */
+ (long) getMemorySize
{
    LSDUIDevice *lsddev = [LSDUIDevice currentDevice];
    return [lsddev totalMemory]/1024;
}

/**
 * 获取固件版本
 * @return
 */
+ (NSString*) exportFirmwareVersion
{
    UIDevice *dev = [UIDevice currentDevice];
    return [dev systemVersion];  //固件版本
}

#ifdef LOTUSEED_FEED

/**
 * 意见反馈 present
 * @return
 */

+ (void)showHistoryFeedBackControllerWithController:(UIViewController *)controller
{
    [LSDHistoryFeedBackViewController presentFeedBackControllerWithController:controller];
}

/**
 * 意见反馈 push
 * @return
 */
+ (UIViewController *)showHistoryFeedBackController
{
    LSDHistoryFeedBackViewController *feedBack = [[[LSDHistoryFeedBackViewController alloc] init] autorelease];
    feedBack.ifPresent = NO;
    return feedBack;
}

/**
 * 意见反馈 获取是否有新的回复信息
 * @return
 */
+ (BOOL)ifHaveNewReply
{
    return [LSDMonitoring shareInstance].ifHaveNewReply;
}

#endif

@end
