//
//  LSDMonitoring.m
//  Lotuseed
//
//  Created by 杨 on 16/3/28.
//
//

#ifdef LOTUSEED_AUTO

#import "LSDMonitoring.h"
#import "Lotuseed.h"
#import "LSDUtils.h"
#import "LotuseedInternal.h"
#import "LSDConstants.h"
#import "LSDPoster.h"
#import "LSDProfile.h"
#import "LSDUIDevice.h"
#import <AudioToolbox/AudioToolbox.h>

@interface zizi : UIViewController
- (void)zi;
@end

@implementation zizi

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)zi{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); //振动
    AudioServicesPlaySystemSound(1007); //声音
}
@end

@implementation LSDMonitoring

//1.1 实时配置握手消息
- (void)postConfigureDeviceInfo {
//    NSLog(@"postConfigureDeviceInfo");
    
    if (self.realtimeLooperQueue != nil) {
        [self.realtimeLooperQueue addOperationWithBlock:^{
            NSMutableDictionary *jsonDic = [[[NSMutableDictionary alloc] init] autorelease];
            [jsonDic setValue:[NSString stringWithFormat:@"%d", MESSAGE_ID_GET_DEVINFO] forKey:@"mid"];
            [jsonDic setValue:[Lotuseed getDeviceID] forKey:@"did"];
            [jsonDic setValue:[LSDProfile appKey] forKey:@"app"];
            NSString* idfa = [LSDProfile getIDFA];
            if (idfa) {
                [jsonDic setValue:idfa forKey:@"IDFA"];
            }
            NSString* idfv = [LSDProfile getIDFV];
            if (idfv) {
                [jsonDic setValue:idfv forKey:@"IDFV"];
            }
            LSDUIDevice *lsddev = [LSDUIDevice currentDevice];
            [jsonDic setValue:[lsddev platform] forKey:@"dm"];
            [jsonDic setValue:[lsddev hwmodel] forKey:@"hn"]; //机型，如k93ap
            UIDevice *dev = [UIDevice currentDevice];
            [jsonDic setValue:[dev systemVersion] forKey:@"fv"];  //固件版本
            
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            
            if (jsonData) {
                NSString *respMsg = [LSDPoster postData:jsonData messageID:MESSAGE_ID_GET_DEVINFO hostServer:AUTO_HOST_SERVER hostPort:AUTO_HOST_PORT urlPath:AUTO_HOST_URLPATH];
                NSLog(@"auto msg(3) ret: %@", respMsg);
            }
        }];
    }
}

//1.2 尝试实时发送配置数据
- (void)tryPostConfigureEvent: (NSString*)fullPath label:(NSString*)label {
//    NSLog(@"tryPostConfigureEvent");
    
    if (self.realtimeLooperQueue != nil) {
        [self.realtimeLooperQueue addOperationWithBlock:^{
            NSMutableDictionary *jsonDic = [[[NSMutableDictionary alloc] init] autorelease];
            [jsonDic setValue:[NSString stringWithFormat:@"%d", MESSAGE_ID_POST_EVENT] forKey:@"mid"];
            [jsonDic setValue:[Lotuseed getDeviceID] forKey:@"did"];
            [jsonDic setValue:[LSDProfile appKey] forKey:@"app"];
            [jsonDic setValue:[NSString stringWithFormat:@"%d", EVENT_TYPE_AUTO] forKey:@"et"];
            [jsonDic setValue:fullPath forKey:@"ei"];
            [jsonDic setValue:label forKey:@"el"];
            
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            
            if (jsonData) {
                NSString *respMsg = [LSDPoster postData:jsonData messageID:MESSAGE_ID_POST_EVENT hostServer:AUTO_HOST_SERVER hostPort:AUTO_HOST_PORT urlPath:AUTO_HOST_URLPATH];
                NSLog(@"auto msg(2) ret: %@", respMsg);
            }
        }];
    }
}

//2.1 发送统计日志
- (void) onEvent: (NSString*)eventID label:(NSString *)label
{
    //发送统计日志
    [self onEvent: eventID label:label internal:NO];
    
    //尝试实时发送配置数据
    [self tryPostConfigureEvent:eventID label:label];
}

//2.2 发送统计日志(内部私有)
- (void) onEvent: (NSString*)eventID label:(NSString *)label internal:(BOOL)flag
{
    if (flag == YES) {
        //只有私有隐式数据 isDuration&immediately 参数同时为 true!!!
        [LotuseedInternal postEvent:EVENT_TYPE_AUTO eventID:eventID eventLabel:label eventCount:1 isDuration:true forcePost:YES];
    }
    else {
        [LotuseedInternal postEvent:EVENT_TYPE_AUTO eventID:eventID eventLabel:label eventCount:1 isDuration:false forcePost:NO];
    }
}


#pragma mark 摇手机监测
- (void)LSD_motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    NSDate *now = [NSDate date];
    LSDLOG(@"shake:%f",[now timeIntervalSinceDate:sharedInstance.startTime]);
    sharedInstance.time += 1;
    if (sharedInstance.time == 5 && ([now timeIntervalSinceDate:sharedInstance.startTime] <= 30)) {
        sharedInstance.time = 0;
        LSDLOG(@"%@",@"shake successful");
        [sharedInstance methodSwizzle:sharedInstance.firstVC withSELOriginal:@selector(motionEnded:withEvent:) andSELSwizzle:@selector(LSD_motionEnded:withEvent:)];
        [sharedInstance.firstVC motionEnded:motion withEvent:event];
        [sharedInstance methodSwizzle:sharedInstance.firstVC withSELOriginal:@selector(motionEnded:withEvent:) andSELSwizzle:@selector(LSD_motionEnded:withEvent:)];
        
        //创建无埋点配置后台线程
        sharedInstance.realtimeLooperQueue = [[[NSOperationQueue alloc] init] autorelease];
        [sharedInstance.realtimeLooperQueue setMaxConcurrentOperationCount:1];
        
        //发送握手用的0003消息
        [sharedInstance postConfigureDeviceInfo];
        
        //振动提醒
        zizi *sound = [zizi new];
        [sound zi];
        
    }else if (sharedInstance.time >= 5 && ([now timeIntervalSinceDate:sharedInstance.startTime] > 30)){
        LSDLOG(@"%@",@"摇手机超时，请重启软件");
    }
}

- (void)methodSwizzle:(id)obj_Class withSELOriginal:(SEL)originalSEL andSELSwizzle:(SEL)swizzleSEL{
    Class class = [obj_Class class];
    if ([obj_Class respondsToSelector:originalSEL]) {
        SEL originalSelector = originalSEL;
        SEL swizzleSelector = swizzleSEL;
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzleMethod = class_getInstanceMethod(NSClassFromString(@"LSDMonitoring"), swizzleSelector);
        
        if (!originalMethod || !swizzleMethod) {
            return;
        }
        
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }
}

#pragma mark 自动添加监控

+ (void)viewControllerChanged{
    
    // Actions & Events
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //交换两个方法的实现，在触发点击方法时获取点击信息上传
        [UIApplication LSD_swizzleMethod:@selector(sendAction:to:from:forEvent:) withMethod:@selector(LSD_sendAction:to:from:forEvent:)];
        [UIApplication sharedApplication].eventDelegate = sharedInstance;
        [UIViewController LSD_swizzleMethod:@selector(viewDidAppear:) withMethod:@selector(LSD_viewDidAppear:)];
        [UIViewController LSD_swizzleMethod:@selector(viewDidDisappear:) withMethod:@selector(LSD_viewDidDisAppear:)];
        [UIViewController LSD_swizzleMethod:@selector(viewWillAppear:) withMethod:@selector(LSD_viewWillAppear:)];
        sharedInstance.startTime = [NSDate date];
    });
    
}


//NSNotification tableView的点击事件
- (void)setViewAppearTableViewDlegate:(NSNotification *)userInfo {
    UIViewController *controller = [userInfo.userInfo objectForKey:@"viewController"];
    
    SEL originalSelector = @selector(tableView:didSelectRowAtIndexPath:);
    SEL swizzleSelector = @selector(LSDtableView:didSelectRowAtIndexPath:);
    
    [sharedInstance exchangeImplementationsWith:controller andOriginalSel:originalSelector andSwizzleSel:swizzleSelector];
}

//NSNotification collectionView的点击事件
- (void)setViewAppearCollectionViewDlegate:(NSNotification *)userInfo {
    UIViewController *controller = [userInfo.userInfo objectForKey:@"viewController"];
    
    SEL originalSelector = @selector(collectionView:didSelectItemAtIndexPath:);
    SEL swizzleSelector = @selector(LSDcollectionView:didSelectItemAtIndexPath:);
    
    [sharedInstance exchangeImplementationsWith:controller andOriginalSel:originalSelector andSwizzleSel:swizzleSelector];
}


- (void)exchangeImplementationsWith:(UIViewController *)controller andOriginalSel:(SEL)originalSel andSwizzleSel:(SEL)swizzleSel {
    
    Method originalMethod = class_getInstanceMethod([controller class], originalSel);
    Method swizzleMethod = class_getInstanceMethod([controller class], swizzleSel);
    if (!originalMethod || !swizzleMethod) {
        return;
    }
    method_exchangeImplementations(originalMethod, swizzleMethod);
}

#pragma mark 获得唯一路径
+ (NSString *)getControlPath:(id)sender withController:(UIViewController *)controller {
    return [self getControlPath:sender withController:controller andIndexPath:nil];
}

+ (NSString *)getControlPath:(id)sender withController:(UIViewController *)controller andIndexPath:(NSIndexPath *)indexPath {
    //如果是第一次加载并且点击的是tabbar且是当前显示的界面 将lastVC存储的界面换位firstVC
    if ([NSStringFromClass([sharedInstance.lastVC class] ) isEqualToString:@"UIInputWindowController"]) {
        sharedInstance.lastVC = sharedInstance.firstVC;
    }
    
    NSString *senderPath;
    if (indexPath) {
        senderPath = [NSString stringWithFormat:@"%@-senction:%ld-row:%ld", [sender class], (long)indexPath.section, (long)indexPath.row];
    } else {
        NSInteger order = [[LSDMonitoring new] controlGetDistinctId:[sender superview] withCompareObj:sender];
        senderPath = [NSString stringWithFormat:@"%@%ld-%@", [sender class], (long)order, [[sender superview] class]];
    }
    
    if ([controller isKindOfClass:[UITabBarController class]]) {
        if (sharedInstance.isSelectLastVC) {
            senderPath = [NSString stringWithFormat:@"%@-%@",senderPath,[sharedInstance.lastVC class]];
        } else {
            senderPath = [NSString stringWithFormat:@"%@-%@",senderPath,[sharedInstance.firstVC class]];
        }
        sharedInstance.isSelectLastVC = NO;
    } else {
        senderPath = [NSString stringWithFormat:@"%@-%@",senderPath,[controller class]];
    }
    return senderPath;
}

- (NSInteger)controlGetDistinctId:(id)obj withCompareObj:(id)origin{
    NSMutableArray *controlArray = [NSMutableArray array];
    NSMutableArray *elementArray = [NSMutableArray array];
    
    [elementArray addObjectsFromArray:[obj subviews]];
    
    for (int i = 0; i<elementArray.count ; i++) {
        id control = elementArray[i];
        if ([control isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)control;
            NSNumber *x = [NSNumber numberWithDouble:label.frame.origin.x];
            NSNumber *y = [NSNumber numberWithDouble:label.frame.origin.y];
            NSNumber *width = [NSNumber numberWithDouble:label.frame.size.width];
            NSNumber *height = [NSNumber numberWithDouble:label.frame.size.height];
            [controlArray addObject:@{
                                      @"x":x,
                                      @"y":y,
                                      @"width":width,
                                      @"height":height,
                                      }];
        }else if ([control isKindOfClass:[UIButton class]]){
            UIButton *button = (UIButton *)control;
            NSNumber *x = [NSNumber numberWithDouble:button.frame.origin.x];
            NSNumber *y = [NSNumber numberWithDouble:button.frame.origin.y];
            NSNumber *width = [NSNumber numberWithDouble:button.frame.size.width];
            NSNumber *height = [NSNumber numberWithDouble:button.frame.size.height];
            [controlArray addObject:@{
                                      @"x":x,
                                      @"y":y,
                                      @"width":width,
                                      @"height":height,
                                      }];
            
        }else if ([control isKindOfClass:[UIView class]]){
            UIView *view = (UIView *)control;
            NSNumber *x = [NSNumber numberWithDouble:view.frame.origin.x];
            NSNumber *y = [NSNumber numberWithDouble:view.frame.origin.y];
            NSNumber *width = [NSNumber numberWithDouble:view.frame.size.width];
            NSNumber *height = [NSNumber numberWithDouble:view.frame.size.height];
            [controlArray addObject:@{
                                      @"x":x,
                                      @"y":y,
                                      @"width":width,
                                      @"height":height,
                                      }];
            
        }else if ([control isKindOfClass:[UITextField class]]){
            UITextField *textField = (UITextField *)control;
            NSNumber *x = [NSNumber numberWithDouble:textField.frame.origin.x];
            NSNumber *y = [NSNumber numberWithDouble:textField.frame.origin.y];
            NSNumber *width = [NSNumber numberWithDouble:textField.frame.size.width];
            NSNumber *height = [NSNumber numberWithDouble:textField.frame.size.height];
            [controlArray addObject:@{
                                      @"x":x,
                                      @"y":y,
                                      @"width":width,
                                      @"height":height,
                                      }];
            
        }
    }
    
    NSInteger index = [elementArray indexOfObject:origin];
    NSInteger order = 0;
    for (int i = 0; i<elementArray.count; i++) {
        if (i == index) {//排序顺序x,y,width,height
            continue;
        }
        if ([controlArray[i][@"x"] doubleValue] < [controlArray[index][@"x"] doubleValue]) {
            order ++;
        }
        else if ([controlArray[i][@"x"] doubleValue] > [controlArray[index][@"x"] doubleValue]){
            continue;
        }
        else{
            if ([controlArray[i][@"y"] doubleValue] < [controlArray[index][@"y"] doubleValue]) {
                order ++;
            }
            else if ([controlArray[i][@"y"] doubleValue] > [controlArray[index][@"y"] doubleValue]){
                continue;
            }else{
                if ([controlArray[i][@"width"] doubleValue] < [controlArray[index][@"width"] doubleValue]) {
                    order ++;
                }
                else if ([controlArray[i][@"width"] doubleValue] > [controlArray[index][@"width"] doubleValue]){
                    continue;
                }
                else{
                    if ([controlArray[i][@"height"] doubleValue] < [controlArray[index][@"height"] doubleValue]) {
                        order ++;
                    }else if ([controlArray[i][@"height"] doubleValue] >[controlArray[index][@"height"] doubleValue]){
                        continue;
                    }
                }
            }
        }
    }
    return order;
}

#pragma mark UIApplicationAutomaticEventsDelegate
//判断点击事件类型 上传对应信息
- (void)touchEventTo:(id)to from:(id)from select:(NSString *)select
{
    
    if ([from isKindOfClass:[UIStepper class]]) {
        UIStepper *step = (UIStepper *)from;
        NSString *name= [NSString stringWithFormat:@"%f",(float)step.value];
        [self onEvent:[LSDMonitoring getControlPath:from withController:to] label:name];
    } else if ([from isKindOfClass:[UISwitch class]]) {
        UISwitch *switchButton = (UISwitch *)from;
        
        BOOL on = switchButton.isOn;
        NSString *state;
        if (on == NO) {
            state = @"off";
        }else{
            state = @"on";
        }
        [self onEvent:[LSDMonitoring getControlPath:from withController:to] label:state];
    } else if ([from isKindOfClass:[UIButton class]]) {
        
        [self onEvent:[LSDMonitoring getControlPath:from withController:to] label:select];
        
    } else if ([from isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *button = (UISegmentedControl *)from;
        
        NSInteger index = button.selectedSegmentIndex;
        NSString *text = [button titleForSegmentAtIndex:index];
        
        NSString *name = [NSString stringWithFormat:@"index:%ld-text:%@",(long)index,text];
        
        if (name == nil) {
            name = @"";
        }
        [self onEvent:[LSDMonitoring getControlPath:from withController:to] label:name];
    } else if ([from isKindOfClass:[UITextField class]]) {
        
    }
    
}

#pragma mark 单例
static LSDMonitoring *sharedInstance = nil;

- (instancetype)initWithToken{
    if (self = [self init]) {}
    return self;
}

+ (LSDMonitoring *)sharedInstance{
    if (sharedInstance == nil) {
        LSDLOG(@"%@",@"warning sharedInstance called before sharedInstanceWithToken:");
    }
    return sharedInstance;
}

+ (LSDMonitoring *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc]init];
        sharedInstance.isSelectLastVC = NO;
        [[NSNotificationCenter defaultCenter ] addObserver:sharedInstance
                                                  selector:@selector(setViewAppearTableViewDlegate:)
                                                      name:@"ViewDidAppearEventNotification"
                                                    object:nil];
        [[NSNotificationCenter defaultCenter ] addObserver:sharedInstance
                                                  selector:@selector(setViewAppearCollectionViewDlegate:)
                                                      name:@"ViewDidAppearCollectionEventNotification"
                                                    object:nil];
        
    });
    return sharedInstance;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:sharedInstance name:@"ViewDidAppearEventNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:sharedInstance name:@"ViewDidAppearCollectionEventNotification" object:nil];
    [super dealloc];
}

@end

#endif
