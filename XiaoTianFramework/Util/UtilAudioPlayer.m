//
//  UtilAudioPlayer.m
//  qiqidu
//
//  Created by XiaoTian on 2020/3/16.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import "UtilAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface UtilAudioPlayer()<AVAudioPlayerDelegate>

@end
@implementation UtilAudioPlayer{
    AVAudioPlayer *audioPlayer;
}

+(instancetype) share{
    static UtilAudioPlayer* utilAudioPlayer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        utilAudioPlayer = [[UtilAudioPlayer alloc] init];
    });
    return utilAudioPlayer;
}

-(void)playBundle:(NSString*) fileName repeat:(BOOL)repeat{
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    if (musicPath) {
        NSError* error;
        NSURL* musicURL = [NSURL fileURLWithPath:musicPath];
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:&error];
        audioPlayer.numberOfLoops = -1;
        [audioPlayer setDelegate:self];
        BOOL preparePlay = [audioPlayer prepareToPlay];
        [Mylog info:@"准备播放:%d", preparePlay];
        BOOL startPlay = [audioPlayer play];
        [Mylog info:@"启动播放:%d", startPlay];
    }
}
-(void)stop{
    if([audioPlayer isPlaying]){
        [audioPlayer stop];
    }
}
// 当音频播放完成之后触发
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [Mylog info:@"音频播放完成"];
}
// 当程序被播放出错时
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    [Mylog info:@"音频播放出错"];
}
@end
