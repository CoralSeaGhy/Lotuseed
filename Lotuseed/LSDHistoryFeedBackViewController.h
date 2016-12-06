//
//  LSDHistoryFeedBackViewController.h
//  Lotuseed
//
//  Created by apple on 16/9/13.
//
//
#ifdef LOTUSEED_FEED
#import <UIKit/UIKit.h>

@interface LSDHistoryFeedBackViewController : UIViewController
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, assign) BOOL        ifPresent;

+ (void)presentFeedBackControllerWithController:(UIViewController *)controller;

@end
#endif
