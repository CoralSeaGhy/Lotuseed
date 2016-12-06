//
//  LSDBaseOperation.h
//  Lotuseed
//
//  Created by beyond on 12-5-29.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSDBaseOperation : NSOperation
{
    int messageID;
    BOOL isNewSession;
}

- (id)initWithMessageID:(int)ID;

//abstract interface
- (void)setPostData:(NSData*)data;

@end
