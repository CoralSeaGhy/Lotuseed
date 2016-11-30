//
//  Lotuseed.h
//  Lotuseed
//
//  Created by beyond on 12-5-22.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Lotuseed : NSObject <UIAlertViewDelegate> {
    
}

#pragma mark basics

/**
 * 开启Lotuseed统计功能
 */
+ (void)initWithCustomData256:(NSString *)data; //可选，在startWithAppKey前调用，最长256字节。

+ (void)startWithAppKey:(NSString *)appKey;

+ (void)startWithAppKey:(NSString *)appKey channelID:(NSString *)cid;

+ (void)startWithAppKey:(NSString *)appKey channelID:(NSString *)cid appleID:(NSString*)aid;

/**
 * Lotuseed推送功能
 */
+ (void)registerDeviceToken:(NSString *)token; //向后台发送deviceToken

/**
 * 是否设置Lotuseed SDK为DEBUG模式
 * 默认为NO
 */
+ (void)setDebugMode:(BOOL)mode;
+ (BOOL)debugMode;

/**
 * 是否通过Lotuseed捕捉和提交错误日志
 * 默认为YES
 */
+ (void)setCrashReportEnabled:(BOOL)value;

/**
 * 设置Session非活动时长，单位：秒
 */
+ (void)setSessionContinueSeconds:(int)seconds;


/**
 * 跟踪记录PageView访问时长
 */
+ (void)onPageViewBegin:(NSString *)pageName;
+ (void)onPageViewEnd:(NSString *)pageName;

+ (void)onPV:(NSString *)pageName; //记录页面中的子页面访问

/**
 * 设置自定义事件动态扩展数据标记位
 * @param flag
 */
+ (void)setEventExtinfoFlag:(int)flag;

/**
 * 获取自定义事件动态扩展数据标记位
 * @return
 */
+ (int)getEventExtinfoFlag;

#pragma mark custom event

/**
 * 统计事件累计次数
 */
+ (void)onEvent:(NSString *)eventID;
+ (void)onEvent:(NSString *)eventID withCount:(long)count;
+ (void)onEvent:(NSString *)eventID label:(NSString *)label;
+ (void)onEvent:(NSString *)eventID label:(NSString *)label withCount:(long)count;
+ (void)onEvent:(NSString *)eventID attributes:(NSDictionary *)dic;
+ (void)onEvent:(NSString *)eventID attributes:(NSDictionary *)dic withCount:(long)count;

+ (void)onEvent:(NSString *)eventID postData:(BOOL)immediately;
+ (void)onEvent:(NSString *)eventID withCount:(long)count postData:(BOOL)immediately;
+ (void)onEvent:(NSString *)eventID label:(NSString *)label postData:(BOOL)immediately;
+ (void)onEvent:(NSString *)eventID label:(NSString *)label withCount:(long)count postData:(BOOL)immediately;
+ (void)onEvent:(NSString *)eventID attributes:(NSDictionary *)dic postData:(BOOL)immediately;
+ (void)onEvent:(NSString *)eventID attributes:(NSDictionary *)dic withCount:(long)count postData:(BOOL)immediately;

/**
 * 统计事件累计时长
 */
+ (void)onEvent:(NSString *)eventID withDuration:(long)duration;
+ (void)onEvent:(NSString *)eventID label:(NSString *)label withDuration:(long)duration;
+ (void)onEvent:(NSString *)eventID attributes:(NSDictionary *)dic withDuration:(long)duration;

+ (void)onEvent:(NSString *)eventID withDuration:(long)duration postData:(BOOL)immediately;
+ (void)onEvent:(NSString *)eventID label:(NSString *)label withDuration:(long)duration postData:(BOOL)immediately;
+ (void)onEvent:(NSString *)eventID attributes:(NSDictionary *)dic withDuration:(long)duration postData:(BOOL)immediately;

/**
 * 设置用户自定义事件分组
 */
+ (void)setEventGroup:(NSString *)property value:(NSString *)value;
+ (void)setEventGroup:(NSDictionary *)dic;

#pragma mark special event

/**
 * 记录特殊事件
 */
// 性别
typedef enum {
    kGenderUnknown = 0,     // 未知
    kGenderMale,            // 男
    kGenderFemale           // 女
} LSGAGender;

+ (void)onRegistration:(NSString*)accountId;
+ (void)onRegistration:(NSString*)accountId gender:(LSGAGender)gender age:(int)age;

+ (void)onLogin:(NSString*)accountId;
+ (void)onLogin:(NSString*)accountId type:(NSString*)accountType;
+ (void)onLogout:(NSString*)accountId;

+ (void)onOrder:(NSString*)accountId orderId:(NSString*)orderId amount:(double)number;

#pragma mark log report

/**
 * 记录自定义日志
 */
+ (void)onCustomLog:(NSString *)logmsg;

#pragma mark check update

/**
 * 应用版本更新
 */
+ (void)checkUpdate;
+ (void)checkUpdate:(NSString*)title updateButtonCaption:(NSString*)update cancelButtonCaption:(NSString*)cancel;
+ (void)checkUpdateWithDelegate:(id)delegate didFinishSelector:(SEL)selector;
+ (BOOL)isUpdating;

#pragma mark online config

/**
 * 在线参数配置
 */
+ (void)updateOnlineConfig;
+ (NSString *)getConfigParams:(NSString*)key withDefaultValue:(NSString *)value;

#pragma mark utils

/**
 * 强制提交缓存数据
 */
+ (void)forcePost;

/**
 * 获取设备唯一识别串
 */
+ (NSString*)getDeviceID;

#pragma mark exports

/**
 * 获取SD版本号
 * @return
 */
+ (NSString*) getSDKVersion;

/**
 * 获取设备标识串
 * @return
 */
+ (NSString*) exportDeviceID;

/**
 * 获取APPKEY
 * @return
 */
+ (NSString*) exportAppKey;

/**
 * 获取渠道编号
 * @return
 */
+ (NSString*) exportChannel;

/**
 * 获取APP版本号
 * @return
 */
+ (NSString*) getAppVersionCode;

/**
 * 获取APP版本名称
 * @return
 */
+ (NSString*) exportAppVersionName;

/**
 * 获取APP Bundle名称
 * @return
 */
+ (NSString*) exportAppBundleName;

/**
 * 获取IDFA
 */
+ (NSString*) exportIDFA;

/**
 * 获取IDFV
 */
+ (NSString*) exportIDFV;

/**
 * 获取运营商
 * @return
 */
+ (NSString*) exportCarrier;

/**
 * 获取当前网络类型
 *
 * @param context
 * @return
 */
+ (NSString*) exportNetworkType;

/**
 * 获取屏幕分辨率 hxw
 * @return
 */
+ (NSString*) exportDisplayMetrics;

/**
 * 判断是否越狱
 * @return
 */
+ (BOOL) isJailbroken;

/**
 * 获取设备品牌
 * @return
 */
+ (NSString*) exportDeviceBrand;

/**
 * 获取设备机型
 * @return
 */
+ (NSString*) exportDeviceModel;

/**
 * 获取系统总内存，单位Kb
 * 示例：MemTotal:          94096 kB
 *
 * @return
 */
+ (long) getMemorySize;

/**
 * 获取固件版本
 * @return
 */
+ (NSString*) exportFirmwareVersion;

#ifdef LOTUSEED_FEED
/**
 * 意见反馈 present
 * @return
 */
+ (void)showHistoryFeedBackControllerWithController:(UIViewController *)controller;

/**
 * 意见反馈 push
 * @return
 */
+ (UIViewController *)showHistoryFeedBackController;

/**
 * 意见反馈 获取是否有新的回复信息
 * @return
 */
+ (BOOL)ifHaveNewReply;
#endif
@end
