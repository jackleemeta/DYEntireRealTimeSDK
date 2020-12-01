//
//  MQTTSetting.swift
//
//  Created by beck tian on 2017/6/16.
//  Copyright © 2017年 beck tian. All rights reserved.
//


import CocoaMQTT
import CocoaLumberjack

final class MQTTSetting {
    
    var host: String?
    
    var password: String?
    
    var port = 1883 // 服务端端口号
    var keepAlive = 60 // 心跳时间，单位秒，每隔固定时间发送心跳包
    let qosLevel: CocoaMQTTQOS = .qos1
    
    var roomId: String = ""
    var uid: String?
    
    /**
     客户端id，需要特别指出的是这个id需要全局唯一，因为服务端是根据这个来区分不同的客户端的，
     默认情况下一个id登录后，假如有另外的连接以这个id登录，上一个连接会被踢下线
     */
    
    var clientId: String?
    
    var username: String?
    
    var topics: [DYTopic]?
    
}
