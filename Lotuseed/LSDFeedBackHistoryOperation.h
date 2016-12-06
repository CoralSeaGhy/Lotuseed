//
//  LSDFeedBackHistoryOperation.h
//  Lotuseed
//
//  Created by apple on 16/9/13.
//
//
#ifdef LOTUSEED_FEED

#import "LSDOnlineOperation.h"

@interface LSDFeedBackHistoryOperation : LSDOnlineOperation
{
@private
    
    id _delegate;
    SEL _selector;
}

@property (nonatomic, retain) NSString  *lastTime;
@property (nonatomic, assign) NSInteger ID;

- (void)setSelector:(SEL)selector toTarget:(id)delegate;

- (id)initWithMessageID:(int)ID withLastTime:(NSString *)lastTime withID:(NSInteger)ID;

@end

#endif
