//
//  UIApplication+Swizzle.m
//  Lotuseed
//
//  Created by beyond on 16/7/11.
//
//

#import "UIApplication+Swizzle.h"
#import "LSDMonitoring.h"
#import <objc/runtime.h>

static const void *eventDelegateKey = @"eventDelegateKey";

@implementation UIApplication (AutomaticEvents)

@dynamic eventDelegate;

- (id<UIApplicationAutomaticEventsDelegate>)eventDelegate {
    return objc_getAssociatedObject(self, eventDelegateKey);
}

- (void)setEventDelegate:(id<UIApplicationAutomaticEventsDelegate>)eventDelegate {
    objc_setAssociatedObject(self, eventDelegateKey, eventDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)LSD_sendAction:(SEL)action
                    to:(nullable id)to
                  from:(nullable id)from
              forEvent:(nullable UIEvent *)event
{
    //拦截点击事件后将信息上传
    if (self.eventDelegate && [self.eventDelegate respondsToSelector:@selector(touchEventTo:from:select:)]) {
        if ([to isKindOfClass:[UITabBarController class]]) {
            [LSDMonitoring shareInstance].isSelectLastVC = YES;
        }
        //延迟0.5秒执行，是为了让这个方法在viewWillAppear之后执行 让lastVC存储要显示的Controller
        dispatch_time_t delayInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC); dispatch_after(delayInNanoSeconds, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.eventDelegate touchEventTo:to from:from select:NSStringFromSelector(action)];
        });
    }
    return [self LSD_sendAction:action to:to from:from forEvent:event];
}

@end
