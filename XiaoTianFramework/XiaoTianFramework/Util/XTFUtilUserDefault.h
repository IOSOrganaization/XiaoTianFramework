//
//  XTFUtilUserDefault.h
//  XiaoTianFramework
//
//  Created by XiaoTian on 1/14/15.
//  Copyright (c) 2015 XiaoTian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTFUtilUserDefault : NSObject

-(BOOL) getBOOL;
-(BOOL) getBOOL:(NSString*) tagname;
-(void) setBOOL;
-(void) setBOOL:(NSString*) tagname;

@end
