//
//  XTFUtilUserDefault.m
//  XiaoTianFramework
//
//  Created by XiaoTian on 1/14/15.
//  Copyright (c) 2015 XiaoTian. All rights reserved.
//

#import "XTFUtilUserDefault.h"

// 宏定义静态字符串[编译时替代]
#ifndef __DEFAULT_TAG_NAME__
#define __DEFAULT_TAG_NAME__

#define TAG_NAME_BOOL @"TAG_NAME_DETAULT_BOOL"
#define TAG_NAME_STRING @"TAG_NAME_DETAULT_STRING"
#define TAG_NAME_INTEGER @"TAG_NAME_DETAULT_INTEGER"

#endif

@implementation XTFUtilUserDefault{
    NSUserDefaults *mNSUserDefaults;
}

-(instancetype) init{
    self = [super init];
    if(self){
        mNSUserDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}
//
-(BOOL) getBOOL{
    return [mNSUserDefaults boolForKey:TAG_NAME_BOOL];
}
-(BOOL) getBOOL:(NSString*) tagname{
    return [mNSUserDefaults boolForKey:tagname];
}
-(void) setBOOL{
    [mNSUserDefaults setBool:YES forKey:TAG_NAME_BOOL];
}
-(void) setBOOL:(NSString*) tagname{
    [mNSUserDefaults setBool:YES forKey:tagname];
}
@end
