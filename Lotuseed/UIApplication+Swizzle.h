//
//  UIApplication+Swizzle.h
//  Lotuseed
//
//  Created by beyond on 16/7/11.
//
//

#import <UIKit/UIKit.h>

@protocol UIApplicationAutomaticEventsDelegate <NSObject>

@optional

- (void)touchEventTo:(nullable id)to from:(nullable id)from select:(NSString *)select;

@end

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (AutomaticEvents)

@property (nonatomic, assign) id <UIApplicationAutomaticEventsDelegate> eventDelegate;


- (BOOL)LSD_sendAction:(SEL)action
                   to:(nullable id)to
                 from:(nullable id)from
             forEvent:(nullable UIEvent *)event;

@end

NS_ASSUME_NONNULL_END
