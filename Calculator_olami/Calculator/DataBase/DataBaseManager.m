//
//  DataBaseManager.m
//  UI_22_FMDB
//
//  Created by zsh on 16/1/7.
//  Copyright © 2017年 zsh. All rights reserved.
//

#import "DataBaseManager.h"
#import "FMDB.h"
@interface DataBaseManager ()

@property(nonatomic,copy)NSString *filepath;
@property(nonatomic,retain)FMDatabase *fmdb;

@end
@implementation DataBaseManager

+(instancetype)shareDataBase{
      static DataBaseManager *manager=nil;
      static dispatch_once_t onceToken;
      dispatch_once(&onceToken, ^{
          if (!manager ) {
              manager=[[DataBaseManager alloc]init];

              [manager openDB];
          };

     
   });
        return manager;
}
-(void)openDB
{
    NSString *sendboxpath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 1, YES)lastObject];
    self.filepath=[sendboxpath stringByAppendingPathComponent:@"calculator.sqlite"];
    NSLog(@"%@",self.filepath);
    //创建一个fmdb对象
    
    self.fmdb=[[FMDatabase alloc]initWithPath:self.filepath];
    BOOL result=[self.fmdb open];
    
    if (result) {
        NSLog(@"成功");
    }else
    {
        NSLog(@"失败");
    }
    
    NSString *sqlstr=@"create table if not exists calculate(number integer primary key autoincrement,resultstr text,contentstr text,equateID text)";
    
    BOOL result1 =[self.fmdb executeUpdate:sqlstr];
    if (result1 ) {
        NSLog(@"创建表初始化成功");
        
    }else
    {
        NSLog(@"创建表失败");
    }

}

-(void)insertEquation:(Equation *)equation;
{
    
    [_fmdb open];
    BOOL result1=[self.fmdb executeUpdate:@"insert into calculate(resultstr,contentstr,equateID)values(?,?,?)",equation.resultstr,equation.content,equation.equateID];
    if (result1) {
        NSLog(@"插入成功");
    }else
    {
        NSLog(@"插入失败");
    }

    [_fmdb close];
}

-(void)updateEquation:(Equation *)equation;
{
    [_fmdb open];
    [_fmdb executeUpdate:@"update calculate set resultstr= ?  where contentstr = ? ", equation.resultstr, equation.content];
    [_fmdb close];
}


-(void)removeEquation:(Equation *)equation;
{
    [_fmdb open];

    BOOL result = [_fmdb executeUpdate:@"delete from calculate where equateID= ?" ,equation.equateID];
    
    if (result) {
        NSLog(@"删除成功");
    }else{
        NSLog(@"删除失败");
    }
    [_fmdb close];
}

-(void)deleteAllEquation{
    [_fmdb open];
    [_fmdb executeUpdate:@"DELETE FROM calculate"];
    [_fmdb close];
}

-(NSMutableArray *)getAllEquation
{
    [_fmdb open];
    NSString *sqlstr=@"select * from calculate";
    //执行查询的方法
    FMResultSet *resultSet=[self.fmdb executeQuery:sqlstr];
    //系统会把查询之后的结果赋值给resultSet
    //进行遍历
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSMutableArray *fanDataArray = [[NSMutableArray alloc] init];
    while ([resultSet next]) {
        Equation *equation = [[Equation alloc] init];
        equation.resultstr = [resultSet stringForColumn:@"resultstr"];
        equation.content = [resultSet stringForColumn:@"contentstr"];
        equation.equateID = [resultSet stringForColumn:@"equateID"];
        [dataArray addObject:equation];
        fanDataArray = [[[dataArray reverseObjectEnumerator]allObjects] mutableCopy];
    }
    
    [_fmdb close];
    
    
    
    return fanDataArray;

}


-(void)droptable
{
    NSString *sqlstr=@"drop table calculate";
    [_fmdb executeUpdate:sqlstr];
}

@end
