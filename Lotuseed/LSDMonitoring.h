//
//  LSDMonitoring.h
//  Lotuseed
//
//  Created by 杨 on 16/3/28.
//
//

#ifdef LOTUSEED_AUTO

#import <Foundation/Foundation.h>
#import "UIApplication+Swizzle.h"
#import "UIViewController+AutomaticEvents.h"
#import "LSDSizzle.h"
#import <objc/runtime.h>

@interface LSDMonitoring : NSObject <UIApplicationAutomaticEventsDelegate>

@property (nonatomic, strong)id lastVC;//跳转页面时将要显示的页面
@property (nonatomic, strong)id firstVC;//跳转页面时将要消失的页面
@property (nonatomic, strong)NSArray *pageViews; //手势结束后存储当前pageViewController的viewControllers
@property (nonatomic, strong) NSArray *tabbarChildControllers; //存储tabbar的子控制器
@property (nonatomic, assign) BOOL isSelectLastVC; //是否使用lastVC （传入点击事件的路径）
@property (nonatomic, strong)NSDate *startTime;//初始化时间
@property (nonatomic, assign)NSInteger time;//摇手机次数
@property (nonatomic, assign) BOOL  ifHaveNewReply;//反馈部分用到的 是否有新的回复信息
@property (nonatomic, strong)NSOperationQueue *realtimeLooperQueue;//无埋点配置后台线程
@property (nonatomic, strong)UIViewController *methodSwizzleController;//存储交换了方法实现的controller

+ (LSDMonitoring *)shareInstance;

+ (void)viewControllerChanged;

- (void) onEvent: (NSString*)eventID label:(NSString *)label;

+ (NSString *)getControlPath:(id)sender withController:(UIViewController *)controller;

+ (NSString *)getControlPath:(id)sender withController:(UIViewController *)controller andIndexPath:(NSIndexPath *)indexPath;

- (void)methodSwizzle:(id)obj_Class withSELOriginal:(SEL)originalSEL andSELSwizzle:(SEL)swizzleSEL;

@end

#endif