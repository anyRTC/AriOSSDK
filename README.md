## 一. 新版SDK介绍

在该版本对通信场景采用了全新的系统架构。全新的API接口，更符合开发者习惯。

### 1.1 功能模块

1. 核心模块：
2. 音频模块
3. 视频模块
4. 视频预处理和后处理模块
5. 音频路由控制模块
6. 耳返
7. 音频音响模块
8. 音乐文件播放和混合模块
9. 音频录制模块
10. 还回测试模块
11. 网络相关测试模块
12. 自定义视频采集渲染模块
13. 外部音频输入模块
14. 外部视频输入模块
15. 水印模块
16. 大小流模块
17. 自定义加密模块
18. 在线媒体流推流模块
19. CDN直播模块
20. 广播消息模块
21. 摄像头控制模块
22. 屏幕共享模块
23. 设备管理模块
24. SEI补充增强信息模块
25. 等等....

### 1.2 关于费用
anyRTC 新版本SDK，在5月~7月之间免费使用，免费之后，按照官网标准报价:[价格](https://www.anyrtc.io/price),优惠信息请联系客服sales@dync.cc

## 二. SDK大事记 
### 2.1 20年发布大事记  
1. 2020.03.10 新版本SDK规划-能承载亿万级并发的架构；
1. 2020.04.10 SDK基础框架发布；
1. 2020.04.30 4.0.0bate版本发布：核心模块/音频模块/视频模块/音频路由控制模块/耳返/大小流模块/摄像头控制模块；

### 2.2 近期工作   

1. 2020.05:release版本发布;
1. 2020.06:录制网关(本地录制、云录制)、小程序网关、SIP网关;
3. 2020.07:官网改版升级;
4. 2020.07:官网改版升级;

## 三. SDK集成方法介绍   
### 3.1 系统要求    
* 最低支持iOS版本：iOS 9.0
* 最低支持iPhone型号：iPhone 5s
* 支持CPU架构： armv7s,arm64

### 3.2 下载工程
本SDK 提供如下列出获取方式:     

#### 3.2.1 从[github](<https://github.com/anyRTC/ArIOSSDK.git>) clone

目录结构如下所示:  
- Demo        : Demo工程 ，演示本SDK的主要接口的使用
- Release  : SDK
- README.md    : SDK介绍

```
$ git clone https://github.com/anyRTC/ArIOSSDK.git
```

#### 3.2.2 使用Cocoapods 进行安装    
通过Cocoapods 能将本SDK的静态库和代码下载到本地，只需要将类似如下语句中的一句加入你的Podfile：   
```ruby
pod 'ARtcKit'
```
执行 pod install即可.  

### 3.3 集成时的注意事项
* 本framework暂时不支持bitcode
* 本framework为动态库，虽然库的大小为20M+，但是最后链接后，对app的增量只有5M+
* 如果使用cocoapod官方库Trunk时,发现找不到最新版本的库, 需要先执行如下命令, 更新spec库
```
pod repo update
```

## 四. 使用示例
请见github库：<https://github.com/anyRTC/ArIOSSDK.git>

## 五. 反馈与建议
### 5.1 联系方式

* 主页：[anyRTC](https://www.anyrtc.io/)
* Issues:<https://github.com/anyRTC/ArIOSSDK/issues>
* QQ技术交流群：554714720
* 联系电话:021-65650071-816
* Email:[hi@dync.cc](mailto:hi@dync.cc)
