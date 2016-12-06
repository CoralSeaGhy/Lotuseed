//
//  LSDOnlineLocationOperation.h
//  Tabster
//
//  Created by beyond on 12-8-22.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#ifdef LOTUSEED_LOCATION

#import "LSDOnlineOperation.h"
#import <CoreLocation/CoreLocation.h>

@interface LSDOnlineLocationOperation : LSDOnlineOperation
{
@private
    id _delegate;
    SEL _selector;
    CLLocation *location;
}

@property(assign,nonatomic) CLLocation *location;

- (id)initWithMessageID:(int)ID;

- (void)setSelector:(SEL)selector toTarget:(id)delegate;

@end

#endif
