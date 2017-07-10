//
//  CulculatorViewController.m
//  Culculator
//
//  Created by Scarlett on 2017/6/29.
//  Copyright © 2017年 Scarlett Zhao. All rights reserved.
//

#import "CulculatorViewController.h"
#import "OlamiRecognizer.h"
#import "WaveView.h"
#import "UIViewController+ZYSliderViewController.h"
#import "ZYSliderViewController.h"
#import "DataBaseManager.h"
#import "Equation.h"


@interface CulculatorViewController ()<OlamiRecognizerDelegate, UITextViewDelegate>

@property (nonatomic, strong) OlamiRecognizer *olamiRecognizer;
@property (nonatomic, strong) NSString *speakStr;
@property (nonatomic, strong) WaveView *waveView;

@property (nonatomic, strong) NSMutableArray *dataArr;
@end

@implementation CulculatorViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArr = [[NSMutableArray alloc] init];
    
    self.view.backgroundColor = [UIColor whiteColor];
        
    self.title = @"Olami_calculator";
    
    //键盘弹出收回通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                            object:nil];
    
    
    //接收传值通知(注册)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyTongzhi:) name:@"historyTongzhi" object:nil];
    
    //设置nav栏
    [self setupNavView];

    //UI
    [self setupUI];
    
    //语音初始化
    [self setupOLAMI];

}

//历史记录传回
-(void)historyTongzhi:(NSNotification *)text{
    NSLog(@"%@", text.userInfo[@"text"]);
    _showTextView.text = text.userInfo[@"text"];
    NSLog(@"－－－－－接收到通知------");
}



- (void) keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    int sizeH = keyboardFrame.origin.y;
    self.recordButton.frame = CGRectMake((kScreenWidth-100)/2, kScreenHeight-sizeH, 100, 100);
}

-(void)keyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:1 animations:^{
        self.recordButton.frame = CGRectMake((kScreenWidth-100)/2, kScreenHeight-200, 100, 100);
    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"historyTongzhi" object:self];
}

-(void)setupNavView{
    self.navigationController.navigationBar.backgroundColor = zBackColor;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [leftBtn sizeToFit];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    [leftBtn addTarget:self action:@selector(OpenLeftMenuView) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"history"] forState:UIControlStateNormal];
    [rightBtn sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    [rightBtn addTarget:self action:@selector(OpenHistoryView) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -- rightViewOpen
-(void)OpenHistoryView{
    [[self sliderViewController] showRight];

}

#pragma mark -- leftViewOpen
- (void)OpenLeftMenuView{
    
    [[self sliderViewController] showLeft];
}


-(void)setupUI{
    UIImageView *backImage = [[UIImageView alloc] initWithFrame:kScreenBounds];
    backImage.image = [UIImage imageNamed:@"123.jpeg"];
    [self.view addSubview:backImage];
    [self.view sendSubviewToBack:backImage];

    //波动图
    _waveView = [[WaveView alloc] initWithFrame:CGRectMake(0, kScreenHeight-300, kScreenWidth, 300)];
    [self.view addSubview:_waveView];

    
    self.showTextView.delegate = self;
    self.showTextView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    self.showTextView.layer.borderWidth = 1;
    self.showTextView.layer.borderColor = MagentaColor.CGColor;
    self.showTextView.layer.cornerRadius = 10;
    self.showTextView.layer.masksToBounds = YES;
    
    self.showTextView.textAlignment = NSTextAlignmentLeft;
    self.showTextView.contentInset = UIEdgeInsetsMake(15.f, 15.f, 0.f, 0.f);
    self.showTextView.keyboardType = UIKeyboardTypeNumbersAndPunctuation;//将弹出键盘设置为数字符号键盘
    
    [self.view bringSubviewToFront:_recordButton];
    
}


#pragma mark --  asr语音系统初始化设置
-(void)setupOLAMI{
    _olamiRecognizer= [[OlamiRecognizer alloc] init];
    _olamiRecognizer.delegate = self;

    [_olamiRecognizer setAuthorization:AppKey api:@"asr" appSecret:AppSecret cusid:macID];
    
    //设置语言，目前只支持中文
    [_olamiRecognizer setLocalization:LANGUAGE_SIMPLIFIED_CHINESE];

}

#pragma mark--UITextView delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if (textView.text.length != 0) {
            NSLog(@"文本输入=%@",textView.text);
            _speakStr =[NSString stringWithFormat:@"%@",textView.text];

            [_olamiRecognizer setInputType:1];//设置为文本输入
            [_olamiRecognizer sendText:textView.text];//发送文本到服务器
        }

        return NO;
    }
    return YES;
    
}

#pragma mark--NLU delegate
- (void)onUpdateVolume:(float)volume {
    if (_olamiRecognizer.isRecording) {
        _waveView.present = volume/100;
    }
}


#pragma mark --返回结果
- (void)onResult:(NSData *)result {
    NSError *error;
    __weak typeof(self) weakSelf = self;
    if (error) {
        NSLog(@"error is %@",error.localizedDescription);
    }else{
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:result
                                                            options:NSJSONReadingMutableContainers
                                                              error:&error];
        NSLog(@"json=%@",json);
        
        if ([json[@"status"] isEqualToString:@"ok"]) {

            
            NSDictionary *asr = [json[@"data"] objectForKey:@"asr"];
            
            //如果asr不为空，说明目前是语音输入
            if (asr) {
                [weakSelf processASR:asr];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *resultStr = json[@"data"][@"nli"][0][@"desc_obj"][@"result"];
                
                if (resultStr.length == 0) {
                    resultStr = @"";
                }
                
                _showTextView.text  = [NSString stringWithFormat:@"%@%@%@%@",_speakStr,@"\n",@"\n",resultStr];

            });
            
            
        }else{
            _showTextView.text = @"请说出要计算的公式";
        }
    }
    
}


#pragma mark --处理ASR语音对话节点
- (void)processASR:(NSDictionary*)asrDic {
    NSString *result  = [asrDic objectForKey:@"result"];
    if (result.length == 0) { //如果结果为空，则弹出警告框
        [self showAlert:@"没有接受到语音，请重新输入!"];
        _speakStr = @"";
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *str = [result stringByReplacingOccurrencesOfString:@" " withString:@""];//去掉字符中间的空格
            NSLog(@"answer result = %@",str);
            _speakStr =[NSString stringWithFormat:@"%@",str];
        });
    }
    
}


#pragma mark --olamidelegate error
- (void)onError:(NSError *)error {
    [self showAlert:@"网络超时，请重试!"];
    
    if (error) {
        NSLog(@"error is %@",error.localizedDescription);
    }
    
}

#pragma mark -- 录音结束
-(void)onEndOfSpeech{
    [_recordButton setTitle:@"开始录音" forState:UIControlStateNormal];
}

#pragma mark --录音键
- (IBAction)recordButton:(UIButton *)sender {
    _showTextView.text = @"";
    //设置为语音模式
    [_olamiRecognizer setInputType:0];
    
    [_showTextView resignFirstResponder];
    
    //开始录音
    if (_olamiRecognizer.isRecording) {//isRecording = YES 即为录音模式
        [_olamiRecognizer stop];
        [_recordButton setTitle:@"开始录音" forState:UIControlStateNormal];
        
    }else{
        [_olamiRecognizer start];
        [_recordButton setTitle:@"结束录音" forState:UIControlStateNormal];
    }
    
}

- (IBAction)clearBtn:(id)sender {
    _showTextView.text = @"";

}

//保存想要的算式
- (IBAction)saveButton:(UIButton *)sender {
    [_showTextView resignFirstResponder];
    
    if ([_showTextView.text isEqualToString:@""]) {
        [self showAlert:@"请输入内容后再保存哦"];
        return;
    }
    
    NSLog(@"save:%@",_showTextView.text);
    Equation *equation = [[Equation alloc] init];
    equation.resultstr = [[[_showTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"结果等于" withString:@"="];
    equation.content = @"1";
    equation.equateID = [NSString stringWithFormat:@"%@%u",equation.resultstr,arc4random_uniform(1000) ];
    
    [[DataBaseManager shareDataBase] insertEquation:equation];
    _dataArr = [[DataBaseManager shareDataBase] getAllEquation];
    NSLog(@"arr=%@",_dataArr);
    
    //通知传值
    NSDictionary *dict =[[NSDictionary alloc]initWithObjectsAndKeys:_dataArr,@"arr", nil];
    //创建通知
    NSNotification *notification =[NSNotification notificationWithName:@"saveTongzhi" object:nil userInfo:dict];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

//提示框
-(void)showAlert:(NSString *)str{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:str
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:^{
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [alertController dismissViewControllerAnimated:YES completion:nil];
            
        });
        
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
