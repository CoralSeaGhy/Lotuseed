//
//  LSDFeedBackViewController.m
//  Lotuseed
//
//  Created by apple on 16/9/13.
//
//
#ifdef LOTUSEED_FEED
#import "LSDFeedBackViewController.h"
#import "LotuseedInternal.h"
#import "Lotuseed.h"

#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height

@interface LSDFeedBackViewController ()

@end

@implementation LSDFeedBackViewController

{
    UITextView  *_feedBackTV;
    UILabel     *_placeholderLbl;
    UIButton    *_creamBtn;
    UIButton    *_addBtn;
    BOOL        _ifCream;
    UILabel     *_selectTypeLbl;
    UITableView *_contactTypeTB;
    UITextField *_contactTF;
    UIImage     *_selectImg;
    
    NSData      *_selectData;
    NSString    *_timeStr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubViews];
}

- (void)initSubViews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 64)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake(0, 22, 60, 40);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth / 2.0 - 50, 22, 100, 40)];
    title.text = @"意见反馈";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor blackColor];
    title.font = [UIFont systemFontOfSize:18];
    [topView addSubview:title];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 63.5, KScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor colorWithRed:190 / 255.0 green:190 / 255.0 blue:190 / 255.0 alpha:1.0];
    [topView addSubview:lineView];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 64 + 10, KScreenWidth - 5, 30)];
    titleLbl.font = [UIFont systemFontOfSize:14];
    titleLbl.text = @"您的意见:";
    [self.view addSubview:titleLbl];
    
    _feedBackTV = [[UITextView alloc] initWithFrame:CGRectMake(5, 64 + 45, KScreenWidth - 10, 150)];
    _feedBackTV.layer.borderColor = [UIColor colorWithRed:190 / 255.0 green:190 / 255.0 blue:190 / 255.0 alpha:1.0].CGColor;
    _feedBackTV.layer.borderWidth = 1.0;
    _feedBackTV.delegate = self;
    _feedBackTV.font = [UIFont systemFontOfSize:12];
    _feedBackTV.dataDetectorTypes = UIDataDetectorTypeAll;
    _feedBackTV.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_feedBackTV];
    
    NSString *place = @" 请输入您的宝贵意见和建议，以帮助我们更好的改进产品。(150字以内)";
    CGFloat hei = [place boundingRectWithSize:CGSizeMake(KScreenWidth - 10, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size.height;
    _placeholderLbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 64 + 45, KScreenWidth - 10, hei)];
    _placeholderLbl.font = [UIFont systemFontOfSize:12];
    _placeholderLbl.textColor = [UIColor colorWithRed:205 / 255.0 green:205 / 255.0 blue:205 / 255.0 alpha:1.0];
    _placeholderLbl.backgroundColor = [UIColor clearColor];
    _placeholderLbl.numberOfLines = 0;
    _placeholderLbl.text = @" 请输入您的宝贵意见和建议，以帮助我们更好的改进产品。(150字以内)";
    [self.view addSubview:_placeholderLbl];
    
    
    _creamBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _creamBtn.frame = CGRectMake(5, 64 + 200, 60, 60);
    [_creamBtn setBackgroundImage:[UIImage imageNamed:@"cream"] forState:UIControlStateNormal];
    [_creamBtn addTarget:self action:@selector(startCream) forControlEvents:UIControlEventTouchUpInside];
    _creamBtn.layer.borderColor = [UIColor colorWithRed:190 / 255.0 green:190 / 255.0 blue:190 / 255.0 alpha:1.0].CGColor;
    _creamBtn.layer.borderWidth = 1.0;
    [self.view addSubview:_creamBtn];
    
    
    _addBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _addBtn.frame = CGRectMake(80, 64 + 200, 60, 60);
    [_addBtn setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [_addBtn addTarget:self action:@selector(addPhone) forControlEvents:UIControlEventTouchUpInside];
    _addBtn.layer.borderColor = [UIColor colorWithRed:190 / 255.0 green:190 / 255.0 blue:190 / 255.0 alpha:1.0].CGColor;
    _addBtn.layer.borderWidth = 1.0;
    [self.view addSubview:_addBtn];
    
    
    UILabel *contactLbl = [[UILabel  alloc] initWithFrame:CGRectMake(5, 64 + 270, 80, 30)];
    contactLbl.font = [UIFont systemFontOfSize:14];
    contactLbl.text = @"联系方式:";
    [self.view addSubview:contactLbl];
    
    _selectTypeLbl = [[UILabel alloc] initWithFrame:CGRectMake(70, 64 + 270, 120, 30)];
    _selectTypeLbl.backgroundColor = [UIColor colorWithRed:203 / 255.0 green:203 / 255.0 blue:203 / 255.0    alpha:1.0];
    _selectTypeLbl.font = [UIFont systemFontOfSize:14];
    _selectTypeLbl.layer.cornerRadius = 2;
    _selectTypeLbl.layer.borderColor = [UIColor colorWithRed:190 / 255.0 green:190 / 255.0 blue:190 / 255.0 alpha:1.0].CGColor;
    _selectTypeLbl.layer.borderWidth = 1.0;
    _selectTypeLbl.clipsToBounds = YES;
    _selectTypeLbl.text = @"  手机";
    [_selectTypeLbl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectContactType)]];
    _selectTypeLbl.userInteractionEnabled = YES;
    [self.view addSubview:_selectTypeLbl];
    
    _contactTypeTB = [[UITableView alloc] initWithFrame:CGRectMake(70, 64 + 300, 120, 200) style:UITableViewStylePlain];
    _contactTypeTB.backgroundColor = [UIColor clearColor];
    _contactTypeTB.delegate = self;
    _contactTypeTB.dataSource = self;
    _contactTypeTB.hidden = YES;
    _contactTypeTB.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _contactTF = [[UITextField alloc] initWithFrame:CGRectMake(5, 64 + 310, KScreenWidth - 10, 30)];
    _contactTF.font = [UIFont systemFontOfSize:12];
    _contactTF.placeholder = @"请输入联系方式";
    _contactTF.layer.cornerRadius = 2.0;
    _contactTF.layer.borderColor = [UIColor colorWithRed:190 / 255.0 green:190 / 255.0 blue:190 / 255.0 alpha:1.0].CGColor;
    _contactTF.layer.borderWidth = 1.0;
    _contactTF.returnKeyType = UIReturnKeyDone;
    _contactTF.delegate = self;
    [self.view addSubview:_contactTF];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    submitBtn.frame = CGRectMake(5, 64 + 360, KScreenWidth - 10, 40);
    [submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitBtn.backgroundColor = [UIColor colorWithRed:52 / 255.0 green:133 / 255.0 blue:216 / 255.0 alpha:1.0];
    [submitBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    submitBtn.layer.cornerRadius = 2.0;
    submitBtn.clipsToBounds = YES;
    [self.view addSubview:submitBtn];
    
    [self.view addSubview:_contactTypeTB];
}

- (void)popSelf {
    [self.navigationController popViewControllerAnimated:YES];
}

//打开摄像头
- (void)startCream {
    _ifCream = YES;
    BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    
    if (!isCamera) {
        NSLog(@"没有摄像头");
        return;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    //编辑模式
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:^{
        
    }];
}

//打开相册添加图片
- (void)addPhone {
    _ifCream = NO;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    //编辑模式
//    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:^{
        
    }];
}

//选择联系方式
- (void)selectContactType {
    _contactTypeTB.hidden = NO;
}

//提交
- (void)submit {
    //先注销输入控件的第一响应者状态
    [_feedBackTV resignFirstResponder];
    [_contactTF resignFirstResponder];
    
    if (_feedBackTV.text.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"反馈内容不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    if (_contactTF.text.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请填写联系方式，以便我们更好的与您沟通" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    if ([_selectTypeLbl.text isEqualToString:@"  手机"]) {
        if (![self validateMobile:_contactTF.text]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请填写正确的联系方式" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
    }
    
    if ([_selectTypeLbl.text isEqualToString:@"  邮箱"]) {
        if (![self validateEmail:_contactTF.text]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请填写正确的联系方式" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
    }
    
    if ([_selectTypeLbl.text isEqualToString:@"  QQ"]) {
        if (![self validateNumber:_contactTF.text]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请填写正确的联系方式" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
    }
    
    NSData *data;
    if (UIImageJPEGRepresentation(_selectImg, 0.6) == nil) {
        
        data = UIImagePNGRepresentation(_selectImg);
        
    } else {
        
        data = UIImageJPEGRepresentation(_selectImg, 0.6);
        
    }
    
    _timeStr = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    _selectData = data;
    [LotuseedInternal postFeedBackInfo:NO withMessage:_feedBackTV.text withFileName:nil withFileData:data withPostTime:_timeStr withPosterAge:nil withPosterGender:nil withPosterContact:[NSString stringWithFormat:@"%@:%@", _selectTypeLbl.text, _contactTF.text] withTarget:self withSelect:@selector(requestResult:)];
}

//邮箱
- (BOOL)validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

//手机号码验证
- (BOOL)validateMobile:(NSString *)mobile
{
//    //手机号以13， 15，18开头，八个 \d 数字字符
//    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
//    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
//    return [phoneTest evaluateWithObject:mobile];
    
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    
    /**
     
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    
//    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
//    NSPredicate *regextestPHS = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    if(([regextestmobile evaluateWithObject:mobile] == YES)
       
       || ([regextestcm evaluateWithObject:mobile] == YES)
       
       || ([regextestct evaluateWithObject:mobile] == YES)
       
       || ([regextestcu evaluateWithObject:mobile] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

//qq
- (BOOL)validateNumber:(NSString *) textString
{
    NSString* number=@"^[0-9]+$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:textString];
}

//发送请求成功回调
- (void)requestResult:(NSDictionary *)info
{
    
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
        
        NSDictionary *feedBackData = @{@"m":_feedBackTV.text, @"imageFileName":str, @"tm":_timeStr, @"postContact":[NSString stringWithFormat:@"%@:%@", _selectTypeLbl.text, _contactTF.text]};
        [feedBackArr addObject:feedBackData];
    } else {
        NSDictionary *feedBackData = @{@"m":_feedBackTV.text, @"imageFileName":@"", @"tm":_timeStr, @"postContact":[NSString stringWithFormat:@"%@:%@", _selectTypeLbl.text, _contactTF.text]};
        [feedBackArr addObject:feedBackData];
    }
    
    [feedBackArr writeToFile:filename atomically:NO];
    
    //发送通知反馈界面刷新
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpDateFeedBack" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma Delegate method UIImagePickerControllerDelegate
//图像选取器的委托方法，选完图片后回调该方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
    //当图片不为空时显示图片并保存图片
    if (image != nil) {
        //图片显示在界面上
        if (_ifCream) {
            [_creamBtn setBackgroundImage:image forState:UIControlStateNormal];
            [_addBtn setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        } else {
            [_addBtn setBackgroundImage:image forState:UIControlStateNormal];
            [_creamBtn setBackgroundImage:[UIImage imageNamed:@"cream"] forState:UIControlStateNormal];
        }
        _selectImg = image;
    }
    //关闭相册界面
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


// 取消相册
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITextViewDelegate
//内容将要发生改变编辑
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.text.length > 150) {
        if ([text isEqualToString:@""]) {
            return YES;
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"反馈内容不能超过150字" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    if (text && ![text isEqualToString:@"\n"]) {
        _placeholderLbl.hidden = YES;
    }
    if ([text isEqualToString:@""]) {
        if (textView.text.length == 0 || textView.text.length == 1) {
            _placeholderLbl.hidden = NO;
        }
    }
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - UITextFiledDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *contactArr = @[@"手机", @"QQ", @"邮箱", @"其他"];
    UILabel *contentLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    contentLbl.backgroundColor = [UIColor colorWithRed:203 / 255.0 green:203 / 255.0 blue:203 / 255.0    alpha:1.0];
    contentLbl.font = [UIFont systemFontOfSize:14];
    contentLbl.text = [NSString stringWithFormat:@"  %@",contactArr[indexPath.row]];
    contentLbl.layer.cornerRadius = 2;
    contentLbl.clipsToBounds = YES;
    [cell.contentView addSubview:contentLbl];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *contactArr = @[@"手机", @"QQ", @"邮箱", @"其他"];
    _selectTypeLbl.text = [NSString stringWithFormat:@"  %@",contactArr[indexPath.row]];
    _contactTypeTB.hidden = YES;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有触摸对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
    int y = point.y;
    //判断如果点击的不在两个输入控件的范围内 就注销掉第一响应者身份
    if (y <= 64 + 45 || y >= 64 + 310 + 30) {
        [_feedBackTV resignFirstResponder];
        [_contactTF resignFirstResponder];
    }
    if (y <= 64 + 310 && y >= 64 + 45 + 150) {
        [_feedBackTV resignFirstResponder];
        [_contactTF resignFirstResponder];
    }
    
}


@end
#endif