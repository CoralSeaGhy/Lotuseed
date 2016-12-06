//
//  UIViewController+AutomaticEvents.m
//  Lotuseed
//
//  Created by beyond on 16/7/14.
//
//

#import "UIViewController+AutomaticEvents.h"
#import "LSDMonitoring.h"
#import "Lotuseed.h"
#import "LSDSizzle.h"


@implementation UIViewController (AutomaticEvents)

- (void)LSD_viewDidAppear:(BOOL)animated {
    
    //摇一摇
    if ([Lotuseed debugMode]) {
        [[LSDMonitoring shareInstance] methodSwizzle:self withSELOriginal:@selector(motionEnded:withEvent:) andSELSwizzle:@selector(LSD_motionEnded:withEvent:)];
    }
    //发送显示界面信息
//    UIViewController *controller = [self getCurrentVC];
//    if ([controller isKindOfClass:[UITabBarController class]]) {
//        //如果tabbar当前的控制器是UINavigationController 则选择Navi当前显示的控制器
//        if ([[(UITabBarController *)controller selectedViewController] isKindOfClass:[UINavigationController class]]) {
//            UIViewController *visibleController = [(UINavigationController *)[(UITabBarController *)controller selectedViewController] visibleViewController];
//            
//            if ([visibleController presentedViewController]) {
//                visibleController = [visibleController presentedViewController];
//            }
//            
//            if ([NSStringFromClass([visibleController class]) isEqualToString:NSStringFromClass([self class])]) {
//                
//                //交换当前controller方法实现之前 先恢复之前改动的controller。
//                [self resetMethodImp];
//                
//                if ([visibleController isKindOfClass:[UIPageViewController class]]) {
//                    
//                    for (UIViewController *con in [(UIPageViewController *)visibleController viewControllers]) {
//                        if ([con respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
//                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearEventNotification" object:nil userInfo:@{@"viewController":con}];
//                        }
//                        if ([con respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
//                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearCollectionEventNotification" object:nil userInfo:@{@"viewController":con}];
//                        }
//                        
//                        [LSDMonitoring shareInstance].methodSwizzleController = con;
//                        [LSDMonitoring shareInstance].firstVC = con;
//                        //发送显示界面信息
//                        [Lotuseed onPageViewBegin:NSStringFromClass([con class])];
//                    }
//                } else {
//                    //如果有tableView 发送通知交换方法实现
//                    if ([visibleController respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearEventNotification" object:nil userInfo:@{@"viewController":visibleController}];
//                    }
//                    if ([visibleController respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearCollectionEventNotification" object:nil userInfo:@{@"viewController":visibleController}];
//                    }
//                    
//                    [LSDMonitoring shareInstance].methodSwizzleController = visibleController;
//                    [LSDMonitoring shareInstance].firstVC = visibleController;
//                    //发送显示界面信息
//                    [Lotuseed onPageViewBegin:NSStringFromClass([visibleController class])];
//                }
//                
//                
//            }
//            
//        } else {
//            UIViewController *currentCon = [(UITabBarController *)controller selectedViewController];
//            
//            if ([NSStringFromClass([currentCon class]) isEqualToString:NSStringFromClass([self class])]) {
//                
//                //交换当前controller方法实现之前 先恢复之前改动的controller。
//                [self resetMethodImp];
//                
//                if ([currentCon isKindOfClass:[UIPageViewController class]]) {
//                    
//                    for (UIViewController *con in [(UIPageViewController *)currentCon viewControllers]) {
//                        if ([con respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
//                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearEventNotification" object:nil userInfo:@{@"viewController":con}];
//                        }
//                        if ([con respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
//                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearCollectionEventNotification" object:nil userInfo:@{@"viewController":con}];
//                        }
//                        
//                        [LSDMonitoring shareInstance].methodSwizzleController = con;
//                        [LSDMonitoring shareInstance].firstVC = con;
//                        //发送显示界面信息
//                        [Lotuseed onPageViewBegin:NSStringFromClass([con class])];
//                    }
//                } else {
//                    //如果有tableView 发送通知交换方法实现
//                    if ([currentCon respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearEventNotification" object:nil userInfo:@{@"viewController":currentCon}];
//                    }
//                    if ([currentCon respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearCollectionEventNotification" object:nil userInfo:@{@"viewController":currentCon}];
//                    }
//                    
//                    [LSDMonitoring shareInstance].methodSwizzleController = currentCon;
//                    [LSDMonitoring shareInstance].firstVC = currentCon;
//                    //发送显示界面信息
//                    [Lotuseed onPageViewBegin:NSStringFromClass([currentCon class])];
//                }
//                
//                
//            }
//            
//        }
//    } else {
//        if ([NSStringFromClass([controller class]) isEqualToString:NSStringFromClass([self class])]) {
//            //交换当前controller方法实现之前 先恢复之前改动的controller。
//            [self resetMethodImp];
//            
//            if ([self isKindOfClass:[UIPageViewController class]]) {
//                
//                for (UIViewController *con in [(UIPageViewController *)self viewControllers]) {
//                    if ([con respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearEventNotification" object:nil userInfo:@{@"viewController":con}];
//                    }
//                    if ([con respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearCollectionEventNotification" object:nil userInfo:@{@"viewController":con}];
//                    }
//                    
//                    [LSDMonitoring shareInstance].methodSwizzleController = con;
//                    [LSDMonitoring shareInstance].firstVC = con;
//                    //发送显示界面信息
//                    [Lotuseed onPageViewBegin:NSStringFromClass([con class])];
//                }
//            } else {
//                //如果有tableView 发送通知交换方法实现
//                if ([self respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearEventNotification" object:nil userInfo:@{@"viewController":self}];
//                }
//                if ([self respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearCollectionEventNotification" object:nil userInfo:@{@"viewController":self}];
//                }
//                
//                [LSDMonitoring shareInstance].methodSwizzleController = self;
//                [LSDMonitoring shareInstance].firstVC = self;
//                //发送显示界面信息
//                [Lotuseed onPageViewBegin:NSStringFromClass([self class])];
//            }
//        }
//    }
    
    //交换当前controller方法实现之前 先恢复之前改动的controller。
    [self resetMethodImp];
    //不过滤 将所有显示的界面都交换方法实现。
    if ([self isKindOfClass:[UIPageViewController class]]) {
        
        for (UIViewController *con in [(UIPageViewController *)self viewControllers]) {
            if ([con respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearEventNotification" object:nil userInfo:@{@"viewController":con}];
            }
            if ([con respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearCollectionEventNotification" object:nil userInfo:@{@"viewController":con}];
            }
            //存储改动的controller 用来在改动别的controller时恢复改动
            [LSDMonitoring shareInstance].methodSwizzleController = con;
            [LSDMonitoring shareInstance].firstVC = con;
            //发送显示界面信息
            [Lotuseed onPageViewBegin:NSStringFromClass([con class])];
        }
    } else {
        //如果有tableView 发送通知交换方法实现
        if ([self respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearEventNotification" object:nil userInfo:@{@"viewController":self}];
        }
        if ([self respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearCollectionEventNotification" object:nil userInfo:@{@"viewController":self}];
        }
        
        [LSDMonitoring shareInstance].methodSwizzleController = self;
        [LSDMonitoring shareInstance].firstVC = self;
        //发送显示界面信息
        [Lotuseed onPageViewBegin:NSStringFromClass([self class])];
    }
    
    [self LSD_viewDidAppear:animated];
}

//恢复之前改动的controller中的方法实现
- (void)resetMethodImp {
    
    //如果有tableView 发送通知交换方法实现
    if ([[LSDMonitoring shareInstance].methodSwizzleController respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearEventNotification" object:nil userInfo:@{@"viewController":[LSDMonitoring shareInstance].methodSwizzleController}];
    }
    if ([[LSDMonitoring shareInstance].methodSwizzleController respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearCollectionEventNotification" object:nil userInfo:@{@"viewController":[LSDMonitoring shareInstance].methodSwizzleController}];
    }
    
}

- (void)LSD_viewDidDisAppear:(BOOL)animated {
    
    //摇一摇
    if ([Lotuseed debugMode]) {
        [[LSDMonitoring shareInstance] methodSwizzle:self withSELOriginal:@selector(motionEnded:withEvent:) andSELSwizzle:@selector(LSD_motionEnded:withEvent:)];
    }
    //发送消失界面信息
    [Lotuseed onPageViewEnd:NSStringFromClass([self class])];
    [self LSD_viewDidDisAppear:animated];
    
}

//设置将要出现的界面
- (void)LSD_viewWillAppear:(BOOL)animated {
    
    if ([self isKindOfClass:[UITabBarController class]]) {
        [LSDMonitoring shareInstance].tabbarChildControllers = [(UITabBarController *)self viewControllers];
        [self LSD_viewWillAppear:animated];
        return;
    }
    
    if ([NSStringFromClass([self class]) isEqualToString:@"UIInputWindowController"]) {
        [LSDMonitoring shareInstance].lastVC = self;
        [self LSD_viewWillAppear:animated];
        return;
    }
    
    if (![LSDMonitoring shareInstance].lastVC) {
        [self LSD_viewWillAppear:animated];
        return;
    }
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        if ([LSDMonitoring shareInstance].isSelectLastVC) {
            [LSDMonitoring shareInstance].lastVC = [(UINavigationController *)self visibleViewController];
        }
    } else if ([[LSDMonitoring shareInstance].tabbarChildControllers containsObject:self]) {
        if ([LSDMonitoring shareInstance].isSelectLastVC) {
            [LSDMonitoring shareInstance].lastVC = self;
        }
    }
    
    [self LSD_viewWillAppear:animated];
    
}


- (void)LSDtableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [[LSDMonitoring shareInstance] onEvent:[LSDMonitoring getControlPath:cell withController:self andIndexPath:indexPath] label:[NSString stringWithFormat:@"tableViewController:%@  indexPath:%ld, %ld", NSStringFromClass([self class]), (long)indexPath.section , (long)indexPath.row]];
    
    [self LSDtableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)LSDcollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [[LSDMonitoring shareInstance] onEvent:[LSDMonitoring getControlPath:cell withController:self andIndexPath:indexPath] label:[NSString stringWithFormat:@"collectionViewController:%@  indexPath:%ld, %ld", NSStringFromClass([self class]), (long)indexPath.section , (long)indexPath.row]];
    [self LSDcollectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

//获取当前显示的控制器
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([self getPresentedViewController] == nil) {
        if ([nextResponder isKindOfClass:[UIViewController class]])
            result = nextResponder;
        else
            result = window.rootViewController;
    } else {
        result = [self getPresentedViewController];
    }
    return result;
}

//获取当前屏幕中present出来的viewcontroller
- (UIViewController *)getPresentedViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    if (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    return topVC;
}

@end
