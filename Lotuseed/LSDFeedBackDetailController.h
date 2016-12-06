//
//  LSDFeedBackDetailController.h
//  Lotuseed
//
//  Created by apple on 16/9/26.
//
//
#ifdef LOTUSEED_FEED

#import <UIKit/UIKit.h>
#import "LSDFeedBackVO.h"

@interface LSDFeedBackDetailController : UIViewController
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, retain) UITableView *tableView;

- (instancetype)initWithVO:(LSDFeedBackVO *)VO;

@end
#endif