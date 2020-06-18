//
//  Person.h
//  XiaoTianFramework
//
//  Created by XiaoTian on 16/6/28.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Dog;

@interface Person : NSObject
@property (nonatomic, strong) NSString * nameXJ;
@property (nonatomic, strong) NSString * sexXJ;
@property (nonatomic, assign) float weightXJ;
@property (nonatomic, strong) NSDecimalNumber * heightXJ;
@property (nonatomic, strong) NSNumber * ageXJ;
@property (nonatomic, strong) NSNumber * birthdayXJ;
@property (nonatomic, assign) BOOL workingXJ;
@property (nonatomic, assign) Dog * dogXJ;
@property (nonatomic, strong) NSArray * dogsXJ;
@property (nonatomic, strong) NSDictionary * dogdXJ;
@end

@interface Dog : NSObject
@property (nonatomic, strong) NSString * nameXJ;
@property (nonatomic, strong) NSString * sexXJ;
@end
