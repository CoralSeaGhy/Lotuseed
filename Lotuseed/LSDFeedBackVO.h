//
//  LSDFeedBackVO.h
//  Lotuseed
//
//  Created by apple on 16/9/13.
//
//
#ifdef LOTUSEED_FEED
#import <Foundation/Foundation.h>

#if ! __has_feature(objc_arc)
#define JSONAutoRelease(param) ([param autorelease]);
#else
#define JSONAutoRelease(param) (param)
#endif

@interface LSDFeedBackVO : NSObject

@property (nonatomic, retain) NSString  *message;
@property (nonatomic, retain) NSString  *fileName;
@property (nonatomic, assign) NSInteger revertTime;
@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, retain) NSString  *imgFM;
@property (nonatomic, assign) BOOL      isReply;


+ (LSDFeedBackVO *)LSDFeedBackVOWithJSONString:(NSString *)jsonString usingEncoding:(NSStringEncoding)stringEncoding error:(NSError **)error;
+ (LSDFeedBackVO *)LSDFeedBackVOWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)LSDFeedBackVOListWithArray:(NSArray *)array reply:(BOOL)isReply;
+ (NSArray *)LSDFeedBackVOListWithArray:(NSArray *)array;


@end
#endif