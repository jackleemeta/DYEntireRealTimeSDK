//
//  ViewController.swift
//  DYRealTimeSDKDemo
//
//  Created by beck tian on 2019/12/15.
//  Copyright © 2019 beck tian. All rights reserved.
//

import UIKit

class DYRealTimeSDKDemoConfig {
    // 腾讯
    let sdk: DYRealTimeSDKType //sdk类型
    let roomId: String //房间id
    let uid: String //uid
    let sdkId: String //sdkId
    let sdkSign: String //sdk签名
    let sdkSignalId: String //IMSDK ID
    let sdkSignalSign: String //sdk签名
    let expired_time: Int //过期时间
    let mqttHost: String
    let mqttPassword: String
    
    let timAppId: String
    let timSign: String

    
    init(type: DYRealTimeSDKType) {
        if type == .agora {// 声网
             sdk = .agora
             sdkId = "1"
             sdkSignalId = "1"
             sdkSign = "1"
             sdkSignalSign = "1"
        } else {
             sdk = .trtc
             sdkId = "1"
             sdkSign = "1"
             sdkSignalId = "1"
             sdkSignalSign = "1"
        }
        roomId = "1"
        uid = "1"
        expired_time = 86400
        mqttHost = "1"
        mqttPassword = "1"
        timAppId = "1"
        timSign = "1"
    }
    
}

class ViewController: UIViewController {
    
    var realTimeSDK: DYRealTimeSDK?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
        initRtc()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 11) { [weak self] in
//            guard let `self` = self else { return }
//            self.switchRtc()
//        }
    }
    
    //初始化
    func initRtc() {
        
        let demoConfig = DYRealTimeSDKDemoConfig(type: .trtc)
     
        var setting = DYRealTimeSettingConfig()
        setting.messgeTypeOfJoinRoom = NSNumber(value: 103)
        setting.messgeTypeOfLeftRoom = NSNumber(value: 104)
        setting.timeOffSet = 0
        
        //mqtt配置
        var mqttConfig = DYRealTimeSettingConfig.DYMQTTConfig()
        mqttConfig.host = demoConfig.mqttHost
        mqttConfig.password = demoConfig.mqttPassword
        mqttConfig.topics = ["topic1", "topic2", "topic3"]
        setting.mqttConfig = mqttConfig
        
        //TIM配置
        var timConfig = DYRealTimeSettingConfig.DYTIMConfig()
        timConfig.appId = demoConfig.timAppId
        timConfig.sign = demoConfig.timSign
        setting.timConfig = timConfig
        
        var user = DYRealTimeSDKUserConfig()
        user.roomId = demoConfig.roomId
        user.account = String(demoConfig.uid)
        
        var auth = DYRealTimeSDKAuthenticationConfig()
        auth.sdkId = demoConfig.sdkId
        auth.sdkSign = demoConfig.sdkSign
        auth.sdkSignalSign = demoConfig.sdkSignalSign
        
        realTimeSDK = DYRealTimeSDK(sdk: demoConfig.sdk,
                                    authenticationConfig: auth,
                                    settingConfig: setting,
                                    userConfig: user,
                                    delegate: self)
        
        realTimeSDK?.engine()
    }
    
    
    /// 切换Rtc
    func switchRtc() {
        
        let demoConfig = DYRealTimeSDKDemoConfig(type: realTimeSDK!.sdk! == .agora ? .trtc : .agora)
        
        var auth = DYRealTimeSDKAuthenticationConfig()
        auth.sdkId = demoConfig.sdkId
        auth.sdkSign = demoConfig.sdkSign
        auth.sdkSignalSign = demoConfig.sdkSignalSign
        auth.expired_time = demoConfig.expired_time
        
        realTimeSDK?.switch(to: demoConfig.sdk,
                            with: auth) { isSuccess in
                                if !isSuccess { return }
                                print("switched rtc")
        }
    }
    
}

extension ViewController: DYRealTimeSDKProtocol {
    func parseMSGID_UID_ROOMIDFor(message: String) -> DYMessageKeys {
        return (nil, nil, nil)
    }
    
    func parseType(forMessage message: String) -> NSObject? {
        return nil
    }
    
    func joinRoom(isSuccess: Bool, uid: String) {
        
    }
    
    func videoSizeParsed(uid: String) {
        
    }
    
    func viewForLocalVideo() -> UIView {
        return UIView()
    }
    
    func viewForRemoteVideo(uid: String) -> UIView {
        return UIView()
    }
    
    func userDidCloseVideo(uid: String, isMuted: Bool) {
        
    }
    
    func sentMessage(isSuccess: Bool, uid: String, msgId: String, msg: String) {
        
    }
    
    func receivedMessage(uid: String, msgId: String, msg: String) {
        
    }
    
    func leftRoom(uid: String, reason: DYRealTimeSDKLeaveReason) {
        
    }
    
    func onNetworkQuality(uid: String, quality: DYRealTimeSDKNetworkQuality) {
        
    }
    
    func onConnectStatus(status: DYRealTimeSDKConnectStatus, message: String) {
        
    }
    
    func audioRestarted() {
        
    }
    
    func onError(code: String, message: String) {
        
    }
    
}
