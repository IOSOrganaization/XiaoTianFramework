//
//  UtilAudioPlayer.h
//  qiqidu
//
//  Created by XiaoTian on 2020/3/16.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UtilAudioPlayer : NSObject

+(instancetype) share;
-(void) playBundle:(NSString*) fileName repeat:(BOOL)repeat;
-(void) stop;
@end

NS_ASSUME_NONNULL_END
