//
//  LSDBaseOperation.m
//  Lotuseed
//
//  Created by beyond on 12-5-29.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import "LSDBaseOperation.h"
#import "LSDConstants.h"
#import "LSDSession.h"
#import "LSDPoster.h"
#import "LSDProfile.h"

@implementation LSDBaseOperation

- (id) initWithMessageID:(int)ID
{
    if (self = [super init]) {
        messageID = ID;
        
        //隐式启动SESSION
        isNewSession = [LSDSession tryResetSession];
    }
    return self;
}

- (void)setPostData:(NSData*)data
{
    
}

@end
