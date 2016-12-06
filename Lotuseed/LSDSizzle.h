//
//  LSDSizzle.h
//  Lotuseed
//
//  Created by beyond on 16/7/13.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (LSDSwizzle)

+ (BOOL)LSD_swizzleMethod:(SEL)origSel withMethod:(SEL)altSel;

@end
