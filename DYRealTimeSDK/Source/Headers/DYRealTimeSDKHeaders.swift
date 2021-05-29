//
//  DYRealTimeSDKHeaders.swift
//  RealTimeDemo
//
//  Created by beck tian on 2019/12/5.
//  Copyright © 2019 beck tian. All rights reserved.
//

/// 关键字段
public typealias DYMessageKeys = (msgId: String?, uid: String?, roomId: String?)

/// MQTT Topic
public typealias DYTopic = String

/// SDK鉴权配置
public struct DYRealTimeSDKAuthenticationConfig {
    public var sdkId: String = "" //sdkId
    public var sdkSign: String = "" //实时音视频 签名
    public var sdkSignalSign: String = "" //实时音视频相对应信令通道 签名
    public var expired_time: Int = 604800
    public init() {}
}

/// SDK用户配置
public struct DYRealTimeSDKUserConfig {
    public var roomId: String = ""
    public var account: String = ""
    public init() {}
}

/// SDK基础功能设置
public struct DYRealTimeSettingConfig {
    
    /// MQTT基础配置
    public struct DYMQTTConfig {
        public var host: String? // defalut 192.168.2.198
        public var port: Int?
        public var keepAlive: Int?
        public var clientId: String?
        public var username: String?
        public var password: String?
        public var topics: [DYTopic]?
        
        public init() {}
    }
    
    /// Tencent Instant Messaging(TIM)基础配置
    public struct DYTIMConfig {
        public var appId: String?
        public var sign: String = "" // Tencent Instant Messaging SDK 签名
        public init() {}
    }
    
    /**
     - Note: 不注入时，默认使用原业务项目中的逻辑
     */
    public var mqttConfig: DYMQTTConfig?
    
    public var timConfig: DYTIMConfig?
    
    /**
     SDK监听【进入房间】自定义消息
     - Note:
        - 原则上SDK管理【进入房间】消息，当有【自定义的进入消息】时，建议注入【进入房间】控制协议
        - 不注入，SDK会调用receivedMessage(uid:msgId:msg:)
        - 注入后，SDK会调用joinRoom(isSuccess:uid:) 和 receivedMessage(uid:msgId:msg:)
        - 建议在joinRoom(isSuccess:uid:)中进行【进入房间】管理，在receivedMessage(uid:msgId:msg:)中根据msg进行UI更新等操作
     */
    public var messgeTypeOfJoinRoom: NSObject?
    
    /**
    SDK监听【退出房间】自定义消息
    - Note:
       - 原则上SDK管理【退出房间】消息，当有【自定义的退出消息】时，建议注入【退出房间】控制协议
       - 不注入，SDK会调用receivedMessage(uid:msgId:msg:)
       - 注入后，SDK会调用leftRoom(uid:reason:completion:) 和 receivedMessage(uid:msgId:msg:)
       - 建议在leftRoom(uid:reason:completion:)中进行【退出房间】管理，在receivedMessage(uid:msgId:msg:)中根据msg进行UI更新等操作
    */
    public var messgeTypeOfLeftRoom: NSObject?
    public var timeOffSet: Int64?
    /// 是否允许高频log及显示在控制台
    public var allowHighFrequencyLog = true
    public init() {}
}

public extension DYRealTimeSDKUserConfig {
    var isLegalMe: Bool {
        return account.count > 0
    }
}

/// SDK类型
public enum DYRealTimeSDKType: Int {
    case old_trtc = 1
    case agora = 2
    case agora_live = 3 // 声网直播模式
    case zego = 4
    case trtc = 5
}

/// 消息通道
public struct DYRealTimeSDKPipe: OptionSet {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let mqtt = DYRealTimeSDKPipe(rawValue: 1 << 0)
    public static let tim = DYRealTimeSDKPipe(rawValue: 1 << 1)
    public static let rtc = DYRealTimeSDKPipe(rawValue: 1 << 2)
    public static let signal = DYRealTimeSDKPipe(rawValue: 1 << 3)
    public static let all: DYRealTimeSDKPipe  = [.mqtt, .tim, .rtc, .signal]
    
}

/// 网络质量
public enum DYRealTimeSDKNetworkQuality: String {
    case good = "good"
    case medium = "medium"
    case bad = "bad"
    case unknown = "unknown"
}

/// 退房原因
public enum DYRealTimeSDKLeaveReason: Int {
    case voluntary//主动退出
    case extrusion//被挤出
    case offline//网络质量差
    case ignore//退出原因忽略
}

/// 网络连接状况
public enum DYRealTimeSDKConnectStatus: String {
    case connecting = "正在连接"//正在连接
    case succeed = "已连接"//已连接
    case failed = "连接失败"//连接失败
    case disconnected = "连接断开"//连接断开
    case recovery = "连接已恢复"//已恢复
}

/// SDK基础信息
public struct DYRealTimeSDKBaseInformation {
    public var sdkVersion: String?
    public var thirdRtcSDKType: DYRealTimeSDKType?
    public var thirdRtcSDKName: String?
    public var thirdRtcVersion: String?
    public init() {}
}
