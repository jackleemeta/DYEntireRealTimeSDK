//
//  DYRealTimeManager+LogAdd.swift
//  DYRealTimeSDKDemo
//
//  Created by beck tian on 2019/12/22.
//  Copyright © 2019 beck tian. All rights reserved.
//

import CocoaLumberjack

// MARK: - 日志
extension DYRealTimeManager {
    
    /// 日志 - 尝试加入RTC房间
    func log_tryToJoinRtcRoom() {
        let param = ["roomId": userConfig.roomId]
        DYRealTimeSDKActionLog.log(.joinchannel, pipe: .rtc, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(DYRealTimeSDKPipe.rtc.rawValue), 加入房间")
    }
    
    /// 日志 - 尝试加入SIGNAL房间
    func log_tryToJoinSignalRoom() {
        let param = ["roomId": userConfig.roomId]
        DYRealTimeSDKActionLog.log(.joinchannel, pipe: .signal, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(DYRealTimeSDKPipe.signal.rawValue), 退出房间")
    }
    
    /// 日志 - 尝试离开RTC房间
    func log_tryToLeaveRtcRoom() {
        let param = ["roomId": userConfig.roomId]
        DYRealTimeSDKActionLog.log(.exitchannel, pipe: .rtc, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(DYRealTimeSDKPipe.rtc.rawValue)")
    }
    
    /// 日志 - 尝试离开SIGNAL房间
    func log_tryToLeaveSignalRoom() {
        let param = ["roomId": userConfig.roomId]
        DYRealTimeSDKActionLog.log(.exitchannel, pipe: .signal, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(DYRealTimeSDKPipe.signal.rawValue)")
    }

    
    ///日志 - 加入房间回调
    func log_joinRoom(isSuccess: Bool, uid: String, pipe: DYRealTimeSDKPipe) {
        let param: [String : Any] = ["roomId": userConfig.roomId,
                                     "uid": uid]
        DYRealTimeSDKActionLog.log(isSuccess ? .joinchannel_success : .joinchannel_falilure, pipe: pipe, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(pipe.describeString), isSuccess = \(isSuccess), uid = \(uid), param = \(param)")
    }
    
    //日志 - 已经离开了房间回调
    func log_leftRoom(uid: String, reason: DYRealTimeSDKLeaveReason, pipe: DYRealTimeSDKPipe) {
        let param = ["roomId": userConfig.roomId, "uid": uid]
        if reason == .extrusion {
            DYRealTimeSDKActionLog.log(.exitchannel_excrusion, pipe: pipe, param: param)
        } else if reason == .offline {
            DYRealTimeSDKActionLog.log(.exitchannel_offline, pipe: pipe, param: param)
        } else {
            DYRealTimeSDKActionLog.log(.exitchannel_success, pipe: pipe, param: param)
        }
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(pipe.describeString), uid = \(uid), param = \(param)")
    }
    
    ///日志 - 发送RTC消息
    func log_sendRtcMessage(msgId: String, msg: String, receiverIds: Set<String>? = nil) {
        var param: [String: Any] = ["roomId": userConfig.roomId,
                                    "msgId": msgId,
                                    "msg": msg]
        if receiverIds != nil { param["receiverIds"] = receiverIds! }
        DYRealTimeSDKActionLog.log(.message_send, pipe: .rtc, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(DYRealTimeSDKPipe.rtc.rawValue), param = \(param)")
    }
    
    ///日志 - 发送SIGNAL消息
    func log_sendSignalMessage(msgId: String, msg: String, receiverIds: Set<String>? = nil) {
        var param: [String: Any] = ["roomId": userConfig.roomId,
                                    "msgId": msgId,
                                    "msg": msg]
        if receiverIds != nil { param["receiverIds"] = receiverIds! }
        DYRealTimeSDKActionLog.log(.message_send, pipe: .signal, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(DYRealTimeSDKPipe.signal.rawValue), param = \(param)")
    }
    
    ///日志 - 发送消息回调； isFirstReceive 此消息第一次发出成功
    func log_sentMessage(isSuccess: Bool, uid: String, msgId: String, msg: String, pipe: DYRealTimeSDKPipe, isFirstSent: Bool) {
        let param: [String: Any] = ["roomId": userConfig.roomId,
                                    "uid": uid,
                                    "msgId": msgId,
                                    "msg": msg,
                                    "isFirstSent": isFirstSent]
        DYRealTimeSDKActionLog.log(isSuccess ? .message_send_success : .message_send_failure, pipe: pipe, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(pipe.describeString), isSuccess = \(isSuccess), param = \(param)")
    }
    
    ///日志 - 收到自定义消息； isFirstReceive 此消息第一次收到
    func log_receivedMessage_duplicateRemoval(uid: String, msgId: String, msg: String, pipe: DYRealTimeSDKPipe, isFirstReceive: Bool) {
        let param: [String: Any] = ["roomId": userConfig.roomId,
                                    "uid": uid,
                                    "msgId": msgId,
                                    "msg": msg,
                                    "isFirstReceive": isFirstReceive]
        DYRealTimeSDKActionLog.log(.message_received, pipe: pipe, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(pipe.describeString), param = \(param)")
    }
    
    ///日志 - 网络连接状况
    func log_onConnectStatus(status: DYRealTimeSDKConnectStatus, message: String , pipe: DYRealTimeSDKPipe) {
        let param = ["roomId": userConfig.roomId,
                     "status": status.rawValue,
                     "message": message]
        
        switch status {
        case .connecting:
            DYRealTimeSDKActionLog.log(.connect_connecting, pipe: pipe, param: param)
        case .succeed:
            DYRealTimeSDKActionLog.log(.connect_succeed, pipe: pipe, param: param)
        case .failed:
            DYRealTimeSDKActionLog.log(.connect_failed, pipe: pipe, param: param)
        case .disconnected:
            DYRealTimeSDKActionLog.log(.connect_disconnected, pipe: pipe, param: param)
        case .recovery:
            DYRealTimeSDKActionLog.log(.connect_recovery, pipe: pipe, param: param)
        }
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(pipe.describeString), status = \(status.rawValue), param = \(param)")
    }
    
    func log_viewForLocalVideo() {
        let param = ["roomId": userConfig.roomId,
                     "uid": userConfig.account];
        DYRealTimeSDKActionLog.log(.video_set_local_video, pipe: .rtc, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("")
    }
    
    ///日志 - 第一个远程视频帧解码成功
    func log_firstRemoteVideoDecodedOfUid(uid: String) {
        let param = ["roomId": userConfig.roomId,
                     "uid": uid]
        DYRealTimeSDKActionLog.log(.video_remote_video_decode_first, pipe: .rtc, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("param = \(param)")
    }
    
    ///日志 - 第一个本地/远程视频帧Size解析成功
    func log_firstVideoSizeParsedOfUid(uid: String) {
        let param = ["roomId": userConfig.roomId,
                     "uid": uid]
        DYRealTimeSDKActionLog.log(.video_video_frame_first, pipe: .rtc, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("param = \(param)")
    }
    
    ///日志 - 用户关闭/开启摄像头
    func log_userDidCloseVideo(uid: String, isMuted: Bool) {
        let param: [String: Any] = ["roomId": userConfig.roomId,
                                    "uid": uid,
                                    "isMuted": isMuted]
        DYRealTimeSDKActionLog.log(.video_muted, pipe: .rtc, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("param = \(param)")
    }
    
    func log_onNetworkQuality(uid: String, quality: DYRealTimeSDKNetworkQuality) {
        let param: [String: Any] = ["roomId": userConfig.roomId,
                                    "uid": uid,
                                    "quality": quality.rawValue]
        
        let aLevel: DDLogLevel
        if DYRealTimeSDKActionLog.allowHighFrequencyLog {
            aLevel = .all
        } else {
            aLevel = .off
        }
        
        DYRealTimeSDKActionLog.log(.network_quality, pipe: .rtc, param: param, level: aLevel)
        DYRealTimeSDKActionLog.ddLogInfo("quality = \(quality.rawValue), param = \(param)",
                                         level: aLevel)
    }
    
    func log_rtc_video_enabled(enabled: Bool, uid: String) {
        let param: [String: Any] = ["roomId": userConfig.roomId,
                                    "uid": uid,
                                    "enabled": enabled]
        DYRealTimeSDKActionLog.log(.video_enabled, pipe: .rtc, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("enabled = \(enabled), param = \(param)")
    }
    
    ///日志 - 本地音频重启
    func log_audioRestarted() {
        let pipe = DYRealTimeSDKPipe.rtc
        DYRealTimeSDKActionLog.log(.audio_restarted, pipe: pipe)
        DYRealTimeSDKActionLog.ddLogInfo("")
    }
    
    func log_occur_warning(code: String, pipe: DYRealTimeSDKPipe) {
        let param: [String: Any] = ["roomId": userConfig.roomId,
                                    "code": code]
        DYRealTimeSDKActionLog.log(.occur_warning, pipe: pipe, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(pipe.describeString), code = \(code), param = \(param)")
    }
    
    func log_occur_error(code: String, pipe: DYRealTimeSDKPipe) {
        let param: [String: Any] = ["roomId": userConfig.roomId,
                                    "code": code]
        DYRealTimeSDKActionLog.log(.occur_error, pipe: pipe, param: param)
        DYRealTimeSDKActionLog.ddLogInfo("通讯通道 = \(pipe.describeString), code = \(code), param = \(param)")
    }
    
    func log_startAudioMixing(_ filePath: String!, loopback: Bool, replace: Bool, cycle: Int, finishedCallBack: (()->())?) {
        DYRealTimeSDKActionLog.ddLogInfo("filePath = \(String(describing: filePath)), loopback = \(loopback), replace = \(replace), cycle = \(cycle), finishedCallBack = \(finishedCallBack)")
    }
    
    func log_stopAudioMixing() {
        DYRealTimeSDKActionLog.ddLogInfo("")
    }
    
    func log_pauseAudioMixing() {
        DYRealTimeSDKActionLog.ddLogInfo("")
    }
    
    func log_resumeAudioMixing() {
        DYRealTimeSDKActionLog.ddLogInfo("")
    }
    
    func log_adjustAudioMixingVolume(_ volume: Int) {
        DYRealTimeSDKActionLog.ddLogInfo(" volume = \(volume)")
    }
    
    func log_muteLocalVideoStream(_ mute: Bool) {
        DYRealTimeSDKActionLog.ddLogInfo(" mute = \(mute)")
    }
    
    func log_muteLocalAudioStream(_ status: Bool) {
        DYRealTimeSDKActionLog.ddLogInfo("status = \(status)")
    }
    
    func log_muteRemoteAudioStream(mute: Bool, userId:String) {
        DYRealTimeSDKActionLog.ddLogInfo("mute = \(mute), userId = \(userId)")
    }
    
    func log_audioMixingFinishedCallBack() {
        let pipe = DYRealTimeSDKPipe.rtc
        DYRealTimeSDKActionLog.log(.audio_audioMixingFinishedCallBack, pipe: pipe)
        DYRealTimeSDKActionLog.ddLogInfo("")
    }
    
}
