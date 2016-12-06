//
//  LSDUtils.m
//  Lotuseed
//
//  Created by beyond on 12-5-31.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import "LSDUtils.h"
#import "LSDConstants.h"
#import <sys/xattr.h>
#import <zlib.h>

/**
 * The smallest value of type <code>int</code>. The constant
 * value of this field is <tt>-2147483648</tt>.
 */
static const int MIN_VALUE = 0x80000000;

/**
 * The largest value of type <code>int</code>. The constant
 * value of this field is <tt>2147483647</tt>.
 */
static const int MAX_VALUE = 0x7fffffff;

/**
 * All possible chars for representing a number as a String
 */
static const char digits[] = {
	'0' , '1' , '2' , '3' , '4' , '5' ,
	'6' , '7' , '8' , '9' , 'a' , 'b' ,
	'c' , 'd' , 'e' , 'f' , 'g' , 'h' ,
	'i' , 'j' , 'k' , 'l' , 'm' , 'n' ,
	'o' , 'p' , 'q' , 'r' , 's' , 't' ,
	'u' , 'v' , 'w' , 'x' , 'y' , 'z'
};

/**
 * The minimum radix available for conversion to and from Strings.
 */
static const int MIN_RADIX = 2;

/**
 * The maximum radix available for conversion to and from Strings.
 */
static const int MAX_RADIX = 36;

@implementation LSDUtils

+ (void)intToByteArray:(int)value outputBytes:(Byte[4])output
{
    // TOTO...
}

+ (int)byteArrayToInt:(Byte[])value offset:(int)off
{
    int v = 0;
    for (int i = 0; i < 4; i++) {
        int shift = (4 - 1 - i) * 8;
        v += (value[i + off] & 0x000000FF) << shift;
    }
    return v;
}

+ (int) toDigit:(char)ch radix:(int)radix
{
	int value = -1;
	if (radix >= MIN_RADIX && radix <= MAX_RADIX) {
        if (isdigit(ch)) {
            value = ch - '0';
        }
        else if (isupper(ch) || islower(ch)) {
            // Java supradecimal digit
            value = (ch & 0x1F) + 9;
        }
	}
	return (value < radix) ? value : -1;
}

+ (int)parseInt:(NSString*)string radix:(int)radix
{
    if (string == nil || string.length == 0) {
		return 0;
	}
	
	if (radix < MIN_RADIX) {
		return 0; //error
	}
    
	if (radix > MAX_RADIX) {
		return 0; //error
	}
	
	int result = 0;
	BOOL negative = NO;
	int i = 0, max = string.length;
	int limit;
	int multmin;
	int digit;
    
    const char *s = [string UTF8String];
    
	if (max > 0) {
		if (s[0] == '-') {
			negative = YES;
			limit = MIN_VALUE;
			i++;
		} else {
			limit = -MAX_VALUE;
		}
		multmin = limit / radix;
		if (i < max) {
			digit = [self toDigit:s[i++] radix:radix];
			if (digit < 0) {
				return 0; //error
			} else {
				result = -digit;
			}
		}
		while (i < max) {
			// Accumulating negatively avoids surprises near MAX_VALUE
			digit = [self toDigit:s[i++] radix:radix];
			if (digit < 0) {
				return 0; //error
			}
			if (result < multmin) {
				return 0; //error
			}
			result *= radix;
			if (result < limit + digit) {
				return 0; //error
			}
			result -= digit;
		}
	} else {
		return 0;
	}
	if (negative == YES) {
		if (i > 1) {
			return result;
		} else {	/* Only got "-" */
			return 0; //error
		}
	} else {
		return -result;
	}
}

/**
 * 16进制的字符串表示转成字节数组
 * 
 * @param hexString
 *            16进制格式的字符串
 * @return 转换后的字节数组
 **/
+ (void)hexStringToByteArray:(NSString*)hexString outputBytes:(Byte[])output
{
    if (hexString == nil || [hexString length] % 2 == 1) {
        NSLog(@"%@ this hexString format is wrong", SDK_LOG_TAG);
        return;
    }
    
    const char *s = [hexString UTF8String];
    
    int k = 0;
    for (int i = 0; i < strlen(s)/2; i++) {
        // 因为是16进制，最多只会占用4位，转换成字节需要两个16进制的字符，高位在先
        int8_t high = (int8_t) ([self toDigit:s[k] radix:16] & 0xff);
        int8_t low = (int8_t) ([self toDigit:s[k+1] radix:16] & 0xff);
        output[i] = (int8_t) (high << 4 | low);
        k += 2;
    }
}

+ (NSString*)base64forData:(NSData*)theData
{
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
     return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

// 获取应用程序的文档目录
+ (NSString*)getDocFolder
{
    NSArray *userPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [userPaths objectAtIndex:0];
}

// 获取应用程序的库文件目录
+ (NSString*)getLibFolder
{
    NSArray *userPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	return [userPaths objectAtIndex:0];
}

// 获取应用程序文档目录中某个指定文件全路径
+ (NSString *)getFileFullPathInDocument:(NSString *)fileName
{
	NSString *docPath = [self getDocFolder];
	return [docPath stringByAppendingPathComponent:fileName];
}

// 设置文件"set not backup attribution"属性
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const  char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
    
    /*
    if (&NSURLIsExcludedFromBackupKey == nil) { // iOS <= 5.0.1
        const char* filePath = [[URL path] fileSystemRepresentation];
        
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    } else { // iOS >= 5.1
        NSError *error = nil;
        [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        return error == nil;
    }
     */
}

+ (long)getFileSize:(FILE*)fno
{
	long curPos = ftell(fno);		// get the curr pos
	fseek(fno, 0, SEEK_END);
	
	long ret = ftell(fno);
	fseek(fno, curPos, SEEK_SET);	// restore to the previous pos
	return ret;
}

+(NSData*) gzipCompressData: (NSData*)pUncompressedData
{
    /* 
     Special thanks to Robbie Hanson of Deusty Designs for sharing sample code 
     showing how deflateInit2() can be used to make zlib generate a compressed 
     file with gzip headers: 
     
     http://deusty.blogspot.com/2007/07/gzip-compressiondecompression.html 
     */
    
    if (!pUncompressedData || [pUncompressedData length] == 0)
    {
        NSLog(@"%s: Error: Can't compress an empty or null NSData object.", __func__);
        return nil;
    }
    
    /* Before we can begin compressing (aka "deflating") data using the zlib 
     functions, we must initialize zlib. Normally this is done by calling the 
     deflateInit() function; in this case, however, we'll use deflateInit2() so 
     that the compressed data will have gzip headers. This will make it easy to 
     decompress the data later using a tool like gunzip, WinZip, etc. 
     
     deflateInit2() accepts many parameters, the first of which is a C struct of 
     type "z_stream" defined in zlib.h. The properties of this struct are used to 
     control how the compression algorithms work. z_stream is also used to 
     maintain pointers to the "input" and "output" byte buffers (next_in/out) as 
     well as information about how many bytes have been processed, how many are 
     left to process, etc. */
    z_stream zlibStreamStruct;
    zlibStreamStruct.zalloc    = Z_NULL; // Set zalloc, zfree, and opaque to Z_NULL so
    zlibStreamStruct.zfree     = Z_NULL; // that when we call deflateInit2 they will be
    zlibStreamStruct.opaque    = Z_NULL; // updated to use default allocation functions.
    zlibStreamStruct.total_out = 0; // Total number of output bytes produced so far
    zlibStreamStruct.next_in   = (Bytef*)[pUncompressedData bytes]; // Pointer to input bytes
    zlibStreamStruct.avail_in  = [pUncompressedData length]; // Number of input bytes left to process
    
    /* Initialize the zlib deflation (i.e. compression) internals with deflateInit2(). 
     The parameters are as follows: 
     
     z_streamp strm - Pointer to a zstream struct 
     int level      - Compression level. Must be Z_DEFAULT_COMPRESSION, or between 
     0 and 9: 1 gives best speed, 9 gives best compression, 0 gives 
     no compression. 
     int method     - Compression method. Only method supported is "Z_DEFLATED". 
     int windowBits - Base two logarithm of the maximum window size (the size of 
     the history buffer). It should be in the range 8..15. Add 
     16 to windowBits to write a simple gzip header and trailer 
     around the compressed data instead of a zlib wrapper. The 
     gzip header will have no file name, no extra data, no comment, 
     no modification time (set to zero), no header crc, and the 
     operating system will be set to 255 (unknown). 
     int memLevel   - Amount of memory allocated for internal compression state. 
     1 uses minimum memory but is slow and reduces compression 
     ratio; 9 uses maximum memory for optimal speed. Default value 
     is 8. 
     int strategy   - Used to tune the compression algorithm. Use the value 
     Z_DEFAULT_STRATEGY for normal data, Z_FILTERED for data 
     produced by a filter (or predictor), or Z_HUFFMAN_ONLY to 
     force Huffman encoding only (no string match) */
    int initError = deflateInit2(&zlibStreamStruct, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY);
    if (initError != Z_OK)
    {
        NSString *errorMsg = nil;
        switch (initError)
        {
            case Z_STREAM_ERROR:
                errorMsg = @"Invalid parameter passed in to function.";
                break;
            case Z_MEM_ERROR:
                errorMsg = @"Insufficient memory.";
                break;
            case Z_VERSION_ERROR:
                errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
                break;
            default:
                errorMsg = @"Unknown error code.";
                break;
        }
        NSLog(@"%s: deflateInit2() Error: \"%@\" Message: \"%s\"", __func__, errorMsg, zlibStreamStruct.msg);
        [errorMsg release];
        return nil;
    }
    
    // Create output memory buffer for compressed data. The zlib documentation states that
    // destination buffer size must be at least 0.1% larger than avail_in plus 12 bytes.
    //NSMutableData *compressedData = [NSMutableData dataWithLength:[pUncompressedData length] * 1.01 + 12]; //has bug:Z_BUF_ERROR
    
    // This may seem a bit weird at first,
    // but the array that is to hold the compressed
    // data must start out being AT LEAST 0.1% larger than
    // the original size of the data, + 12 extra bytes.
    
    // So, we'll just play it safe and alloated 1.1x
    NSMutableData *compressedData = [NSMutableData dataWithLength:[pUncompressedData length] * 1.2 + 256];  //eagle
    
    int deflateStatus;
    do
    {
        // Store location where next byte should be put in next_out
        zlibStreamStruct.next_out = [compressedData mutableBytes] + zlibStreamStruct.total_out;
        
        // Calculate the amount of remaining free space in the output buffer
        // by subtracting the number of bytes that have been written so far
        // from the buffer's total capacity
        zlibStreamStruct.avail_out = [compressedData length] - zlibStreamStruct.total_out;
        
        /* deflate() compresses as much data as possible, and stops/returns when 
         the input buffer becomes empty or the output buffer becomes full. If 
         deflate() returns Z_OK, it means that there are more bytes left to 
         compress in the input buffer but the output buffer is full; the output 
         buffer should be expanded and deflate should be called again (i.e., the 
         loop should continue to rune). If deflate() returns Z_STREAM_END, the 
         end of the input stream was reached (i.e.g, all of the data has been 
         compressed) and the loop should stop. */
        deflateStatus = deflate(&zlibStreamStruct, Z_FINISH);
        
    } while ( deflateStatus == Z_OK );      
    
    // Check for zlib error and convert code to usable error message if appropriate
    if (deflateStatus != Z_STREAM_END)
    {
        NSString *errorMsg = nil;
        switch (deflateStatus)
        {
            case Z_ERRNO:
                errorMsg = @"Error occured while reading file.";
                break;
            case Z_STREAM_ERROR:
                errorMsg = @"The stream state was inconsistent (e.g., next_in or next_out was NULL).";
                break;
            case Z_DATA_ERROR:
                errorMsg = @"The deflate data was invalid or incomplete.";
                break;
            case Z_MEM_ERROR:
                errorMsg = @"Memory could not be allocated for processing.";
                break;
            case Z_BUF_ERROR:
                errorMsg = @"Ran out of output buffer for writing compressed bytes.";
                break;
            case Z_VERSION_ERROR:
                errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
                break;
            default:
                errorMsg = @"Unknown error code.";
                break;
        }
        NSLog(@"%s: zlib error while attempting compression: \"%@\" Message: \"%s\"", __func__, errorMsg, zlibStreamStruct.msg);
        [errorMsg release];
        
        // Free data structures that were dynamically created for the stream.
        deflateEnd(&zlibStreamStruct);
        
        return nil;
    }
    // Free data structures that were dynamically created for the stream.
    deflateEnd(&zlibStreamStruct);
    [compressedData setLength: zlibStreamStruct.total_out];
    //NSLog(@"%s: Compressed file from %d KB to %d KB", __func__, [pUncompressedData length]/1024, [compressedData length]/1024);
    
    return compressedData;
}

+(NSData*) gzipDecompressData: (NSData*)pCompressedData
{
    if (!pCompressedData) {
        return nil;
    }
    if (pCompressedData.length == 0) {
        return pCompressedData;
    }
    
    NSUInteger dataLength = [pCompressedData length];
    NSUInteger halfLength = dataLength / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: dataLength + halfLength];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[pCompressedData bytes];
    strm.avail_in = (uInt)dataLength;
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    // inflateInit2 knows how to deal with gzip format
    if (inflateInit2(&strm, (15+32)) != Z_OK) {
        return nil;
    }
    
    while (!done){
        // extend decompressed if too short
        if (strm.total_out >= [decompressed length])
        {
            [decompressed increaseLengthBy: halfLength];
        }
        
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)[decompressed length] - (uInt)strm.total_out;
        
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        
        if (status == Z_STREAM_END)
        {
            done = YES;
        }
        else if (status != Z_OK)
        {
            break;     
        }}
    
    if (inflateEnd (&strm) != Z_OK || !done){
        return nil;
    }
    
    // set actual length
    [decompressed setLength:strm.total_out];
    
    return decompressed;
}

+(NSString*)toTimestampString:(NSDate*)date withTimezone:(int)zone {
    return [NSString stringWithFormat:@"%lld+%d", (int64_t)[date timeIntervalSince1970] * 1000, zone];
}

@end //!

/*
 * string split
 */
char* strsplit(const char *from, const char *separators, int32_t pos, 
                   char *to, int32_t to_size)
{
	char *pstart, *pend, *p;
	int32_t i;
    
	if (!from || !to || to_size < 1) {
		return NULL;
	}
	memset(to, 0, to_size);
	
	if (pos < 1) {
		return NULL;
	}
	
	pstart = (char *)from;
	pend = pstart + strlen(from);
    
	i = 0;
	while (pstart) {
		i++;
		p = strstr(pstart, separators);
		if (!p) {
			if (i == pos) {
				memcpy(to, pstart, MIN((int32_t)strlen(pstart), to_size-1));
                
				break;
			}
			else
				return NULL;
		}
		if (i == pos) {
			memcpy(to, pstart, MIN(MIN(p-pstart, pend-pstart), to_size-1));
            
			break;
		}
		pstart = p + strlen(separators);
	}
	
	return to;
}

