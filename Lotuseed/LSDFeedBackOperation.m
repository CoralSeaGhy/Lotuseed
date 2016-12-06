//
//  LSDFeedBackOperation.m
//  Lotuseed
//
//  Created by apple on 16/9/13.
//
//
#ifdef LOTUSEED_FEED

#import "LSDFeedBackOperation.h"
#import "Lotuseed.h"
#import "LSDConstants.h"
#import "LSDProfile.h"
#import "LSDJsonParser.h"
#import "LSDSession.h"
#import "LSDEMP2.h"


@implementation LSDFeedBackOperation

- (id)initWithMessageID:(int)ID withMessage:(NSString *)message withFileName:(NSString *)fileName withFileData:(NSData *)fileData withPostTime:(NSString *)postTime withPosterAge:(NSString *)posterAge withPosterGender:(NSString *)posterGender withPosterContact:(NSString *)posterContact
{
    if (self = [super initWithMessageID:ID]) {
        self.message = message;
        self.fileName = fileName;
        self.fileData = fileData;
        self.posterTime = postTime;
        self.posterAge = posterAge;
        self.posterGender = posterGender;
        self.posterContact = posterContact;
        [self setPostData:[self generatePostData]];
    }
    return self;
}

- (void)dealloc
{
    if (_delegate) {
        [_delegate release];
    }
    if (self.message) {
        [self.message release];
    }
    if (self.fileName) {
        [self.fileName release];
    }
    if (self.fileData) {
        [self.fileData release];
    }
    if (self.posterTime) {
        [self.posterTime release];
    }
    if (self.posterAge) {
        [self.posterAge release];
    }
    if (self.posterGender) {
        [self.posterGender release];
    }
    if (self.posterContact) {
        [self.posterContact release];
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
    
    [emp addInteger:@"/mid" value:MESSAGE_ID_POST_FEEDBACK];
    [emp addString:@"/mid/msg" value:self.message];
    [emp addString:@"/mid/sid" value:[LSDSession sessionID]];
    [emp addString:@"/mid/tm" value:self.posterTime];
    if (self.fileName && self.fileName != nil) {
        [emp addString:@"/mid/fn" value:self.fileName];
    }
    if (self.fileData && self.fileData != nil) {
        [emp addData:@"/mid/fd" value:self.fileData];
    }
    if (self.posterAge && self.posterAge != nil) {
        [emp addString:@"/mid/pa" value:self.posterAge];
    }
    if (self.posterGender && self.posterGender != nil) {
        [emp addString:@"/mid/pg" value:self.posterGender];
    }
    if (self.posterContact && self.posterContact != nil) {
        [emp addString:@"/mid/pc" value:self.posterContact];
    }
    
    return [emp getBuffer];
}

//Override
- (BOOL)doResult:(NSDictionary*)jsonDic
{
    if (jsonDic && _delegate && _selector) {
        NSString *ret = [jsonDic objectForKey:@"ret"];
        NSString *mid = [jsonDic objectForKey:@"mid"];
        
        NSMutableDictionary *retDic = [NSMutableDictionary dictionaryWithCapacity:2];
        if (ret) [retDic setObject:ret forKey:@"ret"];
        if (mid) [retDic setObject:mid forKey:@"mid"];
        
        //消息回调
        [_delegate performSelectorOnMainThread:_selector withObject:retDic waitUntilDone:NO];
        
        return YES;
    }
    
    if (_delegate && _selector) {
        //消息回调
        [_delegate performSelectorOnMainThread:_selector withObject:nil waitUntilDone:NO];
    }
    
    return NO;
}


@end
#endif