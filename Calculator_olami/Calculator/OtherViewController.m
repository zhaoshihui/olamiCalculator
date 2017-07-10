//
//  OtherViewController.m
//  Calculator
//
//  Created by Scarlett on 2017/7/7.
//  Copyright © 2017年 zsh. All rights reserved.
//

#import "OtherViewController.h"

@interface OtherViewController ()

@end

@implementation OtherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"关于我们";
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 200, kScreenWidth, 300)];
    titleLabel.text = @"微信：121003626 多多指教";
    titleLabel.font = textFont(18);
    [self.view addSubview:titleLabel];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
