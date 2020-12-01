//
//  DYRealTimeSDK+TIMKit.swift
//  DYRealTimeSDK
//
//  Created by diff on 2020/4/29.
//  Copyright © 2020 beck tian. All rights reserved.
//

/// Internal invoke Method - Tencent Instant Messaging (TIM) 相关
extension DYRealTimeSDK {
    
    func initTIMKit(with settingConfig: DYRealTimeSettingConfig) {
        if Self.manager == nil { return }
        timKit = TIMKit(appId: UInt32(settingConfig.timConfig?.appId ?? "0") ?? 0,
                        roomId: Self.manager?.userConfig.roomId ?? "",
                        account: Self.manager?.userConfig.account ?? "",
                        sign: settingConfig.timConfig?.sign ?? "")
        timKit?.delegate = self
    }
    
    func joinTimKit() {
        timKit?.login()
        log_joinTimKit()
    }
    
    func leaveTIMKit() {
        timKit?.logout()
    }
    
}

/// Internal CallBack Method - Tencent Instant Messaging (TIM) 相关
extension DYRealTimeSDK: DYRealTimeSDKSignalKitProtocol {
    
    func signalOnLoginSuccess(uid: String) {
        Self.manager?.joinRoom_duplicateRemoval(isSuccess: true, uid: uid, pipe: .tim)
    }
    
    func signalOnLoginFailed(uid: String, reason: RealTimeSDKSinalExitReason) {
        Self.manager?.joinRoom_duplicateRemoval(isSuccess: true, uid: uid, pipe: .tim)
    }
    
    func signalOnSendMessageSuccess(uid: String, msgId: String, msg: String) {
        Self.manager?.sentMessage(isSuccess: true, uid: uid, msgId: msgId, msg: msg, pipe: .tim)
    }
    
    func signalOnSendMessageFailed(uid: String, msgId: String, msg: String) {
        Self.manager?.sentMessage(isSuccess: false, uid: uid, msgId: msgId, msg: msg, pipe: .tim)
    }
    
    func signalOnExit(uid: String, reason: RealTimeSDKSinalExitReason) {
        let r: DYRealTimeSDKLeaveReason
        switch reason {
        case .voluntary: r = .voluntary
        case .extrusion: r = .extrusion
        default: r = .ignore
        }
        
        Self.manager?.leftRoom_duplicateRemoval(uid: uid, reason: r, pipe: .tim)
    }
    
    func signalOnMessageReceived(uid: String, msgId: String, msg: String) {
        Self.manager?.receivedMessage_duplicateRemoval(uid: uid, msgId: msgId, msg: msg, pipe: .tim)
    }
    
    func signalOnConnectStatus(status: DYRealTimeSDKConnectStatus, message: String) {
        Self.manager?.onConnectStatus(status: status, message: message, pipe: .tim)
    }
    
    func signalOnError(err: String) {
        Self.manager?.log_occur_error(code: err, pipe: .tim)
    }
    
}
