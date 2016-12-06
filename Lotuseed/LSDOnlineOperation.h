//
//  LSDOnlineOperation.h
//  Lotuseed
//
//  Created by beyond on 12-6-5.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import "LSDBaseOperation.h"

@interface LSDOnlineOperation : LSDBaseOperation
{
    NSData *postData;
}

//abstract
- (BOOL)doResult:(NSDictionary*)jsonDic;

@end
