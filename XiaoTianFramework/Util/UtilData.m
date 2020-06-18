//
//  UtilData.m
//  jjrcw
//
//  Created by XiaoTian on 2020/5/26.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import "UtilData.h"

@implementation UtilData

// 进程间共享数据
-(void)shareProcessPasteboard{//粘贴板
    //进程赋值保存
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:@"shareProcessPasteboard" create:YES];//创建粘贴板
    pasteboard.string = @"myShareData";//赋值数据
    //进程取值读取
    UIPasteboard *_pasteboard = [UIPasteboard pasteboardWithName:@"shareProcessPasteboard" create:NO];//创建粘贴板
    NSString* data = _pasteboard.string;
    [Mylog info:data];
}
-(void)shareProcessURLScheme{//URL Scheme
    //myscheme://name=xiaotian&age=18&params=1
    //发送
    /*NSURL * urlStr = [NSURL URLWithString:@"myscheme://name=xiaotian&age=18&params=1"];//后面为参数
    if ([[UIApplication sharedApplication] canOpenURL:urlStr]) {
        NSLog(@"can go to test");
        [[UIApplication sharedApplication] openURL:urlStr];
    }else{
        NSLog(@"can not go to test！！！！！");
    }*/
    //接收参数
    /*-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
        if (!url) {  return NO; }
        NSString *URLString = [url absoluteString];
        return YES;
    }*/
}
-(void)shareProcessKeychainAccess{//Shared Keychain Access
    //通常每个应用程序只允许访问自己在keychain中保存的数据，不过假如你使用同一个证书的话，不同的app也可以通过keychain来实现应用间的数据共享
    //1.为了实现keychain共享数据，我们需要开启Keychain Sharing，开启方法如下[项目->Targets-项目名->Capability->添加Keychain Sharing]，然后添加设置相同的Keychain Group
    //2.send和receive两个项目都需要开启Keychain Sharing(添加相同的Group即可共享秘钥链数据)， 开启之后会生成xxxxx.entitlements文件，需要在receive项目里的xxxxx.entitlements文件添加send的bundle ID才能正常共享数据
    //进程赋值保存
    //[UtilKeyChain.share addKeyChainData:@"XiaoTian" key:@"user.name"];
    //进程取值读取
    //NSString* name = [UtilKeyChain.share getKeyChainData:@"user.name"];
}
-(void)shareProcessAppGroups{
    //iOS8之后苹果加入了App Groups功能，应用程序之间可以通过同一个group来共享资源，app group可以通过NSUserDefaults进行小量数据的共享， 如果需要共享较大的文件可以通过NSFileCoordinator、NSFilePresenter等方式。
    //1.开启app groups，需要添加一个group name，app之间通过这个group共享数据[项目->Targets-项目名->Capability->添加App Groups]
    //共享NSUserDefaults
    //进程赋值保存
    //NSUserDefaults* userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.77du.mobile"];//GroupName
    //[userDefaults setObject:@"XiaoTian" forKey:@"user.name"];
    //进程取值读取
    //NSUserDefaults* userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.77du.mobile"];
    //NSString* name = [userDefaults objectForKey:@"group.77du.mobile"];
    //
    //共享NSFileManager
    //NSFileManager *fileMgr = [NSFileManager defaultManager];
    //NSURL *url = [fileMgr containerURLForSecurityApplicationGroupIdentifier:@"group.77du.mobile"];
}
//iOS沙盒机制, iOS应用程序只能在为该改程序创建的文件系统中读取文件，不可以去其它地方访问，此区域被成为沙盒，所以所有的非代码文件都要保存在此，例如图像，图标，声音，映像，属性列表，文本文件等。 1.每个应用程序都有自己的存储空间,2.应用程序不能翻过自己的围墙去访问别的存储空间的内容,3.应用程序请求的数据都要通过权限检测，假如不符合条件的话，不会被放行。
//
@end
