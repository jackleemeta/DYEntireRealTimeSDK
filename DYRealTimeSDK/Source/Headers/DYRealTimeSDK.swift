//
//  DYRealTimeSDK.swift
//  DYRealTimeSDKDemo
//
//  Created by beck tian on 2019/12/8.
//  Copyright © 2019 beck tian. All rights reserved.
//

import CocoaLumberjack

// MARK: - 基础Api
public final class DYRealTimeSDK {
    
    /**
     获取当前服务商
     */
    public var sdk: DYRealTimeSDKType? {
        if Self.manager is AgoraManager { return .agora }
        if Self.manager is TRTCManager { return .trtc }
        return nil
    }
    
    /**
     获取当前鉴权配置
     */
    public var authConfig: DYRealTimeSDKAuthenticationConfig {
        return Self.manager?.authenticationConfig ?? DYRealTimeSDKAuthenticationConfig()
    }
    
    /**
     获取当前用户配置
     */
    public var userConfig: DYRealTimeSDKUserConfig {
        return Self.manager?.userConfig ?? DYRealTimeSDKUserConfig()
    }
    
    /**
     获取SDK基础信息
     */
    public class var baseInformation: DYRealTimeSDKBaseInformation {
        var bi = manager?.baseInformation ?? DYRealTimeSDKBaseInformation()
        bi.sdkVersion = "0.0.4"
        return bi
    }
    
    /**
     sdk 已被销毁 true ;  未被销毁 false
     */
    public class var isDestroyed: Bool {
        return manager == nil
    }
    
    /**
     初始化sdk接口
     - Parameters:
        - sdk: 服务商 声网 或 腾讯
        - authenticationConfig: 鉴权配置
        - settingConfig: mqtt等基础配置
        - userConfig: 用户配置
        - delegate: 受托方
     */
    public init(sdk: DYRealTimeSDKType,
                authenticationConfig: DYRealTimeSDKAuthenticationConfig,
                settingConfig: DYRealTimeSettingConfig,
                userConfig: DYRealTimeSDKUserConfig,
                delegate: DYRealTimeSDKProtocol) {
        
        DYRealTimeSDKActionLog.timeOffset = settingConfig.timeOffSet
        DYRealTimeSDKActionLog.allowHighFrequencyLog = settingConfig.allowHighFrequencyLog
        Self.manager = generateManager(sdk: sdk,
                                       authenticationConfig: authenticationConfig,
                                       userConfig: userConfig,
                                       delegate: delegate)
        
        Self.manager?.messgeTypeOfJoinRoom = settingConfig.messgeTypeOfJoinRoom
        Self.manager?.messgeTypeOfLeftRoom = settingConfig.messgeTypeOfLeftRoom
    
        initMQTT(with: settingConfig)
        initTIMKit(with: settingConfig)
    }
    
    /**
     sdk启动
     */
    public func engine() {
        connectMQTT()
        joinTimKit()
        Self.manager?.engine()
    }
    
    /**
     sdk重启
     */
    public func reengine() {
        engine()
    }
    
    /**
     离开房间
     - Parameters:
        - callBack: 离开房间成功的回调
     */
    public func leaveRoom(_ callBack: ((Bool)->())? = nil) {
        disconnectMQTT()
        leaveTIMKit()
        Self.manager?.leaveRoom(callBack)
    }
    
    /**
     离开房间并销毁三方视讯商相关资源
     - Parameters:
       - callBack: 离开房间并销毁资源成功的回调
     */
    public func destroy(_ callBack: ((_ isSuccess: Bool)->())? = nil) {
        flameout(callBack)
    }
    
    //MARK: - Internal & Private API
    
    /// - Note: 为了处理DYRealTimeSDK销毁后的一些三方回调，manager生命周期需要比DYRealTimeSDK长
    static var manager: DYRealTimeManager?
    
    var mqtt: MQTTManager?
    
    var timKit: TIMKit?
        
    private init() {}
    
    ///deinit
    deinit {
        flameout()
    }
    
}
// MARK: - 发送消息
extension DYRealTimeSDK {
    
    /**
     发送消息
     - Parameters:
        - msgId: 消息id
        - msg: 消息
        - receiverIds: 接收者id集合
        - topic: mqtt主题
        - pipe: 消息通道（默认全部）
     */
    public func sendMessage(msgId: String,
                            msg: String,
                            receiverIds: Set<String>? = nil,
                            topic: DYTopic? = nil,
                            pipe: DYRealTimeSDKPipe = .all) {
        
        // MQTT发送
        if let topic = topic, pipe.contains(.mqtt) {
            mqtt?.sendMessage(msg, topic: topic)
            log_sendMQTTMessage(msgId: msgId, msg: msg, receiverIds: receiverIds)
        }
        
        // tim发送
        if let receiverIds = receiverIds, pipe.contains(.tim) {
            timKit?.sendMessage(msgID: msgId, msg: msg, receiverIds: receiverIds)//IM发送
        }

        // rtc发送
        if pipe.contains(.rtc) {
            Self.manager?.sendMessage(msgId: msgId, msg: msg, receiverIds: receiverIds)
        }
        
        // signal发送
        if pipe.contains(.signal) {
            Self.manager?.sendSignalMessage(msgId: msgId, msg: msg, receiverIds: receiverIds)
        }
        
        // 去重操作
        Self.manager?.processFurtherMessage(msgId: msgId,
                                            msg: msg,
                                            receiverIds: receiverIds,
                                            pipe: pipe)
    }
    
    /**
     设置遗言消息
     - Parameters:
        - msg: message
        - topic: mqtt主题
    */
    public func setWillMessage(msg: String,
                               forTopic topic: DYTopic) {
        mqtt?.setWillMessage(msg, topic: topic)
    }

}

// MARK: - 切换音视频服务商、房间API
extension DYRealTimeSDK {
    
    /**
     切换实时音视频服务商
     - Parameters:
        - sdk: 声网 或 腾讯
        - auth: 鉴权
        - switchedCallBack: 切换回调
     */
    public func `switch`(to sdk: DYRealTimeSDKType,
                         with auth: DYRealTimeSDKAuthenticationConfig? = nil,
                         switchedCallBack: ((Bool)->())? = nil) {
        
        guard let manager = Self.manager else { switchedCallBack?(false); return }
        guard let delegate = manager.delegate else { switchedCallBack?(false); return }
        if sdk == self.sdk { switchedCallBack?(false); return }
        
        if manager.isHaveExtruded { switchedCallBack?(false); return }
        
        let toAuth: DYRealTimeSDKAuthenticationConfig //处理鉴权数据
        if let aAuth = auth {
            toAuth = aAuth
        } else {
            toAuth = manager.authenticationConfig
        }
        
        manager.destroy { [weak self] _ in
            guard let `self` = self else { return }
            Self.manager = self.generateManager(sdk: sdk,
                                                authenticationConfig: toAuth,
                                                userConfig: manager.userConfig,
                                                delegate: delegate)
            Self.manager?.sdkSwitchedBlock = switchedCallBack
            Self.manager?.engine()
        }
        
    }
    
    /**
     修改房间
     - Parameters:
        - userConfig: 用户配置
        - auth: 鉴权
        - switchedCallBack: 切换回调
     */
    public func `switch`(to userConfig: DYRealTimeSDKUserConfig,
                         with auth: DYRealTimeSDKAuthenticationConfig? = nil,
                         switchedCallBack: ((Bool)->())? = nil) {
        
        guard let manager = Self.manager else { switchedCallBack?(false); return }
        
        if manager.isHaveExtruded { switchedCallBack?(false); return }
        
        let currentUserConfig = manager.userConfig
        
        if userConfig.roomId == currentUserConfig.roomId { switchedCallBack?(false); return }// 房间相同
        
        let toAuth: DYRealTimeSDKAuthenticationConfig // 处理鉴权数据
        if let aAuth = auth {
            toAuth = aAuth
        } else {
            toAuth = manager.authenticationConfig
        }
        
        // MQTT离开房间后再重新进房
        mqtt?.leaveChannel()
        manager.didMQTTLeaveCallBack = { [weak self] _ in
            guard let `self` = self else { return }
            self.mqtt?.currentSetting.uid = userConfig.account
            self.mqtt?.currentSetting.roomId = userConfig.roomId
            self.joinMQTTChannel()
        }
        
        // 应sdk的建议，离房回调成功后再重新进房
        manager.leaveRoom { [weak manager] _ in
            guard let `manager` = manager else { return }
            manager.resetConfig(authConfig: toAuth, userConfig: userConfig)
            manager.joinRoom()
            manager.sdkSwitchedBlock = switchedCallBack
        }
    }
    
}

// MARK: - 音视频API
extension DYRealTimeSDK {
    
    /**
     开始混音
     - Parameters:
        - filePath: filePath
        - loopback: loopback
        - replace: replace
        - cycle: cycle
        - finishedCallBack: finishedCallBack
     */
    public func startAudioMixing(_ filePath: String!,
                                 loopback: Bool,
                                 replace: Bool,
                                 cycle: Int,
                                 finishedCallBack: (() -> ())?) {
        Self.manager?.startAudioMixing(filePath, loopback: loopback, replace: replace, cycle: cycle, finishedCallBack: finishedCallBack)
    }
    
    /**
     停止
     */
    public func stopAudioMixing() {
        Self.manager?.stopAudioMixing()
    }
    /**
     暂停
     */
    public func pauseAudioMixing() {
        Self.manager?.pauseAudioMixing()
    }
    
    /**
     恢复
     */
    public func resumeAudioMixing() {
        Self.manager?.resumeAudioMixing()
    }
    
    /**
     适配音量
     */
    public func adjustAudioMixingVolume(_ volume: Int) {
        Self.manager?.adjustAudioMixingVolume(volume)
    }
    
    /**
     静音视频
     */
    public func muteLocalVideoStream(_ mute: Bool) {
        Self.manager?.muteLocalVideoStream(mute)
    }
    
    /**
     静音音频
     */
    public func muteLocalAudioStream(_ status: Bool) {
        Self.manager?.muteLocalAudioStream(status)
    }
    
    /**
     静音远端音频
     */
    public func muteRemoteAudioStream(_ mute: Bool, userId:String) {
        Self.manager?.muteRemoteAudioStream(mute, userId: userId)
    }

}

// MARK: - 日志API
extension DYRealTimeSDK {
    
    /**
     设置SDK日志路径
     - 默认路径 - Library/Caches/actionLogs
     - 如需修改，必须在所有方法前调用
     - Parameter path: 日志路径
     */
    public class func setLogFilePath(_ path: String) {
        DYRealTimeSDKActionLog.filePath = path
    }
    
    /**
     获取SDK日志Logger - DDFileLogger
     - DDFileLogger默认路径 - Library/Caches/actionLogs
     - 如调用过setLogFilePath，DDFileLogger的路径则为注入路径
     */
    public class var ddFileLogger: DDFileLogger? {
        return DYRealTimeSDKActionLog.ddFileLogger
    }
    
    /**
     获取【子SDK - Agora】日志路径
     - 路径 - Library/Caches/agoraLogs
     */
    public class var sortedAgoraLogFileInfos: [DDLogFileInfo]? {
        return AgoraManager.sortedAgoraLogFileInfos
    }
    
    /**
     获取【子SDK - TRTC】日志路径
     - 路径 - Library/Caches/trtcLogs
     */
    public class var sortedTRTCLogFileInfos: [DDLogFileInfo]? {
        return TRTCManager.sortedAgoraLogFileInfos
    }
    
}
