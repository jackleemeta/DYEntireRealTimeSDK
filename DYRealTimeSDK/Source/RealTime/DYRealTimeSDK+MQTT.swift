//
//  DYRealTimeSDK+MQTT.swift
//  DYRealTimeSDK
//
//  Created by diff on 2020/4/29.
//  Copyright © 2020 beck tian. All rights reserved.
//


extension DYRealTimeSDK {
    
    func initMQTT(with settingConfig: DYRealTimeSettingConfig) {
        
        if Self.manager == nil { return }
        
        let setting = MQTTSetting()
        
        setting.uid = Self.manager?.userConfig.account
        setting.roomId = Self.manager?.userConfig.roomId ?? ""
        
        if let mqttConfig = settingConfig.mqttConfig {
            
            if let host = mqttConfig.host {
                setting.host = host
            }
            
            if let port = mqttConfig.port {
                setting.port = port
            }
            
            if let keepAlive = mqttConfig.keepAlive {
                setting.keepAlive = keepAlive
            }
            
            if let clientId = mqttConfig.clientId {
                setting.clientId = clientId
            }
            
            if let username = mqttConfig.username {
                setting.username = username
            }
            
            if let password = mqttConfig.password {
                setting.password = password
            }
            
            if let topics = mqttConfig.topics {
                setting.topics = topics
            }
            
        }
        
        mqtt = MQTTManager(setting: setting)
        mqtt?.delegate = self
    }
    
    func connectMQTT() {// 连接MQTT
        mqtt?.connect()
    }
    
    func disconnectMQTT() {// 断开MQTT
        leaveMQTTChannel() // 离开频道
        mqtt?.disconnect() // 断开连接
    }
    
    // 加入MQTT房间
    func joinMQTTChannel() {
        mqtt?.joinChannel()
        log_joinMQTT()
    }
    
    // 退出MQTT房间
    func leaveMQTTChannel() {
        mqtt?.leaveChannel() // 离开频道
        log_leaveMQTT()
    }
}

/// Internal CallBack Method - MQTT 相关
extension DYRealTimeSDK: MQTTManagerProtocol {
    
    func mqttDidConnected() {// 连接成功的回调
        joinMQTTChannel()
        let succeed = DYRealTimeSDKConnectStatus.succeed
        Self.manager?.onConnectStatus(status: succeed, message: "mqtt\(succeed.rawValue)", pipe: .mqtt)
    }

    func mqttDidDisconnect(_ error: Swift.Error?) {// 关闭连接的回调
        if let _ = error {// 非正常关闭连接
            let disconnected = DYRealTimeSDKConnectStatus.disconnected
            Self.manager?.onConnectStatus(status: disconnected, message: "mqtt\(disconnected.rawValue)", pipe: .mqtt)
        } else {
            Self.manager?.leftRoom_duplicateRemoval(uid: userConfig.account, reason: .voluntary, pipe: .mqtt)
        }
    }

    func mqttOnChannelJoin() {// 加入频道的回调
        Self.manager?.joinRoom_duplicateRemoval(isSuccess: true, uid: userConfig.account, pipe: .mqtt)
    }

    func mqttOnChannelLeave() {// 离开频道的回调
        Self.manager?.leftRoom_duplicateRemoval(uid: userConfig.account, reason: .ignore, pipe: .mqtt)
    }

    func mqttOnMessageReceive(_ msg: String) {// 收到消息的回调
        Self.manager?.receivedMessage_duplicateRemoval(uid: "", msgId: "", msg: msg, pipe: .mqtt)
    }

    func mqttOnMessageSend(_ msg: String) {// 消息发送成功的回调
        Self.manager?.sentMessage(isSuccess: true, uid: "", msgId: "", msg: msg, pipe: .mqtt)
    }

}

