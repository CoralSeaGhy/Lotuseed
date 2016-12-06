//
//  LSDUtils.h
//  Lotuseed
//
//  Created by beyond on 12-5-31.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSDUtils : NSObject
{
    
}

+ (void)intToByteArray:(int)value outputBytes:(Byte[4])output;
+ (int)byteArrayToInt:(Byte[])value offset:(int)off;

+ (void)hexStringToByteArray:(NSString*)hexString outputBytes:(Byte[])output;
+ (int)parseInt:(NSString*)string radix:(int)radix;
+ (int) toDigit:(char)ch radix:(int)radix;

+ (NSString*)base64forData:(NSData*)theData;

+ (NSString*)getDocFolder;
+ (NSString*)getLibFolder;
+ (NSString *)getFileFullPathInDocument:(NSString *)fileName;
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

+ (long)getFileSize:(FILE*)fno;

/** 
 Uses zlib to compress the given data. Note that gzip headers will be added so 
 that the data can be easily decompressed using a tool like WinZip, gunzip, etc. 
 
 Note: Special thanks to Robbie Hanson of Deusty Designs for sharing sample code 
 showing how deflateInit2() can be used to make zlib generate a compressed file 
 with gzip headers: 
 
 http://deusty.blogspot.com/2007/07/gzip-compressiondecompression.html 
 
 @param pUncompressedData memory buffer of bytes to compress 
 @return Compressed data as an NSData object 
 */
+(NSData*) gzipCompressData: (NSData*)pUncompressedData;

+(NSData*) gzipDecompressData: (NSData*)pCompressedData;

+(NSString*)toTimestampString:(NSDate*)date withTimezone:(int)zone;

@end

char* strsplit(const char *from, const char *separators, int32_t pos, 
               char *to, int32_t to_size);

#ifndef LSDUTIL_H
#define LSDUTIL_H

#define LSDLOG(s,...) do { \
    if ([Lotuseed debugMode]) { \
        NSLog(s,__VA_ARGS__); \
    } \
}while(0);

#define ARRAY_LEN(a)  ((int)(sizeof(a) / sizeof(a[0])))

#endif

