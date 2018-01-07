# -WBPayManager
> 自己在两个项目中接入了移动端支付宝和微信支付，也对支付代码进行了简单的封装。在项目集成与调试的时候遇到了一些问题，自己也一直想找时间进行整理，方便以后在项目中集成与使用。**支付宝SDK**和**微信SDK**都进行了相应的更新，我项目中使用的还是老版本的SDK，下面开始介绍最新版本的SDK集成与使用。

### 一、[支付宝](https://open.alipay.com/platform/home.htm)
#### 1> [快速接入](https://docs.open.alipay.com/204/105297/)
在接入前，首先要对流程要有相应的了解，主要有以下三个步骤（具体详情，请点击上面链接查看）：
- 创建应用并获取APPID
- 配置应用
![1.png](https://user-gold-cdn.xitu.io/2018/1/4/160c06b0fbf8e7bc?w=865&h=462&f=png&s=30507)
- 集成和开发
![81fdbf664f654970835e5426b55959f6.jpg](https://user-gold-cdn.xitu.io/2018/1/4/160c06b0fc910665?w=675&h=524&f=png&s=98584)
#### 2> SDK下载
- [SDK&DEMO](http://p.tb.cn/rmsportal_6680_WS_APP_PAY_SDK_BASE_2.0.zip)
- [AliSDK_V15.4.1](https://github.com/wenmobo/WBPayManager/blob/master/Lib/AliSDK/AliSDK_V15.4.1.zip)(现在项目中使用的版本)
- [AliSDK_V15.5.0](https://github.com/wenmobo/WBPayManager/blob/master/Lib/AliSDK/AliSDK_V15.5.0.zip
)
#### 3> 集成SDK
[1]、将下面两个文件拖入到工程
**AlipaySDK.bundle**
**AlipaySDK.framework**
![屏幕快照 2018-01-04 上午11.18.23.png](https://user-gold-cdn.xitu.io/2018/1/4/160c06b0fb26a62a?w=271&h=65&f=png&s=8652)
添加官方demo中依赖文件到工程，如下图所示：
![屏幕快照 2018-01-04 上午11.45.26.png](https://user-gold-cdn.xitu.io/2018/1/4/160c06b0fbbaf3f9?w=274&h=229&f=png&s=19530)
[2]、 添加依赖库
> `libc++.tbd`
`libz.tbd`
`SystemConfiguration.framework`
`CoreTelephony.framework`
`QuartzCore.framework`
`CoreText.framework`
`CoreGraphics.framework`
`UIKit.framework`
`Foundation.framework`
`CFNetwork.framework`
`CoreMotion.framework`
`AlipaySDK.famework`

**注意**
> 如果是Xcode 7.0之后的版本，需要添加libc++.tbd、libz.tbd；
如果是Xcode 7.0之前的版本，需要添加libc++.dylib、libz.dylib

![屏幕快照 2018-01-04 上午11.17.28.png](https://user-gold-cdn.xitu.io/2018/1/4/160c06b0fc58b13b?w=699&h=486&f=png&s=62304)
[3]、配置info.plist,添加支付回调URL scheme，可以自己定义一个名字，如下图：
![屏幕快照 2018-01-04 下午3.19.54.png](https://user-gold-cdn.xitu.io/2018/1/4/160c06b0fd5f92c1?w=918&h=168&f=png&s=21173)
好了，到这里，SDK库文件和系统依赖库都已经导入到工程，`command+R`运行一下，你会发现报错，就是**oppssl/asn1.h not found**，在我最开始集成支付宝的时候，这个问题折腾了我好久，网上和官方都能找到解决方法，虽然每次都解决了，但是都尝试了好久。

**报错解决**
1、**oppssl/asn1.h not found**
![屏幕快照 2018-01-04 上午11.48.22.png](https://user-gold-cdn.xitu.io/2018/1/4/160c06b125de01ce?w=271&h=247&f=png&s=25561)
在**Build Settings**下搜索**Header Search Paths**中添加`$(SRCROOT)/项目名称`,我写的[WBPayManagerDemo](https://github.com/wenmobo/WBPayManager)中的**openssl**文件夹在**AliSDK_V15.5.0**文件下，所以这里需要修改
方式一：手动添加路径
`$(SRCROOT)/WBPayManagerDemo/AliSDK_V15.5.0`
![屏幕快照 2018-01-04 下午12.01.02.png](https://user-gold-cdn.xitu.io/2018/1/4/160c06b12c9559cf?w=877&h=394&f=png&s=45803)
方式二：将AliSDK_V15.5.0文件夹拖入到**Header Search Paths**
![Untitled.gif](https://user-gold-cdn.xitu.io/2018/1/4/160c06b12bb0d56c?w=1240&h=724&f=gif&s=389620)

### 二、[微信](https://open.weixin.qq.com/cgi-bin/index?t=home/index&lang=zh_CN)
#### 1> [接入指南](https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=1417694084&token=&lang=zh_CN)
微信SDK集成主要有以下三个步骤：
- 向微信注册你的应用程序id
请到 开发者应用登记页面 进行登记，登记并选择移动应用进行设置后，将获得AppID，可立即用于开发。但应用登记完成后还需要提交审核，只有审核通过的应用才能正式发布使用。
- 下载微信终端SDK文件
SDK文件包括 libWeChatSDK.a，WXApi.h，WXApiObject.h 三个。
如选用手动集成，请前往“[资源下载页](https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=open1419319164&lang=zh_CN "iOS资源下载")”下载最新SDK包

- 搭建开发环境
#### 2> 项目集成
- 1、通过CocoaPods集成
`pod 'WechatOpenSDK'`
**注意**
- 命令行下执行pod search WechatOpenSDK,如显示的WechatOpenSDK版本不是最新的，则先执行pod repo update操作更新本地repo的内容
- 对于之前SDK放在主工程目录下，切换成CocoaPods的形式，执行pod install 之后，出现
Use the $(inherited) flag, or
Remove the build settings from the target.
解决方法是 把工程target中的build Setting里面PODS_ROOT的值替换成$(inherited)Other Linker Flags中 -all_load 替换成$(inherited)
**![image](https://user-gold-cdn.xitu.io/2018/1/4/160c06b126fe25df?w=575&h=244&f=jpeg&s=8700)**
**![image](https://user-gold-cdn.xitu.io/2018/1/4/160c06b12ba1b634?w=575&h=246&f=jpeg&s=8221)**
2、手动集成
[1]、SDK下载
- [官方下载地址](https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=open1419319164&token=&lang=zh_CN)
- [WeChatSDK_V1.7.8](https://github.com/wenmobo/WBPayManager/blob/master/Lib/WeChat/WeChatSDK_V1.7.8.zip)(现在项目使用的版本，通过ShareSDK导入)
- [WechatSDK1.8.2](https://github.com/wenmobo/WBPayManager/blob/master/Lib/WeChat/WechatSDK1.8.2.zip)
[2]、导入工程
将WechatSDK1.8.2文件夹（**libWeChatSDK.a**、**WechatAuthSDK.h**、**WXApi.h**、**WXApiObject.h**）拖入到工程。
![屏幕快照 2018-01-04 下午2.42.39.png](https://user-gold-cdn.xitu.io/2018/1/4/160c06b12b8f74c0?w=273&h=125&f=png&s=13388)
[3]、添加依赖库
```
SystemConfiguration.framework
libz.tbd
libsqlite3.0.tbd
libc++.tbd
Security.framework
CoreTelephony.framework
CFNetwork.framework
```
**注意**
Xcode 7.0之前
`libz.tbd` 对应的是`libz.dylib`
`libsqlite3.0.tbd`对应的是`libsqlite3.0.dylib`
`libc++.tbd`对应的是`libc++.dylib`
[4]、配置工程
- 在你的工程文件中选择Build Setting，在"Other Linker Flags"中加入"-Objc -all_load"，在Search Paths中添加 libWeChatSDK.a ，WXApi.h，WXApiObject.h，文件所在位置（如下图所示）。
![屏幕快照 2018-01-04 下午3.00.25.png](https://user-gold-cdn.xitu.io/2018/1/4/160c06b14b34b862?w=1031&h=246&f=png&s=35647)
- 在info.plist添加key为**LSApplicationQueriesSchemes**，**Type**为数组类型，添加一个item为**weixin**，如下图所示：
![屏幕快照 2018-01-04 下午3.04.56.png](https://user-gold-cdn.xitu.io/2018/1/4/160c06b14e196370?w=1030&h=337&f=png&s=72062)
-  在Xcode中，选择你的工程设置项，选中“TARGETS”一栏，在“info”标签栏的“URL type“添加“URL scheme”为你所注册的应用程序id
![屏幕快照 2018-01-04 下午3.13.56.png](https://user-gold-cdn.xitu.io/2018/1/4/160c06b15290c56a?w=1033&h=677&f=png&s=122621)
### 三、支付封装
封装主要是新建了一个工具类，通过封装工具，可以将支付宝Block回调和微信的代理回调集中在一个回调里，支付只需调用一行代码就OK，我现在的项目都是用的这个支付工具类，下面介绍下核心代码和使用注意事项吧。
[1]注意URL Types的配置
在**WBPayManager.h**的头文件中，定义了两个URL identifier，所以配置的时候，需要保证info里的identifier和头文件定义的一致。
```
//此处必须保证在Info.plist 中的 URL Types 的 Identifier 对应一致
UIKIT_EXTERN NSString * const ALIPAY_URLIDENTIFIER;/**  支付宝URL NAME  */
UIKIT_EXTERN NSString * const WECHAT_URLIDENTIFIER;/**  微信URL NAME  */
```
![屏幕快照 2018-01-04 下午3.59.03.png](https://user-gold-cdn.xitu.io/2018/1/4/160c06b153d7f31e?w=845&h=302&f=png&s=37362)
[2]、处理支付回调
```
/**  < 微信需要在程序加载完成注册 >  */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
// Override point for customization after application launch.

[[WBPayManager shareManager] wb_registerApp];
return YES;
}

/**
*
*  最老的版本，最好也写上
*/
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
return [[WBPayManager shareManager] wb_handleUrl:url];
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
return [[WBPayManager shareManager] wb_handleUrl:url];
}

/**  *  iOS 9.0 之前 会调用  */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
return [[WBPayManager shareManager] wb_handleUrl:url];
}
```
[3]、发起支付
- 支付宝
```
//直接传入后台返回的订单信息支付串
[[WBPayManager shareManager] wb_payWithOrderInfo:orderInfo payCallBack:^(WBPayStatusCode errorCode, NSString *errorStr) {
//支付结果回调
}]
```
- 微信
```
//构建PayReq对象，后台返回
PayReq * req = [PayReq new];
req.partnerId = orderModel.wechatpay_data.partnerid;
req.prepayId= orderModel.wechatpay_data.prepayid;
req.package = orderModel.wechatpay_data.package;
req.nonceStr= orderModel.wechatpay_data.noncestr;
req.timeStamp= (UInt32)[orderModel.wechatpay_data.timestamp integerValue];
req.sign= orderModel.wechatpay_data.sign;
[[WBPayManager shareManager] wb_payWithOrderInfo:req payCallBack:^(WBPayStatusCode errorCode, NSString *errorStr) {
//支付结果回调
}]
```
具体详情，请戳GitHub：[WBPayManagerDemo](https://github.com/wenmobo/WBPayManager)
### 结语
> 终于整理完成了，通过这次整理，希望以后在项目集成少遇到一些坑吧，微信的支付文档感觉确实有点老了，SDK在更新，文档却没有更新，不过也没有关系。最新版本的SDK在自己的项目中也没有使用，项目中还是用的老版本的SDK，我也将老版本SDK的下载链接也放在文章中。如有不对的地方，欢迎指正，希望这篇文章能对你有所帮助。

