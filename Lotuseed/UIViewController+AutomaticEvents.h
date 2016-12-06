//
//  UIViewController+AutomaticEvents.h
//  Lotuseed
//
//  Created by beyond on 16/7/14.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (AutomaticEvents)

- (void)LSDtableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)LSDcollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

//当用户从一个页面转向下一个或者前一个页面,或者当用户开始从一个页面转向另一个页面的途中后悔 了,并撤销返回到了之前的页面时,将会调用这个方法。假如成功跳转到另一个页面时,transitionCompleted 会被置成 YES,假如在跳转途中取消了跳转这个动作将会被置成 NO。
//- (void)LSDpageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished
//      previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed;
//
//- (void)LSDsetViewControllers:(nullable NSArray<UIViewController *> *)viewControllers direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion;

- (void)LSD_viewDidAppear:(BOOL)animated;

- (void)LSD_viewDidDisAppear:(BOOL)animated;

- (void)LSD_viewWillAppear:(BOOL)animated;

@end
