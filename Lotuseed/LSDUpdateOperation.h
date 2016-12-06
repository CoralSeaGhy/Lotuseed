//
//  LSDUpdateOperation.h
//  Lotuseed
//
//  Created by beyond on 12-6-5.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import "LSDOnlineOperation.h"

@interface LSDUpdateOperation : LSDOnlineOperation
{
@private
    id _delegate;
    SEL _selector;
}

- (id)initWithMessageID:(int)ID;

- (void)setSelector:(SEL)selector toTarget:(id)delegate;

@end
