//
//  DataBaseManager.h
//  UI_22_FMDB
//
//  Created by zsh on 16/1/7.
//  Copyright © 2017年 zsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Equation.h"
@interface DataBaseManager : NSObject

+(instancetype)shareDataBase;
-(void)openDB;
-(void)insertEquation:(Equation *)equation;
-(void)updateEquation:(Equation *)equation;
-(void)removeEquation:(Equation *)equation;
-(NSMutableArray *)getAllEquation;
-(void)deleteAllEquation;
-(void)droptable;

@end
