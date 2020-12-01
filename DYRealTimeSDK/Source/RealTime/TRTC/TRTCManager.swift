//
//  TRTCManager.swift
//  RealTimeDemo
//
//  Created by beck tian on 2019/11/13.
//  Copyright © 2019 beck tian. All rights reserved.
//
import TXLiteAVSDK_TRTC

class TRTCManager: DYRealTimeManager {
    
    //MARK: - Common API
    lazy var trtc = TRTCCloud.sharedInstance()
    
    override var authenticationConfig: DYRealTimeSDKAuthenticationConfig {
        didSet {
            DYRealTimeAppKeys.TRTC.id = UInt32(authenticationConfig.sdkId) ?? 0
        }
    }
    
    override func connectSDK() {
        super.connectSDK()
        initSDK()
        joinRoom()
    }
    
    override func joinRoom() {
        super.joinRoom()
        joinRtcRoom()
    }
    
    override func leaveRoom(_ callBack: ((Bool) -> ())? = nil) {
        super.leaveRoom()
        leaveRtcRoom()
        didRtcLeaveCallBack = { isSuccess in
            callBack?(isSuccess)
        }
    }
    
    override func destroy(_ callBack: ((Bool)->())? = nil) {
        super.destroy(callBack)
        leaveRtcRoom()
        didRtcLeaveCallBack = { isSuccess in
            TRTCCloud.destroySharedIntance()
            callBack?(isSuccess)
        }
    }
    
    override func leaveRtcRoom() {
        super.leaveRtcRoom()
        trtc?.stopLocalPreview()
        trtc?.stopLocalAudio()
        trtc?.stopAllRemoteView()
        trtc?.exitRoom()
    }
    
    override func sendMessage(msgId: String, msg: String, receiverIds: Set<String>? = nil) {
        super.sendMessage(msgId: msgId, msg: msg)
        trtc?.sendCustomCmdMsg(1, data: msg.jsonData, reliable: false, ordered: false)//腾讯发送
    }
    
    //MARK: - 音视频API
    override func startAudioMixing(_ filePath: String!, loopback: Bool, replace: Bool, cycle: Int, finishedCallBack: (() -> ())?) {
        super.startAudioMixing(filePath, loopback: loopback, replace: replace, cycle: cycle, finishedCallBack: finishedCallBack)
        trtc?.playBGM(filePath, withBeginNotify: nil, withProgressNotify: nil, andCompleteNotify: { [weak self] errorCode in
            guard let `self` = self else { return }
            self.audioMixingFinishedCallBack?()
        })
    }
    
    override func stopAudioMixing() {
        super.stopAudioMixing()
        trtc?.stopBGM()
    }
    
    override func pauseAudioMixing() {
        super.pauseAudioMixing()
        trtc?.pauseBGM()
    }
    
    override func resumeAudioMixing() {
        super.resumeAudioMixing()
        trtc?.resumeBGM()
    }
    
    override func adjustAudioMixingVolume(_ volume: Int) {
        super.adjustAudioMixingVolume(volume)
        trtc?.setBGMVolume(volume)
    }
    
    override func muteLocalVideoStream(_ mute: Bool) {
        super.muteLocalVideoStream(mute)
        trtc?.muteLocalVideo(mute)
    }
    
    override func muteLocalAudioStream(_ status: Bool) {
        super.muteLocalAudioStream(status)
        trtc?.muteLocalAudio(status)
    }
    
    override var baseInformation: DYRealTimeSDKBaseInformation {
        var bi = DYRealTimeSDKBaseInformation()
        bi.thirdRtcSDKType = .trtc
        bi.thirdRtcSDKName = "trtc"
        bi.thirdRtcVersion = TRTCCloud.getSDKVersion()
        return bi
    }
    
    //MARK: - Private API
    
    private func initSDK() {
        
        TRTCCloud.setLogDirPath(Self.trtcLogFilePath)
        
        trtc?.delegate = self
        
        let encParam = TRTCVideoEncParam()
        encParam.videoResolution = ._320_240
        encParam.resMode = .landscape
        encParam.videoFps = 15
        encParam.videoBitrate = 200
        
        trtc?.setVideoEncoderParam(encParam)
        trtc?.setVideoEncoderRotation(._180)
        
    }
    
    override func joinRtcRoom() {
        super.joinRtcRoom()
        startLocalPreview()
        trtc?.startLocalAudio()
        let params = TRTCParams()
        params.sdkAppId = DYRealTimeAppKeys.TRTC.id
        params.userId = userConfig.account
        params.userSig = authenticationConfig.sdkSign
        params.roomId = UInt32(userConfig.roomId) ?? 0
        trtc?.enterRoom(params, appScene: .videoCall)
    }
    
    private func startLocalPreview() {
        if let aView = viewForLocalVideo() {
            trtc?.setLocalViewFillMode(.fit)
            trtc?.startLocalPreview(true, view: aView)
        }
    }
    
    override var allPipesOfWillJoin: DYRealTimeSDKPipe {
        return [.mqtt,
                .tim,
                .rtc]
    }
    
}

