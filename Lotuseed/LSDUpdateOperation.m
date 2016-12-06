//
//  LSDUpdateOperation.m
//  Lotuseed
//
//  Created by beyond on 12-6-5.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import "LSDUpdateOperation.h"
#import "LSDPoster.h"
#import "LSDConstants.h"
#import "LSDProfile.h"
#import "LSDJsonParser.h"
#import "LSDProvider.h"
#import "LSDSession.h"
#import "LSDEMP2.h"
#import "LotuseedInternal.h"
#import "Lotuseed.h"

@interface LSDUpdateOperation(PRIVATE)

- (NSData*)generatePostData;

@end

@implementation LSDUpdateOperation

- (id)initWithMessageID:(int)ID
{
    if (self = [super initWithMessageID:ID]) {
        [self setPostData:[self generatePostData]];
    }
    return self;
}

- (void)dealloc
{
    if (_delegate) {
        [_delegate release];
    }
    [super dealloc];
}

- (void)setSelector:(SEL)selector toTarget:(id)delegate
{
    [delegate retain];
    [_delegate release];
    _delegate = delegate;
    
    _selector = selector;
}

- (NSData*)generatePostData
{
    LSDEMP2 *emp = [[[LSDEMP2 alloc] init] autorelease];
    
    [emp addInteger:@"/mid" value:MESSAGE_ID_APP_UPDATE];
    [emp addString:@"/mid/sid" value:[LSDSession sessionID]];
    [emp addString:@"/mid/ac" value:[LSDProfile getChannel]];
    [emp addString:@"/mid/av" value:[LSDProfile getAppBuildVersion]];
    [emp addString:@"/mid/cl" value:[LSDProfile getSystemLanguage]];
        
    return [emp getBuffer];
}

//Override
- (BOOL)doResult:(NSDictionary*)jsonDic
{
    if (!jsonDic) return  NO;
    
    NSString *msgRet = [jsonDic objectForKey:@"ret"];
    NSString *buildVersion = [jsonDic objectForKey:@"v"];
    NSString *updateLog = [jsonDic objectForKey:@"l"];
    NSString *openUrl = [jsonDic objectForKey:@"u"];
    NSString *versionName = [jsonDic objectForKey:@"n"];
    
    if (_delegate && _selector) {
        //修改节点名
        NSMutableDictionary *retDic = [NSMutableDictionary dictionaryWithCapacity:5];
        
        if (!msgRet || [msgRet intValue] != MESSAGE_RET_OK) {
            [retDic setObject:@"-1" forKey:@"respCode"];
        }
        else {
            [retDic setObject:@"0" forKey:@"respCode"];
            if (buildVersion) [retDic setObject:buildVersion forKey:@"buildVersion"];
            if (updateLog)    [retDic setObject:updateLog forKey:@"updateLog"];
            if (openUrl)      [retDic setObject:openUrl forKey:@"openUrl"];
            if (versionName)  [retDic setObject:versionName forKey:@"versionName"];
        }
        
        //消息回调
        [_delegate performSelectorOnMainThread:_selector withObject:retDic waitUntilDone:NO];
        
        return YES;
    }
    else {
        if (!msgRet || [msgRet intValue] != MESSAGE_RET_OK) {
            return NO;
        }
        
        if (buildVersion == nil || buildVersion.length == 0 || [buildVersion isEqualToString:[LSDProfile getAppBuildVersion]]) {
            // 已经是最新版本
            return YES;
        }
        else {
            //sleep one second
            [NSThread sleepForTimeInterval:1.0f];
            
            // 显示新下载提示界面
            [LotuseedInternal showUpdateAlertDialogWithUpdateLog:updateLog versionName:versionName openUrl:openUrl];
            
            return YES;
        }
        
        return NO;
    }
}

@end
