//
//  LSDOnlineConfigOperation.m
//  Tabster
//
//  Created by beyond on 12-6-14.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import "LSDOnlineConfigOperation.h"
#import "LSDConstants.h"
#import "LSDEMP2.h"
#import "LSDSession.h"
#import "LSDProfile.h"
#import "LSDProvider.h"

@implementation LSDOnlineConfigOperation

- (NSData*)generatePostData
{
    LSDEMP2 *emp = [[[LSDEMP2 alloc] init] autorelease];
    
    [emp addInteger:@"/mid" value:MESSAGE_ID_ONLINE_CONFIG];
    [emp addString:@"/mid/sid" value:[LSDSession sessionID]];
    [emp addString:@"/mid/ac" value:[LSDProfile getChannel]];
    [emp addString:@"/mid/av" value:[LSDProfile getAppBuildVersion]];
    [emp addInteger:@"/mid/pv" value:[LSDProvider getOnlineConfigParamVer]];
    
    BOOL realtimeMode = [LSDProvider getRealTimeMode];
    if (realtimeMode) {
        [emp addBoolean:@"/mid/rt" value:realtimeMode];
    }
    
    return [emp getBuffer];
}

- (id)init
{
    if (self = [super initWithMessageID:MESSAGE_ID_ONLINE_CONFIG]) {
        [super setPostData:[self generatePostData]];
    }
    return self;
}

- (BOOL)doResult:(NSDictionary*)jsonDic
{
    if (!jsonDic) {
        return NO;
    }
    
    NSString *realTime = [jsonDic objectForKey:@"rt"];
    if (realTime) {
        //设置离线发送策略
        [LSDProvider setRealTimeMode:([realTime intValue] == 0) ? NO : YES];
    }
    
    NSString *ver = [jsonDic objectForKey:@"pv"];
    NSArray *arr = [jsonDic objectForKey:@"pm"];
    if (ver && arr) {
        int verCode = [ver intValue];
        [LSDProvider setOnlineConfigParamVer:verCode];
        [LSDProvider saveOnlineConfigParam:arr];
        
        //下载所有文件
        for (int i=0; i<arr.count; i++) {
            NSDictionary *dic = [arr objectAtIndex:i];
            
            NSString *key = [dic objectForKey:@"k"];
            NSString *value = [dic objectForKey:@"v"];
            NSString *isFile = [dic objectForKey:@"f"];
            
            int fileFlag = [isFile intValue];
            if (fileFlag != 0) {
                // 下载文件并修改value为本地带路径文件名
                // TODO...
            }
        }
        
        return YES;
    }
    
    return NO;
}

@end
