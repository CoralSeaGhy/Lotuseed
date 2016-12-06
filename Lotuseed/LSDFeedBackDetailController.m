//
//  LSDFeedBackDetailController.m
//  Lotuseed
//
//  Created by apple on 16/9/26.
//
//
#ifdef LOTUSEED_FEED

#import "LSDFeedBackDetailController.h"
#import "LSDFeedBackViewController.h"
#import "LotuseedInternal.h"
#import "UIImageView+WebCache.h"

#define KScreenWid [UIScreen mainScreen].bounds.size.width
#define KScreenHei [UIScreen mainScreen].bounds.size.height

@interface LSDFeedBackDetailController ()

@end

@implementation LSDFeedBackDetailController

{
    LSDFeedBackVO   *_feedbackVO;
    UIView          *_headerView;
    UILabel         *_timeLbl;
    UIImageView     *_imgView;
    UILabel         *_msgLbl;
}

- (instancetype)initWithVO:(LSDFeedBackVO *)VO
{
    self = [super init];
    if (self) {
        _feedbackVO = VO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubViews];
}

- (void)initSubViews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWid, 64)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake(0, 22, 60, 40);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 63.5, KScreenWid, 0.5)];
    lineView.backgroundColor = [UIColor colorWithRed:190 / 255.0 green:190 / 255.0 blue:190 / 255.0 alpha:1.0];
    [topView addSubview:lineView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, KScreenWid, KScreenHei - 104) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    _headerView = [[UIView alloc] init];
    _headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_headerView];
    [self createTimeLbl];
    [self createMsgLbl];
    [self createImgView];
    if (_imgView.hidden) {
        _headerView.frame = CGRectMake(0, 0, KScreenWid, 40 + _msgLbl.frame.size.height + 10);
    } else {
        _headerView.frame = CGRectMake(0, 0, KScreenWid, 250 + _msgLbl.frame.size.height + 10);
    }
    self.tableView.tableHeaderView = _headerView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIButton *feedBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    feedBtn.frame = CGRectMake(0, KScreenHei - 40, KScreenWid, 40);
    feedBtn.backgroundColor = [UIColor colorWithRed:52 / 255.0 green:133 / 255.0 blue:216 / 255.0 alpha:1.0];
    [feedBtn addTarget:self action:@selector(push) forControlEvents:UIControlEventTouchUpInside];
    [feedBtn setTitle:@"我要反馈" forState:UIControlStateNormal];
    [feedBtn setTintColor:[UIColor whiteColor]];
    [self.view addSubview:feedBtn];
    
}

- (void)popSelf {
    [self.navigationController popViewControllerAnimated:YES];
}

//我要反馈
- (void)push {
    LSDFeedBackViewController *controller = [[LSDFeedBackViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)createTimeLbl {
    
    _timeLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KScreenWid - 5, 30)];
    _timeLbl.font = [UIFont systemFontOfSize:14];
    _timeLbl.textAlignment = NSTextAlignmentRight;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_feedbackVO.revertTime];
    NSString *dateStr = [formatter stringFromDate:date];
    _timeLbl.text = dateStr;
    [_headerView addSubview:_timeLbl];
}

- (void)createImgView {
    
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(KScreenWid / 2.0 - 100, 40 + _msgLbl.frame.size.height + 10, 200, 200)];
    _imgView.contentMode = UIViewContentModeScaleToFill;
    if (_feedbackVO.fileName && _feedbackVO.fileName.length != 0) {
        [_imgView sd_setImageWithURL:[NSURL URLWithString:_feedbackVO.fileName] placeholderImage:[UIImage imageNamed:@"add"]];
    } else if (_feedbackVO.imgFM && _feedbackVO.imgFM.length != 0 && ![_feedbackVO.imgFM isEqualToString:@""]) {
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *plistPath1 = [paths objectAtIndex:0];
        //得到完整的文件名
        NSString *filename=[plistPath1 stringByAppendingPathComponent:_feedbackVO.imgFM];
        NSData *imgData = [NSData dataWithContentsOfFile:filename];
        _imgView.image = [UIImage imageWithData:imgData];
    } else {
        _imgView.hidden = YES;
    }
    [_headerView addSubview:_imgView];
    
}

- (void)createMsgLbl {
    
    CGFloat hei = [_feedbackVO.message boundingRectWithSize:CGSizeMake(KScreenWid - 10, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]} context:nil].size.height;
    _msgLbl = [[UILabel alloc] init];
    _msgLbl.text = _feedbackVO.message;
    _msgLbl.numberOfLines = 0;
    _msgLbl.font = [UIFont systemFontOfSize:18];
    _msgLbl.textAlignment = NSTextAlignmentLeft;
    _msgLbl.frame = CGRectMake(5, 40, KScreenWid - 10, hei);
    
    [_headerView addSubview:_msgLbl];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
#endif