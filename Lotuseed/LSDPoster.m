////
////  LSDPoster.m
////  Lotuseed
////
////  Created by beyond on 12-5-29.
////  Copyright (c) 2012年 beyond. All rights reserved.
////
//
#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access
#import "LSDPoster.h"
#import "LSDConstants.h"
#import "LSDUtils.h"
#import "LSDSession.h"
#import "LSDProfile.h"
#import "LSDProvider.h"
#import "LSDUIDevice.h"
#import "Lotuseed.h"

@interface asyncPoster : NSObject
@property (nonatomic,strong)NSMutableData *AllData;
@property (nonatomic,assign)BOOL receiveData;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@end

@implementation asyncPoster

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse");
}

-(instancetype)init{
    if (self = [super init]) {
        _AllData = [[NSMutableData alloc] init ];
    }
    return self;
}

-(void)dealloc{
    [_AllData release];
    [super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_AllData appendData:data];
    NSLog(@"didReciveData");
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _receiveData = YES;
    [connection release];
    NSLog(@"didFinishLoading");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [connection release];
    _receiveData = YES;
    [_AllData release];
    _AllData = nil;
    NSLog(@"Connection failed! Error - %@ FailingURLStringKey:%@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    NSLog(@"canAuthenticateAgainstProtectionSpace");
    
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"Got auth challange via NSURLConnection");
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        //        if ([trustedHosts containsObject:challenge.protectionSpace.host])
        [challenge.sender useCredential:[NSURLCredential	credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end


@implementation LSDPoster

+ (NSString*)genMD5:(NSString*)str
{
    CC_MD5_CTX ctx;
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    const char *pchar = [str UTF8String];
    
    CC_MD5_Init(&ctx);
    CC_MD5_Update(&ctx, pchar, strlen(pchar));
    CC_MD5_Update(&ctx, SDK_MOD5_KEY, strlen(SDK_MOD5_KEY));
    CC_MD5_Final(digest, &ctx);
    
    NSString* result = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                        digest[0], digest[1],
                        digest[2], digest[3],
                        digest[4], digest[5],
                        digest[6], digest[7],
                        digest[8], digest[9],
                        digest[10], digest[11],
                        digest[12], digest[13],
                        digest[14], digest[15]];
    return result;
}

+ (NSString *)postData:(NSData *)data messageID:(int)ID hostServer:(NSString*)server hostPort:(int)port urlPath:(NSString*)path
{
    NSString *uri_base = [NSString stringWithFormat:@"%@?%@%d&sv=%@&tm=%lld&sid=%@&ct=%@", path, (ID > 0 ? [NSString stringWithFormat:@"mid=%d&st=", ID] : @"st="),
                          SDK_TYPE, SDK_VERSION, [LSDProfile currentTimeMillis], [[LSDSession sessionID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                          [LSDProfile getNetworkType]];
    NSString *url_base = [NSString stringWithFormat:@"https://%@:%d%@&md=%@", server, port, uri_base, [self genMD5:uri_base]];
    
    NSURL	*url = [NSURL URLWithString:url_base];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:NET_CON_TIMEOUT] autorelease];
    /*
     NSString* secretAgent = nil;
     if (![[LSDSession sessionID] isEqualToString:lastSessionID]) {
     if (!lastSessionID) {
     lastSessionID = [[NSMutableString alloc] initWithCapacity:50];
     }
     [lastSessionID setString:[LSDSession sessionID]];
     secretAgent = [LSDProvider getDefaultWebViewUserAgent];
     }
     else {
     secretAgent = NET_DEFAULT_USERAGENT;
     }
     if (secretAgent) {
     [request setValue:secretAgent forHTTPHeaderField:@"User-Agent"];
     }
     */
    [request setHTTPMethod:@"POST"];
    [request setValue:NET_DEFAULT_USERAGENT forHTTPHeaderField:@"User-Agent"];
    /* eagle 20130926 */
    [request addValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    //gzip
    NSData *gzipData = [LSDUtils gzipCompressData:data];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[gzipData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:gzipData];
    
    asyncPoster* ap = [[[asyncPoster alloc] init] autorelease];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:ap];
    [connection start];
    
    while(!ap.receiveData)
    {
        [NSThread sleepForTimeInterval:0.01f];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    
    
    if (ap.AllData)
    {
        Byte *bytes = (Byte*)[ap.AllData bytes];
        if (*bytes == '{')
        {  //JSON
            NSString *returnStr = [[[NSString alloc] initWithData:ap.AllData encoding:NSUTF8StringEncoding] autorelease];
            return returnStr;
        }
        else if (*bytes == 0x1f) {  //gzip,deflate
            NSData *dcompressData = [LSDUtils gzipDecompressData:ap.AllData];
            NSString *returnStr = [[[NSString alloc] initWithData:dcompressData encoding:NSUTF8StringEncoding] autorelease];
            return returnStr;
        }
        else {  //other
            //TODO...
        }
        
    }
    return nil;
}

/**
 * File write
 *
 * 保存PostData到本地缓存
 *
 * @param data
 * @return -1 - 失败
 *          0 - 成功
 *          1 - 成功，但超缓存上限。
 */
+ (int)savePostData: (NSData *)data fileName:(NSString *)name overWrite:(BOOL)flag
{
    if (!data || !name) {
        return -1;
    }
    
    if (data.length <=0) {
        return 0;
    }
    
    @synchronized(self) {
        NSString *path = [LSDUtils getFileFullPathInDocument:name];
        FILE *file = NULL;
        
        @try {
            if (flag) {
                file = fopen([path UTF8String], "w");
                if (file) {
                    fwrite((void*)[data bytes], 1, [data length], file);
                }
                return 0;
            }
            else {
                file = fopen([path UTF8String], "a+"); //fixbug:r+ --> a+
                if (file) {
                    fseek(file, 0, SEEK_END);
                    long fileSize = ftell(file);
                    
                    if (fileSize < POST_DATA_MAX_CACHE_SIZE) {
                        fwrite((void*)[data bytes], 1, [data length], file);
                        fileSize += [data length];
                    }
                    
                    return (fileSize < POST_DATA_ALERT_CACHE_SIZE) ? 0: 1;
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@ %@", SDK_LOG_TAG, exception);
        }
        @finally {
            if (file) {
                //关闭文件句柄
                fclose(file);
                //设置不备份属性
                NSString *encPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURL *url = [NSURL URLWithString:encPath];
                [LSDUtils addSkipBackupAttributeToItemAtURL:url];
            }
        }
    }
    return -1;
}

/**
 * File read
 *
 * Post所有本地缓存到服务器
 *
 * @param context
 * @return
 */
/**
 * File read
 *
 * Post所有本地缓存到服务器
 *
 * @param context
 * @return
 */
+ (int)getAllPostData:(NSMutableData*)outputStream
{
    @synchronized(self) {
        int eventDataSize = 0;
        
        NSString *path = [LSDUtils getFileFullPathInDocument:POST_DATA_CACHE_FILE_SESSION];
        FILE *file = fopen([path UTF8String], "r");
        if (file) {
            @try {
                eventDataSize = [LSDUtils getFileSize:file];
                char *pData = malloc(eventDataSize);
                if (pData) {
                    if (fread(pData, 1, eventDataSize, file) == eventDataSize) {
                        [outputStream appendBytes:pData length:eventDataSize];
                    }
                    free(pData);
                }
            }
            @catch (NSException *exception) {
                eventDataSize = 0;
            }
            @finally {
                fclose(file);
            }
        }
        
        return eventDataSize;
    }
}

/**
 *  File delete
 *
 *  清除所有本地缓存
 *
 * @param context
 */
+ (void)deleteAllCacheFile:(int)eventDataSize
{
    @synchronized(self) {
        NSString *path = nil;
        
        // delete lotuseed.s
        if (eventDataSize > 0) {
            path = [LSDUtils getFileFullPathInDocument:POST_DATA_CACHE_FILE_SESSION];
            FILE *file = fopen([path UTF8String], "r+");
            if (file) {
                @try {
                    long fileSize = [LSDUtils getFileSize:file];
                    if (fileSize == eventDataSize) {
                        ftruncate(fileno(file), (off_t)0L);
                    }
                    else if (fileSize > eventDataSize) {
                        long leftSize = fileSize - eventDataSize;
                        char *pData = malloc(leftSize);
                        fseek(file, (long)eventDataSize, SEEK_SET);
                        if (fread(pData, 1, leftSize, file) == leftSize) {
                            rewind(file);
                            fwrite(pData, 1, leftSize, file);
                            ftruncate(fileno(file), (off_t)leftSize);
                        }
                        free(pData);
                    }
                }
                @finally {
                    fclose(file);
                }
            }
        }
    }
}

@end