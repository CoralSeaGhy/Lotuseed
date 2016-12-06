//
//  LSDSizzle.m
//  Lotuseed
//
//  Created by beyond on 16/7/13.
//
//

#import "LSDSizzle.h"
#import <objc/runtime.h>

@implementation NSObject (LSDSwizzle)

+ (BOOL)LSD_swizzleMethod:(SEL)origSel withMethod:(SEL)altSel
{
    SEL originalSelector = origSel;
    SEL swizzleSelector = altSel;
    
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method swizzleMethod = class_getInstanceMethod(self, swizzleSelector);
    
    if (!originalMethod || !swizzleMethod) {
        return NO;
    }
    
    method_exchangeImplementations(originalMethod, swizzleMethod);
    return YES;
}

@end
