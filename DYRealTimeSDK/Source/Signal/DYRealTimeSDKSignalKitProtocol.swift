//
//  DYRealTimeSDKSignalKitProtocol.swift
//  DYRealTimeSDKDemo
//
//  Created by beck tian on 2019/12/9.
//  Copyright © 2019 beck tian. All rights reserved.
//

//信令通道退出原因
enum RealTimeSDKSinalExitReason: Int {
    case voluntary//主动退出
    case extrusion//被挤出
    case reconnect_failed//重连失败
    case sign_expired//签名过期
    case sign_failed//登录验证失败
    case ignore
}

protocol DYRealTimeSDKSignalKitProtocol: AnyObject {
    
    func signalOnLoginSuccess(uid: String)//登录成功
    
    func signalOnLoginFailed(uid: String, reason: RealTimeSDKSinalExitReason)//登录失败
    
    func signalOnSendMessageSuccess(uid: String, msgId: String, msg: String)//发送消息成功
    
    func signalOnSendMessageFailed(uid: String, msgId: String, msg: String)//发送消息失败
    
    func signalOnExit(uid: String, reason: RealTimeSDKSinalExitReason)//退出登录
    
    func signalOnMessageReceived(uid: String, msgId: String, msg: String)//收到消息
    
    func signalOnConnectStatus(status: DYRealTimeSDKConnectStatus, message: String)//网络连接情况
    
    func signalOnError(err: String)//发生错误
}
