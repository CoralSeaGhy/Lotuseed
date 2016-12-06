//
//  LSDPoster.h
//  Lotuseed
//
//  Created by beyond on 12-5-29.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSDPoster : NSObject
{
    
}

+ (NSString *)postData:(NSData *)data messageID:(int)ID hostServer:(NSString*)server hostPort:(int)port urlPath:(NSString*)path;

+ (int)savePostData: (NSData *)data fileName:(NSString *)name overWrite:(BOOL)flag;

+ (int)getAllPostData:(NSData*)outputStream;

+ (void)deleteAllCacheFile:(int)eventDataSize;

@end
