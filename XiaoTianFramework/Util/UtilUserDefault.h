//
//  UtilUserDefault.h
//  XiaoTianFramework
//
//  Created by XiaoTian on 1/14/15.
//  Copyright (c) 2015 XiaoTian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilUserDefault : NSObject

-(BOOL) getBOOL;
-(BOOL) getBOOL:(NSString*) tagname;
-(void) setBOOL;
-(void) setBOOL:(NSString*) tagname;
-(void) setBOOL:(NSString*) tagname value:(BOOL) value;
@end
