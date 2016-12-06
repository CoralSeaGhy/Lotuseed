//
//  LSDEMP2.h
//  Lotuseed
//
//  Created by beyond on 12-6-1.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct _Head Head;
typedef struct _Node Node;

@interface LSDEMP2 : NSObject
{
    Head *pkgHead;
	Node *rootNode;
}

- (boolean_t)addString:(NSString*)path value:(NSString*)value;
- (boolean_t)addInteger:(NSString*)path value:(int64_t)value;
- (boolean_t)addBoolean:(NSString*)path value:(BOOL)value;
- (boolean_t)addData:(NSString*)path value:(NSData*)data;
- (boolean_t)addFloat:(NSString*)path value:(float)value;

- (NSData*)getBuffer;
- (NSData*)getBuffer:(NSString*)path;

@end
