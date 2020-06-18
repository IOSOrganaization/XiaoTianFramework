//
//  UtilUserDefault.m
//  XiaoTianFramework
//
//  Created by XiaoTian on 1/14/15.
//  Copyright (c) 2015 XiaoTian. All rights reserved.
//

#import "UtilUserDefault.h"

// 宏定义静态字符串[编译时替代]
#ifndef __DEFAULT_TAG_NAME__
#define __DEFAULT_TAG_NAME__

#define TAG_NAME_BOOL @"TAG_NAME_DETAULT_BOOL"
#define TAG_NAME_STRING @"TAG_NAME_DETAULT_STRING"
#define TAG_NAME_INTEGER @"TAG_NAME_DETAULT_INTEGER"

#endif

@implementation UtilUserDefault{
    NSUserDefaults *_userDefaults;
}

-(instancetype) init{
    self = [super init];
    if(self){
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}
//
-(BOOL) getBOOL{
    return [_userDefaults boolForKey:TAG_NAME_BOOL];
}
-(BOOL) getBOOL:(NSString*) tagname{
    return [_userDefaults boolForKey:tagname];
}
-(void) setBOOL{
    [_userDefaults setBool:YES forKey:TAG_NAME_BOOL];
}
-(void) setBOOL:(NSString*) tagname{
    [_userDefaults setBool:YES forKey:tagname];
}
-(void) setBOOL:(NSString*) tagname value:(BOOL) value{
    [_userDefaults setBool:value forKey:tagname];
}
@end
