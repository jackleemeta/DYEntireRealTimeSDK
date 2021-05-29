//
//  MQTTManager.swift
//
//  Created by beck tian on 2017/6/16.
//  Copyright © 2017年 beck tian. All rights reserved.
//

import CocoaMQTT
import CocoaLumberjack

protocol MQTTManagerProtocol: AnyObject {
    
    func mqttDidConnected()
    func mqttDidDisconnect(_ error: Swift.Error?)
    func mqttOnChannelJoin()
    func mqttOnChannelLeave()
    func mqttOnMessageReceive(_ msg: String)
    func mqttOnMessageSend(_ msg: String)
}

final class MQTTManager: NSObject {
    
    weak var delegate: MQTTManagerProtocol?
    
    private var subscribedTopics = Set<DYTopic>()

    fileprivate var cocoaMqtt: CocoaMQTT?
    
    fileprivate var autoReconnect = true
    fileprivate let reconnectDelay: Double = 10
        
    let currentSetting: MQTTSetting
    
    private var didPublishMsgKeyPairs = [UInt16: String]()
    
    private var isHaveConnectResult = false
    
    init(setting: MQTTSetting) {
        currentSetting = setting
       
        super.init()
        DDLogInfo("MQTT init")
        
        guard let host = currentSetting.host, host.count > 0 else {
            DDLogInfo("MQTT.host = nil 或 MQTT.host长度为0")
            return
        }
       
        cocoaMqtt = CocoaMQTT(clientID: setting.clientId ?? "",
                              host: host,
                              port: UInt16(currentSetting.port))
        
        DDLogInfo("<<<<<<\(String(describing: setting.clientId))>>>>>>")
        
        guard let cocoaMqtt = cocoaMqtt else {
            DDLogInfo("cocoaMqtt 初始化失败, reason：初始化参数有误")
            return
        }
        
        cocoaMqtt.delegate = self
        cocoaMqtt.keepAlive = UInt16(currentSetting.keepAlive)
        
        DDLogInfo("cocoaMqtt 初始化成功")
    }
    
}

// MARK: Public Method
extension MQTTManager {
    
    func connect() {
        DDLogInfo("MQTT connect")
        
        let param = ["usernameExsit": currentSetting.username != nil,
                     "passwordExsit":currentSetting.password != nil]
        
        DYRealTimeSDKActionLog.log(.joinchannel, pipe: .mqtt, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(DYRealTimeSDKPipe.mqtt.rawValue), param = \(param)")
        
        guard let cocoaMqtt = cocoaMqtt else {
            DDLogInfo("MQTT连接失败，reason: cocoaMqtt初始化失败，cocoaMqtt实例不存在")
            return
        }
        
        cocoaMqtt.username = currentSetting.username
        cocoaMqtt.password = currentSetting.password
        
        DDLogInfo("<<<<<<\(cocoaMqtt.username ?? "")>>>>>>")
        DDLogInfo("<<<<<<\(cocoaMqtt.password ?? "")>>>>>>")
        
        _ = cocoaMqtt.connect()
        
        autoReconnect = true
        
        isHaveConnectResult = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self] in
            guard let `self` = self else { return }
            if !self.isHaveConnectResult {
                self.connect()
            }
        }
        
    }
    
    func disconnect() {
        
        guard let cocoaMqtt = cocoaMqtt else {
            DDLogInfo("MQTT不需要断开连接，reason: cocoaMqtt实例不存在")
            return
        }
        
        DDLogInfo("MQTT disconnect")
        DYRealTimeSDKActionLog.log(.exitchannel, pipe: .mqtt, param: ["uid": currentSetting.uid ?? ""])
        
        cocoaMqtt.disconnect()
        isHaveConnectResult = true
        autoReconnect = false
    }
    
    func setWillMessage(_ msg: String, topic: DYTopic) {
        
        if currentSetting.topics?.contains(topic) == true {
            DDLogInfo("MQTT setWillMessage topic = \(topic) 已订阅: \(msg), currentSetting.roomId: \(currentSetting.roomId)")
        } else {
            DDLogInfo("MQTT setWillMessage topic = \(topic) 未订阅: \(msg), currentSetting.roomId: \(currentSetting.roomId)")
        }
        
        guard let cocoaMqtt = cocoaMqtt else {
            DDLogInfo("MQTT不需要设置遗言消息，reason: cocoaMqtt实例不存在")
            return
        }
        
        cocoaMqtt.willMessage = CocoaMQTTWill(topic: topic, message: msg)
    }
    
    func joinChannel() {
        DDLogInfo("MQTT joinChannel currentSetting.roomId: \(currentSetting.roomId)")
        DYRealTimeSDKActionLog.log(.joinchannel, pipe: .mqtt, param: ["uid": currentSetting.uid ?? "", "channelid": currentSetting.roomId])
        subAllTopic()
    }
    
    func leaveChannel() {
        DDLogInfo("MQTT leaveChannel currentSetting.roomId: \(currentSetting.roomId)")
        DYRealTimeSDKActionLog.log(.exitchannel, pipe: .mqtt, param: ["uid": currentSetting.uid ?? "", "channelid": currentSetting.roomId])
        
        unsubAllTopic()
    }
    
    func sendMessage(_ msg: String,
                     topic: DYTopic) {
        
        if currentSetting.topics?.contains(topic) == true {
            DDLogInfo("MQTT sendMessage topic = \(topic) 已订阅: \(msg), currentSetting.roomId: \(currentSetting.roomId)")
        } else {
            DDLogInfo("MQTT sendMessage topic = \(topic) 未订阅: \(msg), currentSetting.roomId: \(currentSetting.roomId)")
        }
        
        cocoaMqtt?.publish(topic,
                           withString: msg,
                           qos: currentSetting.qosLevel,
                           retained: false,
                           dup: false)
    }
    
}

extension MQTTManager: CocoaMQTTDelegate {
    
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        DDLogInfo("MQTT didConnect: \(host) : \(port)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        DDLogInfo("MQTT didConnectAck: \(ack.describing)")
        
        switch ack {
        case .accept:
            isHaveConnectResult = true
            delegate?.mqttDidConnected()
            
        default:
            DDLogError("ack = \(ack.rawValue)")
        }
        
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Swift.Error?) {
        DDLogInfo("MQTT didDisconnect \(String(describing:err))")
        var param = ["uid": currentSetting.uid ?? ""]
        if let error = err {
            param["cause"] = error.localizedDescription
        }
        
        delegate?.mqttDidDisconnect(err)
        
        isHaveConnectResult = true
        
        if let _ = err {
            reconnect()
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        DDLogInfo("MQTT didSubscribeTopic: \(topic)")
        
        subscribedTopics.insert(topic)
        
        guard let allTopicsAry = currentSetting.topics else { return }
        
        let allTopics = Set(allTopicsAry)
        
        if allTopics == subscribedTopics { // 所有的topic已经订阅
            DYRealTimeSDKActionLog.log(.joinchannel_success, pipe: .mqtt, param: ["isDelayJudge": false])
            delegate?.mqttOnChannelJoin()
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        DDLogInfo("MQTT didUnsubscribeTopic: \(topic)")
        
        subscribedTopics.remove(topic)
                
        if subscribedTopics.count == 0 { // 所有的topic已经取消订阅
            DYRealTimeSDKActionLog.log(.exitchannel_success, pipe: .mqtt, param: ["isDelayJudge": false])
            delegate?.mqttOnChannelLeave()
        }
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        DDLogInfo("MQTT didReceiveMessage: \(message.string ?? ""), topic: \(message.topic), id: \(id)")
        delegate?.mqttOnMessageReceive(message.string ?? "")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        DDLogInfo("MQTT didPublishMessageResultUnknown: \(message.string ?? ""), topic: \(message.topic)")
        didPublishMsgKeyPairs[id] = message.string ?? ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [weak self] in
            guard let `self` = self else { return }
            self.didPublishMsgKeyPairs.removeValue(forKey: id)
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        DDLogInfo("MQTT didPublishAck: \(id)")
        if let msg = didPublishMsgKeyPairs[id] {
            DDLogInfo("MQTT didPublishMessageSuccess: \(msg), \(id)")
            delegate?.mqttOnMessageSend(msg)
            didPublishMsgKeyPairs.removeValue(forKey: id)
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishComplete id: UInt16) {
        DDLogInfo("MQTT didPublishComplete \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        DDLogInfo("MQTT didReceivetrust")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        DDLogInfo("MQTT didPing")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        DDLogInfo("MQTT didReceivePong")
    }
}

// MARK: Private Method
extension MQTTManager {
    
    private func subAllTopic() {
        currentSetting.topics?.forEach { topic in
            cocoaMqtt?.subscribe(topic, qos: currentSetting.qosLevel)
        }
        
        subAllTopicDelayJudge()
    }
    
    private func unsubAllTopic() {
        currentSetting.topics?.forEach { topic in
            cocoaMqtt?.unsubscribe(topic)
        }
        
        unsubAllTopicDelayJudge()
    }
    
    private func reconnect() {
        DispatchQueue.main.asyncAfter(deadline: .now() + reconnectDelay) { [weak self] in
            guard let `self` = self else { return }
            if self.autoReconnect {
                self.connect()
            }
        }
    }
    
    private func subAllTopicDelayJudge() {
        let time: TimeInterval = 10
        DispatchQueue.main.asyncAfter(deadline: .now() + time) { [weak self] in
            guard let `self` = self else { return }
            guard let allTopicsAry = self.currentSetting.topics else { return }
            let allTopics = Set(allTopicsAry)
            if self.subscribedTopics != allTopics, self.subscribedTopics.count > 0  {
                DYRealTimeSDKActionLog.log(.joinchannel_success, pipe: .mqtt, param: ["isDelayJudge": true])
                self.delegate?.mqttOnChannelJoin()
            }
        }
    }
    
    private func unsubAllTopicDelayJudge() {
        let time: TimeInterval = 8
        DispatchQueue.main.asyncAfter(deadline: .now() + time) { [weak self] in
            guard let `self` = self else { return }
            if self.subscribedTopics.count != 0 {
                DYRealTimeSDKActionLog.log(.exitchannel_success, pipe: .mqtt, param: ["isDelayJudge": true])
                self.delegate?.mqttOnChannelLeave()
            }
        }
    }
    
}

extension CocoaMQTTConnAck {
    var describing: String {
        get {
            switch self {
            case .accept:
                return "accept"
            case .unacceptableProtocolVersion:
                return "unacceptableProtocolVersion"
            case .identifierRejected:
                return "identifierRejected"
            case .serverUnavailable:
                return "serverUnavailable"
            case .badUsernameOrPassword:
                return "badUsernameOrPassword"
            case .notAuthorized:
                return "notAuthorized"
            default:
                return "reserved"
            }
        }
    }
}
