//
//  AgoraManager+Invoke.swift
//  RealTimeDemo
//
//  Created by beck tian on 2019/12/2.
//  Copyright © 2019 beck tian. All rights reserved.
//
import CocoaLumberjack
import AgoraRtcEngineKit
// MARK: - AgoraManager对象主动调用

//SDK内部调用
extension AgoraManager {
    
    func leaveChannel(_ leaveChannelBlock: ((AgoraChannelStats?) -> Void)!) -> Bool {
        let code = agora?.leaveChannel(leaveChannelBlock)
        return code == 0
    }
    
    //设置回调是否在主线程
    func enableAgoraMainQueueDispatch(_ enabled: Bool) -> Bool {
        guard agora != nil else { return false }
        let code = agora?.enableMainQueueDispatch(enabled)
        
        return code == 0
    }
    
    func joinChannel(byKey channelKey: String, channelName: String, info: String?, uid: UInt, joinSuccess joinSuccessBlock: ((String?, UInt, Int) -> Void)?) -> Bool {
        guard agora != nil else { return false }
        
        let code = agora?.joinChannel(byToken: channelKey, channelId: channelName, info: info, uid: uid, joinSuccess: joinSuccessBlock)
        return code == 0
    }
    
    func setupLocalVideo(_ local: UIView?, renderModel: AgoraVideoRenderMode = .fit, uid: String) -> Bool {
        guard agora != nil else {
            return false
        }
        
        let code = agora?.setupLocalVideo(generateCanvas(local, renderModel, uid))
        return code == 0
    }
    
    func setupRemoteVideo(_ remote: UIView?, renderModel: AgoraVideoRenderMode = .fit, uid: String) -> Bool {
        guard agora != nil else {
            return false
        }
        
        let code = agora?.setupRemoteVideo(generateCanvas(remote, renderModel, uid))
        
        return code == 0
    }
    
    func enableVideo() -> Bool {
        guard agora != nil else { return false }
        let code = agora?.enableVideo()
        
        return code == 0
    }
    
    func startPreview() -> Bool {
        guard agora != nil else { return false }
        let code = agora?.startPreview()
        
        return code == 0
    }
    
    func stopPreview() -> Bool {
        guard agora != nil else { return false }
        let code = agora?.stopPreview()
        
        return code == 0
    }
    
    func enableAudio() -> Bool {
        guard agora != nil else { return false }
        let code = agora?.enableAudio()
        
        return code == 0
    }
    
    func setVideoEncoderConfiguration(_ size: CGSize) -> Bool {
        
        guard agora != nil else { return false }
        
        let agoraVideoEncoderConfiguration = AgoraVideoEncoderConfiguration(size: size, frameRate: .fps15, bitrate: 200, orientationMode: .fixedLandscape)
        let code = agora?.setVideoEncoderConfiguration(agoraVideoEncoderConfiguration)
        
        return code == 0
    }
    
    func setChannelProfile(_ profile: MediaChannelProfile) -> Bool {
        guard agora != nil else {
            return false
        }
        
        let agoraProfile = AgoraChannelProfile(rawValue: profile.rawValue) ?? AgoraChannelProfile(rawValue: 0)
        let code = agora?.setChannelProfile(agoraProfile!)
        
        return code == 0
    }
    
    func createDataStream(_ streamId: UnsafeMutablePointer<Int>, reliable: Bool, ordered: Bool) -> Bool {
        guard agora != nil else {
            return false
        }
        let code = agora?.createDataStream(streamId, reliable: reliable, ordered: ordered)
        
        return code == 0
    }
    
    func sendStreamMessage(_ streamId: Int, data: Data) -> Bool {
        guard agora != nil else {
            return false
        }
        let code = agora?.sendStreamMessage(streamId, data: data)
        
        return code == 0
    }
    
    func setLogFile(filePath: String) -> Bool {
        guard agora != nil else {
            return false
        }
        let code = agora?.setLogFile(filePath)
        
        return code == 0
    }
    
    class func getAgoraRtcEngineKitSDKVersion() -> String {
        return AgoraRtcEngineKit.getSdkVersion()
    }
    
    private func generateCanvas(_ view: UIView?, _ renderModel: AgoraVideoRenderMode = .fit, _ uid: String) -> AgoraRtcVideoCanvas {
        let canvas = AgoraRtcVideoCanvas()
        canvas.view = view
        canvas.renderMode = renderModel
        canvas.uid = UInt(uid) ?? 0
        return canvas
    }
    
}
