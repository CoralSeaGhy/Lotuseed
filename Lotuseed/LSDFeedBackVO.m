//
//  LSDFeedBackVO.m
//  Lotuseed
//
//  Created by apple on 16/9/13.
//
//
#ifdef LOTUSEED_FEED

#import "LSDFeedBackVO.h"

@implementation LSDFeedBackVO

+ (LSDFeedBackVO *)LSDFeedBackVOWithJSONString:(NSString *)jsonString usingEncoding:(NSStringEncoding)stringEncoding error:(NSError **)error
{
    NSData *jsonData = [jsonString dataUsingEncoding:stringEncoding];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                   options:0
                                                                     error:error];
    
    if (nil != error && nil != jsonDictionary) {
        return [LSDFeedBackVO LSDFeedBackVOWithDictionary:jsonDictionary];
    }
    
    return nil;
}

+ (LSDFeedBackVO *)LSDFeedBackVOWithDictionary:(NSDictionary *)dictionary reply:(BOOL)isReply {
    LSDFeedBackVO *instance = [[LSDFeedBackVO alloc] initWithDictionary:dictionary reply:isReply];
    return instance;
}

+ (LSDFeedBackVO *)LSDFeedBackVOWithDictionary:(NSDictionary *)dictionary
{
    LSDFeedBackVO *instance = [[LSDFeedBackVO alloc] initWithDictionary:dictionary];
    return instance;
}

+ (NSArray *)LSDFeedBackVOListWithArray:(NSArray *)array reply:(BOOL)isReply
{
    if (!array || ![array isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSMutableArray *resultsArray = [[NSMutableArray alloc] init];
    
    for (id entry in array) {
        if (![entry isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        [resultsArray addObject:[LSDFeedBackVO LSDFeedBackVOWithDictionary:entry reply:isReply]];
    }
    
    return resultsArray;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary reply:(BOOL)isReply
{
    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"m"] && [dictionary objectForKey:@"m"] != nil && [[dictionary objectForKey:@"m"] isKindOfClass:[NSString class]] && ![[dictionary objectForKey:@"m"] isEqualToString:@"null"]) {
            self.message = [dictionary objectForKey:@"m"];
        }
        if ([dictionary objectForKey:@"fd"] && [dictionary objectForKey:@"fd"] != nil && [[dictionary objectForKey:@"fd"] isKindOfClass:[NSString class]] && ![[dictionary objectForKey:@"fd"] isEqualToString:@"null"]) {
            self.fileName = [dictionary objectForKey:@"fd"];
        }
        if ([dictionary objectForKey:@"tm"] && [dictionary objectForKey:@"tm"] != nil) {
            if ([[dictionary objectForKey:@"tm"] isKindOfClass:[NSNumber class]] || [[dictionary objectForKey:@"tm"] isKindOfClass:[NSString class]]) {
                self.revertTime = [[dictionary objectForKey:@"tm"] integerValue] / 1000;
            }
        }
        if ([dictionary objectForKey:@"id"] && [dictionary objectForKey:@"id"] != nil && [[dictionary objectForKey:@"id"] isKindOfClass:[NSNumber class]]) {
            self.ID = [[dictionary objectForKey:@"id"] integerValue];
        }
        if ([dictionary objectForKey:@"imageFileName"] && [dictionary objectForKey:@"imageFileName"] != nil && [[dictionary objectForKey:@"imageFileName"] isKindOfClass:[NSString class]]) {
            self.imgFM = [dictionary objectForKey:@"imageFileName"];
        }
        self.isReply = isReply;
    }
    return self;
}

+ (NSArray *)LSDFeedBackVOListWithArray:(NSArray *)array
{
    if (!array || ![array isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSMutableArray *resultsArray = [[NSMutableArray alloc] init];
    
    for (id entry in array) {
        if (![entry isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        [resultsArray addObject:[LSDFeedBackVO LSDFeedBackVOWithDictionary:entry]];
    }
    
    return resultsArray;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"m"] && [dictionary objectForKey:@"m"] != nil && [[dictionary objectForKey:@"m"] isKindOfClass:[NSString class]] && ![[dictionary objectForKey:@"m"] isEqualToString:@"null"]) {
            self.message = [dictionary objectForKey:@"m"];
        }
        if ([dictionary objectForKey:@"fd"] && [dictionary objectForKey:@"fd"] != nil && [[dictionary objectForKey:@"fd"] isKindOfClass:[NSString class]] && ![[dictionary objectForKey:@"fd"] isEqualToString:@"null"]) {
            self.fileName = [dictionary objectForKey:@"fd"];
        }
        if ([dictionary objectForKey:@"tm"] && [dictionary objectForKey:@"tm"] != nil) {
            if ([[dictionary objectForKey:@"tm"] isKindOfClass:[NSNumber class]] || [[dictionary objectForKey:@"tm"] isKindOfClass:[NSString class]]) {
                self.revertTime = [[dictionary objectForKey:@"tm"] integerValue];
            }
        }
        if ([dictionary objectForKey:@"id"] && [dictionary objectForKey:@"id"] != nil && [[dictionary objectForKey:@"id"] isKindOfClass:[NSNumber class]]) {
            self.ID = [[dictionary objectForKey:@"id"] integerValue];
        }
        if ([dictionary objectForKey:@"imageFileName"] && [dictionary objectForKey:@"imageFileName"] != nil && [[dictionary objectForKey:@"imageFileName"] isKindOfClass:[NSString class]]) {
            self.imgFM = [dictionary objectForKey:@"imageFileName"];
        }
        self.isReply = NO;
    }
    return self;
}

@end
#endif