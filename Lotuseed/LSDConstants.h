//
//  LSDConstants.h
//  Lotuseed
//
//  Created by beyond on 12-5-29.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#ifndef Tabster_Constants_h
#define Tabster_Constants_h

#define JAILBROKEN_VERSION 0   //是否越狱版

#define DEBUG_MODE_DEFAULT NO  //默认调试模式
#define SDK_TYPE           2     //1-android 2-appleios 3-winphone 4-blackberry
#define SDK_BASE_VERSION   @"2.0.6"

#ifdef LOTUSEED_TRACK
#define SDK_VERSION        SDK_BASE_VERSION".19"
#else
#define SDK_VERSION        SDK_BASE_VERSION
#endif

/**
 * 以下数据需要拆分伪装处理
 */
#define SDK_MOD5_KEY  "j(3efj@u%$"  //MD5校验密码

#define AUTO_HOST_SERVER    @"md.lotuseed.com"          //无埋点配置服务器域名
#define AUTO_HOST_PORT      8283                     //无埋点配置服务器端口
#define AUTO_HOST_URLPATH   @"/"                     //无埋点配置服务器访问路径

#define GATHER_HOST_SERVER   @"gather.lotuseed.com"  //数据采集服务器域名
#define GATHER_HOST_PORT     4443                      //数据采集服务器端口
#define GATHER_HOST_URLPATH  @"/"                    //数据采集服务器访问路径

#define ONLINE_HOST_SERVER   @"online.lotuseed.com"  //实时交易服务器域名
//#define ONLINE_HOST_SERVER   @"192.168.1.9"
#define ONLINE_HOST_PORT     4443                      //实时交易服务器端口
//#define ONLINE_HOST_PORT     2080
#define ONLINE_HOST_URLPATH  @"/"                    //实时交易访服务器问路径

#define NET_CON_TIMEOUT     60                //连接超时设置，单位：秒 (说明：iOS3.0后，setHTTPBody后会导致timeout失效，默认最小值是240s ?)
#define NET_COMPRESS_DATA   YES               //HTTP压缩标志
#define NET_POST_GZIPSIZE   100               //超出该值则GZIP压缩
#define NET_RECV_BUFSIZE    4096              //HTTP接收缓冲大小
#define NET_DEFAULT_USERAGENT     @"Mozilla/5.0(iOS)"    //默认WAP代理用User-Agent
#define NET_REACHABILITY_HOSTNAME @"www.baidu.com" //reachability网络测试服务器

#define SDK_APPEKY_LABEL    @"LOTUSEED_APPKEY"       //App Key Label
#define SDK_CHANNEL_LABEL   @"LOTUSEED_CHANNEL"      //Channel Label

#define SDK_LOG_TAG         @"Lotuseed"      //日志标识
#define SDK_CAN_USE_LCT     YES              //允许使用Java Local信息
#define SDK_CAN_GET_LOC     YES              //允许获取位置信息

#define NETWORK_TYPE_WIFI   @"wifi"          //WIFI标识
#define NETWORK_TYPE_WWAN   @"wwan"          //WWAN标识
#define NETWORK_TYPE_2G     @"2G"
#define NETWORK_TYPE_3G     @"3G"
#define NETWORK_TYPE_4G     @"4G"

#define CONTINUE_SESSION_SECONDS   10        //超出该值则SID重置，单位：秒

#define VALUE_UNKNOWN       @"Unknown" 

#define DEVID_IMEI          @"I"         //IMEI
#define DEVID_MAC           @"M"         //MAC
#define DEVID_ANDROID_ID    @"A"         //ANDROID_ID
#define DEVID_UUID          @"U"         //UUID
#define DEVID_OPENUDID      @"O"         //OpenUDID
#define DEVID_SECUREUDID    @"S"         //SecureUDID
#define DEVID_IDFA          @"D"         //IDFA(identifierForAdvertising)
#define DEVID_IDFV          @"V"         //IDFV(identifierForVendor)

#define POST_DATA_MAX_CACHE_SIZE   409600L            //本地缓存文件最大字节数，超出后不再缓存
#define POST_DATA_ALERT_CACHE_SIZE   4096L            //本地缓存文件报警字节数，超出后尝试上传
#define POST_DATA_CACHE_FILE_SESSION   @"lotuseed.s"  //本地缓存文件名：事件

///**
// * FILE: lotuseed_extinfo
// * MODE: SharedPreferences
// * KEY: devid   str 已采集到的设备串号
// *      paramver int 在线参数版本号
// *      paramupd long 最近一次在线参数配置更新时间
// *      realtime boolean 是否实时发送统计数据
// *      replaced boolean app覆盖更新标志
// */
//#define LOTUSEED_GLOBAL_CONFIG_FILE   @"lotuseed_extinfo" 
#define   ONLINE_CONFIG_UPDATE_INTERVAL   3600000L    //1000*60*60=1小时，在线参数尝试更新最小时间间隔
#define   APPLICATION_UPDATE_INTERVAL     3600000L    //1000*60*60=1小时, 默认自动尝试更新周期

/**
 * FILE: lotuseed_config
 * MODE: JSONArray
 */
#define LOTUSEED_ONLINE_CONFIG_FILE   @"lotuseed_config"

// 脱机交易(0001-1000)
#define MESSAGE_ID_START_SESSION   1             //Start Session
#define MESSAGE_ID_POST_EVENT      2             //Post EventHandler
#define MESSAGE_ID_GET_DEVINFO     3             //设备信息采集
#define MESSAGE_ID_GET_EXTINFO     4             //附加信息采集
// 实时交易(1001-2000)
#define MESSAGE_ID_ONLINE_CONFIG   1005          //在线参数配置
#define MESSAGE_ID_APP_UPDATE      1006          //应用在线更新
#define MESSAGE_ID_POST_FEEDBACK   1007          //提交反馈信息
#define MESSAGE_ID_FEEDBACK_REVERT 1008          //获取回复信息
#define MESSAGE_ID_LOCATION_QUERY  1009          //位置查询

#define MESSAGE_RET_OK             0             //成功
#define MESSAGE_RET_URL_INVALID    1001          //包括校验码错
#define MESSAGE_RET_DATA_MISSING   1002          //POST数据空
#define MESSAGE_RET_DATA_INVALID   1003          //无效数据
#define MESSAGE_RET_BLOCKED        9998          //服务端拒绝服务
#define MESSAGE_RET_UNKNOWN_ERROR  9999          //未知错误

#define EVENT_TYPE_LIFECYCLE   0                 //内部定义生命周期管理事件
#define EVENT_TYPE_LOG         1                 //内部定义日志事件
#define EVENT_TYPE_AUTO        8                 //程序自动埋点事件
#define EVENT_TYPE_CUSTOM      9                 //用户自定义事件

#define EVENT_TYPE_CUSTOM_KV_SEPARATOR @"\01"    //用户自定义事件K-V分隔符 fixbug:"\0" --> "\01"
#define EVENT_GROUP_KEY        @"^ug"            //用户自定义事件分组ID

#define EVENT_ID_ONCREATE      @"C"              //onCreate
#define EVENT_ID_ONDESTROY     @"D"              //onDestroy
#define EVENT_ID_ONRESUME      @"R"              //onResume
#define EVENT_ID_ONPAUSE       @"P"              //onPause
#define EVENT_ID_ONENDSESSION  @"E"              //onEndSession

#define EVENT_ID_ONCRASHLOG    @"E"              //系统错误日志
#define EVENT_ID_ONCUSTOMLOG   @"C"              //用户自定义日志

#define DOWNLOAD_HTTP_USER_AGENT   "iOS"     //后台下载Http User-Agent

#define KEYCHAIN_ID            @"com.lotuseed.uuid"  //Keychain service & access group postfix

#define LOCATION_GET_INTERVAL  10000 //位置信息采集时间间隔,10s

// 动态扩展数据标记位：共支持8类(8Bit表示)
#define DYNAMIC_FLAG_ALL        0xFF   //全部打开
#define DYNAMIC_FLAG_FILELINE   0x80   //埋点信息追踪
#define DYNAMIC_FLAG_DEVICE     0x40   //设备信息追踪
#define DYNAMIC_FLAG_LOCATION   0x20   //位置信息追踪
#define DYNAMIC_FLAG_NETWORK    0x10   //联网信息追踪
#define DYNAMIC_FLAG_CUSTOM     0x08   //用户自定义数据

#endif
