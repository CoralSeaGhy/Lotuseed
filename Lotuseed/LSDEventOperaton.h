//
//  LSDEventOperaton.h
//  Lotuseed
//
//  Created by beyond on 12-5-30.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import "LSDGatherOperation.h"

@interface LSDEventOperaton : LSDGatherOperation
{
    int _eventType;
    NSString *_eventID;
    NSString *_eventLabel;
    boolean_t _isDuration;
    BOOL _isImmediate;
    long _eventCount;
    int64_t _eventTime;
}

- (id)initWithEventType:(int)eventType eventID:(NSString*)ID eventLabel:(NSString*)label eventCount:(long)count isDuration:(boolean_t)flag forcePost:(BOOL)immediately eventTime:(int64_t)time;

@end
