//
//  LSDHistoryFeedBackViewController.m
//  Lotuseed
//
//  Created by apple on 16/9/13.
//
//
#ifdef LOTUSEED_FEED

#import "LSDHistoryFeedBackViewController.h"
#import "LSDFeedBackViewController.h"
#import "LSDHistoryFeedBackCell.h"
#import "LSDHistoryReplyCell.h"
#import "LSDFeedBackVO.h"
#import "LotuseedInternal.h"
#import "LSDFeedBackDetailController.h"

#define KScreenWid [UIScreen mainScreen].bounds.size.width
#define KScreenHei [UIScreen mainScreen].bounds.size.height

@implementation LSDHistoryFeedBackViewController

{
    NSMutableArray  *_data;
//    LSDFeedBackInputView    *_inputView;
    BOOL        _ifCream;
//    UIImageView *_showImgView;
    UIImage     *_selectImg;
    NSData      *_selectData;
    NSString    *_timeStr;
    UITextView  *_TV;
    UIButton    *_addBtn;
    BOOL        *_ifCustom;//判断是否是用户滑动 如果是键盘回收，如果不是键盘不变化
    BOOL        *_ifTBShow;
    BOOL        *_ifBarHidden;
    BOOL        *_ifScrollToBottom;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadNews];
    //监听键盘
    _ifCustom = YES;
    _ifTBShow = NO;
    _ifScrollToBottom = NO;
    //注册通知刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedbackSuccessed) name:@"UpDateFeedBack" object:nil];
    _data = [NSMutableArray arrayWithCapacity:0];
}

- (void)feedbackSuccessed {
    _ifScrollToBottom = YES;
    [self loadNews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _ifTBShow = NO;
}

+ (void)presentFeedBackControllerWithController:(UIViewController *)controller {
    LSDHistoryFeedBackViewController *feedBack = [[LSDHistoryFeedBackViewController alloc] init];
    feedBack.ifPresent = YES;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:feedBack];
    [controller presentViewController:navi animated:YES completion:nil];
}

- (void)loadNews {
    
    _ifBarHidden = self.navigationController.navigationBar.hidden;
    self.navigationController.navigationBar.hidden = YES;
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWid, 64)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake(0, 22, 60, 40);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
    UIButton *upDateBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    upDateBtn.frame = CGRectMake(KScreenWid - 60, 22, 60, 40);
    [upDateBtn setTitle:@"刷新" forState:UIControlStateNormal];
    [upDateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [upDateBtn addTarget:self action:@selector(loadNews) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:upDateBtn];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWid / 2.0 - 50, 22, 100, 40)];
    titleLbl.text = @"反馈历史";
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.textColor = [UIColor blackColor];
    titleLbl.font = [UIFont systemFontOfSize:18];
    [topView addSubview:titleLbl];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 63.5, KScreenWid, 0.5)];
    lineView.backgroundColor = [UIColor colorWithRed:190 / 255.0 green:190 / 255.0 blue:190 / 255.0 alpha:1.0];
    [topView addSubview:lineView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, KScreenWid, KScreenHei - 104) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    UIButton *feedBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    feedBtn.frame = CGRectMake(0, KScreenHei - 40, KScreenWid, 40);
    feedBtn.backgroundColor = [UIColor colorWithRed:52 / 255.0 green:133 / 255.0 blue:216 / 255.0 alpha:1.0];
    [feedBtn addTarget:self action:@selector(push) forControlEvents:UIControlEventTouchUpInside];
    [feedBtn setTitle:@"我要反馈" forState:UIControlStateNormal];
    [feedBtn setTintColor:[UIColor whiteColor]];
    [self.view addSubview:feedBtn];
    
    //输入框
//    _inputView = [[LSDFeedBackInputView alloc] initWithFrame:CGRectMake(0, KScreenHei - 40, KScreenWid, 40)];
//    _inputView.delegate = self;
//    [self.view addSubview:_inputView];
    
    //图片展示
//    _showImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _inputView.frame.origin.y - 80, 80, 80)];
//    _showImgView.contentMode = UIViewContentModeScaleToFill;
//    _showImgView.hidden = YES;
//    [self.view addSubview:_showImgView];
    
    [self loadData];
}

- (void)popSelf {
    self.navigationController.navigationBar.hidden = _ifBarHidden;
    if (self.ifPresent) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)loadData {
    
    NSString *time = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    [LotuseedInternal postFeedBackImmedialtely:NO withLastTime:time withID:0 withTarget:self withSelect:@selector(updateNews:)];
    
}

- (void)updateNews:(NSDictionary *)info {
    NSArray *dataArr = [info objectForKey:@"msg"];
    
    //反馈回复数据
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    //得到完整的文件名
    NSString *filename=[plistPath1 stringByAppendingPathComponent:@"historyFeed.plist"];
    //创建文件
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createFileAtPath:filename contents:nil attributes:nil];
    //写入文件
    //将原数据后加上请求的新数据再写入文件
    [dataArr writeToFile:filename atomically:NO];
    
    //反馈数据
    NSArray *feedPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *feedPlistPath1 = [feedPaths objectAtIndex:0];
    //得到完整的文件名
    NSString *feedFileName = [feedPlistPath1 stringByAppendingPathComponent:@"feedBack.plist"];
    NSArray *feedBackArr = [LSDFeedBackVO LSDFeedBackVOListWithArray:[NSArray arrayWithContentsOfFile:feedFileName]];
    [_data removeAllObjects];
    [_data addObjectsFromArray:[LSDFeedBackVO LSDFeedBackVOListWithArray:dataArr reply:YES]];
    
    //将反馈数据和回复数据 根据时间戳混合排序
    [_data addObjectsFromArray:feedBackArr];
    if (_data.count > 1) {
        for (int i = 0; i < _data.count - 1; i++) {
            for (int j = 0; j < _data.count - i - 1; j++) {
                LSDFeedBackVO *vo1 = _data[j];
                LSDFeedBackVO *vo2 = _data[j + 1];
                if (vo1.revertTime > vo2.revertTime) {
                    [_data exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
                }
            }
        }
    }
    _ifTBShow = YES;
    [self.tableView reloadData];
    if (_ifScrollToBottom) {
        if (self.tableView.contentSize.height > self.tableView.bounds.size.height) {
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height) animated:YES];
        }
    }
}

//我要反馈
- (void)push {
    LSDFeedBackViewController *controller = [[LSDFeedBackViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_ifTBShow) {
        return _data.count;
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSDFeedBackVO *vo = _data[indexPath.row];
    if (vo.isReply) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reply"];
        if (!cell) {
            cell = [[LSDHistoryReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reply"];
        }
        [(LSDHistoryReplyCell *)cell setFeedBackVO:vo];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    } else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"feed"];
        if (!cell) {
            cell = [[LSDHistoryFeedBackCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"feed"];
        }
        [(LSDHistoryFeedBackCell *)cell setFeedBackVO:vo];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100 + 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LSDFeedBackVO *vo = _data[indexPath.row];
    LSDFeedBackDetailController *controller = [[LSDFeedBackDetailController alloc] initWithVO:vo];
    [self.navigationController pushViewController:controller animated:YES];
}


//发送反馈请求成功回调
- (void)requestResult:(NSDictionary *)info {
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *filename = [plistPath1 stringByAppendingPathComponent:@"feedBack.plist"];
    NSMutableArray *feedBackArr = [NSMutableArray arrayWithArray:[NSArray arrayWithContentsOfFile:filename]];
    
    if (!feedBackArr || feedBackArr.count == 0) {
        //创建文件
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm createFileAtPath:filename contents:nil attributes:nil];
    }
    
    if (_selectData != nil) {
        //得到完整的文件名
        NSString *filename = [plistPath1 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", _timeStr]];
        //取最后/后面的文件名
        NSArray *strArr = [filename componentsSeparatedByString:@"/"];
        NSString *str = [strArr lastObject];
        
        //创建文件
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm createFileAtPath:filename contents:nil attributes:nil];
        
        [_selectData writeToFile:filename atomically:NO];
        
        NSDictionary *feedBackData = @{@"m":_TV.text, @"imageFileName":str, @"tm":_timeStr, @"postContact":@""};
        [feedBackArr addObject:feedBackData];
    } else {
        NSDictionary *feedBackData = @{@"m":_TV.text, @"imageFileName":@"", @"tm":_timeStr, @"postContact":@""};
        [feedBackArr addObject:feedBackData];
    }
    
    [feedBackArr writeToFile:filename atomically:NO];
    _TV.text = @"";
    [_TV endEditing:YES];
    //将图片btn还原。
    [_addBtn setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    _addBtn.layer.borderWidth = 1.0;
    _addBtn.layer.cornerRadius = 15.0;
    
    //反馈成功后，刷新数据
    [self loadData];
}



@end
#endif