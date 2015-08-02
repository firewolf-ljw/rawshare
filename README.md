# rawshare


## 介绍 
用swift 1.2实现：不使用相关APP提供的SDK，分享信息（文本，图片，连接）到iOS的主流社交APP

在此之前，本人是做java服务端开发的，现在转型做iOS开发，学的是swift，由于swift是一门新的语言，其本身还在完善中，网上相关教程也越越多，但还不够，很多demo都是用Objective-C写的，所以本人通过将再网上收罗到的demo的源码从Objectiv-C翻译到swift的方式，来熟悉swift和iOS相关基础库组件，并将觉得对大家有帮助的demo分享出来，一起交流学习。

本示例demo也是从github上的一个开源项目翻译过来的，网址：https://github.com/100apps/openshare
本人还根据自己的编程习惯做了一些修改。可能对swift掌握还不到位，若觉得有不妥的，还望指点。觉得可以的话，不妨施舍一颗星

源项目的作者还专门开了博客做推广：http://www.gfzj.us/series/openshare/
里面介绍了实现的思路，主要信息有：不同APP间是通过一个调起APP的URL和存放大数据（如：图片）的系统粘贴板来实现通信的，监控官方SDK的参数格式的方式是hook相关的方法，本项目中也提供了一段监控openURL方法的swift代码

## demo
本项目主要实现了将文本，图片，链接等信息分享到微信，QQ，微博的功能
微信，QQ登录认证也都能工作，唯独微博的登录认证没跑通，因为没有去注册应用，不过登录认证的界面是调起来的了
支付相关代码也都翻译完了，但由于没有相应的服务端，所以这两个都没有跑通。有兴趣，有时间的朋友可以帮我试试并修正

## 参考链接
http://www.gfzj.us/series/openshare/ 

https://github.com/100apps/openshare 

http://nshipster.com/method-swizzling/ 

http://nshipster.cn/swift-objc-runtime/ 
