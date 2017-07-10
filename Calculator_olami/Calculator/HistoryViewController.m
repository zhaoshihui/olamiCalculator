//
//  HistoryViewController.m
//  Calculator
//
//  Created by Scarlett on 2017/7/6.
//  Copyright © 2017年 zsh. All rights reserved.
//

#import "HistoryViewController.h"
#import "UIViewController+ZYSliderViewController.h"
#import "ZYSliderViewController.h"
#import "DataBaseManager.h"
#import "Equation.h"

#define zScreenW self.view.frame.size.width
#define zScreenH self.view.frame.size.height

@interface HistoryViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *selectArr;

@property (nonatomic, strong) UIView *deleteView;

@property (nonatomic, strong) UIButton *rightBtn;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = WhiteColor;
    
    _selectArr = [[NSMutableArray alloc] init];
    
    _dataSource = [[NSMutableArray alloc] init];
    
    [self setUI];
    
    _dataSource = [[DataBaseManager shareDataBase] getAllEquation];
    
    //注册通知（接收通知）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveTongzhi:) name:@"saveTongzhi" object:nil];
}

-(void)setUI{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(zScreenW-240, 0, 240, 64)];
    headView.backgroundColor = ARGBColor(200, 255, 90, 156);
    [self.view addSubview:headView];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(zScreenW-240 + (240/2-40), 30, 80, 30)];
    titleLabel.text = @"历史记录";
    titleLabel.font = textFont(18);
    [self.view addSubview:titleLabel];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:leftBtn];
    leftBtn.frame = CGRectMake(10, 35, 24, 24);
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [rightBtn setTitle:@"完成" forState:UIControlStateSelected];
    rightBtn.titleLabel.font = textFont(16);
    [rightBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:rightBtn];
    rightBtn.frame = CGRectMake(240-10-34, 35, 41, 24);
    _rightBtn = rightBtn;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(zScreenW-240, 64, 240, zScreenH-64) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 44.f;
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _deleteView = [[UIView alloc] initWithFrame:CGRectMake(zScreenW-240, zScreenH-49, 240, 49)];
    _deleteView.backgroundColor = ARGBColor(200, 241, 199, 223);
    [self.view addSubview:_deleteView];
    UIButton *deleteAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteAllBtn setBackgroundColor:RedColor];
    [deleteAllBtn setTitle:@"全部删除" forState:UIControlStateNormal];
    [deleteAllBtn setTitleColor:WhiteColor forState:UIControlStateNormal];
    deleteAllBtn.layer.cornerRadius = 8;
    deleteAllBtn.layer.masksToBounds = YES;
    [_deleteView addSubview:deleteAllBtn];
    deleteAllBtn.frame = CGRectMake(240/2-70, 49/2-15, 140, 30);
    _deleteView.hidden = YES;
    
    
    [deleteAllBtn addTarget:self action:@selector(deleteAll:) forControlEvents:UIControlEventTouchUpInside];
}

//删除全部
-(void)deleteAll:(UIButton *)deleteBtn{
    [[DataBaseManager shareDataBase] deleteAllEquation];
    
    _dataSource = [[DataBaseManager shareDataBase] getAllEquation];
    [_tableView reloadData];
    
    _tableView.editing = NO;
    
    _deleteView.hidden = YES;
    _rightBtn.selected = NO;

}

//保存值处理
-(void)saveTongzhi:(NSNotification *)text{
    NSLog(@"savetongzhi:%@",text.userInfo[@"arr"]);
    _dataSource = text.userInfo[@"arr"];
    [_tableView reloadData];
}

-(void)back{
    NSLog(@"dfa");
    [[self sliderViewController] hideRight];

}

-(void)edit:(UIButton *)btn{
    BOOL flag = _tableView.editing;
    if (flag) {
        //删除的操作
        //得到删除的索引
        _deleteView.hidden = YES;
        
        //下面一部分是多选删除
        NSMutableArray *indexArray = [NSMutableArray array];
        for (Equation *equation in _selectArr) {
            NSInteger num = [_dataSource indexOfObject:equation];
            
            NSIndexPath *path = [NSIndexPath indexPathForRow:num inSection:0];
            [indexArray addObject:path];
        }
        
        //修改数据模型model（数据库）
//        [_dataSource removeObjectsInArray:_selectArr];
        for (Equation *equ in _selectArr) {
            [[DataBaseManager shareDataBase] removeEquation:equ];
        }
        
        _dataSource = [[DataBaseManager shareDataBase] getAllEquation];
        
        [_selectArr removeAllObjects];
        
        //刷新 UI删除
        [_tableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
        
        _tableView.editing = NO;
        btn.selected = NO;
    }
    else{
        _deleteView.hidden = NO;
        //开始选择行
        [_selectArr removeAllObjects];
        
        _tableView.editing = YES;
        btn.selected = YES;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    Equation *eqModel = _dataSource[indexPath.row];
    
    cell.textLabel.text = eqModel.resultstr;
    cell.detailTextLabel.text = eqModel.content;
    
    cell.textLabel.textColor = BlackColor;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
       
    if (!_tableView.editing){
        [[self sliderViewController] hideRight];
        NSMutableArray *allArr = [[DataBaseManager shareDataBase] getAllEquation];
        Equation *eqModel = allArr[indexPath.row];
        NSDictionary *dict =[[NSDictionary alloc]initWithObjectsAndKeys:eqModel.resultstr,@"text", nil];
        //创建通知
        NSNotification *notification =[NSNotification notificationWithName:@"historyTongzhi" object:nil userInfo:dict];
        
        //通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        return;
    }
    
    Equation *equation = [_dataSource objectAtIndex:indexPath.row];
    if (![_selectArr containsObject:equation]) {
        [_selectArr addObject:equation];
    }
}

#pragma mark 取消选中行
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_tableView.editing){
        return;
    }
    
    Equation *equation = _dataSource[indexPath.row];
    if ([_selectArr containsObject:equation]) {
        [_selectArr removeObject:equation];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {//删除
        
        NSMutableArray *allArr = [[DataBaseManager shareDataBase] getAllEquation];
        Equation *eqModel = allArr[indexPath.row];
        
        [[DataBaseManager shareDataBase] removeEquation:eqModel];
        
        _dataSource = [[DataBaseManager shareDataBase] getAllEquation];
        
        [_tableView reloadData];
    }

}

//侧滑出现的文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
//}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
