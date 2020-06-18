//
//  UtilGCD.m
//  XiaoTianFramework
//  GCD全局调度中心
//  Created by XiaoTian on 2016/12/5.
//  Copyright © 2016 XiaoTian. All rights reserved.
//

#import "UtilGCD.h"
#import "UtilKeyChain.h"

@implementation UtilGCD
static UtilGCD* _instance = nil;
+(void)runInThread:(void (^)(void))asyncThreadTask on:(void (^)(void))mainThreadTask{
    // block 的局部变量必须用__block修饰符声明才能修改其值, 当引用的为对象时, 我们引用的是指针，当只是操作并不会改变指针的指向，赋值的话就会引发指针指向的改变。block禁止的是指针指向的改变(传地址值,根类型地址=值)
    // 使用系统的某些block api一般不需要考虑引用循环,所谓“引用循环”是指双向的强引用，所以那些“单向的强引用”（block 强引用 self ）没有问题,
    //      但是如果用到比如GCD 内部如果引用了 self，而且 GCD 的其他参数是 ivar，则要考虑到循环引用：
    //      __block修饰符不能用于修饰全局变量、静态变量。
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//默认优先级
        asyncThreadTask();
        if(mainThreadTask){
            dispatch_async(dispatch_get_main_queue(), ^{
                mainThreadTask();
            });
        }
    });
}

+(void)post:(void (^)(void))mainThreadTask{
    // 主线程任务:
    // [_NSObject performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];//
    // [[NSOperationQueue mainQueue] addOperationWithBlock:^{}];//使用GCD封装方法
    // dispatch_async(dispatch_get_main_queue(), ^{});
    dispatch_async(dispatch_get_main_queue(), mainThreadTask);
}

+(void)postDelay:(void (^)(void))mainThreadTask delay:(NSTimeInterval) delay{
    if(mainThreadTask){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            mainThreadTask();
        });
    }
}
+(NSTimer*)careateTimerScheduler:(void (^)(void)) asyncHandlerTask interval:(NSTimeInterval) interval{
    //1.iOS 10 及以上通过block回调方式,避免强引用, init(timeInterval:repeats:block:)
    //2.编写中间件强引用中间件对象, 避免强应用
    //3.NSTimer内部使用弱引用(外部如果确保有调用invalidate方法并把定时器引用设置为nil则不会导致循环引用问题(如果无法确保stop一定被调用，就极易造成内存泄露))
    //__weak typeof(self) wSelf = self;//__weak修饰的指针变量，在指向的内存地址销毁后，会在 Runtime 的机制下，自动置为nil。
    //__unsafe_unretained typeof(self) wSelf = self;//_unsafe_unretained不会置为nil，容易出现悬垂指针，发生崩溃。但是_unsafe_unretained比__weak效率高。
    if (@available(iOS 10.0, *)) {
        NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:interval repeats:NO block:^(NSTimer * _Nonnull timer) {
            //__strong typeof(self) self = wSelf;//防止使用过程中被释放了,释放后可能会出现闪退的情形
            asyncHandlerTask();//主线程
        }];
        //[timer invalidate];//结束定时器,释放内存
        return timer;
    }
    return nil;
}
+(NSTimer*)scheduler:(void (^)(BOOL *stop)) asyncHandlerTask delay:(NSTimeInterval) delay interval:(NSTimeInterval)interval repeat:(BOOL) repeat{
    NSTimer* timer;
    if (@available(iOS 10.0, *)) {
        timer = [NSTimer timerWithTimeInterval:interval repeats:repeat block:^(NSTimer * _Nonnull timer) {
            BOOL stop = NO;
            asyncHandlerTask(&stop);
            if(!repeat || stop) [timer invalidate];
        }];
    }else{
        return nil;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // runloop的mode作用主要是用来指定事件在运行循环中的优先级的, NSRunLoop中的4种模式:
        //1.NSDefaultRunLoopMode（kCFRunLoopDefaultMode）：默认，空闲状态(公开属性)
        //2.UITrackingRunLoopMode：ScrollView滑动时(不公开)
        //3.UIInitializationRunLoopMode：启动时(不公开),刚启动APP时第一个模式,启动完成后不再使用
        //4.GSEventReceiveRunLoopMode：接受系统内部事件，通常用不到
        //5.NSRunLoopCommonModes（kCFRunLoopCommonModes）：Mode集合(公开属性)这个模式等效于NSDefaultRunLoopMode和NSEventTrackingRunLoopMode的结合。 两个模式以数组的形式组合成一个形式，当只要其中任意一个模式触发，都是这个大模式的触发。都可响应。
        //  RunLoop只能运行在一种mode下，如果要换mode，当前的loop也需要停下重启成新的。利用这个机制， ScrollView滚动过程中NSDefaultRunLoopMode（kCFRunLoopDefaultMode）的mode会切换到UITrackingRunLoopMode来保证ScrollView的流畅滑动： 只能在NSDefaultRunLoopMode模式下处理的事件会影响ScrollView的滑动。NSRunLoopCommonModes多种模式混合
        // 线程和 RunLoop 之间是一一对应的，其关系是保存在一个全局的 Dictionary 里。线程刚创建时并没有 RunLoop，如果你不主动获取，那它一直都不会有。RunLoop 的创建是发生在第一次获取时，RunLoop 的销毁是发生在线程结束时。你只能在一个线程的内部获取其 RunLoop（主线程除外）。
        [NSRunLoop.currentRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
        //NSRunLoop(Foundation)是CFRunLoop(CoreFoundation)的封装，提供了面向对象的API,RunLoop 相关的主要涉及五个类：
        //1.CFRunLoop：RunLoop对象, 由pthread(线程对象，说明RunLoop和线程是一一对应的)、currentMode(当前所处的运行模式)、modes(多个运行模式的集合)、commonModes(模式名称字符串集合)、 commonModelItems(Observer,Timer,Source集合)构成
        //2.CFRunLoopMode：运行模式, 由name、source0、source1、observers、timers构成
        //3.CFRunLoopSource：输入源/事件源, 分为source0和source1两种 source0:即非基于port的，也就是用户触发的事件。需要手动唤醒线程，将当前线程从内核态切换到用户态 source1:基于port的，包含一个mach_port和一个回调，可监听系统端口和通过内核和其他线程发送的消息，能主动唤醒RunLoop，接收分发系统事件。 具备唤醒线程的能力
        //4.CFRunLoopTimer：定时源, 基于时间的触发器，基本上说的就是NSTimer。在预设的时间点唤醒RunLoop执行回调。因为它是基于RunLoop的，因此它不是实时的（就是NSTimer 是不准确的。 因为RunLoop只负责分发源的消息。如果线程当前正在处理繁重的任务，就有可能导致Timer本次延时，或者少执行一次）
        //5.CFRunLoopObserver：观察者, 监听以下时间点:CFRunLoopActivity,
        //  1.kCFRunLoopEntry RunLoop准备启动
        //  2.kCFRunLoopBeforeTimers RunLoop将要处理一些Timer相关事件
        //  3.kCFRunLoopBeforeSources RunLoop将要处理一些Source事件
        //  4.kCFRunLoopBeforeWaiting RunLoop将要进行休眠状态,即将由用户态切换到内核态
        //  5.kCFRunLoopAfterWaiting RunLoop被唤醒，即从内核态切换到用户态后
        //  6.kCFRunLoopExit RunLoop退出
        //  7.kCFRunLoopAllActivities 监听所有状态
        //线程和RunLoop一一对应(一个线程只有一个RunLoop)， RunLoop和Mode是一对多的(一个RunLoop有多种Mode)，Mode和source、timer、observer也是一对多的(一个Mode有多个源,定时器,监听器)
        //线程和RunLoop是一一对应的,其映射关系是保存在一个全局的 Dictionary 里, 自己创建的线程默认是没有开启RunLoop的
        //创建一个常驻线程:
        //  NSRunLoop *runLoop = [NSRunLoop currentRunLoop];//1.为当前线程开启一个RunLoop（第一次调用 [NSRunLoop currentRunLoop]方法时实际是会先去创建一个RunLoop）
        //  [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode]; //2.向当前RunLoop中添加一个Port/Source等维持RunLoop的事件循环（如果RunLoop的mode中一个item都没有，RunLoop会退出）
        //  [runLoop run];//3.启动该RunLoop
        //利用RunLoop的Mode机制滑动时为UITrackingRunLoopMode,停止时NSDefaultRunLoopMode,可以等待滑动完成在reloadTable,不会闪一下跳动
        //  主线程RunLoop由UITrackingRunLoopMode切换到NSDefaultRunLoopMode时再去更新UI
        //  [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
    });
    return timer;
}

+(dispatch_source_t)careateTimerSchedulerAsync:(void (^)(void)) asyncHandlerTask interval:(NSTimeInterval) interval{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);//所在线程,后台线程
    dispatch_source_t secondScheduler = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);//创建定时器
    dispatch_source_set_timer(secondScheduler, DISPATCH_TIME_NOW,  interval* NSEC_PER_SEC, 0);//设置定时器,启动时间,时间间隔,延迟
    dispatch_source_set_event_handler(secondScheduler, asyncHandlerTask);//设置定时器回调函数
    dispatch_resume(secondScheduler);//执行定时器
    //dispatch_cancel(secondScheduler);//取消定时器
    return secondScheduler;
}
+(dispatch_source_t)schedulerSource:(void(^)(BOOL* stop)) mainThreadTask delay:(NSTimeInterval) delay interval:(NSTimeInterval)interval repeat:(BOOL) repeat{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);//所在线程,后台线程(默认优先级)
    dispatch_source_t scheduler = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);//创建定时器
    dispatch_source_set_timer(scheduler, dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC),  interval* NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);//设置定时器,启动时间,时间间隔,延迟
    dispatch_source_set_event_handler(scheduler, ^(void){//设置定时器回调函数
        __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL stop = NO;
            mainThreadTask(&stop);//stop 地址
            if(!repeat || stop) dispatch_cancel(scheduler);//取消定时器(必须)
            dispatch_semaphore_signal(semaphore);
        });
         dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    dispatch_resume(scheduler);//执行定时器
    //dispatch_cancel(secondScheduler);//取消定时器
    return scheduler;
}
+(dispatch_source_t)schedulerSourceAsync:(void(^)(BOOL* stop)) asyncHandlerTask delay:(NSTimeInterval) delay interval:(NSTimeInterval)interval repeat:(BOOL) repeat{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);//所在线程,后台线程(默认优先级)
    dispatch_source_t scheduler = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);//创建定时器
    dispatch_source_set_timer(scheduler, DISPATCH_TIME_NOW,  interval* NSEC_PER_SEC, delay * NSEC_PER_SEC);//设置定时器,启动时间,时间间隔,延迟
    dispatch_source_set_event_handler(scheduler, ^(void){//设置定时器回调函数
        BOOL stop = NO;
        asyncHandlerTask(&stop);//stop 地址
        if(!repeat || stop) dispatch_cancel(scheduler);//取消定时器(必须)
    });
    dispatch_resume(scheduler);//执行定时器
    //dispatch_cancel(secondScheduler);//取消定时器
    return scheduler;
}

/// 多线程队列
+(dispatch_queue_t) createQueue{
    // 串行队列的创建方法
    dispatch_queue_t queueSerial = dispatch_queue_create("com.xiaotian.QueueSerial", DISPATCH_QUEUE_SERIAL);
    // 并发队列的创建方法
    dispatch_queue_t queueConcurrent = dispatch_queue_create("com.xiaotian.QueueConcurrent", DISPATCH_QUEUE_CONCURRENT);
    // 主队列(主线程)
    dispatch_queue_t queueMain = dispatch_get_main_queue();
    [Mylog info:@"%p,%p,%p",queueSerial,queueConcurrent,queueMain];
    // 系统默认全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 同步执行任务创建方法(加入队列等待执行,串行队列不能使用同步导致死锁)
    dispatch_sync(queue, ^{
        // 这里放同步执行任务代码
    });
    // 异步执行任务创建方法(开启新线程执行)
    dispatch_async(queue, ^{
        // 这里放异步执行任务代码
    });
    // 延时执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 2.0 秒后异步追加任务代码到主队列，并开始执行
        NSLog(@"after---%@", [NSThread currentThread]);  // 打印当前线程
    });
    // 只执行一次(单例初始化)
    static dispatch_once_t onceToken;//静态标识
    dispatch_once(&onceToken, ^{//根据标识只执行一次方法
        // 只执行 1 次的代码（这里面默认是线程安全的）
    });
    // 队列组(异步转同步,多线程)
    dispatch_queue_t group_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);//信号量
    dispatch_group_t group = dispatch_group_create();//分组信号量
    dispatch_group_enter(group);//进入组信号(手动发送进入信号量)
    dispatch_group_leave(group);//结束组信号(结束个数 == 进入个数: 完成, 手动发送结束信号量)
    dispatch_group_async(group, group_queue, ^{});//直接添加异步任务(自动处理信号量)
    // 组信号结束完成回调触发
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //
        NSLog(@"group 全部执行完成");
    });
    // 组信号阻塞等待(组信号结束才继续,120秒超时)
    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120.0 * NSEC_PER_SEC)));//信号量等待释放(无限期等待)
    // 调度信号量(异步转同步,单线程)
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_semaphore_signal(semaphore);//释放信号量
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER); //信号量等待释放(无限期等待)
    return nil;
}
+(void)dispatchBarrier {
    [Mylog info:@"start"];
    //The queue you specify should be a concurrent queue that you create yourself using the dispatch_queue_create function. If the queue you pass to this function is a serial queue or one of the global concurrent queues, this function behaves like the dispatch_sync function.
    //在使用栅栏函数时.使用自定义队列才有意义,如果用的是串行队列或者系统提供的全局并发队列,这个栅栏函数的作用等同于一个同步函数的作用
    dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);//创建自定义并发队列
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:3];
        [Mylog info:@"%@ Task 1", [NSThread currentThread]];
    });
    dispatch_async(queue, ^{
        [Mylog info:@"%@ Task 2", [NSThread currentThread]];
    });
    //栅栏(障碍/界线)dispatch_barrier_sync:当前线程同步执行,dispatch_barrier_async:当前线程异步执行
    dispatch_barrier_async(queue, ^{//分割任务,等待分割前任务完成后再继续执行后面的任务(并行执行,等待已加入线程执行完毕再下一步)
        [NSThread sleepForTimeInterval:3];
        [Mylog info:@"+++barrier++"];
    });
    [Mylog info:@"+++执行完删栏操作+++"];
    dispatch_async(queue, ^{
        [Mylog info:@"%@ Task 3", [NSThread currentThread]];
    });
    dispatch_async(queue, ^{
        [Mylog info:@"%@ Task 4", [NSThread currentThread]];
    });
    [Mylog info:@"end"];
}
+(void)test{
    NSLog(@"2");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"2");
        //带afterDelay的延时函数，会在内部创建一个 NSTimer，然后添加到当前线程的RunLoop中。也就是如果当前线程没有开启RunLoop，该方法会失效。
        [self performSelector:@selector(testDelay) withObject:nil afterDelay:10];
        //开启NSRunLoop等待线程执行结束,当前线程结束,NSRunLoop就会结束(当前线程有一个Timer的延时执行器)
        [[NSRunLoop currentRunLoop] run];
        NSLog(@"3");
    });
    NSLog(@"4");
    //[self performSelector:sel withObject:id afterDelay:delay];
    //[self performSelector:sel withObject:id];
    [self nsOperation];
}
-(void)testDelay{
    NSLog(@"5");
}
+(void)nsOperation{
    //创建操作队列(异步)
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc]init];
    //创建最后一个操作(NSBlockOperation和NSInvocationOperation)
    NSBlockOperation *lastBlockOperation = [NSBlockOperation blockOperationWithBlock:^{
        sleep(1);
        [Mylog info:@"最后的任务:%@,%@",NSThread.mainThread,NSThread.currentThread];
    }];
    for (int i=0; i<5-1; ++i) {
        //创建多线程操作
        NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            sleep(i);
            NSLog(@"第%d个任务",i);
        }];
        blockOperation.queuePriority = NSOperationQueuePriorityHigh;
        //设置依赖操作为最后一个操作
        //1.依赖必须在操作被添加到队列(确切来说应该是被执行)之前设置、否则无效。
        //2.依赖关系与本身绑定、并不受限于同一个队列。即使所执行的队列不同、也可以完成依赖操作。
        //3.如果所插入的操作存在依赖关系、优先完成依赖操作。
        //4.如果所插入的操作不存在依赖关系、队列并发数为1下采用先进先出的原则、反之直接开辟新的线程执行
        [blockOperation addDependency:lastBlockOperation];
        [operationQueue addOperation:blockOperation];
    }
    //将最后一个操作加入线程队列(操作的状态为取消、进行、完成。是不可以被添加进队列)
    [operationQueue addOperation:lastBlockOperation];//NSOperation (NSInvocationOperation 和 NSBlockOperation)
    [operationQueue addOperationWithBlock:^{ }];//block
    [lastBlockOperation addExecutionBlock:^{//加入线程队列后可以追加任务,需要注意的是、追加的操作是并发执行
        NSLog(@"进入追加操作");
        sleep(5);
        NSLog(@"追加操作完成");
    }];
}
//
//默认情况下NSTimer在主线程运行
//NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) { 主线程 }];
//NSThread:–优点：NSThread 比其他两个轻量级，使用简单,缺点：需要自己管理线程的生命周期、线程同步、加锁、睡眠以及唤醒等。线程同步对数据的加锁会有一定的系统开销
//      [NSThread detachNewThreadSelector:@selector(doSomething:) toTarget:self withObject:nil];
//      NSThread *myThread = [[NSThread alloc] initWithTarget:self selector:@selector(doSomething:) object:nil]; [myThread start];
//NSOperation：–不需要关心线程管理，数据同步的事情，可以把精力放在自己需要执行的操作上–NSOperation是面向对象的,属于OC类
//GCD：–Grand Central Dispatch是由苹果开发的一个多核编程的解决方案。是相比NSThread， NSOperation更高效和强大的技术–GCD是基于C的底层API。更高的并发执行能力。
//   dispatch queue分为下面三种:
//      private dispatch queues，同时只执行一个任务，通常用于同步访问特定的资源或数据。
//      global dispatch queue，可以并发地执行多个任务，但是执行完成的顺序是随机的。
//      Main dispatch queue 它是在应用程序主线程上执行任务的。
//多线程安全
//NSLock同步锁: 使用时把需要加锁的代码放到NSLock的lock和unlock之间，一个线程A进入加锁代码以后，另一个线程B就无法访问了，只能等线程A执行完加锁代码后解锁，B线程才能访问加锁代码。
//@Synchronized代码块 （相比NSlock简单一点 也是解决同步线程问题）
//GCD信号机制，（和同步锁的机制并不一样）
//NSRecursiveLock：递归锁 有时候加锁代码中存在递归调用，递归开始前加锁，递归开始调用后重复执行此方法以至于加锁代码照成死锁
//NSDistributedLock：分布锁，它本身时一个互斥锁，基于文件方式实现锁机制，可以跨进程访问
//pthread_mutex_t：同步锁，基于C语言的同步锁机制，使用方法与其他同步锁机制类似
//
//Block
//block 是将函数及其执行上下文封装起来的对象(包含isa类指针) block类名: [^{} class]; block类型: dispatch_block_t
//分为全局Block(_NSConcreteGlobalBlock)、栈Block(_NSConcreteStackBlock)、堆Block(_NSConcreteMallocBlock)三种形式 其中栈Block存储在栈(stack)区，堆Block存储在堆(heap)区，全局Block存储在已初始化数据(.data)区
//block参数:个人理解: 局部变量(运行时赋值,运行到代码位置直接赋值), 其他变量(局部静态,全局,全局静态,__block局部)执行时赋值(运行到代码位置不赋值,执行才赋值) 底层:编译时通过局部变量/结构体/引用实现
//1.不使用外部变量的block是全局block                      [Mylog info:@"Block Name: %@",[^{} class]];//__NSGlobalBlock__
//2.使用外部变量并且未进行copy操作的block是栈block          NSString* name = @"Name"; [Mylog info:@"Block Name: %@",[^{name.length;} class]];//__NSStackBlock__
//3.对栈block进行copy操作，就是堆block，而对全局block进行copy，仍是全局block  void(^blockName)(void) = ^{name.length;};//栈block赋值给blockName, __NSMallocBlock__ void(^blockName)(dispatch_block_t) = ^(dispatch_block_t block){dispatch_block_t _block = block;/*block赋值*/ [Mylog info:@"%@,%@",[block class],[_block class]];}; 即如果对栈Block进行copy，将会copy到堆区，对堆Block进行copy，将会增加引用计数，对全局Block进行copy，因为是已经初始化的，所以什么也不做。
//  另外，__block变量在copy时，由于__forwarding的存在，栈上的__forwarding指针会指向堆上的__forwarding变量，而堆上的__forwarding指针指向其自身， 所以，如果对__block的修改，实际上是在修改堆上的__block变量。即__forwarding指针存在的意义就是，无论在任何内存位置， 都可以顺利地访问同一个__block变量。 另外由于block捕获的__block修饰的变量会去持有变量，那么如果用__block修饰self，且self持有block，并且block内部使用到__block修饰的self时，就会造成多循环引用，即self持有block，block 持有__block变量，而__block变量持有self，(__block typeof(self) weakSelf = self;) 造成内存泄漏。:: __block声明weakSelf会造成内存泄露,__weak声明weakSelf不会
    
//4.
@end
