//
//  DYRealTimeSDK+LogAdd.swift
//  DYRealTimeSDK
//
//  Created by diff on 2020/5/15.
//  Copyright © 2020 beck tian. All rights reserved.
//

extension DYRealTimeSDK {
    /// 日志 - 加入MQTT CHANNEL
    func log_joinMQTT() {
        let param = ["roomId": userConfig.roomId]
        DYRealTimeSDKActionLog.log(.joinchannel, pipe: .mqtt, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(DYRealTimeSDKPipe.mqtt.rawValue), 加入房间")
    }
    
    /// 日志 - 离开MQTT CHANNEL
    func log_leaveMQTT() {
        let param = ["roomId": userConfig.roomId]
        DYRealTimeSDKActionLog.log(.exitchannel, pipe: .mqtt, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(DYRealTimeSDKPipe.mqtt.rawValue), 退出房间")
    }
    
    /// 日志 - 发送MQTT消息
    func log_sendMQTTMessage(msgId: String, msg: String, receiverIds: Set<String>? = nil) {
        var param: [String: Any] = ["roomId": userConfig.roomId,
                                    "msgId": msgId,
                                    "msg": msg]
        if receiverIds != nil { param["receiverIds"] = receiverIds! }
        DYRealTimeSDKActionLog.log(.message_send, pipe: .mqtt, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(DYRealTimeSDKPipe.mqtt.rawValue), param = \(param)，发送消息")
    }
    
    /// 日志 - 加入TIM
    func log_joinTimKit() {
        let param = ["roomId": userConfig.roomId]
        DYRealTimeSDKActionLog.log(.joinchannel, pipe: .tim, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(DYRealTimeSDKPipe.tim.rawValue), 加入房间")
    }
    
    /// 日志 - 离开TIM
    func log_leaveTimKit() {
        let param = ["roomId": userConfig.roomId]
        DYRealTimeSDKActionLog.log(.exitchannel, pipe: .tim, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(DYRealTimeSDKPipe.tim.rawValue), 退出房间")
    }
}
