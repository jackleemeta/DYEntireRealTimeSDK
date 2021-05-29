//
//  AgoraManager.swift
//  DYRealTimeSDK
//
//  Created by 88 on 2017/2/20.
//  Copyright © 2017年 DT. All rights reserved.
//  声网SDK构建


import AgoraRtcEngineKit
import CocoaLumberjack

class AgoraManager: DYRealTimeManager {
    
    //MARK: - Common API
    var agora: AgoraRtcEngineKit?
    private var agoraIMKit: AgoraIMKit?
    var streamId: Int = 0
    
    override var authenticationConfig: DYRealTimeSDKAuthenticationConfig {
        didSet {
            DYRealTimeAppKeys.Agora.id = authenticationConfig.sdkId
        }
    }
    
    override func connectSDK() {//连接声网SDK
        initSDK()
        joinRoom()
    }
    
    override func joinRoom() {
        super.joinRoom()
        joinRtcRoom()
        joinSignalRoom()
    }
    
    override func leaveRoom(_ callBack: ((Bool)->())? = nil) {
        super.leaveRoom(callBack)
        leaveRtcRoom()
        leaveSignalRoom()
        didRtcLeaveCallBack = { isSuccess in
            callBack?(isSuccess)
        }
    }
    
    /// 离开房间后销毁Agora SDK
    /// - Note: 销毁后canvas view还在，需在业务中特殊处理
    /// - Parameter callBack: callBack
    override func destroy(_ callBack: ((Bool)->())? = nil) {//离开房间后销毁Agora SDK
        super.destroy(callBack)
        leaveRtcRoom()
        leaveSignalRoom()
        didRtcLeaveCallBack = { isSuccess in
            AgoraRtcEngineKit.destroy()
            callBack?(isSuccess)
        }
    }
    
    override func leaveRtcRoom() {
        super.leaveRtcRoom()
        _ = agora?.setupLocalVideo(nil)
        _ = agora?.stopPreview()
        _ = agora?.leaveChannel(nil)
    }
    
    override func leaveSignalRoom() {
        super.leaveSignalRoom()
        agoraIMKit?.channelLeave()
        agoraIMKit?.logout()
        
        log_tryToLeaveSignalRoom()
    }
    
    override func sendMessage(msgId: String, msg: String, receiverIds: Set<String>? = nil) {
        super.sendMessage(msgId: msgId, msg: msg, receiverIds: receiverIds)
        
        let msgdata = msg.data(using: .utf8) ?? Data()
        agora?.sendStreamMessage(streamId, data: msgdata) // 声网发送
    }
    
    override func sendSignalMessage(msgId: String, msg: String, receiverIds: Set<String>? = nil) {
        super.sendSignalMessage(msgId: msgId, msg: msg, receiverIds: receiverIds)
        agoraIMKit?.messageChannelSend(channelID: userConfig.roomId, msgId: msgId, msg: msg) // 声网信令发送
    }
    
    func initStreamId() {
        let astreamId = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        astreamId.initialize(to: 0)
        _ = agora?.createDataStream(astreamId, reliable: true, ordered: true)
        streamId = astreamId[0]
    }
    
    // MARK: - 音视频API
    override func startAudioMixing(_ filePath: String!, loopback: Bool, replace: Bool, cycle: Int, finishedCallBack: (() -> ())?) {
        super.startAudioMixing(filePath, loopback: loopback, replace: replace, cycle: cycle, finishedCallBack: finishedCallBack)
        _ = agora?.startAudioMixing(filePath, loopback: loopback, replace: replace, cycle: cycle)
    }
    
    override func pauseAudioMixing() {
        super.pauseAudioMixing()
        _ = agora?.pauseAudioMixing()
    }
    
    override func stopAudioMixing() {
        super.stopAudioMixing()
        _ = agora?.stopAudioMixing()
    }
    
    override func resumeAudioMixing() {
        super.resumeAudioMixing()
        _ = agora?.resumeAudioMixing()
    }
    
    override func adjustAudioMixingVolume(_ volume: Int) {
        super.adjustAudioMixingVolume(volume)
        _ = agora?.adjustAudioMixingVolume(volume)
    }
    
    override func muteLocalVideoStream(_ mute: Bool) {
        super.muteLocalVideoStream(mute)
        _ = agora?.muteLocalVideoStream(mute)
    }
    
    override func muteLocalAudioStream(_ status: Bool) {
        super.muteLocalAudioStream(status)
        _ = agora?.muteLocalAudioStream(status)
    }
    
    override func muteRemoteAudioStream(_ mute: Bool, userId:String) {
        super.muteRemoteAudioStream(mute, userId: userId)
        _ = agora?.muteRemoteAudioStream(UInt(userId) ?? 0, mute: mute)
    }
    
    override var baseInformation: DYRealTimeSDKBaseInformation {
        var bi = DYRealTimeSDKBaseInformation()
        bi.thirdRtcSDKType = .agora
        bi.thirdRtcSDKName = "agora"
        bi.thirdRtcVersion = Self.getAgoraRtcEngineKitSDKVersion()
        return bi
    }
    
    //MARK: - Private API
    private func initSDK() {
        agora = AgoraRtcEngineKit.sharedEngine(withAppId: DYRealTimeAppKeys.Agora.id, delegate: self)
        _ = setLogFile(filePath: Self.agoraLogFilePath)
        let jsonObject: [String: Any] = ["che.video.setstream": ["uid": 100,
                                                                 "stream": 0],
                                         "che.video.enableAutoVideoResize": 0,
                                         "che.video.inactive_enable_encoding_and_decoding": true]
        agora?.setParameters(jsonObject.jsonString!)//配置服务器返回视频流清晰度等参数
        _ = setVideoEncoderConfiguration(CGSize(width: 320, height: 240))
        _ = enableAgoraMainQueueDispatch(true)
        _ = setChannelProfile(.Communication)
        _ = enableAudio()
        _ = enableVideo()
        initStreamId()
        agora?.adjustRecordingSignalVolume(400)//  4 * orginVolume(自带溢出保护)
    }
    
    override func joinRtcRoom() {
        super.joinRtcRoom()
        setupLocalVideo()
        _ = joinChannel(byKey: authenticationConfig.sdkSign,
                        channelName: userConfig.roomId,
                        info: nil,
                        uid: UInt(userConfig.account) ?? 0) { [weak self] channel, uid, elapsed in
                            guard let `self` = self else { return }
                            if let channel = channel,
                                channel.count > 0 {//加入频道成功
                                self.joinRoom_duplicateRemoval(isSuccess: true, uid: self.userConfig.account, pipe: .rtc)
                            } else {
                                self.joinRoom_duplicateRemoval(isSuccess: false, uid: self.userConfig.account, pipe: .rtc)
                            }
        }
    }
    
    override func joinSignalRoom() {//连接声网SDK信令通道
        super.joinSignalRoom()
        agoraIMKit = AgoraIMKit()
        agoraIMKit?.account = userConfig.account
        agoraIMKit?.roomId = userConfig.roomId
        agoraIMKit?.delegate = self
        agoraIMKit?.login(token: authenticationConfig.sdkSignalSign)
    }
    
    private func setupLocalVideo() {
        if let video = viewForLocalVideo() {
            _ = setupLocalVideo(video, uid: userConfig.account)
            _ = startPreview()
        }
    }
 
    override var allPipesOfWillJoin: DYRealTimeSDKPipe {
        return .all
    }
    
}


