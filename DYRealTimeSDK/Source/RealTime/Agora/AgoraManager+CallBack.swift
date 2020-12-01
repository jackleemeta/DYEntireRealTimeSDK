//
//  AgoraManager+CallBack.swift
//  RealTimeDemo
//
//  Created by beck tian on 2019/12/2.
//  Copyright © 2019 beck tian. All rights reserved.
//

// MARK: - AgoraManager声网基本连接回调协议实现
import AgoraRtcEngineKit
extension AgoraManager: AgoraRtcEngineDelegate {
    
    //远程用户加入
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        initStreamId()
        joinRoom_duplicateRemoval(isSuccess: true, uid: String(uid), pipe: .rtc)
    }
    
    //第一个远程视频帧解码成功回调
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
        let str_uid = String(uid)
        if let aView = viewForRemoteVideo(uid: str_uid) {
            _ = setupRemoteVideo(aView, uid: str_uid)
        }
        joinRoom_duplicateRemoval(isSuccess: true, uid: String(uid), pipe: .rtc)
    }
    
    //第一个本地视频帧Size解析成功回调
    //startPreview后回调
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalVideoFrameWith size: CGSize, elapsed: Int) {
        videoSizeParsed(uid: userConfig.account)
    }
    
    //第一个远程视频帧Size解析成功回调
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoFrameOfUid uid: UInt, size: CGSize, elapsed: Int) {
        videoSizeParsed(uid: String(uid))
    }
    
    //远程用户掉线
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        if reason == .quit {
            leftRoom_duplicateRemoval(uid: "\(uid)", reason: .voluntary, pipe: .rtc)
        } else if reason == .dropped {
            leftRoom_duplicateRemoval(uid: "\(uid)", reason: .offline, pipe: .rtc)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        leftRoom_duplicateRemoval(uid: "\(userConfig.account)", reason: .voluntary, pipe: .rtc)
    }
    
    //远程用户发送的自定义消息体
    func rtcEngine(_ engine: AgoraRtcEngineKit, receiveStreamMessageFromUid uid: UInt, streamId: Int, data: Data) {
        guard let msg = data.jsonString else { return }
        receivedMessage_duplicateRemoval(uid: "\(uid)", msgId: "", msg: msg, pipe: .rtc)
    }
    
    //丢失与服务器的链接，在回调interrupted之后的10秒钟是会回调该方法
    func rtcEngineConnectionDidLost(_ engine: AgoraRtcEngineKit) {
        let disconnected = DYRealTimeSDKConnectStatus.disconnected
        onConnectStatus(status: disconnected, message: "音视频\(disconnected.rawValue)", pipe: .rtc)
    }
    
    //本地和远端用户的网络质量
    func rtcEngine(_ engine: AgoraRtcEngineKit, networkQuality uid: UInt, txQuality: AgoraNetworkQuality, rxQuality: AgoraNetworkQuality) {
        
        var quality: DYRealTimeSDKNetworkQuality = .unknown
        let str_uid: String
        if uid == 0 {
            str_uid = userConfig.account
        } else {
            str_uid = String(uid)
        }
        
        let aQuality = str_uid == userConfig.account ? rxQuality : txQuality
        
        switch aQuality {
        case .excellent, .good:
            quality = .good
        case .poor:
            quality = .medium
        case .bad, .vBad, .down:
            quality = .bad
        default:
            quality = .unknown
        }
        
        onNetworkQuality(uid: str_uid, quality: quality)
    }
    
    //ApiCall 执行
    func rtcEngine(_ engine: AgoraRtcEngineKit!, didApiCallExecute api: String!, error: Int) {
        if api == "che.audio.restart", error == 0 {
            audioRestarted()
        }
    }
    
    //远程用户video打开与否
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted: Bool, byUid uid: UInt) {
        userDidCloseVideo(uid: String(uid), isMuted: muted)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoEnabled enabled: Bool, byUid uid: UInt) {
        log_rtc_video_enabled(enabled: enabled, uid: String(uid))
    }
    
    func rtcEngineLocalAudioMixingDidFinish(_ engine: AgoraRtcEngineKit) {
        audioMixingFinishedCallBack?()
        log_audioMixingFinishedCallBack()
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        log_occur_warning(code: String(warningCode.rawValue), pipe: .rtc)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        onError(code: String(errorCode.rawValue), message: "", pipe: .rtc)
    }
    
}
