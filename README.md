# DYRealTimeSDK

## 简介

DYRealTimeSDK(实时音视频SDK)

本SDK封装了`多厂商的音视频SDK`和`相应的即时通讯SDK`

1. 简化和统一了各厂商服务注册和接口调用方式
2. 支持在各厂商SDK之间安全、高效地调度(目前支持声网、腾讯)
3. 多条通道并行发送自定义消息和消息去重
4. 封装了日志模块（厂商log，自定义log，DDLog），用于数据跟踪和后续分析
5. 解决多SDK引入和编译问题

>集成的SDK列表：
>- MQTT（MQTT SDK）- 常驻
>- TIM（腾讯即时通讯SDK）- 常驻
>- TXLiteAVSDK_TRTC（腾讯音视频SDK）
>- AgoraRtcEngine_iOS（声网音视频SDK）
>- AgoraRtmKit（声网即时通讯SDK）
>- 日志模块（基于`CocoaLumberjack/Swift`）

## Carthage引入
 
- 业务路径新建`Cartfile`，编辑
 ```
git "https://github.com/jackleemeta/DYEntireRealTimeSDK.git"  >= 0.0.1
 ```

> ### 需要手动引入MQTT等依赖库


## CocoaPods引入（推荐）

### 引入

- 编辑podfile，添加source
```
source 'https://cdn.cocoapods.org'
```

- 依赖方式（任选其一）

1. framework依赖（推荐）
```
pod 'DYEntireRealTimeSDK'
或
pod 'DYEntireRealTimeSDK/Framework'
```

2. 源码依赖
```
pod 'DYEntireRealTimeSDK/Source'
```

- note: pod install优先本地缓存

### 使用

- import
  - framework依赖方式 - import：DYRealTimeSDK
  - 源码依赖 - import：DYEntireRealTimeSDK

- Init

```
var auth = DYRealTimeSDKAuthenticationConfig()
var setting = DYRealTimeSettingConfig()
var user = DYRealTimeSDKUserConfig()

var mqttConfig = DYRealTimeSettingConfig.DYMQTTConfig()
setting.mqttConfig = mqttConfig

realTimeSDK = DYRealTimeSDK(sdk: .agora,
                            authenticationConfig: auth,
                            settingConfig: setting,
                            userConfig: user,
                            delegate: self)
```

- engine

```
realTimeSDK?.engine()
```

- Register Protocol

```
extension Registrant: DYRealTimeSDKProtocol {}
```

- 发送消息

```
realTimeSDK?.sendMessage(msgId: msgId, msg: msg, receiverIds: [receiverId], topic: topic)
```

- 切换sdk

```
realTimeSDK?.switch(to: sdk, 
                    with: auth,
                    switchedCallBack: { isSuccess in
                       if !isSuccess { return }
                       //code
                    })

```

- 切换房间

```
realTimeSDK?.switch(to: user, 
                    switchedCallBack: { isSuccess in
                       if !isSuccess { return }
                       //code
                    })
```

- SDK主动销毁

1、统一行为：

> mqtt断开连接

> TIM登出

2、各个模式下的行为：

> 声网模式：
> 
> AgoraRtcEngine_iOS登出、sdk销毁
>
> AgoraRtmKit登出、sdk销毁

或

> 腾讯模式：
>
> TRTC登出、sdk销毁

```
realTimeSDK?.destroy(callBack:)
```

- 设置SDK日志路径

```
DYRealTimeSDK.setLogFilePath(path)
```

- 获取SDK日志Logger - DDFileLogger

```
DYRealTimeSDK.ddFileLogger
```

- 获取【子SDK - Agora】日志路径

```
DYRealTimeSDK.sortedAgoraLogFileInfos
```

- 获取【子SDK - TRTC】日志路径

```
DYRealTimeSDK.sortedTRTCLogFileInfos
```

# 当前三方音视频SDK版本
- AgoraRtcEngine_iOS(2.9.0.105)
- TXLiteAVSDK_TRTC(7.2.8980)

# 在XCode12，Carthage编译失败问题及临时解决方案
- 相关issus: https://github.com/Carthage/Carthage/issues/3019
- 临时解决方案：

```
1. Save the script (👇) to your project (e.g. as a carthage.sh file).

2. Make the script executable chmod +x carthage.sh

3. Instead of calling carthage ... call ./carthage.sh ...
E.g. ./carthage.sh build or ./carthage.sh update --use-submodules

```

- [script](./carthage.sh)

