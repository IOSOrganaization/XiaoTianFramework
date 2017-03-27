App Icon 图标：
1.在Assets.xcassets中创建App Icon的Image Assets［选中Assets.xcassets文件，new App Icon］
2.准备好图标资源，直接拖到对应的Icon中，对应关系如下：
a.Spotlight搜索图标[必要]: Iphone Spotlight ios7-9 40pt: 2x对应80px * 80px,3x对应120px * 120px
b.程序图标[必要]: Iphone App ios7-9 60pt: 2x对应120px * 120px,3x对应180px * 180px

LaunchImage 启动图片
1.ios8以前的系统不支持Launch Screan.storyboard页面布局文件,所以如果要兼容ios7,6必需要用LunchImage形式的启动图
2.在Assets.xcassets中创建LaunchImage的Image Assets[选中Assets.xcassets文件,new Launch Image]
3.准备好对应的图片资源,直接拖动到对应的Icon中,对应关系如下:
a.竖屏 iPhone portrait ios 8,9: 5.5寸[iPhone6 Plus]对应1242px * 2208,4.7寸[iPone6]对应750px * 1334px
b.横屏 iPhone Landscape ios 8,9: 5.5寸对应2208*1242
c.竖屏 iPhone portrait ios7-9: 2x[iPhone4s]对应640px * 960px,Retina 4[iPhone5]对应640px * 1136px

普通图片的ImageAsset:
