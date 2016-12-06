//
//  LSDHistoryFeedBackCell.m
//  Lotuseed
//
//  Created by apple on 16/9/13.
//
//
#ifdef LOTUSEED_FEED

#import "LSDHistoryFeedBackCell.h"
#import "UIImageView+WebCache.h"


#define KScreenWid  [UIScreen mainScreen].bounds.size.width

@implementation LSDHistoryFeedBackCell

{
    UIImageView     *_icon;
    UIImageView     *_img;
    UILabel         *_timeLbl;
    UILabel         *_contentLbl;
    UIImageView     *_bgView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _initSubViews];
    }
    return self;
}

- (void)_initSubViews
{
    
    _icon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 30, 60, 60)];
    _icon.contentMode = UIViewContentModeScaleToFill;
    _icon.image = [UIImage imageNamed:@"customer"];
    [self.contentView addSubview:_icon];
    
    _img = [[UIImageView alloc] initWithFrame:CGRectMake(90, 30, 60, 60)];
    _img.contentMode = UIViewContentModeScaleToFill;
    _img.hidden = YES;
    [self.contentView addSubview:_img];
    
    _timeLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, KScreenWid, 20)];
    _timeLbl.font = [UIFont systemFontOfSize:12];
    _timeLbl.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_timeLbl];
    
    _contentLbl = [[UILabel  alloc] init];
    _contentLbl.font = [UIFont systemFontOfSize:12];
    _contentLbl.numberOfLines = 1;
    [self.contentView addSubview:_contentLbl];
    
    _bgView = [[UIImageView alloc] init];
//    _bgView.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:240 / 255.0 blue:240 / 255.0 alpha:1.0];
    _bgView.layer.cornerRadius = 5;
    _bgView.clipsToBounds = YES;
    _bgView.image = [UIImage imageNamed:@"feed"];
    [self.contentView addSubview:_bgView];
    [self.contentView sendSubviewToBack:_bgView];
    
}

- (void)setFeedBackVO:(LSDFeedBackVO *)feedBackVO
{
    if (!feedBackVO) {
        return;
    }
    _feedBackVO = feedBackVO;
    
    if (feedBackVO.fileName && feedBackVO.fileName.length != 0) {
        
        _img.hidden = NO;
        [_img sd_setImageWithURL:[NSURL URLWithString:feedBackVO.fileName] placeholderImage:[UIImage imageNamed:@"add"]];
        _contentLbl.frame = CGRectMake(155, 30, KScreenWid - 165, 20);
        _bgView.frame = CGRectMake(70, 25, KScreenWid - 75, 70);
        
    } else if (feedBackVO.imgFM && feedBackVO.imgFM.length != 0 && ![feedBackVO.imgFM isEqualToString:@""]) {
        
        _img.hidden = NO;
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *plistPath1 = [paths objectAtIndex:0];
        //得到完整的文件名
        NSString *filename=[plistPath1 stringByAppendingPathComponent:feedBackVO.imgFM];
        NSData *imgData = [NSData dataWithContentsOfFile:filename];
        _img.image = [UIImage imageWithData:imgData];
        _contentLbl.frame = CGRectMake(155, 30, KScreenWid - 165, 20);
        _bgView.frame = CGRectMake(70, 25, KScreenWid - 75, 70);
        
    } else {
        
        _contentLbl.frame = CGRectMake(85, 30, KScreenWid - 90, 60);
        _bgView.frame = CGRectMake(70, 30, KScreenWid - 75, 70);
        
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:feedBackVO.revertTime];
    NSString *dateStr = [formatter stringFromDate:date];
    _timeLbl.text = dateStr;
    _contentLbl.text = feedBackVO.message;
    
}

- (void)prepareForReuse
{
    _img.hidden = YES;
}

@end
#endif