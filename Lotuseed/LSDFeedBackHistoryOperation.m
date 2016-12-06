//
//  LSDFeedBackHistoryOperation.m
//  Lotuseed
//
//  Created by apple on 16/9/13.
//
//

#ifdef LOTUSEED_FEED

#import "LSDFeedBackHistoryOperation.h"
#import "Lotuseed.h"
#import "LSDConstants.h"
#import "LSDProfile.h"
#import "LSDJsonParser.h"
#import "LSDSession.h"
#import "LSDEMP2.h"

@implementation LSDFeedBackHistoryOperation

- (id)initWithMessageID:(int)MID withLastTime:(NSString *)lastTime withID:(NSInteger)ID
{
    if (self = [super initWithMessageID:MID]) {
        self.lastTime = lastTime;
        self.ID = ID;
        [self setPostData:[self generatePostData]];
    }
    return self;
}

- (void)dealloc
{
    if (_delegate) {
        [_delegate release];
    }
    if (self.lastTime) {
        [self.lastTime release];
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
    
    [emp addInteger:@"/mid" value:MESSAGE_ID_FEEDBACK_REVERT];
    [emp addString:@"/mid/sid" value:[LSDSession sessionID]];
    [emp addInteger:@"/mid/id" value:self.ID];
    [emp addString:@"/mid/tm" value:self.lastTime];
    return [emp getBuffer];
}

//Override
- (BOOL)doResult:(NSDictionary*)jsonDic
{
    if (jsonDic && _delegate && _selector) {
        NSString *ret = [jsonDic objectForKey:@"ret"];
        NSString *mid = [jsonDic objectForKey:@"mid"];
        NSArray  *messageArr = [jsonDic objectForKey:@"msg"];
        NSMutableDictionary *retDic = [NSMutableDictionary dictionaryWithCapacity:2];
        if (ret) [retDic setObject:ret forKey:@"ret"];
        if (mid) [retDic setObject:mid forKey:@"mid"];
        if (messageArr) [retDic setObject:messageArr forKey:@"msg"];
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