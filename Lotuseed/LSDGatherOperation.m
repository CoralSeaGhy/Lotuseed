//
//  LSDGatherOperation.m
//  Lotuseed
//
//  Created by beyond on 12-6-5.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import "LSDGatherOperation.h"
#import "LotuseedInternal.h"
#import "LSDPoster.h"
#import "LSDConstants.h"
#import "LSDProfile.h"
#import "LSDJsonParser.h"
#import "LSDProvider.h"
#import "LSDSession.h"
#import "Lotuseed.h"
#import "LSDEMP2.h"
#import "LSDUIDevice.h"
#import "LSDUtils.h"

static BOOL mFirstTryPost = NO;

@implementation LSDGatherOperation

- (id) initWithMessageID:(int)ID forcePost:(BOOL)immediately
{
    if (self = [super initWithMessageID:ID]) {
        forcePostImmediately = immediately;
        outputStream = NULL;
    }
    return self;
}

- (void)dealloc
{
    if (outputStream) {
        [outputStream release];
    }
    
    [super dealloc];
}

- (void)setPostData:(NSData*)data
{
    postDataWriteStat = [LSDPoster savePostData:data
                                    fileName:POST_DATA_CACHE_FILE_SESSION
                                   overWrite:NO];
    if (postDataWriteStat == -1) {
        if (outputStream == NULL) {
            outputStream = [[NSMutableData alloc] initWithCapacity:100];
        }
        @try {
            [outputStream appendData:data];
        }
        @catch (NSException *exception) {
        }
    }
    
#ifdef LOTUSEED_LOCATION
    //获取gps位置信息
    CLLocation* location = [LotuseedInternal getLocation];
    if (location) {
        if (outputStream == NULL) {
            outputStream = [[NSMutableData alloc] initWithCapacity:100];
        }
        @try {
            if ([outputStream length] < 100*1000) { //<100k
                [self genMsg0004GpsData:outputStream withLocation:location];
            }
        }
        @catch (NSException *exception) {
        }
    }
#endif
}

- (void)doResult:(NSString*)respMsg postDataSize:(int)postCacheDataSize deviceFlag:(BOOL)deviceInfoPosted
{
    if (!respMsg) return;
    
    int mid = -1;
    int ret = -1;
    
    LSDJsonParser *parser = [[LSDJsonParser alloc] init];
    NSError *error = nil;
    NSMutableDictionary *jsonDic = [parser objectWithString:respMsg error:&error];
    if (jsonDic == nil) {
        goto FAILURE;
    }
    
    NSString *value = nil;
    value = [jsonDic objectForKey:@"mid"] ;
    if (value != nil) {
        //mid = [value intValue];
    }
    value = [jsonDic objectForKey:@"ret"] ;
    if (value != nil) {
        ret = [value intValue];
    }
    
    [parser release];
    parser = nil;
    
    if (ret != MESSAGE_RET_OK) {
        goto FAILURE;
    }
    
    // Post成功则删除本地缓存文件
    [LSDPoster deleteAllCacheFile:postCacheDataSize];
    
    // 设置设备信息已采集标志
    if (deviceInfoPosted) {
        [LSDProvider setDeviceInfoPosted:YES];
    }
    
    return;
FAILURE:
    if (parser) {
        [parser release];
    }
    LSDLOG(@"%@ Return error: smid=%d, rmid=%d, ret=%d", SDK_LOG_TAG, messageID, mid, ret);
}

- (void)main
{
    if (self.isCancelled)
        return;
    
    LSDLOG(@"%@ Event: id=%d", SDK_LOG_TAG, messageID);
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        if (isNewSession) {
            LSDLOG(@"Lotuseed SDK init: v%@", SDK_VERSION);
            LSDLOG(@"APPKEY: %@", [LSDProfile appKey]);
            LSDLOG(@"CHANNEL: %@", [LSDProfile getChannel]);
        }
        
        // Post所有本地缓存到服务器
        if ((isNewSession || !mFirstTryPost
             || [LSDProvider getRealTimeMode]
             || postDataWriteStat == 1 || forcePostImmediately
             || outputStream != NULL)
            && [LSDProfile isNetworkAvailable]) {
            /*
             * 发送策略： 调试模式 or 新启动 or 缓存满
             */
            mFirstTryPost = YES;
            
            //创建数据缓冲区
            NSMutableData *output = [[NSMutableData alloc] initWithCapacity:100];
            
            //获取设备信息
            BOOL deviceInfoPosted = [LSDProvider getDeviceInfoPosted];
            BOOL appsNeedPosted = isNewSession || (!deviceInfoPosted);
            if (!deviceInfoPosted) {
                deviceInfoPosted = [self genMsg0003Data:output];
            }
            
            /**
             * 20150618: 内存缓存 & 文件缓存 交换写入顺序!!!
             */
            
            //发送文件缓存信息
            int postCacheDataSize = [LSDPoster getAllPostData:output];
            
            //内存缓存
            if (outputStream != NULL) {
                @try {
                    [output appendData:outputStream];
                }
                @catch (NSException *exception) {
                }
            }
            
            //获取安装列表
            if (appsNeedPosted) {
                [self genMsg0004AppsData:output];
            }
            
            if ([output length] > 0) {
                NSString *respMsg = [LSDPoster postData:output messageID:messageID hostServer:GATHER_HOST_SERVER hostPort:GATHER_HOST_PORT urlPath:GATHER_HOST_URLPATH];
                [self doResult:respMsg postDataSize:postCacheDataSize deviceFlag:deviceInfoPosted];
            }
            
            //资源释放
            [output release];
        }
    }
    @catch (NSException *exception) {
        LSDLOG(@"%@ ##", SDK_LOG_TAG);
    }
    @finally {
        [pool release];
    }
}

- (BOOL)genMsg0003Data:(NSMutableData*)output
{
    // 组织设备信息报文
    // 0003
    
    LSDEMP2 *emp = [[[LSDEMP2 alloc] init] autorelease];
    
    [emp addInteger:@"/mid" value:MESSAGE_ID_GET_DEVINFO];
    [emp addString:@"/mid/sid" value:[LSDSession sessionID]];
    
    [emp addString:@"/mid/ac" value:[LSDProfile getChannel]]; //20160504
    [emp addString:@"/mid/av" value:[LSDProfile getAppBuildVersion]]; //20160504
    
    NSString* idfa = [LSDProfile getIDFA];
    if (idfa) {
        [emp addString:@"/mid/IDFA" value:idfa]; //added on 20130928
    }
    NSString* idfv = [LSDProfile getIDFV];
    if (idfv) {
        [emp addString:@"/mid/IDFV" value:idfv]; //added on 20130928
    }
    
    LSDUIDevice *lsddev = [LSDUIDevice currentDevice];
    [emp addString:@"/mid/dm" value:[lsddev platform]];
    [emp addString:@"/mid/hn" value:[lsddev hwmodel]]; //BOARD ID，如k93ap
    [emp addInteger:@"/mid/cfr" value:[lsddev cpuFrequency]];
    [emp addInteger:@"/mid/mr" value:[lsddev totalMemory]/1024];
    UIDevice *dev = [UIDevice currentDevice];
    [emp addString:@"/mid/fw/fv" value:[dev systemVersion]];  //固件版本
    //[emp addString:@"/mid/fw/bv" value:[dev ]];//基带版本
    [emp addBoolean:@"/mid/fw/mt" value:[LSDProfile isMultitaskingSupported]]; //是否支持多任务
    [emp addBoolean:@"/mid/fw/rf" value:[LSDProfile isJailbroken]];//是否已越狱
    
    CGSize size = [LSDProfile getScreenSize];
    [emp addInteger:@"/mid/ds/vr" value:size.height];
    [emp addInteger:@"/mid/ds/hr" value:size.width];
    
    // TODO: df
    
    @try {
        [output appendData:[emp getBuffer]];
        return YES;
    }
    @catch (NSException *exception) {
    }
    
    return NO;
}

- (BOOL)genMsg0004AppsData:(NSMutableData*)output
{
    NSArray* apps = [LSDProfile getAllApplications];
    if (apps) {
        LSDEMP2 *emp = [[[LSDEMP2 alloc] init] autorelease];
        
        [emp addInteger:@"/mid" value:MESSAGE_ID_GET_EXTINFO];
        [emp addString:@"/mid/sid" value:[LSDSession sessionID]];
        
        int i = 1;
        for (id obj in apps) {
            NSDictionary* dic = (NSDictionary*)obj;
            [emp addString:[NSString stringWithFormat:@"/mid/p|%d/pn", i] value:[dic objectForKey:@"p"]];
            [emp addString:[NSString stringWithFormat:@"/mid/p|%d/n", i] value:[dic objectForKey:@"n"]];
            [emp addString:[NSString stringWithFormat:@"/mid/p|%d/v", i] value:[dic objectForKey:@"v"]];
             
            i++;
        }
        
        @try {
            [output appendData:[emp getBuffer]];
            return YES;
        }
        @catch (NSException *exception) {
        }
    }
    
    return NO;
}

#ifdef LOTUSEED_LOCATION
//@see: http://blog.csdn.net/lingdf/article/details/8858546
//@see: https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocation_Class/#//apple_ref/occ/instp/CLLocation/course
- (BOOL)genMsg0004GpsData:(NSMutableData*)output withLocation:(CLLocation*)location
{
    static int64_t lastGetLocationTime = 0L;
    
    if (!output || !location) return NO;
    
    int64_t currTime = [LSDProfile currentTimeMillis];
    if (currTime - lastGetLocationTime > LOCATION_GET_INTERVAL) {
        lastGetLocationTime = currTime;
    
        CLLocationCoordinate2D loc = [location coordinate];
    
//      NSLog(@"loc la=%f lo=%f h=%f, v=%f", loc.latitude, loc.longitude, [location horizontalAccuracy], [location verticalAccuracy]);
    
        LSDEMP2 *emp = [[[LSDEMP2 alloc] init] autorelease];
    
        [emp addInteger:@"/mid" value:MESSAGE_ID_GET_EXTINFO];
        [emp addString:@"/mid/sid" value:[LSDSession sessionID]];
    
        [emp addFloat:@"/mid/l|1/lla" value:loc.latitude];
        [emp addFloat:@"/mid/l|1/llo" value:loc.longitude];
        [emp addFloat:@"/mid/l|1/lac" value:[location horizontalAccuracy]];
        [emp addFloat:@"/mid/l|1/lal" value:[location altitude]]; //fixed up [location verticalAccuracy]] on 20150713;
        [emp addString:@"/mid/l|1/lat" value:[LSDUtils toTimestampString:[location timestamp] withTimezone:[LSDProfile currentTimeZone]]];
        [emp addFloat:@"/mid/l|1/las" value:[location speed]];
        [emp addFloat:@"/mid/l|1/lab" value:[location course]];

        @try {
            [output appendData:[emp getBuffer]];
            return YES;
        }
        @catch (NSException *exception) {
        }
    }
    
    return NO;
}
#endif

@end
