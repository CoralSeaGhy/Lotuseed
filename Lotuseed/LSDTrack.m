//
//  LSDTrack.m
//  LSDTrack
//
//  Created by beyond on 12-8-22.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#ifdef LOTUSEED_TRACK

#import "LSDTrack.h"
#import "LSDProfile.h"
#import "LSDUIDevice.h"
#import "LSDUtils.h"

#define TRACK2  1  //POST double?

/**
 * 上行数据要素：
 * 1. AppKey
 * 2. OpenUDID
 * 3. MAC
 */

#define SDK_VERSION @"0.2"
#define CONFIG_KEY  @"lotuseed_tracking"
#define HTTP_HOST   @"https://tracker.lotuseed.com:4443"
#if TRACK2
#define HTTP_HOST2   @"https://tracker2.lotuseed.com:4443"
#endif

static NSString *__appkey = nil;
static NSString *__deviceid = nil;
static NSString *__useragent = nil;

@interface LSDTOperation : NSOperation {
    NSString* _url;
}

- (id)initWithUrl:(NSString*)url;

@end

@implementation LSDTOperation

- (id)initWithUrl:(NSString*)url {
    if (self = [super init]) {
        _url = url;
    }
    return self;
}

- (void)main
{
    int retry_count = 0;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:__useragent forHTTPHeaderField:@"User-Agent"];
    NSHTTPURLResponse *responese = nil;
    
RETRY:
	[NSURLConnection sendSynchronousRequest:request
                          returningResponse:&responese error:nil];
	if ([responese statusCode] == 200) {
//		[[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:CONFIG_KEY]; //removed on 20151124
        
#if TRACK2
        int retry2_count = 0;
    RETRY2:
        if (__useragent != nil)
        {
            
            NSString *url2 = [NSString stringWithFormat:@"%@/act?tid=%@&os=1&ua=%@&idfa=%@",
                             HTTP_HOST2, __appkey, [LSDUtils base64forData: [__useragent dataUsingEncoding:NSUTF8StringEncoding]] , [LSDUtils base64forData: [[LSDProfile deviceID] dataUsingEncoding:NSUTF8StringEncoding]]];
            NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url2]];
            [request2 setHTTPMethod:@"POST"];
            [NSURLConnection sendSynchronousRequest:request2
                                  returningResponse:&responese error:nil];
            if ([responese statusCode] == 200) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:CONFIG_KEY]; //!
                return;
            }
            else {
                retry2_count++;
                if (retry2_count < 3) {
                    [NSThread sleepForTimeInterval:1];
                    goto RETRY2;
                }
            }
        }
#else
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:CONFIG_KEY]; //!
        return;
#endif
	}
	else {
		retry_count++;
		if (retry_count < 3) {
			[NSThread sleepForTimeInterval:1];
			goto RETRY;
		}
	}
}

@end

//==============================================================================

@implementation LSDTrack

+ (void)startTracking:(NSString *)appKey {
	if (appKey == nil) {
#ifndef __OPTIMIZE__
		NSLog(@"Tracking: ");
#endif
		return;
	}
	
    if (__appkey == nil) {
        __appkey = [appKey copy]; //copy one!
    }
    if (__deviceid == nil) {
        __deviceid = [[LSDProfile deviceID] copy]; //copy one!
    }
    if (__useragent == nil) {
        UIWebView* wv = [[[UIWebView alloc] initWithFrame:CGRectZero] autorelease];
        __useragent = [[wv stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"] copy]; //copy one!
#ifndef __OPTIMIZE__
        NSLog(@"Useragent: %@", __useragent);
#endif
    }
    
    BOOL isActivated = [[[NSUserDefaults standardUserDefaults] objectForKey:CONFIG_KEY] boolValue];
    if (!isActivated) {
        UIDevice *dev = [UIDevice currentDevice];
        LSDUIDevice *lsddev = [LSDUIDevice currentDevice];
        NSString *url = [NSString stringWithFormat:@"%@/notify.php?appkey=%@&udid=%@&mac=%@&dm=%@&fv=%@&ac=%@&sv=%@&idfa=%@",
                         HTTP_HOST, __appkey, __deviceid, [lsddev macaddress], [lsddev platform], [dev systemVersion], [LSDProfile getChannel], SDK_VERSION, [LSDProfile getIDFA]]; //20141010: add channelid & sdkversion; 20150818: add idfa
        
        NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
        [queue setMaxConcurrentOperationCount:1];
        LSDTOperation *operation = [[LSDTOperation alloc] initWithUrl:url];
        [queue addOperation:operation];
        [operation release];
    }
}

@end

#endif
