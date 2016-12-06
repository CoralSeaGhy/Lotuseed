//
//  LSDGatherOperation.h
//  Lotuseed
//
//  Created by beyond on 12-6-5.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import "LSDBaseOperation.h"

@interface LSDGatherOperation : LSDBaseOperation
{
@private
    int postDataWriteStat;
    BOOL forcePostImmediately;
    NSMutableData *outputStream;
}

- (id) initWithMessageID:(int)ID forcePost:(BOOL)immediately;

@end
