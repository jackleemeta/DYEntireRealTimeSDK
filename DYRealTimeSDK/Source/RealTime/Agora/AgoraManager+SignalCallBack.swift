//
//  AgoraManager+SignalCallBack.swift
//  RealTimeDemo
//
//  Created by beck tian on 2019/12/2.
//  Copyright © 2019 beck tian. All rights reserved.
//

// MARK: 信令的回调
extension AgoraManager: DYRealTimeSDKSignalKitProtocol {
    
    func signalOnLoginSuccess(uid: String) {
        joinRoom_duplicateRemoval(isSuccess: true, uid: uid, pipe: .signal)
    }
    
    func signalOnLoginFailed(uid: String, reason: RealTimeSDKSinalExitReason) {
        if reason == .extrusion {
            leftRoom_duplicateRemoval(uid: uid, reason: .extrusion, pipe: .signal)
        } else {
            joinRoom_duplicateRemoval(isSuccess: false, uid: uid, pipe: .signal)
        }
    }
    
    func signalOnSendMessageSuccess(uid: String, msgId: String, msg: String) {
        sentMessage(isSuccess: true, uid: uid, msgId: msgId, msg: msg, pipe: .signal)
    }
    
    func signalOnSendMessageFailed(uid: String, msgId: String, msg: String) {
        sentMessage(isSuccess: false, uid: uid, msgId: msgId, msg: msgId, pipe: .signal)
    }
    
    func signalOnExit(uid: String, reason: RealTimeSDKSinalExitReason) {
        let r: DYRealTimeSDKLeaveReason
        switch reason {
        case .voluntary: r = .voluntary
        case .extrusion: r = .extrusion
        default: r = .ignore
        }
        leftRoom_duplicateRemoval(uid: uid, reason: r, pipe: .signal)
    }
    
    func signalOnMessageReceived(uid: String, msgId: String, msg: String) {
        receivedMessage_duplicateRemoval(uid: uid, msgId: msgId, msg: msg, pipe: .signal)
    }
    
    func signalOnConnectStatus(status: DYRealTimeSDKConnectStatus, message: String) {
        onConnectStatus(status: status, message: message, pipe: .signal)
    }
    
    func signalOnError(err: String) {
        log_occur_error(code: err, pipe: .signal)
    }
    
}
