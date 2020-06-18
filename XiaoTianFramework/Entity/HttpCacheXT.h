//
//  HttpCacheXT.h
//  jjrcw
//
//  Created by XiaoTian on 2020/5/21.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HttpCacheXT : NSObject<NSCoding,NSCopying>
// weak weak 此特质表明该属性定义了一种“非拥有关系” (nonowning relationship)。为这种属性设置新值时，设置方法既不保留新值，也不释放旧值。此特质同assign类似， 然而在属性所指的对象遭到摧毁时，属性值也会清空(nil out)。
//           runtime 对注册的类， 会进行布局，对于 weak 对象会放入一个 hash 表中。 用 weak 指向的对象内存地址作为 key，当此对象的引用计数为0的时候会 dealloc，假如 weak 指向的对象内存地址是a，那么就会以a为键， 在这个 weak 表中搜索，找到所有以a为键的 weak 对象，从而设置为 nil。
// 属性
// @property 的本质是什么？ivar、getter、setter 是如何生成并添加到这个类中的
// @property = ivar + getter + setter Ivar可以理解为类中的一个变量，主要作用是用来保存数据的。
// “属性” (property)作为 Objective-C 的一项特性，主要的作用就在于封装对象中的数据。 Objective-C 对象通常会把其所需要的数据保存为各种实例变量。实例变量一般通过“存取方法”(access method)来访问。完成属性定义后，编译器会自动编写访问这些属性所需的方法，此过程叫做"自动合成"。这个过程是由编译器在编译期执行，除了生成方法代码getter、setter之外，编译器还要自动向类中添加适当类型的实例变量，并且在属性名前面加下划线，以此作为实例变量的名字。
// @property有两个对应的词，一个是@synthesize，一个是@dynamic。如果@synthesize和@dynamic都没写，那么默认的就是@syntheszie var = _var;
// @synthesize (合成) 的语义是如果你没有手动实现setter方法和getter方法，那么编译器会自动为你加上这两个方法。
// @dynamic (动态绑定) 告诉编译器：属性的setter与getter方法由用户自己实现，不自动生成。（当然对于readonly的属性只需提供getter即可）。假如一个属性被声明为@dynamic var，然后你没有提供@setter方法和@getter方法，编译的时候没问题，但是当程序运行到instance.var = someVar，由于缺setter方法会导致程序崩溃；或者当运行到 someVar = var时，由于缺getter方法同样会导致崩溃。编译时没问题，运行时才执行相应的方法，这就是所谓的动态绑定。
//  ARC下默认属性关键字: 基本数据类型(atomic,readwrite,assign), OC对象(atomic,readwrite,strong)
//  实例变量 = 成员变量 = ivar @synthesize foo; 会生成一个名称为foo的成员变量,也就是说：如果没有指定成员变量的名称会自动生成一个属性同名的成员变量。@synthesize foo = _foo; 指定_foo为成员变量(默认就是前加下划线)
// unrecognized selector的异常? objc在向一个对象发送消息时，runtime库会根据对象的isa指针找到该对象实际所属的类，然后在该类中的方法列表以及其父类方法列表中寻找方法运行，如果，在最顶层的父类中依然找不到相应的方法时，程序在运行时会挂掉并抛出异常unrecognized selector sent to XXX 。但是在这之前，objc的运行时会给出三次拯救程序崩溃的机会：
//  向一个nil对象发送消息? 向nil发送消息是完全有效的——只是在运行时不会有任何作用,(如果向一个nil对象发送消息，首先在寻找对象的isa指针时就是0地址返回了，所以不会出现任何错误。)
//      1.如果一个方法返回值是一个对象，那么发送给nil的消息将返回0(nil)
//      2.如果方法返回值为指针类型，其指针大小为小于或者等于sizeof(void*)，float，double，long double 或者long long的整型标量，发送给nil的消息将返回0。
//      3.如果方法返回值为结构体,发送给nil的消息将返回0。结构体中各个字段的值将都是0。
//      4.如果方法的返回值不是上述提到的几种情况，那么发送给nil的消息的返回值将是未定义的。
//      objc是动态语言，每个方法在运行时会被动态转为消息发送，即：objc_msgSend(receiver, selector)。
// isa isa的指针指向他的类对象,从而可以找到对象上的方法,每个Objective-C对象都有一个隐藏的数据结构，这个数据结构是Objective-C对象的第一个成员变量，它就是isa指针。这个指针指向哪呢？它指向一个类对象(class object 记住它是个对象，是占用内存空间的一个变量，这个对象在编译的时候编译器就生成了，专门来描述某个类的定义)，这个类对象包含了Objective-C对象的一些信息（为了区分两个对象，我把前面提到的对象叫Objective-C对象），包括Objective-C对象的方法调度表，实现了什么协议等等。这个包含信息就是Objective-C动态能力的根源了
// NS* copy浅拷贝(拷贝地址),mutableCopy深拷贝(新建对象),NSMutable* copy/mutableCopy都是深拷贝(新建对象)
@property(strong,nonatomic)NSString* id;
@property(strong,nonatomic)NSString* signature;
@property(strong,nonatomic)NSString* url;
@property(strong,nonatomic)NSString* data;
@property(assign,nonatomic)NSTimeInterval time;

@end

NS_ASSUME_NONNULL_END
