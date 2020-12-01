//
//  TRTCManager+CallBack.swift
//  RealTimeDemo
//
//  Created by beck tian on 2019/12/2.
//  Copyright © 2019 beck tian. All rights reserved.
//

import TXLiteAVSDK_TRTC

extension TRTCManager: TRTCCloudDelegate {
    
    //用户加入
    func onRemoteUserEnterRoom(_ userId: String) {
        joinRoom_duplicateRemoval(isSuccess: true, uid: userId, pipe: .rtc)
    }
    
    //用户离开；断线或者主动
    func onRemoteUserLeaveRoom(_ userId: String, reason: Int) {
        let r: DYRealTimeSDKLeaveReason
        if reason == 0 {
            r = .voluntary
        } else if reason == 2 {
            r = .extrusion
        } else {
            r = .ignore
        }
        leftRoom_duplicateRemoval(uid: userId, reason: r, pipe: .rtc)
    }
    
    //第一个远程视频帧解码成功回调 / 远程用户video打开与否
    func onUserVideoAvailable(_ userId: String, available: Bool) {
        if available {
            if let aview = viewForRemoteVideo(uid: userId) {
                trtc?.setRemoteViewFillMode(userId, mode: .fit)
                trtc?.startRemoteView(userId, view: aview)
            }
        } else {
            trtc?.stopRemoteView(userId)
        }
        userDidCloseVideo(uid: userId, isMuted: !available)
        log_rtc_video_enabled(enabled: available, uid: userId)
    }
    
    //第一个本地/远程视频帧Size解析成功回调
    func onFirstVideoFrame(_ userId: String, streamType: TRTCVideoStreamType, width: Int32, height: Int32) {
        let uid: String
        if userId.count == 0 {
            uid = userConfig.account
        } else {
            uid = userId
        }
        videoSizeParsed(uid: uid)
    }
    
    func onEnterRoom(_ result: Int) {//自身进入
        if result > 0 {
            joinRoom_duplicateRemoval(isSuccess: true, uid: userConfig.account, pipe: .rtc)
        } else {
            joinRoom_duplicateRemoval(isSuccess: false, uid: userConfig.account, pipe: .rtc)
        }
    }
    
    //reason 离开房间原因，0：主动调用 exitRoom 退房；1：被服务器踢出当前房间；2：当前房间整个被解散
    func onExitRoom(_ reason: Int) {
        let r: DYRealTimeSDKLeaveReason
        if reason == 0 {
            r = .voluntary
        } else if reason == 1 {
            r = .extrusion
        } else {
            r = .ignore
        }
        
        leftRoom_duplicateRemoval(uid: userConfig.account, reason: r, pipe: .rtc)
    }
    
    //远程用户发送的自定义消息体
    func onRecvCustomCmdMsgUserId(_ userId: String, cmdID: Int, seq: UInt32, message: Data) {
        let jsonString = message.jsonString ?? ""
        receivedMessage_duplicateRemoval(uid: userId, msgId: "", msg: jsonString, pipe: .rtc)
    }
    
    // 本地用户的下行质量 和 远端用户的上行质量（远端用户上行质量暂时未知）
    func onNetworkQuality(_ localQuality: TRTCQualityInfo, remoteQuality: [TRTCQualityInfo]) {
        
        var scores = [Int]()
        let trtcQualityScoreKVs: [TRTCQuality: Int] = [.excellent: 100,
                                                       .good: 90,
                                                       .poor: 65,
                                                       .bad: 50,
                                                       .vbad: 30,
                                                       .down: 0,
                                                       .unknown: -51]
        
        for item in remoteQuality where item.userId != nil {
            
            if let score = trtcQualityScoreKVs[item.quality] {
                scores.append(score)
            } else {
                scores.append(trtcQualityScoreKVs[.unknown]!)
            }
            
            onNetworkQuality(uid: item.userId!, quality: .unknown)
        }
        
        let realTimeSDKNetworkQuality: DYRealTimeSDKNetworkQuality
        
        scores.removeAll { $0 == trtcQualityScoreKVs[.unknown]! }
        if scores.count == 0 {
            realTimeSDKNetworkQuality = .unknown
            onNetworkQuality(uid: userConfig.account, quality: realTimeSDKNetworkQuality)
            return
        }

        let result = scores.reduce(0) { $0 + $1}
        let average = result / scores.count
                
        switch average {
        case 0...50:
            realTimeSDKNetworkQuality = .bad
        case 51...79:
            realTimeSDKNetworkQuality = .medium
        case 80...100:
            realTimeSDKNetworkQuality = .good
        default:
            realTimeSDKNetworkQuality = .unknown
        }
        
        onNetworkQuality(uid: userConfig.account, quality: realTimeSDKNetworkQuality)
    }
    
    
    func onConnectionRecovery() {
        let recovery = DYRealTimeSDKConnectStatus.recovery
        onConnectStatus(status: recovery, message: "音视频\(recovery.rawValue)", pipe: .rtc)
    }
    
    func onConnectionLost() {
        let disconnected = DYRealTimeSDKConnectStatus.disconnected
        onConnectStatus(status: disconnected, message: "音视频\(disconnected.rawValue)", pipe: .rtc)
    }
    
    func onWarning(_ warningCode: TXLiteAVWarning, warningMsg: String?, extInfo: [AnyHashable : Any]?) {
        log_occur_warning(code: String(warningCode.rawValue), pipe: .rtc)
    }
    
    func onError(_ errCode: TXLiteAVError, errMsg: String?, extInfo: [AnyHashable : Any]?) {
        onError(code: String(errCode.rawValue), message: errMsg ?? "", pipe: .rtc)
    }
    
}
