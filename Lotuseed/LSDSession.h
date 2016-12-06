//
//  LSDSession.h
//  Lotuseed
//
//  Created by beyond on 12-5-29.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSDSession : NSObject
{

}

+ (NSString*)sessionID;
+ (BOOL) tryResetSession;

@end
