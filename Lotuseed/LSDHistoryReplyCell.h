//
//  LSDHistoryReplyCell.h
//  Lotuseed
//
//  Created by apple on 16/10/10.
//
//
#ifdef LOTUSEED_FEED
#import <UIKit/UIKit.h>
#import "LSDFeedBackVO.h"

@interface LSDHistoryReplyCell : UITableViewCell

@property (nonatomic, retain) LSDFeedBackVO *feedBackVO;

@end
#endif