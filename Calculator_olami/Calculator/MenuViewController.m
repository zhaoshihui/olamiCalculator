//
//  MenuViewController.m
//  Calculator
//
//  Created by Scarlett on 2017/7/6.
//  Copyright © 2017年 zsh. All rights reserved.
//

#import "MenuViewController.h"
#import "OtherViewController.h"
#import "UIViewController+ZYSliderViewController.h"
#import "ZYSliderViewController.h"

@interface MenuViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_dataSource;
}
@property (nonatomic ,strong) UITableView *leftTableView;
@property (nonatomic ,strong) UIButton *headButton;
@property (nonatomic ,strong) UIImageView *headImage;;
@property (nonatomic ,strong) UILabel *usrAccountLabel;
@property (nonatomic ,strong) UIView *lineView;
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = zBackColor;
    
    //头像Button
    _headButton = [[UIButton alloc]init];
    [_headButton addTarget:self action:@selector(changeHeaderImage) forControlEvents:UIControlEventTouchUpInside];
    _headImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"hui.jpeg"]];
    _headImage.layer.cornerRadius = 36;
    _headImage.layer.masksToBounds = YES;
    [self.view addSubview:_headButton];
    
    //账户名称
    _usrAccountLabel = [[UILabel alloc]init];
    _usrAccountLabel.text = @"ScarlettZhao";
    _usrAccountLabel.textColor = ARGBColor(255, 187, 190, 199);
    _usrAccountLabel.font = [UIFont systemFontOfSize:15];
    _usrAccountLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_usrAccountLabel];
    
    //线条
    _lineView = [[UIView alloc]init];
    _lineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_lineView];

    
    _leftTableView = [[UITableView alloc] init];
    _leftTableView.backgroundColor = [UIColor clearColor];
    _leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _leftTableView.delegate = self;
    _leftTableView.dataSource = self;
    _leftTableView.rowHeight = 44.f;
    
    CGRect rect = CGRectMake((self.view.frame.size.width - 72)/2, 55, 72, 72);
    _headButton.frame = rect;
    _headImage.frame = CGRectMake(0, 0, 72, 72);
    [_headButton addSubview:_headImage];
    CGFloat marginX = 15;
    _usrAccountLabel.frame = CGRectMake(marginX, CGRectGetMaxY(_headButton.frame) + marginX, self.view.frame.size.width - marginX * 2, marginX);
    _lineView.frame = CGRectMake(marginX, CGRectGetMaxY(_usrAccountLabel.frame)+30, self.view.frame.size.width - marginX * 2, 0.5);
    
    CGFloat tablView_top = CGRectGetMaxY(_lineView.frame) + marginX;
    //    CGFloat tableView_Bottom = CGRectGetMinY([UIScreen mainScreen].bounds) - 20;
    _leftTableView.frame = CGRectMake(marginX, tablView_top, self.view.frame.size.width - marginX * 2, 40);

    
    [self.view addSubview:_leftTableView];


    
    _dataSource = @[@"关于我们"];
}

-(void)changeHeaderImage{
    
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
    cell.textLabel.text = _dataSource[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self sliderViewController] hideLeft];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OtherViewController *controller = [[OtherViewController alloc] init];
    [[self sliderViewController].sliderNavigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
