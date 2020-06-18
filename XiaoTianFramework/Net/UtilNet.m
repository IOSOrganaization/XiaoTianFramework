//
//  UtilNet.m
//  jjrcw
//
//  Created by XiaoTian on 2020/5/20.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import "UtilNet.h"

@implementation UtilNet
-(void)socket{
    //Socket套接字是支持TCP/IP协议的网络通信的基本操作单元,包含进行网络通信必须的五种信息：连接使用的协议，本地主机的IP地址，远地主机的IP地址，本地进程的协议端口，远地进程的协议端口。
    //多个TCP连接或多个应用程序进程可能需要通过同一个 TCP协 议端口传输数据。为了区别不同的应用程序进程和连接，许多计算机操作系统为应用程序与TCP／IP协议交互提供了套接字(Socket)接口, 应用层可以 和传输层通过Socket接口，区分来自不同应用程序进程或网络连接的通信，实现数据传输的并发服务。
    //套接字之间的连接过程分为三个步骤：服务器监听，客户端请求，连接确认。
    //服务器监听：服务器端套接字并不定位具体的客户端套接字，而是处于等待连接的状态，实时监控网络状态，等待客户端的连接请求。
    //客户端请求：指客户端的套接字提出连接请求，要连接的目标是服务器端的套接字。为此，客户端的套接字必须首先描述它要连接的服务器的套接字，指出服务器端套接字的地址和端口号，然后就向服务器端套接字提出连接请求。
    //连接确认：当服务器端套接字监听到或者说接收到客户端套接字的连接请求时，就响应客户端套接字的请求，建立一个新的线程，把服务器端套接字的描述发给客户端，一旦客户端确认了此描述，双方就正式建立连接。而服务器端套接字继续处于监听状态，继续接收其他客户端套接字的连接请求。
    //Socket可以支持不同的传输层协议, TCP或UDP TPC/IP协议是传输层协议，主要解决数据如何在网络中传输，而HTTP是应用层协议(HTTP、FTP、TELNET等,也可以自己定义应用层协议)，主要解决如何包装数据。
    //HTTP请求报文：一个HTTP请求报文由请求行、请求头部、空行和请求数据4部分组成。
    //HTTP响应报文：由三部分组成：状态行、消息报头、响应正文。
    //1、HTTPS是加密传输协议，HTTP是明文传输协议;
    //2、HTTPS需要用到SSL证书，而HTTP不用;
    //3、HTTPS比HTTP更加安全，对搜索引擎更友好，利于SEO；
    //4、HTTPS标准端口443，HTTP标准端口80;
    //5、HTTPS基于传输层，HTTP基于应用层;
    //6、HTTPS在浏览器显示绿色安全锁，HTTP没有显示;
    
    // NSURLSession相对于NSConnection来说，比较具体的优势,1、后台上传和下载,2、可以暂停和重启网络操作, 3、可以对缓存策略，session类型、任务类型（比如上传、下载等任务）进行单独的配置,4、更多更丰富的代理模式
    //  NSURLSession包括与之前相同的组件，例如NSURLRequest, NSURLCache等,把NSURLConnection替换为NSURLSession, NSURLSessionConfiguration，以及3个NSURLSessionTask的子类：NSURLSessionDataTask, NSURLSessionUploadTask, 和NSURLSessionDownloadTask。
}
@end
