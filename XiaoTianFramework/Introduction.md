# CoCo Touch Framework
# 动态库说明文档
#
# 1.创建动态框架 Framework 项目
#
1.构建Framework项目时选择创建：CoCo Touch Framework(XCode 6新增程序扩展框架,相对于静态库减少了手动配置Header,设置方式:在框架中包含开放头):xxx.framework 动态框架项目
  静态项目框架库： CoCo Touch Static Library (静态库):xxx.a库文件底层应用框架
2.引用的静态库和必要的系统框架,为框架使用[Build Phases -> Link Binary with Libraries]
3.配置动态框架的编译选项:
    1.添加编译阶段拷贝的公开类头配置文件[Build Phases -> Editor -> Add Build Phase -> Add Copy Headers Build Phase]
    2.拖动要拷贝开放的类头文件到拷贝配置表格(确定编译时编译器同时拷贝该类头供第三方使用)注意:开放的类头的属性必须在类体中同为public公开,否则运行时异常
4.创建框架实体类[默认创建的类都是私有的类不对外开放,默认的类统一放在Project的Headers组中::Public开放类头,Private私有头]
5.添加公开访问的类头[拖来要公开的访问的类头文件到Public目录表(Build Phases -> Headers -> Public)中,框架头的引入方式:#import <FrameworkName/PublicHeader.h>]注意:必须是公开访问的类头擦可以加入框架的头声明文件中,私有的头文件不能加入框架的头声明中(框架头输出到整个框架中用于被引用)
    a.设置类头的访问权限也可以在文件属性窗口设置Target Membership中的框架属性
6.添加公开访问的类头到类库的主头文件中:[#import <FrameworkName/PublicHeader.h>]
7.配置打包输出的类头存放路径[选择TARGETS->Framework -> Build Setting -> Packaging -> Public Headers Folder Path]
    1.默认$(CONTENTS_FOLDER_PATH)/Headers
8.配置属性:
    1. Dead Code Stripping = NO 移除无效代码
    2. Strip Debug Symbols During Copy = NO 移除调试代码
    3. Strip Style = Non-Global Symbols 移除代码格式
#
# 2.添加动态框架Framework到项目中
#
9.为实际项目添加动态框架：在文件浏览器中直接拖拉项目文件到项目中即可
10.为框架项目编写编译脚本[Editor -> Add Build Phase -> Add Run Script Build Phase]
11.当无法加载时，声明Framework输出到项目中[当项目中无法加载Library::Library not loaded: @rpath/XiaoTianFramework.framework/XiaoTianFramework]
    1.声明Framework编译生成连接静态库文件[默认Framework为动态库 Dynamic Library] [Framework框架->Build Setting->Linking->Match-O Type->Static Library]
    2.声明项目中嵌入Framework编译目标文件 添加框架嵌入[执行的项目->General->Embedded Binaries->Framework]
    
＃
# 3.Framework 动态框架对外开放类
＃
1.创建对外开放类
2.设置对外开放类头拷贝到框架输出 ： Target->Build Phases->Headers->Public
3.设置对外开放类头在项目中为框架开放类用于可以通过框架模块的方式引入 #import <framework/publicheader.h>
4.在框架模块的公共头中引入所有开放类

# 命名规则 前缀+类别+名称+子名称+类型

# 扩展命名规则 类名(扩展类名)