//
//  LSDOnlineOperation.m
//  Lotuseed
//
//  Created by beyond on 12-6-5.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import "LSDOnlineOperation.h"
#import "LSDConstants.h"
#import "LSDProfile.h"
#import "LSDPoster.h"
#import "Lotuseed.h"
#import "LSDJsonParser.h"
#import "LSDUtils.h"

@implementation LSDOnlineOperation

- (void)setPostData:(NSData*)data
{
    postData = [data retain];
}

//abstract
- (BOOL)doResult:(NSDictionary*)jsonDic
{
    return NO;
}

- (void)main
{
    if (self.isCancelled)
        return;
    
    LSDLOG(@"%@ Event: id=%d", SDK_LOG_TAG, messageID);
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        // 发送实时交易
        NSString *respMsg = nil;
        if (postData != nil && [LSDProfile isNetworkAvailable]) {
            respMsg = [LSDPoster postData:postData messageID:messageID hostServer:ONLINE_HOST_SERVER hostPort:ONLINE_HOST_PORT urlPath:ONLINE_HOST_URLPATH];
        }
        
//        respMsg = @"{\"mid\":\"1006\",\"ret\":\"0\",\"v\":\"1.2\",\"l\":\"XXXXX\",\"u\":\"http://itunes.apple.com/cn/app/id473596162?mt=8\",\"n\":\"YYYY\"}"; //only test!
        
        // 响应报文处理
        int mid = -1;
        int ret = -1;
        if (respMsg && respMsg.length > 0) {
            LSDJsonParser *parser = [[LSDJsonParser alloc] init];
            NSError *error = nil;
            NSMutableDictionary *jsonDic = [parser objectWithString:respMsg error:&error];
            if (jsonDic == nil) {
                goto FAILURE;
            }
            
            NSString *value = nil;
            
            value = [jsonDic objectForKey:@"mid"];
            if (value != nil) {
                mid = [value intValue];
            }
            value = [jsonDic objectForKey:@"ret"];
            if (value != nil) {
                ret = [value intValue];
            }
            
            BOOL result = [self doResult:jsonDic];
            
            [parser release];
            parser = nil;
            
            if (ret != MESSAGE_RET_OK || result != YES) {
                goto FAILURE;
            }
            
            //success
            return;
        }
FAILURE:
        LSDLOG(@"%@ Return error: smid=%d, rmid=%d, ret=%d", SDK_LOG_TAG, messageID, mid, ret);
    }
    @catch (NSException *exception) {
        LSDLOG(@"%@ @@", SDK_LOG_TAG);
    }
    @finally {
        [postData release];
        [pool release];
    }
}

@end
