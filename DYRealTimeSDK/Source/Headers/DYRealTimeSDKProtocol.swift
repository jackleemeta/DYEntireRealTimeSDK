//
//  DYRealTimeSDKProtocol.swift
//  RealTimeDemo
//
//  Created by beck tian on 2019/12/2.
//  Copyright © 2019 beck tian. All rights reserved.
//

import UIKit


public protocol DYRealTimeSDKProtocol: AnyObject {
    
    /**
     加入房间回执
     - Parameters:
        - isSuccess: 是否成功
        - uid: 加入者
     */
    func joinRoom(isSuccess: Bool, uid: String)
    
    /**
     用户第一个视频帧Size解析成功
     - Parameters:
        - uid: 用户
     */
    func videoSizeParsed(uid: String)
    
    /**
     本地视频绑定view
     - Returns: 要绑定的view
     */
    func viewForLocalVideo() -> UIView
    
    /**
     远程视频绑定view
     - Parameters:
        - uid: 远程用户
     - Returns: 要绑定的view
     */
    func viewForRemoteVideo(uid: String) -> UIView

    /**
     远程用户关闭/打开了摄像头
     - Parameters:
        - uid: 远程用户
        - isMuted: 是否关闭
     */
    func userDidCloseVideo(uid: String, isMuted: Bool)
    
    /**
     发送自定义消息成功/失败回调
     - Parameters:
        - isSuccess: 成功
        - msgId: 消息id
        - msg: 消息体
     */
    func sentMessage(isSuccess: Bool, uid: String, msgId: String, msg: String)
    
    /**
     收到远端自定义消息
     - Parameters:
        - uid: 消息发送者
        - msgId: 消息id
        - msg: 消息体
     */
    func receivedMessage(uid: String, msgId: String, msg: String)
    
    /**
     离开房间成功回执
     - Parameters:
        - uid: 离开者
        - reason: 原因
        - completion: 离开完成回调
     */
    func leftRoom(uid: String, reason: DYRealTimeSDKLeaveReason)
    
    /**
     实时网络质量
     - Parameters:
        - uid: 用户
        - quality: 网络质量
     */
    func onNetworkQuality(uid: String, quality: DYRealTimeSDKNetworkQuality)
    
    /**
     网络连接情况
     - Parameters:
        - status: 状况
        - message: 提示消息
     */
    func onConnectStatus(status: DYRealTimeSDKConnectStatus, message: String)
    
    /**
     音频引擎重启
     */
    func audioRestarted()
    
    /**
      解析消息id，uid，roomId
     - Parameters:
        - message: 消息体
     - Returns: DYMessageKeys 关键字段 - msgId: 消息id，uid: 消息发送方，roomId: 消息所属的房间id
    */
    func parseMSGID_UID_ROOMIDFor(message: String) -> DYMessageKeys
    
    /**
      解析消息类型
     - Parameters:
        - message: 消息体
     - Returns: 消息类型
    */
    func parseType(forMessage message: String) -> NSObject?
    
    /**
      错误
     - Parameters:
        - code: 错误码
        - message: 错误描述
    */
    func onError(code: String, message: String)

}
